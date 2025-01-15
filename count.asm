section .data
	msg db "NOTE: If you give only numbers it is not counted. A combination of alphabet and number is a valid word (ex, hello567).",0x0a
	len equ $ - msg
	msg1 db "Enter text: ",0
	len1 equ $ - msg1
	msg2 db "Word count:",0
	len2 equ $ - msg2
	msg3 db "Vowel count:",0
	len3 equ $ - msg3
	msg4 db "Consonants count:",0
	len4 equ $ - msg4
	buffer times 12 db 0
	input times 1024 db 0
	
section .bss
	prev_char resb 1
	words resd 1
	vowels resd 1
	consonants resd 1
	
section .text
	global _start
_start:
	mov dword [words], 0
    	mov dword [vowels], 0
    	mov dword [consonants], 0
    	mov byte [prev_char], ' '
	
	mov eax, 4				;prints the msg
	mov ebx, 1
	mov ecx, msg
	mov edx, len
	int 0x80

	mov eax, 4				;prints the msg
	mov ebx, 1
	mov ecx, msg1
	mov edx, len1
	int 0x80

	mov eax, 3				;taking the input
	mov ebx, 0
	mov ecx, input
	mov edx, 1024				;maximum size it can read
	int 0x80

	;mov eax, 4				;prints the input
	;mov ebx, 1
	;mov ecx, input
	;mov edx, 1024
	;int 0x80
	
	push eax				;no of bytes it read actually

processing:
	pop ecx					;retrieving the length
	mov esi, input
	dec ecx					;as newline will be there

count:
	cmp ecx, 0
	je print_result

	;since esi is a pointer to the string
	;so we want to access the first char and since
	;we have to store it in a 32 bit register, hence we store it in eax reg
	movzx eax, byte [esi]

	;comparing if less than 65 which is A in ASCII
	;also checking if less than 90 to ensure it bounds itself to A-Z
	cmp al, 'A'
	jb not_letter				;jump if below 65
	cmp al, 'Z'
	jbe is_upper				;jump if below or equal 90

	;otherwise check if lowercase
	cmp al, 'a'
	jb not_letter
	cmp al, 'z'
	ja not_letter				;if not letter
	jmp is_lower
	
is_upper:
	add al, 32				;converting to upper case

is_lower:
	;if the current char is lower case
	;check if the prev char (loaded in edx) was an alphabet
	;if so, this is not a new word
	;else a new word

	movzx edx, byte [prev_char]
	cmp dl, 'a'				;new word
	jb new_word
	cmp dl, 'z'				;new word
	ja new_word
	jmp vowel_or_consonants			;same word
	
;here if it was a new word the word count will be increased
;and since the current char need to accounted 
;implying we need to check if vowel or consonants
new_word:
	inc dword [words]

vowel_or_consonants:
	cmp al, 'a'
	je is_vowel
	cmp al, 'e'
	je is_vowel
	cmp al, 'i'
	je is_vowel
	cmp al, 'o'
	je is_vowel
	cmp al, 'u'
	je is_vowel
	
	inc dword [consonants]
	jmp store_char

is_vowel:
	inc dword [vowels]
	jmp store_char

not_letter:
	mov al, ' '

store_char:
	mov [prev_char], al
	inc esi
	dec ecx	
	jmp count

print_result:
	mov eax, 4				;printing word count
	mov ebx, 1
	mov ecx, msg2
	mov edx, len2
	int 0x80
	
	mov eax, [words]
	call print_num

	mov eax, 4				;printing vowel count
	mov ebx, 1
	mov ecx, msg3
	mov edx, len3
	int 0x80
	
	mov eax, [vowels]
	call print_num
	
	mov eax, 4				;printing consonants count
	mov ebx, 1
	mov ecx, msg4
	mov edx, len4
	int 0x80
	
	mov eax, [consonants]
	call print_num
	
	jmp exit

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