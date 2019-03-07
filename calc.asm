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
	
	$result_label 	db 10, 13, "Result operation:", 10, 13, "$"
	$result 		db 0, "$"
	
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
		
		call throw_exception
		end_switch1:
		
		;recognise erythmetic opertion
		mov di, offset $plus
		call compare_for_arg2_fn
		
		mov di, offset $minus
		call compare_for_arg2_fn
		
		mov di, offset $miltiply
		call compare_for_arg2_fn
		
		call throw_exception
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
		
		call throw_exception
		end_switch3:
		
		;----------------------------------------------------------
		;do arythmetic operation
		;----------------------------------------------------------
		
		mov ah, $arg2_value
		
		cmp ah, 1
		je operation_add
		cmp ah, 2
		je operation_substract
		cmp ah, 3
		je operation_multiply
		
		operation_add:
			mov al, byte ptr $arg1_value
			add al, byte ptr $arg3_value
			mov byte ptr $result, al
			call print_result
			jmp end_program
			
		operation_substract:
			mov al, byte ptr $arg3_value
			sub al, byte ptr $arg1_value
			mov byte ptr $result, al
			call print_result
			jmp end_program
			
		operation_multiply:
			mov al, byte ptr $arg1_value
			mov bl, byte ptr $arg3_value
			mul bl
			mov byte ptr $result, al
			call print_result
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
		mov bx, ax
		mov bh, 0; potrzeba tylko czesci bl, a rejestr zostanie zapisany do 2 bitowego
		add bx, 2; 1 and 2 byte is reserved ,$buffer[2] iterate over each char in buffer
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
		mov bh, 0; potrzeba tylko czesci bl, a rejestr zostanie zapisany do 2 bitowego
		add bx, 2; 1 and 2 byte is reserved ,$buffer[2] iterate over each char in buffer
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
		
	print_result:
		mov dx, seg $result_label
		mov ds, dx ; segment do ds
		mov dx, offset $result_label                                       
		mov ah, 9 ; wypisz stringa pod adresem ds:dx
		int 21h
		
		;TODO
		;wypisac liczbe dziesietna slownie
		mov ax, 0
		mov al, byte ptr $result
		mov dl, byte ptr $result; copy result
		
		;if zero end program
		cmp al, 0
		je print_0
		
		cmp al, 100
		jg is_overflow
		jmp continue
		
		is_overflow:
			mov bx, 65535d
			sub bx, ax
			mov byte ptr $result, bl
			;print 'minus'
			mov dx, seg $minus
			mov ds, dx ; segment do ds
			mov dx, offset $minus                                      
			mov ah, 9 ; wypisz stringa pod adresem ds:dx
			int 21h
			
		continue:
		
		cmp al, 9
		jg recognise_number_x10
		jmp recognise_number_x1
		
		recognise_number_x10:
			;if 10
			mov al, dl
			mov bl, 10
			div bl
			cmp al, 0 ;in al is result of delivate
			je print_10
			
			;if 20
			mov al, dl
			mov bl, 20
			div bl
			cmp al, 0
			je print_20
			
			;if 30
			mov al, dl
			mov bl, 30
			div bl
			cmp al, 0
			je print_30
			
			;if 40
			mov al, dl
			mov bl, 40
			div bl
			cmp al, 0
			je print_40
			
			;if 50
			mov al, dl
			mov bl, 50
			div bl
			cmp al, 0
			je print_50
			
			;if 60
			mov al, dl
			mov bl, 60
			div bl
			cmp al, 0
			je print_60
			
			;if 70
			mov al, dl
			mov bl, 70
			div bl
			cmp al, 0
			je print_70
			
			;if 80
			mov al, dl
			mov bl, 80
			div bl
			cmp al, 0
			je print_80
			
			;if 90
			mov al, dl
			mov bl, 90
			div bl
			cmp al, 0
			je print_90
		
		recognise_number_x1:
			;counting modulo
			mov dx, 0   
			mov ax, 0
			mov al, byte ptr $result
			mov bx, 10
			div bx 
			;in dx is ax moulo 10
			
			;if 9
			cmp dl, 9
			je print_9
			
			;if 8
			cmp dl, 8
			je print_8
			
			;if 7
			cmp dl, 7
			je print_7
			
			;if 6
			cmp dl, 6
			je print_5
			
			;if 5
			cmp dl, 5
			je print_5
			
			;if 4
			cmp dl, 4
			je print_4
			
			;if 3
			cmp dl, 3
			je print_3
			
			;if 2
			cmp dl, 2
			je print_2
			
			;if 1
			cmp dl, 1
			je print_1
			
		end_recognise_x1:
		
		;mov dx, seg $result
		;mov ds, dx ; segment do ds
		;mov dx, offset $result                                      
		;mov ah, 9 ; wypisz stringa pod adresem ds:dx
		;int 21h
		ret
	
	;-----------------------------------------------------	
	;printing function
	print_10:
		mov dx, seg $ten
		mov ds, dx ; segment do ds
		mov dx, offset $ten                                       
		mov ah, 9 ; wypisz stringa pod adresem ds:dx
		int 21h
		jmp recognise_number_x1
		
	print_20:
		mov dx, seg $twent
		mov ds, dx ; segment do ds
		mov dx, offset $twent                                       
		mov ah, 9 ; wypisz stringa pod adresem ds:dx
		int 21h
		jmp recognise_number_x1
		
	print_30:
		mov dx, seg $thirty
		mov ds, dx ; segment do ds
		mov dx, offset $thirty                                       
		mov ah, 9 ; wypisz stringa pod adresem ds:dx
		int 21h
		jmp recognise_number_x1
		
	print_40:
		mov dx, seg $forty
		mov ds, dx ; segment do ds
		mov dx, offset $forty                                       
		mov ah, 9 ; wypisz stringa pod adresem ds:dx
		int 21h
		jmp recognise_number_x1
		
	print_50:
		mov dx, seg $fifty
		mov ds, dx ; segment do ds
		mov dx, offset $fifty                                       
		mov ah, 9 ; wypisz stringa pod adresem ds:dx
		int 21h
		jmp recognise_number_x1
		
	print_60:
		mov dx, seg $sixty
		mov ds, dx ; segment do ds
		mov dx, offset $sixty                                       
		mov ah, 9 ; wypisz stringa pod adresem ds:dx
		int 21h
		jmp recognise_number_x1
		
	print_70:
		mov dx, seg $seventy
		mov ds, dx ; segment do ds
		mov dx, offset $seventy                                       
		mov ah, 9 ; wypisz stringa pod adresem ds:dx
		int 21h
		jmp recognise_number_x1
		
	print_80:
		mov dx, seg $eighty
		mov ds, dx ; segment do ds
		mov dx, offset $eighty                                       
		mov ah, 9 ; wypisz stringa pod adresem ds:dx
		int 21h
		jmp recognise_number_x1
		
	print_90:
		mov dx, seg $ninety
		mov ds, dx ; segment do ds
		mov dx, offset $ninety                                       
		mov ah, 9 ; wypisz stringa pod adresem ds:dx
		int 21h
		jmp recognise_number_x1
		
	print_1:
		mov dx, seg $one
		mov ds, dx ; segment do ds
		mov dx, offset $one  
		inc dx
		mov ah, 9 ; wypisz stringa pod adresem ds:dx
		int 21h
		jmp end_recognise_x1
		
	print_2:
		mov dx, seg $two
		mov ds, dx ; segment do ds
		mov dx, offset $two 
		inc dx	
		mov ah, 9 ; wypisz stringa pod adresem ds:dx
		int 21h
		jmp end_recognise_x1
		
	print_3:
		mov dx, seg $three
		mov ds, dx ; segment do ds
		mov dx, offset $three  
		inc dx
		mov ah, 9 ; wypisz stringa pod adresem ds:dx
		int 21h
		jmp end_recognise_x1
		
	print_4:
		mov dx, seg $four
		mov ds, dx ; segment do ds
		mov dx, offset $four   
		inc dx	
		mov ah, 9 ; wypisz stringa pod adresem ds:dx
		int 21h
		jmp end_recognise_x1
		
	print_5:
		mov dx, seg $five
		mov ds, dx ; segment do ds
		mov dx, offset $five    
		inc dx
		mov ah, 9 ; wypisz stringa pod adresem ds:dx
		int 21h
		jmp end_recognise_x1
		
	print_6:
		mov dx, seg $six
		mov ds, dx ; segment do ds
		mov dx, offset $six     
		inc dx
		mov ah, 9 ; wypisz stringa pod adresem ds:dx
		int 21h
		jmp end_recognise_x1
		
	print_7:
		mov dx, seg $seven
		mov ds, dx ; segment do ds
		mov dx, offset $seven    
		inc dx	
		mov ah, 9 ; wypisz stringa pod adresem ds:dx
		int 21h
		jmp end_recognise_x1
		
	print_8:
		mov dx, seg $eight
		mov ds, dx ; segment do ds
		mov dx, offset $eight   
		inc dx	
		mov ah, 9 ; wypisz stringa pod adresem ds:dx
		int 21h
		jmp end_recognise_x1
		
	print_9:
		mov dx, seg $nine
		mov ds, dx ; segment do ds
		mov dx, offset $nine    
		inc dx	
		mov ah, 9 ; wypisz stringa pod adresem ds:dx
		int 21h
		jmp end_recognise_x1
		
	print_0:
		mov dx, seg $zero
		mov ds, dx ; segment do ds
		mov dx, offset $zero    
		inc dx	
		mov ah, 9 ; wypisz stringa pod adresem ds:dx
		int 21h
		jmp end_program
		
	;-----------------------------------------------------	
	;debug function
		
	print_debug:
		mov dx, seg $debug
		mov ds, dx ; segment do ds
		mov dx, offset $debug                                       
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