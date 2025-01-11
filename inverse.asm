;!!!!!!!!!! NOTE !!!!!!!!!!!!
;it takes only 2*2 matrix
;values can be updated in line 12 and 13

section .data
	msg1 db "Original 2*2 Matrix: ", 0x0a
	len1 equ $ - msg1
	msg2 db "Determinant value: ", 0
	len2 equ $ - msg2
	msg3 db "Inverse Matrix: ", 0x0a
	len3 equ $ - msg3
	matrix dd -1, -1
	       dd -1, -1
	newline db 0x0a
	space db 0x20
	dot db "."
	minus db "-"
section .bss
	det resd 1			;storing the determinant
	buffer resb 32            ; Buffer for storing the string representation

section .text
	global _start
_start:	
	mov eax, 4			;printing the original matrix
	mov ebx, 1
	mov ecx, msg1
	mov edx, len1
	int 0x80

	mov eax, [matrix]		;printing matrix[0][0]
	call print_num	

	mov eax, 4			;printing space
	mov ebx, 1
	mov ecx, space
	mov edx, 1
	int 0x80
	
	mov eax, [matrix+4]		;printing matrix[0][1]
	call print_num	
	
	mov eax, 4			;printing newline
	mov ebx, 1
	mov ecx, newline
	mov edx, 1
	int 0x80	

	mov eax, [matrix+8]		;printing matrix[1][0]
	call print_num	

	mov eax, 4			;printing space
	mov ebx, 1
	mov ecx, space
	mov edx, 1
	int 0x80

	mov eax, [matrix+12]		;printing matrix[1][1]
	call print_num

	mov eax, 4			;printing newline
	mov ebx, 1
	mov ecx, newline
	mov edx, 1
	int 0x80

	mov eax, 4			;printing the message declaring determinant value
	mov ebx, 1
	mov ecx, msg2
	mov edx, len2
	int 0x80

	;calculating determinant
	mov eax, [matrix]		;eax = matrix[0][0]
	mov ecx, [matrix+12]		;ecx = matrix[1][1]
	imul ecx			;eax = matrix[0][0] * matrix[1][1]
	mov ecx, eax			;ecx = eax

	mov eax, [matrix+4]		;eax = matrix[0][1]
	mov edx, [matrix+8]		;edx = matrix[1][0]
	imul edx			;eax = matrix[0][1] * matrix[1][0]
	
	sub ecx, eax			;ecx = ecx - eax (ad-bc)

	mov [det],ecx			;storing the determinant
	mov eax, ecx			;moving ecx into eax for printing
	call print_num

	cmp dword [det], 0
	je exit

	mov eax, 4			;printing newline
	mov ebx, 1
	mov ecx, newline
	mov edx, 1
	int 0x80

	mov eax, 4			;printing the inverse matrix
	mov ebx, 1
	mov ecx, msg3
	mov edx, len3
	int 0x80
	
	mov eax,[matrix+12]		;printing the [0][0] value
	mov ebx,[det]
	call print_float

	mov eax, 4			;printing space
	mov ebx, 1
	mov ecx, space
	mov edx, 1
	int 0x80
	
	mov eax,[matrix+4]		;printing the [0][1] value
	neg eax
	mov ebx,[det]
	call print_float
	
	mov eax, 4			;printing newline
	mov ebx, 1
	mov ecx, newline
	mov edx, 1
	int 0x80
	
	mov eax,[matrix+8]		;printing the [1][0] value
	neg eax
	mov ebx,[det]
	call print_float

	mov eax, 4			;printing space
	mov ebx, 1
	mov ecx, space
	mov edx, 1
	int 0x80
	
	mov eax,[matrix]		;printing the [1][1] value
	mov ebx,[det]
	call print_float

	mov eax, 4			;printing newline
	mov ebx, 1
	mov ecx, newline
	mov edx, 1
	int 0x80

	;exit
	mov eax, 1
	mov ebx, 0
	int 0x80

print_float:
    ; Save original values
    push eax                ; Save numerator
    push ebx                ; Save denominator

    ; Clean buffer
    mov ecx, 32
    mov edi, buffer
    xor eax, eax
    rep stosb

    pop ebx
    pop eax
    
    ; Save original values
    push eax
    push ebx
    
    ; Determine sign
    xor ecx, ecx            ; Will be 1 if result should be negative
    
    ; Check signs
    mov edx, eax
    xor edx, ebx            ; XOR of both numbers
    test edx, 80000000h     ; Check if signs are different
    jz .process_numbers      ; If same sign, result is positive
    inc ecx                 ; Different signs, result will be negative

.process_numbers:
    pop ebx                 ; Restore denominator
    pop eax                 ; Restore numerator
    
    ; Get absolute values
    test eax, eax
    jns .check_denom
    neg eax
