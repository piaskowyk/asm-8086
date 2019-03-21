mov al, 13h
mov ah, 0
int 10h ; przejście w tryb obrazu

;od pkt 0,0
offset = y*320 + 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mov al, 13h ; tryb graficzny
mov ah, 0 ; tryb vga
int 10h ; just to it !

;pkt
x dw ?
y dw ?
kolor db ?

zapal:
    mov ax, a000h
    mov es, ax ;segment vga
    mov bx, 320
    mov ax, word prt cs:[y]
    mul bx; dx:ax <- ax*bx * 320*y
    mov bx, word ptr cs:[x]
    add bx, ax ; bx = 320*y+x
    mov al, byte ptr cs:[k]
    mov 