[BITS 16]
[ORG 0x7C00]

mov ah, 0x0E   ; BIOS teletype function
mov al, 'F'
int 0x10
mov al, 's'
int 0x10
mov al, 'O'
int 0x10
mov al, 'S'
int 0x10

cli
hlt

times 510 - ($ - $$) db 0
dw 0xAA55