.check_denom:
    test ebx, ebx
    jns .do_division
    neg ebx

.do_division:
    push ecx                ; Save sign flag
    
    ; Do integer division
    xor edx, edx
    div ebx                 ; EAX = quotient, EDX = remainder
    
    push edx                ; Save remainder
    push eax                ; Save quotient
    push ebx                ; Save denominator
    
    ; Print minus if needed
    pop ebx
    pop eax
    pop edx
    pop ecx
    push ebx                ; Keep denominator
    push eax                ; Keep quotient
    push edx                ; Keep remainder
    push ecx                ; Keep sign
    
    test ecx, ecx
    jz .print_integer
    
    ; Print minus
    mov eax, 4
    mov ebx, 1
    mov ecx, minus
    mov edx, 1
    int 0x80
    
.print_integer:
    ; Print integer part
    pop ecx                 ; Recover sign
    pop edx                 ; Recover remainder
    pop eax                 ; Recover quotient
    pop ebx                 ; Recover denominator
    push ebx                ; Save for later
    push edx                ; Save remainder
    push ecx                ; Save sign
    
    ; Convert and print integer part
    mov esi, buffer
    call int_to_string
    mov ecx, buffer
    mov edx, eax
    mov eax, 4
    mov ebx, 1
    int 0x80
    
    ; Print decimal point
    mov eax, 4
    mov ebx, 1
    mov ecx, dot
    mov edx, 1
    int 0x80
    
    ; Handle decimal part
    pop ecx                 ; Recover sign
    pop eax                 ; Get remainder
    pop ebx                 ; Get original denominator
    
    ; Calculate decimal places (remainder * 100000 / denominator)
    mov ecx, 100000
    mul ecx                 ; EDX:EAX = remainder * 100000
    div ebx                 ; EAX = decimal part
    
    ; Handle leading zeros for decimal part
    mov esi, buffer
    cmp eax, 10000
    jge .print_decimal
    
    push eax
    mov byte [buffer], '0'
    mov eax, 4
    mov ebx, 1
    mov ecx, buffer
    mov edx, 1
    int 0x80
    pop eax
    
    cmp eax, 1000
    jge .print_decimal
    
    push eax
    mov byte [buffer], '0'
    mov eax, 4
    mov ebx, 1
    mov ecx, buffer
    mov edx, 1
    int 0x80
    pop eax
    
    cmp eax, 100
    jge .print_decimal
    
    push eax
    mov byte [buffer], '0'
    mov eax, 4
    mov ebx, 1
    mov ecx, buffer
    mov edx, 1
    int 0x80
    pop eax
    
    cmp eax, 10
    jge .print_decimal
    
    push eax
    mov byte [buffer], '0'
    mov eax, 4
    mov ebx, 1
    mov ecx, buffer
    mov edx, 1
    int 0x80
    pop eax
    
.print_decimal:
    mov esi, buffer
    call int_to_string
    mov ecx, buffer
    mov edx, eax
    mov eax, 4
    mov ebx, 1
    int 0x80
    
    ; Print newline
    ;mov eax, 4
    ;mov ebx, 1
    ;mov ecx, newline
    ;mov edx, 1
    ;int 0x80
    
    ; Exit program
    ;mov eax, 1
    ;xor ebx, ebx
    ;int 0x80

; Convert integer in EAX to string at ESI
; Returns length in EAX
int_to_string:
    push ebx
    push ecx
    push edx
    push esi
    
    mov ebx, 10
    mov ecx, 0
    
    test eax, eax
    jnz .not_zero
    mov byte [esi], '0'
    inc esi
    inc ecx
    jmp .done
    
.not_zero:
.convert_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    mov [esi + ecx], dl
    inc ecx
    test eax, eax
    jnz .convert_loop
    
    mov edx, ecx
    dec ecx
    xor eax, eax
    
.reverse_loop:
    cmp eax, ecx
    jge .reverse_done
    mov bl, [esi + eax]
    mov bh, [esi + ecx]
    mov [esi + ecx], bl
    mov [esi + eax], bh
    inc eax
    dec ecx
    jmp .reverse_loop
    
.reverse_done:
.done:
    mov eax, edx
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

print_num:
    ; save registers
    push ebx
    push ecx
    push edx
    
    mov ecx, buffer         ; register pointed to start of buffer
    add ecx, 31             ; moving to last byte
    
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
    add edx, 31            ; point to end of buffer
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
	mov eax, 4			;printing newline
	mov ebx, 1
	mov ecx, newline
	mov edx, 1
	int 0x80

	mov eax, 1
	mov ebx, 0
	int 0x80