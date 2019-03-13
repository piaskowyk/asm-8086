;; hello.asm
;; Wypisuje określony ciąg 14 znaków
;;

segment .data
msg     db      "Hello World!", 0Ah    ; umieszcza w segmencie danych ciąg znaków zakończony znakiem końca linii

segment .text
        global  _start

_start:
        mov     eax, 4
        mov     ebx, 1
        mov     ecx, msg        ; adres pierwszego znaku do wyświetlenia
        mov     edx, 14         ; liczba znaków do wyświetlenia
        int     80h            ; wywołanie funkcji systemowej wyświetlającej ciąg znaków o danej długości

; wyjscie z programu
        mov     eax, 1
        xor     ebx, ebx
        int     0x80
; KONIEC PROGRAMU
