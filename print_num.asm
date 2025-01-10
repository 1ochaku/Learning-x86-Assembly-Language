section .data
	newline db 10 ;for new line
	buffer times 12 db 0 ;buffer to store digits (32 bits + sign + newline)

section .text
global _start
global print_num

;view of the buffer
;_|_|_|_|_|_|_|_|_|_|'\n'  ; each _ represents a byte

_start:
	mov eax, -112345		;number to print
	call print_num		;calling the function
	
	;exit
	mov eax, 1
	mov ebx, 0
	int 0x80

print_num:
	;registers to be used later
	push ebx
	push ecx
	push edx

	mov ecx, buffer		;register pointed to start of buffer
	add ecx, 11		;moving to last byte
	
	mov byte [ecx], 10	;store new line at end
	dec ecx			;moving one position back
	
	mov ebx, 10		;divisor for extracting digits
	
	;handling 0
	test eax, eax
	jnz .extract_digits
	mov byte [ecx], '0'	;if zero
	dec ecx
	jmp .print

.extract_digits:
	;checking if negative
	test eax, eax
	jns .convert_digits	;jump if number is positive
	
	neg eax			;make eax = +ve
	push eax
	mov byte [ecx],'-'	;add minus sign
	dec ecx
	pop eax

.convert_digits:
	mov edx, 0		;clear the upper bits of dividend
	div ebx			;divide by 10

	add dl, '0'		;converting remainder to ASCII
	mov [ecx], dl		;store digit
	dec ecx	
	
	test eax,eax		;is quotient zero
	jnz .convert_digits	;if not, continue extracting the digits
	
.print:
	inc ecx			;move back to first digit
	
	;calculate string length
	mov edx, buffer
	add edx, 12		;point to end of buffer
	sub edx,ecx		;calculate length
		
	;print the number
	mov eax, 4
	mov ebx, 1
	int 0x80

	pop edx
	pop ecx
	pop ebx
	ret
