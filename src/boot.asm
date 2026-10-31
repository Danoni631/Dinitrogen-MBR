[bits 16]
[ORG 0x7C00]

%define KERNEL 0x7E00

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    call read_sectors

    mov ax, 0x0013
    int 0x10

    jmp 0x0000:KERNEL

read_sectors:
    mov ah, 0x02
    mov al, 0x0005
    mov ch, 0x00
    mov cl, 0x02
    mov dh, 0x00
    xor bx, bx
    mov es, bx
    mov bx, KERNEL
    int 0x13
    ret

times 510 - ($ - $$) db 0x00
dw 0xAA55