multiboot2: equ 0xe85250d6  ; multiboot2 magic number
arch_tag: equ 0; protected mode i386
header_length: equ header_end - header_start

section .multiboot2_header
header_start:

	dd multiboot2
	dd arch_tag
	dd header_length

	;checksum
	dd 0x100000000  - (multiboot2 + arch_tag + header_length)

	;end tag
	dw 0
	dw 0
	dd 8

header_end:
