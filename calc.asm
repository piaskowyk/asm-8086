data1 segment
	;sta³e potrzebne do dzia³ania programu
	$zero db 4d, "zero", "$", 0d
	$one db 5d, "jeden", "$", 1d
	$two db 4d, "dwa ", "$", 2d
	$three db 5d, "trzy ", "$", 3d
	$four db 7d, "cztery ", "$", 4d
	$five db 5d, "piec ", "$", 5d
	$six db 6d, "szesc ", "$", 6d
	$seven db 7d, "siedem ", "$", 7d
	$eight db 6d, "osiem ", "$", 8d
	$nine db 9d, "dziewiec ", "$", 9d
	$ten db 9d, "dziesiec ", "$", 10d
	$twent db 11d, "dwadziesci ", "$", 20d
	$thirty db 12d, "trzydziesci ", "$", 30d
	$forty db 13d, "czterdziesci ", "$", 40d
	$fifty db 12d, "piedziesiat ", "$", 50d
	$sixty db 14d, "szescdziesiat ", "$", 60d
	$seventy db 15d, "siedemdziesiat ", "$", 70d
	$eighty db 14d, "osiemdziesiat ", "$", 80d
	$ninety db 16d, "dziewiedziesiat ", "$", 90d
	$hundred db 4d, "sto ", "$", 100d
	
	$plus db 4d, "plus", "$"
	$minus db 5d, "minus", "$"
	$miltiply db 4d, "razy", "$"
	$intro db "Podaj opis dzialania: ", 10, 13, "$"
	
	;bufor na dane od u¿ytkownika
	$buffer  db 10 ;maksymalna dozwolona liczba znaków
		    db ? ;liczba podanych znaków
		    db 26 dup(0) ;znaki podane przez u¿ytkownika
data1 ends

code1 segment
	run_program:
		;wypisz komunikat startowy
		call print_intro

		;zczytaj bufor podany przez u¿ytkownika
		mov dx, offset $buffer
		mov ah, 0ah
		int 21h
		
		;skorzystam z rejestrów al, ah, oraz wiêkszych si, di
		;mov si, $buffer[1]
		;mov di, $one[1]
		
		mov dl, $one[1]                                     
		mov ah, 02h ; wypisz stringa pod adresem ds:dx
		int 21h
		
		; zakoncz program
		mov	ax,04c00h  
		int	21h
	
	print_intro:
		mov dx, seg $intro
		mov ds, dx ; segment do ds
		mov dx, offset $intro                                       
		mov ah, 9 ; wypisz stringa pod adresem ds:dx
		int 21h
		ret
		
code1 ends

stos1 segment stack
stos1 ends

end run_program