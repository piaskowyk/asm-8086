stos1 segment 
	stack 	dw 200 dup (?)
	wstosu  dw ?
stos1 ends  
                          
data1 segment
    blad                db  "Nie mozna otworzyc pliku lub nie podano nazwy pliku.$"
	handle          	dw  ?
	curr_y         		dw  ?
	curr_x				dw	?
	real_x          	dw  ?
	real_y          	dw  ?
	i					dw	?
	skala				dw	1
	omijane_wiersze 	dw  0
	omijane_kolumny 	dw  0
	x0					dw	?
	y0					dw	?
	omijane_bajty		dw	0
	ominiete_wiersze	dw	0
	numer_koloru    	db  ?
	adres           	dw  ?
	buf             	db  200 dup(?)
	size_hd         	dw  ?
	size_x1				dw  ?
	size_x				dw  ?
	size_y				dw  ?
	bpp					db  ?
	b               	db  ?
	g               	db  ?
	r               	db  ?
	$nazwa1				db	30 dup(?)
	
	$filename db 'a.bmp', 0
data1 ends

code1 segment
start:
	;wczytywanie argumentu wejsciowego który jest nazwą pliku
	mov ax, seg $nazwa1
	mov es, ax
	mov dx, offset $nazwa1
	mov di, dx 
	xor cx, cx
	mov si, 82h
	mov cl, byte ptr ds:[80h]
	cmp cl, 0
	jz error1
	dec cl							

	rep movsb ; czytanie nazwy pliku z 0700:0082h
	
	mov sp, offset wstosu
	mov ax, seg wstosu
	mov ss, ax ;inicjacja stosu
	
	;================================
	mov ax, seg nazwa1
	mov ds, ax
	mov dx, offset nazwa1
	mov ax, 3d00h 
	int 21h
	jc error1
	mov word ptr ds:[handle], ax ;otwarcie pliku handle == file handle 
	
	;================================
	mov al, 13h
	xor ah, ah
	int 10h	;wlaczenie trybu graficznego
	
	mov dx, offset buf
	mov ax, seg buf
	mov ds, ax
	mov cx, 200
	mov bx, word ptr ds:[handle]
	xor al, al
	mov ah, 3fh
	int 21h	;przeczytanie wstepu do bufora
	
	;================================
	mov al, byte ptr ds:[buf + 18]
	mov ah, byte ptr ds:[buf + 19]
	mov word ptr ds:[size_x], ax
	
	mov al, byte ptr ds:[buf + 22]
	mov ah, byte ptr ds:[buf + 23]
	mov	word ptr ds:[size_y], ax
	
	mov al, byte ptr ds:[buf + 28]
	cmp al, 24
	jnz error1
	mov byte ptr ds:[bpp], al ;przeczytanie z bufora wielkosci i bpp           
	
	
	mov al, byte ptr ds:[buf + 14]
	mov byte ptr ds:[size_hd], al
	mov byte ptr ds:[size_hd + 1], 0 ; przeczytanie wielkosci naglowka
	
	;================================
	cmp word ptr ds:[size_y], 200
	ja skroc_ilosc_wierszy
	jbe nie_skracaj_wierszy					

reszta1:	
	cmp word ptr ds:[size_x], 320
	ja skroc_ilosc_kolumn
	jbe nie_skracaj_kolumn				;wywolanie procedur odpowiedzialnych za dobranie lewego gornego rogu obrazka
	
reszta2:
    mov bx, ds:[handle]
    mov ax, 13
    mov dx, word ptr ds:[size_hd]
    add dx, ax 
    xor cx, cx
    mov ax, 4200h
    int 21h								;przesuniecie pliku na pierwsze rgb
	
omin_wiersze:                                 
    
	mov bx, ds:[handle]
    mov dx, 3
    mov ax, word ptr ds:[omijane_wiersze]
	mul dx
    mov dx, word ptr ds:[size_x]
    mul dx
    mov cx, dx
    mov dx, ax
    mov ax, 4201h
    int 21h                            		;pominiecie pierwszych wierszy w celu przesuniecia ramki wzgledem osi Y
	
