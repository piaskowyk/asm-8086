data segment
    $error_message  db "Nie poprawny format pliku $"   
    $currX          dw 0000h 
    $currY          dw 0000h
    $zoom_lvl       dw 0001h
    $handle         dw ?
        
    ;BITMAPFILEHEADER ma 14 bajtow
    $bfType	        dw	?
    $bfSize	        dd	?
    $bfReserved1	dw	?
    $bfReserved2    dw	?
    $bfOffBits	    dd	?

    ;BITMAPINFOHEADER ma 40 bajtow
    $biSize	            dd	?
    $biWidth	        dd	?
    $biHeight	        dd	?
    $biPlanes	        dw	?
    $biBitCount	        dw	?
    $biCompression	    dd	?
    $biSizeImage	    dd	?
    $biXPelsPerMeter	dd	?
    $biYPelsPerMeter	dd	?
    $biClrUsed	        dd	?
    $biClrImportant	    dd	?
    
    ;Paleta kolorow
    $palette dd	256 dup (?)
data ends  

image segment
    $pixelArray     db 0fffch dup (0) ; tablica pikseli
image ends

stack segment stack
            dw   128  dup(0)
    $peak   db   ?
stack ends

code segment

start:             
    call stack_init
    call set_segment_adr
    call load_input_arg                                 
    call graphic_mode
    call open_file
    call read_file

    main:
    call load_palette

    mov cx, 200
    mov di, cx
    push dx
    draw_row_loop:;rysuj linia po lini
        call load_row;załąduj linię z pliku
        push cx
        mov cx, di
        mov dx, seg $zoom_lvl
        mov ds, dx
        mov dx, word ptr ds:$zoom_lvl;pobierz obecną wartość zoomu

        zoom_lvl_loop:;rysuj z uwzględnieniem zoom, ryzuj jako kwadraty, powielaj piksele w razie potrzeby
            call draw_row
            dec di
            dec cx
            dec dx
            cmp dx, 0
        jg zoom_lvl_loop

        pop cx
        dec cx
        cmp di, 0
    jg draw_row_loop
    
    pop dx
   
    mov ah, 00h;oczekuj na klawisz
    int 16h
   
    cmp ah, 050h ;strzalka w dol
    je move_down
    cmp ah, 048h ;strzalka do góry
    je move_up
    cmp ah, 04Bh ;strzalka w lewo
    je move_left
    cmp ah, 04Dh ;strzalka w prawo
    je move_right
    cmp ah, 04Eh ;plus
    je zoom_in 
    cmp ah, 04Ah ;strzalka w dol
    je zoom_out
    
    ;jeśli urzyto innego klawisza opuść program
    cmp ah, 01h
    je end_program
    jmp main

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;callable methods
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

stack_init: ;inicjowanie stos, ustawianie odpowiednich rejestrów stosu
    mov sp, offset $peak
    mov ax, seg $peak
    mov ss, ax 
ret

set_segment_adr: ; set segment registers:
    mov ax, data    
    mov es, ax
ret

load_input_arg: ; obsługa wrgumentów wejściowych do programu
    mov bl, byte ptr ds:[80h]; zapisz dlugosc wczytanego argumentu
    mov byte ptr [bx+81h], 0; znak końca '$'
ret

graphic_mode: ;włącz tryb graficzny
    mov al, 13h
	mov ah, 0
	int 10h
ret

open_file: ;wczytaj argumenty wejściowe programu  
    mov al, 0   ;tryb odzytu
	mov dx, 82h ;otworz plik o nawzie poerwszego argumentu
	mov ah, 3dh
	int 21h 
    jc throw_exception  ;jeśli nie udało się otworzyć pliku
ret

read_file:;czytaj zawartość pliku
    mov dx, seg $handle
    mov ds, dx
    mov word ptr ds:$handle, ax ;uchwyt na plik
    mov bx, word ptr ds:$handle; wpisz $handle do pliku
    mov cx, 1078; ilosc bajtow do wczytania pliku od poczatku do palety kolorow                        
    mov dx, seg $bfType
    mov ds, dx
    mov dx, offset $bfType  
    mov ah, 3fh ; czytaj z pliku
    int 21h
