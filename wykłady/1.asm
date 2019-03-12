assume cs:code1 ;definiuje gdzie zaczyna sięsegment kodu
;dw rezerwuje 2 bajty, db rezerwuje 1 bajt
dane1 segment
    db 14
    db 1, 56, 245
    dw 260, 1567
    db 'a'
text1 db "xddddd napis", 10, 13, "xddddddddd", "$"
dane1 ends

code1 segment
    start1: nop
            mov ax, seg ws1 ; przypisuje adres segmentu czyli do całęgo bloku
            mov ss, ax ; nie można przypisać bezpośrednio trzeba przez akumulator
            mov sp, offset ws1 ; przypisuje offset na konkretną zmienną w segmencie / bloku ; wierzchołek stosu wskazuje na ss:sp

            mov dx, offset text1
            call print1

    end1:   mov ah, 4ch ; koniec programu i powrót do systemu
            mov al, 0
            int 21h

    ;==================================================================================

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