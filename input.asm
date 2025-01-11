section .data
	; null terminated string serves as a prompt for userso
	num_prompt db "Enter a number: ",0
	num times 32 db 0
	newline db 10
	buffer times 12 db 0
	test: db 10

section .bss
	num_read resd 1		;store converted number

section .text
	global _start
_start:
	movzx eax, byte [test]
	call print_num

	call read_number
	
	;exiting the program
	mov eax, 1
	xor ebx, ebx
	int 0x80

read_number:
	;print prompt
	mov eax, 4
	mov ebx, 1
	mov ecx, num_prompt
	mov edx, 15
	int 0x80
	
	;read input
	mov eax, 3
	mov ebx, 0
	mov ecx, num		;number stored as string
	mov edx, 32
	int 0x80

	;converting the string_number into number
	push eax
	mov esi, num
	call atoi
	mov [num_read], eax
	pop eax
	
	;doing arithmatic
	push eax
	mov eax, [num_read]
	mov ecx, eax
	mul ecx
	call print_num
	pop eax

	ret

atoi:
	xor eax, eax
	xor ebx, ebx
.next_digit:
	movzx ebx, byte [esi]
	sub ebx, '0'		;converting ascii to number
	jb .done		;if not a digit
	cmp ebx, 9
	ja .done		;if not a digit
	imul eax, 10		;multiply current number by 10
	add eax, ebx		;add new digit
	inc esi			;move to next character
	jmp .next_digit
.done:
	ret
	
print_num:
        ;registers to be used later
        push ebx
        push ecx
        push edx

        mov ecx, buffer         ;register pointed to start of buffer
        add ecx, 11             ;moving to last byte

        mov byte [ecx], 10      ;store new line at end
        dec ecx                 ;moving one position back

        mov ebx, 10             ;divisor for extracting digits

        ;handling 0
        test eax, eax
        jnz .extract_digits
        mov byte [ecx], '0'     ;if zero
        dec ecx
        jmp .print

.extract_digits:
        ;checking if negative
        test eax, eax
        jns .convert_digits     ;jump if number is positive

        neg eax                 ;make eax = +ve
        push eax
        mov byte [ecx],'-'      ;add minus sign
        dec ecx
        pop eax

.convert_digits:
        mov edx, 0              ;clear the upper bits of dividend
        div ebx                 ;divide by 10

        add dl, '0'             ;converting remainder to ASCII
        mov [ecx], dl           ;store digit
        dec ecx

        test eax,eax            ;is quotient zero
        jnz .convert_digits     ;if not, continue extracting the digits

.print:
        inc ecx                 ;move back to first digit

        ;calculate string length
        mov edx, buffer
        add edx, 12             ;point to end of buffer
        sub edx,ecx             ;calculate length

        ;print the number
        mov eax, 4
        mov ebx, 1
        int 0x80

        pop edx
        pop ecx
        pop ebx
        ret
