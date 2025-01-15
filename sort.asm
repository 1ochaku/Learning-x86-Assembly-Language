section .data
	msg db "NOTE: Enter one element at a time",0x0a
	len equ $ - msg
	msg1 db "Enter the size of Array1:",0
	len1 equ $ - msg1
	num times 32 db 0		;buffer array for input
	newline db 10
	msg2 db "Enter the size of Array2:",0
	len2 equ $ - msg2
	msg3 db "Enter the element for Array1:",0
	len3 equ $ - msg3
	msg4 db "Enter the element for Array2:",0
	len4 equ $ - msg4
	buffer times 12 db 0     ;buffer to store digits (32 bits + sign + newline)
	msg5 db "Merged array:",0
	len5 equ $ - msg5
	space db 32

section .bss
	intermediate resd 1
	size1 resd 1
	size2 resd 1
	arr_ptr1 resd 1
	arr_ptr2 resd 1
	combined_arr resd 1
	combined_len resd 1
	is_negative resb 1

section .text
	global _start

_start:
	mov eax, 4			;note
	mov ebx, 1
	mov ecx, msg
	mov edx, len
	int 0x80

	mov eax, 4			;prompt for array1 size
	mov ebx, 1
	mov ecx, msg1
	mov edx, len1
	int 0x80

	call read_number
	mov eax, [intermediate]
	mov [size1],eax
	
	mov eax, 4			;prompt for array2 size
	mov ebx, 1
	mov ecx, msg2
	mov edx, len2
	int 0x80

	call read_number
	mov eax, [intermediate]
	mov [size2],eax
	
	;here we are kind of finding the current free memory address
	mov eax, 45			;allocating memory for first array
	xor ebx, ebx
	int 0x80
	
	push eax

	;storing that address in arr_ptr1
	;so we can access the elements of the array from this address
	;mov [arr_ptr1], eax		;saving address of first array
	
	;making up space for the remaining elements
	mov ebx, eax
	add ebx, 4			;aligning to 4 bytes
	add ebx, [size1]
	shl ebx, 2			;multiplying by 4 for bytes
	
	;getting the address again as after arr1, arr2 comes
	mov eax, 45			;sys_brk
	int 0x80

	cmp eax, -1			;if allocation successful
	je exit

	mov [arr_ptr1], eax		;note: array allocated only if successful
	
	;storing in are_ptr2
	;mov [arr_ptr2], eax
	
	;making up space for the remaining elements
	mov ebx, eax
	add ebx, 4
	add ebx, [size2]
	shl ebx, 2			;multiplying by 4 for bytes
	
	;getting the address again 
	;for combined arr
	mov eax, 45			;sys_brk
	int 0x80

	cmp eax, -1			;if allocation successful
	je exit

	mov [arr_ptr2], eax

	;mov [combined_arr], eax		;for combined array
	
	;building up the space for remaining elements
	mov ebx, eax
	add ebx, 4
	mov edx, [size1]
	add edx, [size2]
	mov [combined_len], edx 
	shl edx, 2		
	add ebx, edx
    	mov eax, 45         ; sys_brk
    	int 0x80
    
    	; Check if allocation failed
    	cmp eax, -1
    	je exit 	

	mov [combined_arr], eax

	xor ecx, ecx 			;setting counter=0

inp_loop1:
	cmp ecx, [size1]
	jge inp2_initialisation

	;printing the prompt
	;since ecx is the counter so we need to store it
	;before processing
	push ecx

	mov eax, 4			;prompt for array1 elements entering
	mov ebx, 1
	mov ecx, msg3
	mov edx, len3
	int 0x80

	call read_number
	pop ecx				;to get the index

	mov eax, [intermediate]
	mov ebx, [arr_ptr1]		;getting the array1 address
	mov [ebx+ecx*4], eax

	inc ecx
	jmp inp_loop1

inp2_initialisation:
	xor ecx, ecx			;setting the counter for arr2

inp_loop2:
	cmp ecx, [size2]
	jge sort_initialisation

	;printing the prompt
	;since ecx is the counter so we need to store it
	;before processing
	push ecx

	mov eax, 4			;prompt for array2 elements entering
	mov ebx, 1
	mov ecx, msg4
	mov edx, len4
	int 0x80

	call read_number
	pop ecx				;to get the index

	mov eax, [intermediate]
	mov ebx, [arr_ptr2]		;getting the array1 address
	mov [ebx+ecx*4], eax

	inc ecx
	jmp inp_loop2

