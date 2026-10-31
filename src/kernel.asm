[bits 16]
[ORG 0x7E00]

kernel_entry:
    xor ah, ah   ; Set video mode function (0x00)
	mov al, 0x13 ; 320x200, 256 colors
	int 0x10

	rdtsc
	mov word [seed], ax ; Set seed to timestamp counter

	call text_loop

	mov ax, 0xA000    ; Video memory address
	mov es, ax        ; Set segment
	mov di, 320*200-1 ; Set index

	jmp noise

xorshift:
	mov ax, bx ; Load seed into AX
	shl ax, 7 ; Shift
	xor bx, ax ; XOR...
	mov ax, bx
	shr ax, 9
	xor bx, ax
	mov ax, bx
	shl ax, 8
	xor bx, ax
	mov ax, bx
	ret

text_loop:
	mov ah, 0x02 ; Set cursor position
	xor bh, bh   ; Page number
	xor dl, dl   ; Column
	int 0x10
	
	mov si, string
.char_loop:
	lodsb             ; Load character from SI
	or al, al         ; Testing for character
	jz .char_loop_end ; Check if character is zero termination

	push ax
	mov bx, word [seed]
	call xorshift
	xor word [seed], ax
	mov bl, al
	pop ax

	mov ah, 0x0E ; Print character
	int 0x10
	jmp .char_loop
.char_loop_end:
	inc dh
	jz .end
	jmp text_loop
.end:
	ret

noise:
    mov ax, 0xa000
    mov es, ax
    xor di, di
    mov cx, 64000
.bg:
    in al, 0x40
    and al, 0x1F
    stosb
    loop .bg

    inc byte [timer]
    jmp end_frame

end_frame:
    mov dx, 0x3DA
.wait:
    in al, dx
    test al, 8
    jz .wait
    
    jmp kernel_entry

delay:
    mov cx, 0x07FF
wait_loop:
    loop wait_loop

    mov ah, 01h
    int 16h
    jz kernel_entry

    ret

seed: dw 4096
string: db "Dinitrogen deleted your drive", 0x00
timer: db 0