omin_bajty:
	
	nop
	mov bx, ds:[handle]
	xor cx, cx
	mov dx, ds:[omijane_bajty]
	mov ax, 3
	mul dx
	mov dx, ax
	mov ax, 4201h
	int 21h
	nop										;pominiecie pierwszych bajtow w celu przesuniecia ramki wzgledem osi X
	
print:										;procedura odpowiedzialna za wyswietlenie obrazka
	mov dx, 200
    petla0:									;petla po wysokosci
	mov word ptr ds:[curr_y], dx
	push dx

	mov dx, 320
	
		petla1:								;petla po szerokosci
		mov word ptr ds:[curr_x], dx
		push dx
		
		call sprawdz						;sprawdzenie czy piksel ma byc narysowany na tej pozycji
		call przeczytaj_BGR					;przeczytanie z pliku 3 bajtow
		call oblicz_bajt					;obliczenie numeru bajtu
				
		continue:
		call oblicz_adres					;obliczenie adresu komorki segmentu A000h
		call zaswiec_punkt					;wyswietlenie pikseli
		
		pop dx
		cmp dx, 0
		jz petla0k	
		sub dx, word ptr ds:[skala]
		jmp petla1							;sprawdzenie konca petli1
		
	petla0k:
		
	mov bx, ds:[handle]
	mov ax, word ptr ds:[omijane_kolumny]
	mov dx, 3
	mul dx
	mov dx, ax
	mov ax, 4201h
	int 21h									;omijanie kolumn w pliku

	pop dx
	cmp dx, 0
	jz czekaj
	sub dx, word ptr ds:[skala]		
	jmp petla0								;sprawdzenie konca petli0
	
czekaj:
	
	xor ax, ax
	int 16h									;czekanie na przycisk z klawiatury
	
	cmp al, 'w'
	jz w_gore
	cmp al, 's'
	jz w_dol
	cmp al, 'a'
	jz w_lewo
	cmp al, 'd'
	jz w_prawo
	cmp al, '='
	jz przybliz
	;cmp al, '-'
	;jz oddal
	
zamknij_plik:

    mov bx, word ptr ds:[handle]
    mov ah, 3eh
    int 21h								
    
    mov al, 3h
	mov ah, 0
	int 10h 							;wyjscie z trybu 13h
    
zamknij_program:
	mov ax, 4c00h
    int 21h 

przybliz:
	sk:
		xor ah, ah
		mov al, byte ptr ds:[skala]
		mov bx, 2
		mul bl
		cmp al, 8
		ja czekaj
		mov byte ptr ds:[skala], al
	y:
		mov ax, word ptr ds:[real_y]
		mov bx, 2
		mul bx
		cmp ax, 200
		jb mn
		jae wi
		mn:
			mov word ptr ds:[real_y], ax
			dec ax
			mov word ptr ds:[y0], ax
			jmp x
		wi:
			mov word ptr ds:[real_y], 200
			mov word ptr ds:[y0], 199
			sub ax, 200
			div byte ptr ds:[skala]
			xor ah, ah
			mov word ptr ds:[adres], ax
			add word ptr ds:[ominiete_wiersze], ax
			add word ptr ds:[omijane_wiersze], ax
	x:
		mov bx, 2
		mov ax, word ptr ds:[size_x1]
		div bx
		mov word ptr ds:[size_x1], ax
		
		mov ax, word ptr ds:[real_x]
		mul bx
		cmp ax, 320
		jb mn1
		jae wi1
		mn1:
			mov word ptr ds:[real_x], ax
			jmp reszta2
		wi1:
			mov word ptr ds:[real_x], 320
			sub ax, 320
			div byte ptr ds:[skala]
			xor ah, ah
			add word ptr ds:[omijane_kolumny], ax
		jmp reszta2
;oddal:
;	cmp byte ptr ds:[skala], 1
;	jz czekaj
;	y1:
;		mov ax, word ptr ds:[omijane_wiersze]
		;cmp ax, 0
		;jb mn2
		;jae wi2
		;mn2:
	;		mov bx, 2
	;		mov ax, word ptr ds:[real_y]
	;		div bx
	;		mov word ptr ds:[real_y], ax
	;		dec ax
	;		mov word ptr ds:[y0], ax
	;		jmp sk1
			;jmp x1
