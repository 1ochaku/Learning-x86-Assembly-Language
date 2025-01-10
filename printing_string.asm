; prints hello world
; we need to generally store the value that we want to print

global _start
section .data
	msg db 'Hello World!', 0x0a, 0 ;string with new line followed with null terminated

section .text
_start:
	; writes out the msg
	mov eax, 4	;sys_write
	mov ebx, 1	;std_out file descriptor
	mov ecx, msg	;bytes to write
	mov edx, 13	;number of characters
	int 0x80	;execute
	
	;exit out of the program
	mov eax, 1	;sys_exit
	mov ebx, 0	;exit status
	int 0x80	;execute

