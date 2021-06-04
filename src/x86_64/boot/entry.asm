video_mem equ 0xb8000

global start

section .text
bits 32
start:
	;print 'ok'

	mov dword [video_mem], 0x2f4b2f4f ; 'OK'

	hlt