;		wi2:
;			mov bl, byte ptr ds:[skala]
;			div bl
			;cmp ax, word ptr ds:[omijane_wiersze]
			;jae ow
			;jb om
			ow:
;				mov ax, 200
;				div byte ptr ds:[skala]
;				xor ah, ah
;				mov ax, word ptr ds:[adres]
;				sub word ptr ds:[omijane_wiersze], ax
;				sub word ptr ds:[ominiete_wiersze], ax
;				mov word ptr ds:[real_y], 200
;				jmp sk1
;				;jmp x1
			;om:
			;	mov ax, 200
			;	div byte ptr ds:[skala]
			;;	add ax, word ptr ds:[real_y]
				;mov bl, 2
				;div bl
				;mov word ptr ds:[real_y], ax
				;mov word ptr ds:[omijane_wiersze], 0
;	x1:
;		mov bx, 2
;		mov ax, word ptr ds:[size_x1]
;		mul bx
;		mov word ptr ds:[size_x1], ax
;		
;		mov ax, word ptr ds:[omijane_kolumny]
;		cmp ax, 0
;		jb mn3
;		jae wi3
;		mn3:
;			mov ax, word ptr ds:[real_x]
;			mov bx, 2
;			div bx
;			mov word ptr ds:[real_x], ax
;			jmp sk1
;		wi3:
;			div byte ptr ds:[skala]
;			cmp ax, word ptr ds:[omijane_kolumny]
;			jae ow1
;			jb om1
;			ow1:
;				mov ax, word ptr ds:[omijane_kolumny]
;				div byte ptr ds:[skala]
;				sub word ptr ds:[omijane_wiersze], ax
;				mov word ptr ds:[real_x], 320
;				jmp sk1
;			om1:
;				mov ax, word ptr ds:[omijane_kolumny]
;				div byte ptr ds:[skala]
;				add ax, word ptr ds:[real_x]
;				mov bl, 2
;				div bl
;				mov word ptr ds:[real_x], ax
;				mov word ptr ds:[omijane_kolumny], 0
;			
;	sk1:
;		xor ah, ah
;		xor bh, bh
;		mov al, byte ptr ds:[skala]
;		mov bl, 2
;		div bl
;		mov byte ptr ds:[skala], al
;		jmp reszta2
;
w_gore:
	mov bx, word ptr ds:[omijane_wiersze]
	add bx, 5
	cmp bx, word ptr ds:[ominiete_wiersze]
	ja czekaj
	add word ptr ds:[omijane_wiersze], 5
	jmp reszta2

w_dol:
	cmp word ptr ds:[y0], 199
	jnz czekaj
	mov bx, word ptr ds:[omijane_wiersze]
	sub bx, 5
	js czekaj
	sub word ptr ds:[omijane_wiersze], 5
	jmp reszta2
	
w_lewo:
	
	mov ax, word ptr ds:[omijane_bajty]
	sub ax, 5
	js czekaj
	sub ds:[omijane_bajty], 5
	jmp reszta2

w_prawo:
	
	mov ax, word ptr ds:[omijane_bajty]
	mov dx, 1
	mul dx
	mov bx, word ptr ds:[size_x1]
	add ax, bx
	cmp ax, word ptr ds:[size_x]
	jae czekaj
	add ds:[omijane_bajty], 5
	jmp reszta2
	
skroc_ilosc_wierszy:

    mov word ptr ds:[real_y], 200
	mov word ptr ds:[y0], 199
	mov ax, word ptr ds:[size_y]                  
    sub ax, 200               
    mov word ptr ds:[omijane_wiersze], ax
	mov word ptr ds:[ominiete_wiersze], ax
    jmp reszta1
                   
skroc_ilosc_kolumn:
    mov word ptr ds:[real_x], 320               
	mov word ptr ds:[size_x1], 320
	mov ax, word ptr ds:[size_x]
    sub ax, 320               
    mov word ptr ds:[omijane_kolumny], ax
    mov word ptr ds:[x0], 0
	jmp reszta2

nie_skracaj_wierszy:
	mov ax, word ptr ds:[size_y]
	mov word ptr ds:[y0], ax
	mov word ptr ds:[real_y], ax 
	jmp reszta1

