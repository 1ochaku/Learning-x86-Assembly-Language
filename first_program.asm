format PE64 NX GUI 6.0
entry start

section '.text' code readable executable
start:
    int3 ; for explicit breakpoint
    ret