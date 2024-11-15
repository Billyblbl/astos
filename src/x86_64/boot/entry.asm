VIDEO_MEM: equ 0xb8000
MULTIBOOT2_LOADED: equ 0x36d76289
SUPPORT_EXTENDED_PROCESSOR_INFO: equ 0x80000000
LONG_MODE_BIT: equ (1 << 29)
PHYSICAL_ADDRESS_EXTENSION_FLAG: equ (1 << 5)
LONG_MODE_MAGIC_VALUE: equ 0xC0000080
LONG_MODE_FLAG: equ (1 << 8)
PAGING_BIT: equ (1 << 31)

global start
global gdt64.description_structure
extern long_mode_start

section .text
bits 32
start:
	mov esp, stack_top

	; validity checks
	call check_multiboot
	call check_cpuid
	call check_long_mode

	call setup_page_tables
	call enable_paging

	lgdt [gdt64.description_structure] ; load descriptor table

	jmp gdt64.code_segment:long_mode_start ;load code segment into code selector & jump to 64bit entry

check_multiboot: ; eax should contain a magic number if we were loaded by multiboot accordingly
	cmp eax, MULTIBOOT2_LOADED
	jne .no_multiboot
	ret
.no_multiboot:
	mov al, "M"
	jmp error

check_cpuid: ;attempt to flip cpuid flag register to verify cpuid supported

	pushfd				; copy the flags in eax by pushing on stack
	pop eax				; and popping in eax
	mov ecx, eax		; keep a copy in ecx for later comparaison
	xor eax, 1 << 21	; flip the id bit
	push eax			; copy back into the flags register by pushing on stack
	popfd				; and popping back into the flags

	pushfd				; re-copy from flags to eax by pushing on stack
	pop eax				; and popping into eax

	push ecx			; restore the flags from the copy kept in ecx by pushing on stack
	popfd				; and popping in flags

	cmp eax, ecx		; compare original flags with flags after attempt to flip the bit
	je .no_cpuid		; failed to flip, no cpuid
	ret					; flip successful, check success
.no_cpuid:
	mov al, "C"
	jmp error

check_long_mode:

	; check if support extended processor info
	mov eax, SUPPORT_EXTENDED_PROCESSOR_INFO
	cpuid ; store a result value in eax
	cmp eax, SUPPORT_EXTENDED_PROCESSOR_INFO+1
	jb .no_long_mode

	; with extended processor info we can check if long mode is possible
	mov eax, SUPPORT_EXTENDED_PROCESSOR_INFO+1
	cpuid ; store result value in edx
	test edx, LONG_MODE_BIT ; test long mode bit in result
	jz .no_long_mode

	ret
.no_long_mode:
	mov al, "L"
	jmp error

setup_page_tables:
	mov eax, page_table_l3
	or eax, 0b11; enable present writable flags
	mov [page_table_l4], eax ; first entry of l4 points to l3

	mov eax, page_table_l2
	or eax, 0b11; enable present writable flags
	mov [page_table_l3], eax ; first entry of l3 points to l2


	; for (ecx = 0; ecx != 512; ecx++)
	mov ecx, 0; counter
	bytes_per_entry equ 8
.loop:

	mov eax, 0x200000; map 2MiB per page
	mul ecx ; calc next page address
	; address = 2MiB * ecx

	or eax, 0b10000011; enable present writable, huge page flags
	; entry = address | flags

	mov [page_table_l2 + ecx * bytes_per_entry], eax ; copy value in entry
	; page_table_l2[ecx] = entry

.iteration:
	inc ecx; increment counter
	cmp ecx, 512 ; checks if whole table is mapped
	jne .loop ; otherwise continue

	ret

enable_paging:

	; pass page table location to cpu
	mov eax, page_table_l4
	mov cr3, eax

	; enable physical address extension flag
	mov eax, cr4
	or eax, PHYSICAL_ADDRESS_EXTENSION_FLAG
	mov cr4, eax

	; enable long mode
	mov ecx, LONG_MODE_MAGIC_VALUE
	rdmsr		; load efer into eax
	or eax, LONG_MODE_FLAG ; enable long mode flag
	wrmsr		; write back to efer from eax

	;enable paging
	mov eax, cr0
	or eax, PAGING_BIT
	mov cr0, eax

	ret

error: ; Expect error character in al
	;print "ERR: X" with X = error character
	mov dword [VIDEO_MEM], 0x4f524f45
	mov dword [VIDEO_MEM+4], 0x4f3a4f52
	mov dword [VIDEO_MEM+8], 0x4f204f20
	mov byte [VIDEO_MEM+10], al
	hlt

section .bss

align 4096
page_table_l4:
	resb 4096
page_table_l3:
	resb 4096
page_table_l2:
	resb 4096

stack_bottom:
	resb 4096 * 4
stack_top:

section .rodata
; global descriptor table
; not much purpose because of the virtual tables (why?) but needed to pass in 64 bit mode
EXECUTABLE_FLAG: equ 1 << 43
CODE_AND_DATA_SEGMENT: equ 1 << 44
PRESENT_FLAG: equ 1 << 47
b64_FLAG: equ 1 << 53

gdt64:
	dq 0 ; zero entry
.code_segment: equ $ - gdt64
	dq EXECUTABLE_FLAG | CODE_AND_DATA_SEGMENT | PRESENT_FLAG | b64_FLAG ; code segment
.description_structure:
	dw $ - gdt64 - 1
	dq gdt64