nie_skracaj_kolumn:
	mov ax, word ptr ds:[size_x]
	mov word ptr ds:[size_x1], 320
	mov word ptr ds:[real_x], ax
	mov word ptr ds:[x0], 0
	jmp reszta2

sprawdz:
	mov ax, word ptr ds:[y0]
	mov bx, word ptr ds:[curr_y]
	dec bx
	cmp ax, bx
	jb na_czarno
	sub ax, word ptr ds:[real_y]
	inc ax
	cmp ax, bx
	ja na_czarno
	
	mov bx, 320
	sub bx, word ptr ds:[curr_x]
	mov ax, 0
	cmp ax, bx
	ja na_czarno
	add ax, word ptr ds:[real_x]
	cmp ax, bx
	jbe na_czarno
	ret

przeczytaj_BGR:         ;wczytuje 3 bajty do handle
    
    mov dx, offset buf
    mov ax, seg buf
    mov ds, ax
    
    mov bx, word ptr ds:[handle]
    push cx
    mov cx, 3
    mov ah, 3fh
    int 21h
    pop cx
    ret  

oblicz_adres:

    mov bx, word ptr ds:[curr_y]
    dec bx

	mov ax, 320
    mul bx
    
    mov bx, 320
    sub bx, word ptr ds:[curr_x]
	dec bx
    add ax, bx
    mov si, ax
    ret 

zaswiec_punkt:  ;na bajcie si wyswietl bl
    
    mov ax, 0A000h
    mov es, ax
    
	mov cx, word ptr ds:[skala]
	z1:
		mov word ptr ds:[i], cx
		push cx
		mov cx, word ptr ds:[skala]
		z2:
			push si
			mov bx, word ptr ds:[i]
			dec bx
			mov ax, 320
			mul bx
			add si, ax
			
			add si, cx
			dec si
			mov al, byte ptr ds:[numer_koloru]
			mov es:[si], al
			pop si
		loop z2
		pop cx
	loop z1
    ret
    
oblicz_bajt: ; wyznacza wartosc bajta do wyswietlenia na podstawie buf i zapisuje do zmiennej
    mov al, byte ptr ds:[buf]
    mov ds:[b], al
    mov al, byte ptr ds:[b]
    mov bl, 64
    call podziel_al_przez_bl
    mov byte ptr ds:[b], al               ;B
    
    mov al, byte ptr ds:[buf+1]
    mov bl, 32
    call podziel_al_przez_bl
    mov bl, 4 
    call pomnoz_al_przez_bl 
    mov byte ptr ds:[g], al                 ;G
    
    mov al, byte ptr ds:[buf+2]
    mov bl, 32
    call podziel_al_przez_bl
    mov bl, 32
    call pomnoz_al_przez_bl
    mov byte ptr ds:[r], al                   ;R
    
    mov bl, byte ptr ds:[b]
    mov bh, byte ptr ds:[g]
    add bl, bh
    mov bh, byte ptr ds:[r]
    add bl, bh
    
    mov byte ptr ds:[numer_koloru], bl
	
	mov dx, 3c8h
	mov al, byte ptr ds:[numer_koloru]
	out dx, al
	mov dx, 3c9h
	mov al, byte ptr ds:[buf] ;składowa R
	shr al, 1
	shr al, 1
	out dx, al
	mov al, byte ptr ds:[buf+2];składowa G
	shr al, 1
	shr al, 1
	out dx, al
	mov al, byte ptr ds:[buf+1] ;składowa B
	shr al, 1
	shr al, 1
	out dx, al
	ret
    
podziel_al_przez_bl:
    div bl
    xor ah, ah
    ret
    
pomnoz_al_przez_bl:    
    mul bl    
    ret

na_czarno:
	mov dx, 3c8h
	mov al, 0
	out dx, al
	mov dx, 3c9h
	
	out dx, al
	
	out dx, al
	
	out dx, al
	
	mov byte ptr ds:[numer_koloru], 0
	pop	ax
	jmp continue

error1:
    mov dx, offset blad
    mov ax, seg blad
    mov ds, ax
    mov ah, 9
    int 21h
    jmp zamknij_program
    
code1 ends
end start