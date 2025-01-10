format PE64 NX GUI 6.0
entry start

section '.text' code readable executable ; program's instructions
start:
    int3
    sub rsp, 8*5 ; adjusting stack ptr and for the first four arguments
    xor rcx, rcx ; first integer/pointer argument set to 0: for ExitProcess(0)
    call [ExitProcess]

section '.idata' import readable writeable ; external lib and their functions stored
idt: ; import directory table starts here
     ; entry for KERNEL32.DLL
     dd rva kernel32_iat
     dd 0
     dd 0
     dd rva kernel32_name
     dd rva kernel32_iat
     ; NULL entry - end of IDT
     dd 5 dup(0)
name_table: ; hint/name table (contains name of the functions to be brought)
    _ExitProcess_Name dw 0
                      db "ExitProcess", 0, 0

kernel32_name db "KERNEL32.DLL", 0
kernel32_iat: ; import address table for KERNEL32.DLL
    ExitProcess dq rva _ExitProcess_Name
    dq 0 ; end of KERNEL32's IAT


; here why is it that i have to call both the iat and the dll inside the idt?
; line 14 and line 17
; it's the format 
; 2 times iat because one is iat and other is ilt