ret

load_palette:
    cmp ds:$biBitCount, 8 ;jeśli tryb pliku jest 8-bitowy
    je load_palette8

    jmp throw_exception

    load_palette8:
        push ax
        push bx
        push cx 
        push dx
        
        ;ustawianie portów aby możliwe było zapisywanie danych do pamięci graficznej
        mov dx, 3C8h
        mov al, 0
        out dx, al
        
        mov dx, seg $palette
        mov ds, dx
        mov cx, 256
        mov di, offset ds:$palette

        loadloop:
            push cx
            mov cl, 02h

            ;RED
            mov al, byte ptr ds:[di+2]
            shr al, cl
            mov dx, 3C9h
            out dx, al

            ;GREEN
            mov al, byte ptr ds:[di+1]
            shr al, cl
            mov dx, 3C9h
            out dx, al
            
            ;BLUE
            mov al, byte ptr ds:[di]
            shr al, cl
            mov dx, 3C9h
            out dx, al

            pop cx
            add di, 4
        loop loadloop

    pop  dx
    pop  cx 
    pop  bx
    pop  ax
ret

close_file:
    mov dx, seg $handle
    mov ds, dx
    mov bx, word ptr ds:$handle; wpisz $handle do pliku
    mov ah, 3eh
    int 21h ;zamknij plik
ret

;ustawia odpowiednie na adresy skąd mają być wczytywane dane do pamięci obrazu
load_row: ; wystietl 1 linie obrazka nr linii podany w cx
    push cx ;zachowaj licznik pętli
    dec cx
    mov dx, seg $currX 
    mov ds, dx

    push cx
    xor cx, cx ; wyzerowanie rejestru cx
    mov dx, word ptr ds:$bfOffBits ;pobranie wartości offsetu
    mov bx, word ptr ds:$handle
    mov al, 0 ;ustaw wskaźnik na początek pliku
    mov ah, 42h
    int 21h ;przesun za naglowek
    
    pop cx
    mov ax, cx ; w ax znajduje się numer linii do wczytania
    push cx

    mov cx, word ptr ds:$biHeight ;wczytaj wysokość obrazka
    sub cx, ax ; uwzględnij wysokość aktualnej lini do wyświetlenia
    mov ax, word ptr ds:$currY ; pobierz aktualną wysokość
    sub cx, ax ; cx = height - cx - $currY

    cmp cx, 0
    jl empty_line
    
    cmp cx, word ptr ds:$biHeight
    jge empty_line

    jmp continue_read 

    empty_line:
        push di
        mov di, 0
        mov al, 00h

    black_lines_loop: ;rysuj czarne linie poza obrazkiem
        mov dx, seg $pixelArray
        mov ds, dx
        mov byte ptr ds:$pixelArray[di], al 
        inc di
        mov dx, seg $biWidth
        mov ds, dx
        cmp di, word ptr ds:$biWidth
    jl black_lines_loop

    pop di
    pop ax
    pop cx 
    ret

    continue_read:
        mov ax, cx
        mov cx, word ptr ds:$biWidth

        ;aby ustawić wartości dla rejestrów
        push ax
        push bx
        push dx
        
        mov ax, cx
        mov bx, word ptr ds:$biBitCount ;liczba bitow na piksel
        mul bx 
        
        add ax, 31
        jnc not_overflow ;skok, jeśli nie ma przeniesienia
        add dx, 1
        
    not_overflow:
        mov bx, 32
        div bx

        mov bx, 4
        mul bx
        mov cx, ax

        pop dx
        pop bx
        pop ax

        mul cx ; wynik w dx:ax
        mov cx, dx
        mov dx, ax ; przeniesienie do cx:dx

        mov bx, word ptr ds:$handle
        mov al, 1 ;SEEK FROM CURRENT
        mov ah, 42h
        int 21h ; przejdz na poczatek szukanej linii

        mov cx, word ptr ds:$biWidth
        mov dx, seg $pixelArray
        mov ds, dx
        mov dx, offset $pixelArray  
        mov ah, 3fh ; czytaj z pliku linie
        int 21h

        pop ax;przywróc argumenty do rejestrów
        pop cx 
