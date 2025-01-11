; req eax and ebx for dividend and dividend respectively
section .data
    dot db "."
    newline db 10
    minus db "-"
    
section .bss
    buffer resb 32            ; Buffer for storing the string representation
    
section .text
    global _start

_start:
    ; Clean buffer
    mov ecx, 32
    mov edi, buffer
    xor eax, eax
    rep stosb

    ; Example values (can be changed)
    mov eax, -9             ; Numerator (a)
    mov ebx, 12              ; Denominator (b)
    
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
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    
    ; Exit program
    mov eax, 1
    xor ebx, ebx
    int 0x80

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