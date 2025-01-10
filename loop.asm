section .data
    newline db 10    ; ASCII code for newline
    buffer times 12 db 0  ; Buffer to store digits (enough for 32-bit number + sign + newline)

section .text
global _start
_start:
	mov ecx, 1     ; Number we want to print (change this to print different numbers)
    	;call print_num   ; Call our number printing routine
loop:	
	mov eax, ecx
	call print_num
	inc ecx
	cmp ecx, 11
	jl loop

;EXIT PROGRAM
exit:
	mov eax, 1
	mov ebx, 0
	int 0x80


;FOR PRINTING NUMBERS
;require the number to be in eax: mov eax, number
;then call print_num function
;also note it works with positive number only
;handling negative numbers not done yet
print_num:
    push ebx         ; Save registers we'll use
    push ecx
    push edx

    mov ecx, buffer  ; Point ecx to end of buffer
    add ecx, 11      ; Move to last byte of buffer

    mov byte [ecx], 10 ; Store newline at end
   ;mov byte [ecx], 32 ; Storing space to print in one line
    dec ecx          ; Move back one position

    mov ebx, 10      ; Divisor for extracting digits

    ; Handle 0 as special case
    test eax, eax
    jnz .extract_digits
    mov byte [ecx], '0'
    dec ecx
    jmp .print

.extract_digits:
    ; Check if number is negative
    test eax, eax
    jns .convert_digits   ; Jump if number is positive

    neg eax              ; Make number positive
    push eax             ; Save number
    mov byte [ecx], '-'  ; Add minus sign
    dec ecx
    pop eax             ; Restore number

.convert_digits:
    mov edx, 0          ; Clear dividend high bits
    div ebx             ; Divide by 10

    add dl, '0'         ; Convert remainder to ASCII
    mov [ecx], dl       ; Store digit
    dec ecx            ; Move buffer pointer

    test eax, eax      ; Is quotient zero?
    jnz .convert_digits ; If not, continue extracting digits
.print:
    inc ecx            ; Move back to first digit

    ; Calculate string length
    mov edx, buffer
    add edx, 12        ; Point to end of buffer
    sub edx, ecx       ; Calculate length

    ; Print the number
    mov eax, 4         ; syscall number for write
    mov ebx, 1         ; file descriptor 1 is stdout
    int 0x80           ; make syscall

    pop edx            ; Restore registers
    pop ecx
    pop ebx
    ret