sort_initialisation:
	xor ecx, ecx					;k=0
	xor edx, edx					;i=0
	xor ebx, ebx 					;j=0

sort:
	cmp ecx, [combined_len]
	jge print_result

	cmp edx, [size1]		
	jge add_arr2					;if array1 completed

	cmp ebx, [size2]
	jge add_arr1					;if array2 completed

	push ecx
	push edx
	push ebx
	
	mov esi, [arr_ptr1]
	mov eax, [esi + edx*4]
	;call print_num
	;jmp exit
	mov esi, [arr_ptr2]
	mov edi, [esi + ebx*4]

	cmp eax,edi	
	jle add_from_arr1				;a[i]<=a[j]

	pop ebx
	pop edx
	pop ecx
	
	mov esi, [arr_ptr2]
	mov eax, [esi + ebx*4]
	mov esi, [combined_arr]
	mov [esi+ecx*4], eax				;a[k]=a[j]

	inc ecx						;k++
	inc ebx						;j++

	jmp sort

add_from_arr1:
	pop ebx
	pop edx
	pop ecx
	
	mov esi, [arr_ptr1]
	mov eax, [esi+edx*4]
	;call print_num
	;jmp exit	
	
	mov esi, [combined_arr]
	mov [esi+ecx*4], eax				;a[k]=a[i]
	inc ecx						;k++
	inc edx						;i++
	jmp sort

add_arr2:
	cmp ecx, [combined_len]
	jge print_result
	
	mov esi, [arr_ptr2]
	mov eax, [esi + ebx*4]
	mov esi, [combined_arr]
	mov [esi+ecx*4], eax
	
	inc ecx
	inc ebx
	jmp add_arr2

add_arr1:
	cmp ecx, [combined_len]
	jge print_result
	
	mov esi, [arr_ptr1]
	mov eax, [esi+edx*4]
	mov esi, [combined_arr]
	mov [esi+ecx*4], eax
	
	inc ecx
	inc edx
	jmp add_arr1

print_result:
	mov ecx, [combined_len]
	cmp ecx, 0
	je exit

	mov eax, 4
	mov ebx, 1
	mov ecx, msg5
	mov edx, len5
	int 0x80

	xor ecx, ecx

print_combined:
	cmp ecx, [combined_len]
	jge print_newline
	
	push ecx
	mov esi, [combined_arr]
	mov eax, [esi + ecx*4]
	call print_num
	
	mov eax, 4
   	mov ebx, 1
   	mov ecx, space
   	mov edx, 1
  	int 0x80

	pop ecx
	inc ecx
	jmp print_combined

print_newline:
	mov eax, 4
   	mov ebx, 1
   	mov ecx, newline
   	mov edx, 1
  	int 0x80
	
exit:
	mov eax, 1
	mov ebx, 0
	int 0x80

read_number:
    ; read input
    mov eax, 3
    mov ebx, 0
    mov ecx, num        ; number stored as string
    mov edx, 32
    int 0x80

    ; converting the string_number into number
    push eax
    mov esi, num
    call atoi
    mov [intermediate], eax
    pop eax
    
    ret

atoi:
    xor eax, eax        ; clear result
    xor ebx, ebx        ; clear temp
    mov byte [is_negative], 0   ; reset negative flag
    
    ; check for minus sign
    movzx ebx, byte [esi]
    cmp ebx, '-'
    jne .process_digits
    
    mov byte [is_negative], 1   ; set negative flag
    inc esi             ; move past minus sign

.process_digits:
    movzx ebx, byte [esi]
    sub ebx, '0'        ; converting ascii to number
    jb .done            ; if not a digit
    cmp ebx, 9
    ja .done            ; if not a digit
    imul eax, 10        ; multiply current number by 10
    add eax, ebx        ; add new digit
    inc esi             ; move to next character
    jmp .process_digits

.done:
    ; check if number should be negative
    cmp byte [is_negative], 1
    jne .return
    neg eax             ; make number negative

.return:
    ret

print_num:
    ; save registers
    push ebx
    push ecx
    push edx
    
    mov ecx, buffer         ; register pointed to start of buffer
    add ecx, 11             ; moving to last byte
    
    mov byte [ecx], 0      ; store null terminate
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
