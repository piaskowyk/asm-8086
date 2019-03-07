data1 segment
	;program variabile
	;lenght, name, end char, decimal value
	$zero 		db 4d, "zero", "$", 0d
	$one 		db 5d, "jeden", "$", 1d
	$two 		db 3d, "dwa", "$", 2d
	$three 		db 4d, "trzy", "$", 3d
	$four 		db 6d, "cztery", "$", 4d
	$five 		db 4d, "piec", "$", 5d
	$six 		db 5d, "szesc", "$", 6d
	$seven 		db 6d, "siedem", "$", 7d
	$eight 		db 5d, "osiem", "$", 8d
	$nine 		db 8d, "dziewiec", "$", 9d
	$ten 		db 8d, "dziesiec", "$", 10d
	$twent 		db 10d, "dwadziesci", "$", 20d
	$thirty 	db 11d, "trzydziesci", "$", 30d
	$forty 		db 12d, "czterdziesci", "$", 40d
	$fifty 		db 11d, "piedziesiat", "$", 50d
	$sixty 		db 13d, "szescdziesiat", "$", 60d
	$seventy 	db 14d, "siedemdziesiat", "$", 70d
	$eighty 	db 13d, "osiemdziesiat", "$", 80d
	$ninety 	db 15d, "dziewiedziesiat", "$", 90d
	$hundred 	db 3d, "sto", "$", 100d
	
	$plus 		db 4d, "plus", "$", 1d
	$minus 		db 5d, "minus", "$", 2d
	$miltiply 	db 4d, "razy", "$", 3d
	
	$intro 		db "Entry equal: ", 10, 13, "$"
	$error 		db 10, 13, "Incorrect data $"
	
	$debug 		db 10, 13, "mleko", 10, 13, "$"
	$debug1 	db 10, 13, "tak", 10, 13, "$"
	$debug2 	db 10, 13, "nie", 10, 13, "$"
	$debug3 	db 10, 13, "ok", 10, 13, "$"
	
	;bufor for user input
	$buffer 	db 26 ;maksymalna dozwolona liczba znaków
				db ? ;liczba podanych znaków
				db 26 dup(0) ;znaki podane przez uzytkownika
	
	$arg1_start 	db 0
	$arg1_end 		db 0
	$arg1_value 	db 0
	
	$arg2_start 	db 0
	$arg2_end 		db 0
	$arg2_value 	db 0
	
	$arg3_start 	db 0
	$arg3_end 		db 0
	$arg3_value 	db 0

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
		mov bx, 2;set index of start buffer string
		find_arg1:
			mov ch, $buffer[bx]; loat char from buffer on index bx to ch	
			;jesli napotkano spacje
			cmp ch, 32 ;32 - asci code of space
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
			dec dh ;because dh pointer on space
			mov byte ptr $arg1_end, dh
			inc dh
			
		;----------------------------------------------------------
		;szukanie wskazników na pierwszy argument
		inc bx ; move to first char behind space
		inc dh ;increment loop index
		mov byte ptr $arg2_start, dh
		find_arg2:
			mov ch, $buffer[bx]
			;jesli napotkano spacje
			cmp ch, 32
			je detect_arg2
			;jesli dotarl do konca stringa to znaczy ze nie podano wszystkich argumentów
			cmp dl, dh
			je throw_exception
			
			inc bx ;move both pointer to next char of string
			inc dh ;increment loop index
		jmp find_arg2
	
		;show information about error and end program
		detect_arg2:
			dec dh ;because dh pointer on space
			mov byte ptr $arg2_end, dh
			inc dh
			
		;----------------------------------------------------------
		;szukanie wskazników na pierwszy argument
		inc bx ; move to first char behind space
		inc dh ;increment loop index
		mov byte ptr $arg3_start, dh
		find_arg3:
			mov ch, $buffer[bx]
			;jesli dotarl do konca stringa to znaczy ze nie podano wszystkich argumentów
			cmp dl, dh
			je detect_arg3
			
			inc bx ;move both pointer to next char of string
			inc dh ;increment loop index
		jmp find_arg3
	
		;show information about error and end program
		detect_arg3:
			dec dh ;because dh pointer on space
			mov byte ptr $arg3_end, dh
			inc dh
		
		;----------------------------------------------------------
		;rozpoznawanie wartosci wszystkich 3 argumentów
		;----------------------------------------------------------
		
		;create switch for arg1 (number)
		mov di, offset $zero
		call compare_for_arg1_fn
		
		mov di, offset $one
		call compare_for_arg1_fn
		
		mov di, offset $two
		call compare_for_arg1_fn
		
		mov di, offset $three
		call compare_for_arg1_fn
		
		mov di, offset $four
		call compare_for_arg1_fn
		
		mov di, offset $five
		call compare_for_arg1_fn
		
		mov di, offset $six
		call compare_for_arg1_fn
		
		mov di, offset $seven
		call compare_for_arg1_fn
		
		mov di, offset $eight
		call compare_for_arg1_fn
		
		mov di, offset $nine
		call compare_for_arg1_fn
		
		end_switch1:
		
		;recognise erythmetic opertion
		mov di, offset $plus
		call compare_for_arg2_fn
		
		mov di, offset $minus
		call compare_for_arg2_fn
		
		mov di, offset $miltiply
		call compare_for_arg2_fn
		
		end_switch2:
		
		;recognise arg3 (number)
		
		mov di, offset $zero
		call compare_for_arg3_fn
		
		mov di, offset $one
		call compare_for_arg3_fn
		
		mov di, offset $two
		call compare_for_arg3_fn
		
		mov di, offset $three
		call compare_for_arg3_fn
		
		mov di, offset $four
		call compare_for_arg3_fn
		
		mov di, offset $five
		call compare_for_arg3_fn
		
		mov di, offset $six
		call compare_for_arg3_fn
		
		mov di, offset $seven
		call compare_for_arg3_fn
		
		mov di, offset $eight
		call compare_for_arg3_fn
		
		mov di, offset $nine
		call compare_for_arg3_fn
		
		end_switch3:
		
		;----------------------------------------------------------
		;do arythmetic operation
		;----------------------------------------------------------
		
		
		
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
		
	;-----------------------------------------------------	
	print_incorrect_data_info:
		mov dx, seg $error
		mov ds, dx ; segment do ds
		mov dx, offset $error                                       
		mov ah, 9 ; wypisz stringa pod adresem ds:dx
		int 21h
		ret
		
	;-----------------------------------------------------	
	throw_exception:
		call print_incorrect_data_info
		jmp end_program
	
	;-----------------------------------------------------	
	;arg
	;mov di, offset $<variabile name>
	compare_for_arg1_fn:
		;compare arg1 to $one
		mov bx, 2; $buffer[2] iterate over each char in buffer
		mov si, 1; $one[1]
		mov dh, byte ptr $arg1_start
		mov dl, byte ptr $arg1_end
		
		;calculate lenght of arg1
		mov ch, dl
		sub ch, dh
		add ch, 1 ;because start index is 0, so lenght of first argument is shorten by one
		mov ah, ch ;ah contains lenght of arg1
		
		;sprawdz czy dlugosci sa takie same
		;di is set as argument before call function, pointing on first byte, whose giveing information about lenght string
		cmp ah, [di]
		jne end_compare1
		
		inc di;go to first char of string
		;if have the same lenght
		compare_to1:
			mov ch, $buffer[bx] 
			mov cl, [di]
			
			cmp ch, cl
			jne end_compare1
			
			cmp dh, dl
			je is_detect1
			
			inc bx ;increment index char of buffer
			inc di ; increment index char of program string 
			inc dh ;increment loop index
		jmp compare_to1
		
		is_detect1:
			;move to posithion with deceminal value
			inc di
			inc di
			mov al, [di]
			mov byte ptr $arg1_value, al
			;end switch
			jmp end_switch1
			
		end_compare1:
		ret
		
	;-----------------------------------------------------	
	;arg
	;mov di, offset $<variabile name>
	compare_for_arg2_fn:
		;compare arg1 to $one
		mov al, byte ptr $arg2_start
		mov bx, ax; $buffer[2] iterate over each char in buffer
		mov si, 1; $one[1]
		mov dh, byte ptr $arg2_start
		mov dl, byte ptr $arg2_end
		
		;calculate lenght of arg1
		mov ch, dl
		sub ch, dh
		add ch, 1 ;because start index is 0, so lenght of first argument is shorten by one
		mov ah, ch ;ah contains lenght of arg1
		
		;sprawdz czy dlugosci sa takie same
		;di is set as argument before call function, pointing on first byte, whose giveing information about lenght string
		cmp ah, [di]
		jne end_compare2
		
		inc di;go to first char of string
		;if have the same lenght
		compare_to2:
			mov ch, $buffer[bx] 
			mov cl, [di]
			
			cmp ch, cl
			jne end_compare2
			
			cmp dh, dl
			je is_detect2
			
			inc bx ;increment index char of buffer
			inc di ; increment index char of program string 
			inc dh ;increment loop index
		jmp compare_to2
		
		is_detect2:
			;move to posithion with deceminal value
			inc di
			inc di
			mov al, [di]
			mov byte ptr $arg2_value, al
			;end switch
			jmp end_switch2
			
		end_compare2:
		ret
		
	;-----------------------------------------------------	
	;arg
	;mov di, offset $<variabile name>
	compare_for_arg3_fn:
		;compare arg1 to $one
		mov al, byte ptr $arg3_start
		mov bx, ax; $buffer[2] iterate over each char in buffer
		mov si, 1; $one[1]
		mov dh, byte ptr $arg3_start
		mov dl, byte ptr $arg3_end
		
		;calculate lenght of arg1
		mov ch, dl
		sub ch, dh
		add ch, 1 ;because start index is 0, so lenght of first argument is shorten by one
		mov ah, ch ;ah contains lenght of arg1
		
		;sprawdz czy dlugosci sa takie same
		;di is set as argument before call function, pointing on first byte, whose giveing information about lenght string
		cmp ah, [di]
		jne end_compare3
		
		inc di;go to first char of string
		;if have the same lenght
		compare_to3:
			mov ch, $buffer[bx] 
			mov cl, [di]
			
			cmp ch, cl
			jne end_compare3
			
			cmp dh, dl
			je is_detect3
			
			inc bx ;increment index char of buffer
			inc di ; increment index char of program string 
			inc dh ;increment loop index
		jmp compare_to3
		
		is_detect3:
			;move to posithion with deceminal value
			inc di
			inc di
			mov al, [di]
			mov byte ptr $arg3_value, al
			;end switch
			jmp end_switch3
			
		end_compare3:
		ret
		
	;-----------------------------------------------------	
	;debug function
		
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
		
	print_debug3:
		mov dx, seg $debug3
		mov ds, dx ; segment do ds
		mov dx, offset $debug3                                       
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