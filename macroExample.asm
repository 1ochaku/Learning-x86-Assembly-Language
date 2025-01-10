use64 ; defining a macroinstructions: custom instructions
; macro add5 target {
;     add target, 5
; }
; add5 rax
; NOTE: above code when compiled can't be run: as it's not in PE/ELF format

macro add5 target* {
    add target, 5
}
add5 rax

; below is an example for arbitrary argument macro
macro foo a, [b, c] {
common
    db a, b
    db a, c
}
foo 0, 1, 2, 3, 4
; this is interpreted as
; db 0 1 3
; db 0 2 4