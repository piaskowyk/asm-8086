data1 segment
	;program variabile
	;lenght, name, end char, decimal value
	$zero db 4d, "zero", "$", 0d
	$one db 5d, "jeden", "$", 1d
	$two db 3d, "dwa", "$", 2d
	$three db 4d, "trzy", "$", 3d
	$four db 6d, "cztery", "$", 4d
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
	$intro db "Entry equal: ", 10, 13, "$"
	$error db 10, 13, "Incorrect data $"
	
	$debug db 10, 13, "mleko", 10, 13, "$"
	$debug1 db 10, 13, "tak", 10, 13, "$"
	$debug2 db 10, 13, "nie", 10, 13, "$"
	
	;bufor for user input
	$buffer db 26 ;maksymalna dozwolona liczba znaków
		    db ? ;liczba podanych znaków
		    db 26 dup(0) ;znaki podane przez uzytkownika
	
	$arg1_start db 0
	$arg1_end db 0
	$arg1_value db 0
	
	$arg2_start db 0
	$arg2_end db 0
	$arg2_value db 0
	
	$arg3_start db 0
	$arg3_end db 0
	$arg3_value db 0
	
	$firstNum db 0
	$secund db 0
	$opertion db 0
	$lastPosition db 0
data1 ends

code1 segment
	run_program:
		;print start message
		call print_intro

		;read user input to buffer
		mov dx, offset $buffer
		mov ah, 0ah
		int 21h
		
		;----------------------------------------------------------
		;wyznaczanie pointerów na wszystkie 3 argumenty
		;----------------------------------------------------------
		
		
		;----------------------------------------------------------
		;szukanie wskazników na pierwszy argument
		;inicjalizowanie rejestrów
		mov dl, $buffer[1] ;size of input buffer
		mov dh, 0 ;counter of loop iteration
		
		mov bx, offset $buffer[2]
		mov ch, $buffer[bx]		
		find_arg1:
			;jesli napotkano spacje
			cmp ch, ' '
			je detect_arg1
			;jesli dotarl do konca stringa to znaczy ze nie podano wszystkich argumentów
			cmp dl, dh
			je throw_exception
			
			inc bx ;move both pointer to next char of string
			inc dh ;increment loop index
		jmp find_arg1
	
		;show information about error and end program
		detect_arg1:
			mov byte ptr $arg1_start, 0
			mov byte ptr $arg1_end, dh
			
		;----------------------------------------------------------
		;szukanie wskazników na pierwszy argument
		inc bx ; move to first char behind space
		inc dh ;increment loop index
		mov ch, $buffer[bx]
		mov byte ptr $arg2_start, bx
		find_arg2:
			;jesli napotkano spacje
			cmp ch, ' '
			je detect_arg2
			;jesli dotarl do konca stringa to znaczy ze nie podano wszystkich argumentów
			cmp dl, dh
			je throw_exception
			
			inc bx ;move both pointer to next char of string
			inc dh ;increment loop index
		jmp find_arg2
	
		;show information about error and end program
		detect_arg2:
			mov byte ptr $arg2_end, dh
			
		;----------------------------------------------------------
		;szukanie wskazników na pierwszy argument
		inc bx ; move to first char behind space
		inc dh ;increment loop index
		mov ch, $buffer[bx]
		mov byte ptr $arg3_start, bx
		find_arg3:
			;jesli dotarl do konca stringa to znaczy ze nie podano wszystkich argumentów
			cmp dl, dh
			je detect_arg3
			
			inc cl ;move both pointer to next char of string
			inc dh ;increment loop index
		jmp find_arg2
	
		;show information about error and end program
		detect_arg3:
			mov byte ptr $arg3_end, dh
		
		
		;----------------------------------------------------------
		;rozpoznawanie jednego wyrazu
		;----------------------------------------------------------
		
		
		;inicjowanie rejestrów dla rozpoznanych liczby
		mov ch, 0
		mov cl, 0
		
		;skorzystam z rejestrów al, ah, oraz wiekszych si, di
		;sprawdzam dlugosc wyrazów
		mov dl, $buffer[1]
		mov dh, $one[0]
		cmp dl, dh
		jne if_not_equal_1
		jmp if_equal_1
		
		if_not_equal_1:
			call print_debug
			jmp end_if_1
		if_equal_1:
			;przypisanie pierwszego znaku z porównywanego stringa do rejestru
			mov bl, $buffer[2]			
			mov bh, $one[1]
			mov dh, 0
			
			;petla sprawdza po kolei reszte znakoow
			loop_1:
				;if all characters is the same words are equals
				cmp dl, dh
				je string_is_the_same
			
				cmp bl, bh ;compare chars from both string
				jne not_equal_chars_1 ;break loop if not equal
				
				;move both pointer to next
				inc bl
				inc bh
				;increment loop index
				inc dh
				;make loop
				jmp loop_1
			
			string_is_the_same:
				call print_debug1
				jmp end_loop_1
				
			not_equal_chars_1:	
				call print_debug2
				jmp end_loop_1
				
			end_loop_1:
			
			jmp end_if_1
			
		end_if_1:
			jmp end_program
		
		; zakoncz program
		end_program:
			mov	ax,04c00h  
			int	21h
	
	;=====================================================
	;callable methods
	;=====================================================
	print_intro:
		mov dx, seg $intro
		mov ds, dx ; segment do ds
		mov dx, offset $intro                                       
		mov ah, 9 ; wypisz stringa pod adresem ds:dx
		int 21h
		ret
		
	print_incorrect_data_info:
		mov dx, seg $error
		mov ds, dx ; segment do ds
		mov dx, offset $error                                       
		mov ah, 9 ; wypisz stringa pod adresem ds:dx
		int 21h
		ret
		
	throw_exception:
		call print_incorrect_data_info
		jmp end_program
		
	print_debug:
		mov dx, seg $debug
		mov ds, dx ; segment do ds
		mov dx, offset $debug                                       
		mov ah, 9 ; wypisz stringa pod adresem ds:dx
		int 21h
		ret
	
	print_debug1:
		mov dx, seg $debug1
		mov ds, dx ; segment do ds
		mov dx, offset $debug1                                       
		mov ah, 9 ; wypisz stringa pod adresem ds:dx
		int 21h
		ret
		
	print_debug2:
		mov dx, seg $debug2
		mov ds, dx ; segment do ds
		mov dx, offset $debug2                                       
		mov ah, 9 ; wypisz stringa pod adresem ds:dx
		int 21h
		ret
	
	;arg:
	;mov dl, $var 
	print_char:
		add dl, 30h                                    
		mov ah, 02h ; wypisz stringa pod adresem ds:dx
		int 21h
		ret
		
code1 ends

stos1 segment stack
stos1 ends

end run_program