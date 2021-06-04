video_mem: equ 0xb8000

global long_mode_start

section .text
bits 64
long_mode_start:
	; load null into all data segment registers
	mov ax, 0
	mov ss, ax
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	;print 'ok'
	mov dword [video_mem], 0x2f4b2f4f ; 'OK'
	hlt

