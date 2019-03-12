mov ax, word ptr ds:[addr]; segment_adres:offset_adres, pobiera dane z pamięci o tym adresie i zapisuje je do ax

push ax ; wrzuć z ax na stos
pop ax ; weź ze stosu i zapisz do ax

;obsługa portów
out addr. al ; wyślij do urządzenia
in al, addr ; odczytaj z urządzenia

in ax, dx
out dx, ax

bx ;rejestr roboczy
cx ;rejestr licznikowy

;pętla
mov bx 0
mov cx, 8
POS1:
    add bx, 3
    loop POS1
; pierwsze zmniejsza cx o jeden do momenu ażbędzie równy zero

rep ; nie wiem co to robi ale coś z pętlą

mov ax, 450
mov bx, 2
mul bx; umieści w dx-ax wynik mnożenia ax * bx

mov dx, 100
mov ax, 3
out dx, ax

;można operowaćbezpośrednio na pamięci - dodawać i odejmować

sp ; stac pointer - wskaźnik sosu
push ; zmniejsza wartość sp = sp - 2
pop ; roścnie wartość sp = sp + 2

mov ax, word ptr ss:[sp+2] ; tak też można :)

bp ; rejestr bazowy - domyślnie zawiera przemieszczenie względem segmentu stosu

ip; licznik rozkazów
cs:ip ; zawiera adres na kolejną instrukcję
cs; adres na segment kodu

;do rejestróe ds, es, ss, nie mogę wrzucićwartości bezpośrednio tylko przez akumulator as

;znaczniki rejestrów zawierają informacje o różnych rzeczkach i wynikach operacji

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



assume cs:code1
dane1 segment
buf db 100 dup(?)
nazwa1 db "nazwa_pliku.txt", 0 ; musi być zakończony 0, bo nazwa pliku
wskaznik1 dw ?
dane1 ends

code1 segment
    start1:
        ;ds:[80h] ; 
        ; 80h - ilość znaków wprowadzonych po nazwie programu
        ; 81h - spacja
        ; 82h - od tego miejsca zaczynają się dane

        ;kopiowanie argumentów wejściowych programu pod inne miejsce
        mov ax, seg buf
        mov es, ax
        mov di offset buf ; -> es:di
        mov si, 82h
        xor cx, cx ; cx = 0
        mov cl, byte ptr ds:[80h]

        cld ; df <= 0 => inc si i inc di
        rep movsb ; es:[di] 

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;obsługa plików 
        ;nazwa pliku w ds:dx
        mov ax, seg nazwa1
        mov ds, ax
        mov dx, offset nazwa1

        mov ah, 3dh ; open file
        int 21h
        ;jećli CF == 0, znaczy że plik otwprzuł się poprawnie, i AX = wskaźnik na plik
        mov word ptr ds:[wskaznik1], ax

        mov, dx, offset buf
        mov bx, word ptr ds[wskaznik1]
        mov ah, 3fh ; read
        ;mov cx, 5 ; można ustawićile ma przepczytać, a w ax zapisana jest ilośćwpisanych znaków
        int 21h
        ;jeśli cf=0 to jest ok

        bov bx, word ptr ds:[wskaznik1]
        mov ah, 3eh ; close file
        int 21h


    ;paramert dx = offset
    print1: mov ax, seg text1
            mov ds, ax ; nie można bezpośrednio przypisać do ds, trzeba za pośrednicstwem np ax
            mov ah, 9h; wypisz tekst z pod ds:dx
            int 21h
            ret
code1 ends

stos1 segment stack
    dw  400 dup(?) ;dowolna wartość domyślna
ws1 dw ?
stos1 ends

end start1

;tetował to ktoś ?