ret

draw_row:
    push ax
    push bx
    push cx 
    push dx

    dec cx ; poprawka na to ze w petli cx jesrt od 320 do 1 a potzreba od 319 do 0

    mov dx, seg $currX
    mov ds, dx
    
    ; pop ax ; nr linii ktora chcemy wyswietlic
    mov ax, cx
    mov bx, 320
    mul bx
    mov cx, 320
    mov dx, cx
    push di
    line_loop:
        mov di, seg $zoom_lvl
        mov ds, di
        mov di, word ptr ds:$zoom_lvl

        pix_zoom_lvl_loop:
            call set_pixel_line
            dec dx
            dec di
            cmp di, 0
            jg pix_zoom_lvl_loop
    loop line_loop

    pop di
    pop dx
    pop cx
    pop bx
    pop ax
ret

set_pixel_line: ; wyswietla piksel na aktualnej linii (w ax = 320*y, w cx x) x w pamieci obrazu w dx
    push ax
    push dx
    push cx

    dec cx ; poprawka na to ze w petli cx jesrt od 320 do 1 a potzreba od 319 do 0

    add ax, cx
    mov cx, ax
    mov dx, 0A000h ; wskaz na pamiec vga
    mov es, dx

    mov dx, seg $pixelArray ;wskaz na
    mov ds, dx

    xor dx, dx
    mov ax, cx
    mov bx, 320
    div bx ; w ax y w dx x
    
    mov bx, dx
    mov dx, seg $currX ;wskaz na
    mov ds, dx
    mov dx, word ptr ds:$currX
    add bx, dx
    
    mov dx, seg $pixelArray ;wskaz na
    mov ds, dx

    mov al, byte ptr ds:[bx] 
    mov bx, cx
    pop cx
    sub bx, cx
    pop dx
    add bx, dx

    mov byte ptr es:[bx], al

    pop ax
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;methods
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

zoom_in:
    mov dx, seg $zoom_lvl
    mov ds, dx
    mov dx, word ptr ds:$zoom_lvl
    cmp dx, 4
    je main
    shl dx, 1
    mov word ptr ds:$zoom_lvl, dx
    jmp main
;------------------------------

zoom_out:
    mov dx, seg $zoom_lvl
    mov ds, dx
    mov dx, word ptr ds:$zoom_lvl
    cmp dx, 1
    je main
    shr dx, 1
    mov word ptr ds:$zoom_lvl, dx
    jmp main
;------------------------------

move_down:
    mov dx, seg $currY
    mov ds, dx 
    mov dx, word ptr ds:$currY
    add dx, 2
    mov word ptr ds:$currY, dx
    jmp main
;------------------------------

move_up:
    mov dx, seg $currY
    mov ds, dx 
    mov dx, word ptr ds:$currY
    sub dx, 2
    mov word ptr ds:$currY, dx
    jmp main
;------------------------------

move_left:
    mov dx, seg $currY
    mov ds, dx 
    mov dx, word ptr ds:$currX
    sub dx, 2
    mov word ptr ds:$currX, dx
    jmp main
;------------------------------

move_right:
    mov dx, seg $currY
    mov ds, dx 
    mov dx, word ptr ds:$currX
    add dx, 2
    mov word ptr ds:$currX, dx
    jmp main
;------------------------------

end_program:  
    call close_file
    mov ah, 0
    mov al, 03h
    int 10h

    mov ax, 4c00h ; zakoncz program
    int 21h   
;------------------------------

throw_exception:
    mov ah, 0
    mov al, 03h
    int 10h
     
    mov dx, offset $error_message
    mov ax, seg $error_message
    mov ds, ax
    mov ah, 9 ;wypisz komunikat o błędzie
    int 21h  
    
    mov ax, 4c00h ; zakoncz program
    int 21h 
;------------------------------

code ends
end start