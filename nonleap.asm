section .data
	msg db "Note: Year1 <= Year2 and Year1 >= 0 and Year2>=0"
	len equ $ - msg
	msg1 db "Enter the Year1 (format:yyyy):",0
	len1 equ $ - msg1
	msg2 db "Enter the Year2 (format:yyyy):",0
	len2 equ $ - msg2
	newline db 10
	buffer times 12 db 0     ;buffer to store digits (32 bits + sign + newline)
	num times 32 db 0	 ;buffer to store the input
	msg3 db "The non-leap years are:",0xa
	len3 equ $ - msg3

section .bss
	intermediate resd 1
	year1 resd 1
	year2 resd 1

section .text
	global _start
_start:
	mov eax, 4			;printing how to use
	mov ebx, 1
	mov ecx, msg
	mov edx, len
	int 0x80

	mov eax, 4			;printing newline
	mov ebx, 1
	mov ecx, newline
	mov edx, 1
	int 0x80

	mov eax, 4			;printing prompt
	mov ebx, 1
	mov ecx, msg1
	mov edx, len1
	int 0x80

	call read_number		;reading year1
	mov eax, [intermediate]
	mov [year1], eax
	
	;call print_num			;debugging

	mov eax, 4			;printing prompt
	mov ebx, 1
	mov ecx, msg2
	mov edx, len2
	int 0x80

	call read_number		;reading year2
	mov eax, [intermediate]
	mov [year2], eax

	;mov eax, [year1]		;debugging
	;call print_num
	
	;mov eax, [year2]		;debugging
	;call print_num

	;jmp exit			;degugging
	
	;call print_num			;debugging
	
	mov eax, 4			;printing prompt
	mov ebx, 1
	mov ecx, msg3
	mov edx, len3
	int 0x80

	mov ecx, [year1]		;ecx = year1

loop:	
	mov edx, [year2]		;edx = year2
	cmp ecx,edx
	jg exit

	mov eax, ecx			;eax = year1
	xor edx, edx
	mov ebx, 400		
	div ebx				;edx = year1%400
	inc ecx				
	cmp edx, 0			
	je loop				;if leap year loop
	
	;jmp exit
	
	dec ecx				
	mov eax, ecx
	xor edx, edx
	mov ebx, 100
	div ebx				;edx = year1%100
	inc ecx
	cmp edx, 0		
	jne .check_by_4			;if not leap year
	dec ecx
	mov eax, ecx
	call print_num			;as non leap year so print
	inc ecx
	jmp loop

.check_by_4:
	dec ecx
	mov eax, ecx
	xor edx, edx
	mov ebx, 4	
	div ebx				;checking if divisible by 4
	inc ecx
	cmp edx, 0
	je loop
	
	dec ecx
	mov eax, ecx
	call print_num
	inc ecx
	jmp loop

read_number:
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
	mov [intermediate], eax
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
    ; save registers
    push ebx
    push ecx
    push edx
    
    mov ecx, buffer         ; register pointed to start of buffer
    add ecx, 11             ; moving to last byte
    
    mov byte [ecx], 10      ; store new line at end
    dec ecx                 ; moving one position back
    
    mov ebx, 10             ; divisor for extracting digits
    
    ; handling 0
    test eax, eax
    jnz .extract_digits
    mov byte [ecx], '0'     ; if zero
    dec ecx
    jmp .print

.extract_digits:
    ; checking if negative
    push eax                ; save original number
    test eax, eax
    jns .convert_digits     ; jump if number is positive
    
    neg eax                 ; make eax positive
    
.convert_digits:
    mov edx, 0             ; clear the upper bits of dividend
    div ebx                ; divide by 10
    add dl, '0'            ; converting remainder to ASCII
    mov [ecx], dl          ; store digit
    dec ecx    
    
    test eax, eax          ; is quotient zero
    jnz .convert_digits    ; if not, continue extracting digits
    
    ; Check if we need to add minus sign
    pop eax                ; restore original number
    test eax, eax
    jns .print             ; if positive, skip minus sign
    mov byte [ecx], '-'    ; add minus sign
    dec ecx

.print:
    inc ecx                ; move back to first character
    
    ; calculate length
    mov edx, buffer
    add edx, 12            ; point to end of buffer
    sub edx, ecx           ; calculate length
    
    ; print the number
    mov eax, 4             ; sys_write
    mov ebx, 1             ; stdout
    int 0x80
    
    ; restore registers
    pop edx
    pop ecx
    pop ebx
    ret

exit:
	mov eax, 1
	mov ebx, 0
	int 0x80