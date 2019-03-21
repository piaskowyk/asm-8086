data1 segment
	$filename db 'asd.bmp', 0
	$filehandle dw ?
	$header db 54 dup (0)
	$palette db 256*4 dup (0)
	$scrLine db 320 dup (0)
	$errorMsg db 'Error', 13, 10, '$'
data1 ends

code1 segment

run_program:
size_w equ 320
size_h equ 200
color_red equ 1

call turn_on_vga_mode

mov dx, -1
loop1:
	mov cx, 0  ; column
	inc dx     ; row
	mov al, color_red
	loop2: call put_pixel
		inc cx
		cmp cx, size_w
		jne loop2
	cmp dx, size_h
	jne loop1

call wait_for_keypress		
call turn_on_text_mode

;==================================================
;callable methods
;==================================================
turn_on_vga_mode: 	
	mov ah, 0
	mov al, 13h 
    int 10h
	ret
	
turn_on_text_mode: 	
	mov ah, 00
	mov al, 03
	int 10h
	ret

wait_for_keypress:
	mov ah,00
	int 16h
	ret

put_pixel:
	mov ah, 0ch
    int 10h
	ret
	
open_file:
    mov ah, 3Dh
    xor al, al
    mov dx, offset $filename
    int 21h

    jc openerror
	call set_ds
    mov ds:[$filehandle], ax
    ret

    openerror:
    mov dx, offset $errorMsg
    mov ah, 9h
    int 21h
    ret

read_header:
    ; Read BMP file header, 54 bytes
	call set_ds
    mov ah, 3fh
    mov bx, ds:[$filehandle]
    mov cx, 54
    mov dx, offset $header
    int 21h
    ret
	
read_palette:
    ; Read BMP file color palette, 256 colors * 4 bytes (400h)
    mov ah, 3fh
    mov cx, 400h
    mov dx, offset $palette
    int 21h
    ret

copy_pal:
    ; Copy the colors palette to the video memory
    ; The number of the first color should be sent to port 3C8h
    ; The palette is sent to port 3C9h
    mov si, offset $palette
    mov cx, 256
    mov dx, 3C8h
    mov al, 0
    ; Copy starting color to port 3C8h
    out dx, al
    ; Copy palette itself to port 3C9h
    inc dx
    PalLoop:
    ; Note: Colors in a BMP file are saved as BGR values rather than RGB.
    mov al, [si+2] ; Get red value.
    shr al, 2 ; Max. is 255, but video palette maximal
    ; value is 63. Therefore dividing by 4.
    out dx, al ; Send it.
    mov al, [si+1] ; Get green value.
    shr al, 2
    out dx, al ; Send it.
    mov al, [si] ; Get blue value.
    shr al, 2
    out dx, al ; Send it.
    add si, 4 ; Point to next color.
    ; (There is a null chr. after every color.)
    loop PalLoop
    ret


copy_bitmap:
    ; BMP graphics are saved upside-down.
    ; Read the graphic line by line (200 lines in VGA format),
    ; displaying the lines from bottom to top.
    mov ax, 0A000h
    mov es, ax
    mov cx, 200
    PrintBMPLoop:
    push cx
    ; di = cx*320, point to the correct screen line
    mov di,cx
    shl cx,6
    shl di,8
    add di,cx
    ; Read one line
    mov ah, 3fh
    mov cx, 320
    mov dx, offset ScrLine
    int 21h

    ; Copy one line into video memory

    cld 

    ; Clear direction flag, for movsb

    mov cx,320
    mov si,offset ScrLine
    rep movsb 

    ; Copy line to the screen
    ;rep movsb is same as the following code:
    ;mov es:di, ds:si
    ;inc si
    ;inc di
    ;dec cx
    ;loop until cx=0

    pop cx
    loop PrintBMPLoop
    ret
	
set_ds:
	mov ax, seg $filename
	mov ds, ax  
	ret
	
code1 ends

stos1 segment stack
stos1 ends

end run_program
