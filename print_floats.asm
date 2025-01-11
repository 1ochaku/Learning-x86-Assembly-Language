; doesn't consider negative numbers

section .data
    dot db "."
    newline db 10
    
section .bss
    buffer resb 32            ; Buffer for storing the string representation
    
section .text
    global _start

_start:
    ; First clean the buffer
    mov ecx, 32             ; Buffer size
    mov edi, buffer         ; Buffer address
    xor eax, eax            ; Zero to fill
    rep stosb               ; Fill buffer with zeros

    ; Example values (can be changed)
    mov eax, 13              ; Numerator (a)
    mov ebx, 2               ; Denominator (b)
    
    ; Save original values
    push eax                ; Save numerator
    push ebx                ; Save denominator
    
    ; First get integer part
    xor edx, edx            ; Clear EDX for division
    div ebx                 ; EAX = quotient (integer part), EDX = remainder
    
    ; Save integer part and remainder
    push eax                ; Save integer part
    push edx                ; Save remainder
    
    ; Print integer part
    mov esi, buffer
    call int_to_string
    mov ecx, buffer
    mov edx, eax            ; Length returned in EAX
    mov eax, 4              ; sys_write
    mov ebx, 1              ; stdout
    int 0x80
    
    ; Clean buffer after integer part
    push ecx                ; Save buffer address
    mov ecx, 32
    mov edi, buffer
    xor eax, eax
    rep stosb
    pop ecx                 ; Restore buffer address
    
    ; Print decimal point
    mov eax, 4
    mov ebx, 1
    mov ecx, dot
    mov edx, 1
    int 0x80
    
    ; Calculate decimal part
    pop eax                 ; Get remainder
    mov ecx, 100000        ; Use higher precision (5 decimal places)
    mul ecx                ; EDX:EAX = remainder * 100000
    pop ecx                ; Remove integer part
    pop ebx                ; Get original denominator
    div ebx                ; Divide by denominator
    
    ; Now EAX contains decimal part with 5 digits precision
    mov esi, buffer
    
    ; Handle leading zeros
    cmp eax, 10000
    jge .print_decimal
    
    ; Print leading zeros as needed
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
    mov edx, eax           ; Length returned in EAX
    mov eax, 4             ; sys_write
    mov ebx, 1             ; stdout
    int 0x80
    
    ; Clean buffer after decimal part
    mov ecx, 32
    mov edi, buffer
    xor eax, eax
    rep stosb
    
    ; Print newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    
    pop eax                ; Clean up stack (original numerator)
    
    ; Exit program
    mov eax, 1             ; sys_exit
    xor ebx, ebx           ; Return 0
    int 0x80

; Convert integer in EAX to string at ESI
; Returns length in EAX
int_to_string:
    push ebx
    push ecx
    push edx
    push esi
    
    mov ebx, 10            ; Divisor
    mov ecx, 0            ; Character count
    
    ; Handle zero specially
    test eax, eax
    jnz .not_zero
    mov byte [esi], '0'
    inc esi
    inc ecx
    jmp .done
    
.not_zero:
    ; First convert to string (reversed)
.convert_loop:
    xor edx, edx          ; Clear EDX for division
    div ebx               ; Divide EAX by 10
    add dl, '0'          ; Convert remainder to ASCII
    mov [esi + ecx], dl   ; Store digit
    inc ecx              ; Increment counter
    test eax, eax        ; Check if EAX is zero
    jnz .convert_loop
    
    ; Now reverse the string
    mov edx, ecx         ; Save length
    dec ecx              ; Last character index
    xor eax, eax         ; Start index
    
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
    mov eax, edx         ; Return length
    
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret