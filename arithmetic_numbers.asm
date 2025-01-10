; this explores doing arithmetic operations on numbers
global _start
section .data
	msg db 'Successfully done!', 0x0a, 0 ; displays successful message
	len equ $ -msg			      ; length of the string
section .text
_start:
	; adds two numbers
	mov ecx, 3
	mov eax, 65	;ecx=10
	;cdq
	;mov edx,10	;edx=20
	div ecx		;eax*=edx
	cmp edx,1
	je display	;if ecx==30 display
	;else exit
	mov eax,1
	mov ebx,0
	int 0x80
display:
	; printing successful message
	mov eax,4
	mov ebx,1
	mov ecx,msg
	mov edx,len
	int 0x80
	;since the code will be looking for next instruction here
	;we need to write the exit statement
	;it doesn't jump back to _start
	mov eax,1
	mov ebx,0
	int 0x80
