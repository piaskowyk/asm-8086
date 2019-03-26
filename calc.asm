data1 segment
	;długość, wartość string, snak końca, wartość w systemie dziesiętnym
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

	$eleven		db 10d, "jedenascie", "$", 11d
	$twelve		db 9d, "dwanascie", "$", 12d
	$thirteen	db 10d, "trzynascie", "$", 13d
	$fourteen	db 11d, "czternascie", "$", 14d
	$fiveteen	db 10d, "pietnascie", "$", 15d
	$sixteen	db 10d, "szesnascie", "$", 16d
	$seventeen	db 12d, "siedemnascie", "$", 17d
	$eighteen	db 11d, "osiemnascie", "$", 18d
	$nineteen	db 14d, "dziewietnascie", "$", 19d

	$twent 		db 10d, "dwadziesci", "$", 20d
	$thirty 	db 11d, "trzydziesci", "$", 30d
	$forty 		db 12d, "czterdziesci", "$", 40d
	$fifty 		db 11d, "piedziesiat", "$", 50d
	$sixty 		db 13d, "szescdziesiat", "$", 60d
	$seventy 	db 14d, "siedemdziesiat", "$", 70d
	$eighty 	db 13d, "osiemdziesiat", "$", 80d
	
	$tail 		db 6d, "nascie", "$", 11d
	$plus 		db 4d, "plus", "$", 1d
	$minus 		db 5d, "minus", "$", 2d
	$miltiply 	db 4d, "razy", "$", 3d
	
	$intro 		db "Entry equal: ", 10, 13, "$"
	$error 		db 10, 13, "Incorrect data $"
	
	$debug 		db 10, 13, "mleko", 10, 13, "$"
	
	;bufor na wartosci wprowadzone przez użytkownika
	$buffer 	db 100 ;maksymalna dozwolona liczba znaków
				db ? ;liczba podanych znaków
				db 100 dup(0) ;znaki podane przez uzytkownika
	
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
	$separator		db " $"
	
data1 ends

code1 segment
	run_program:   
		;ustaw ds na segment danych
	    call set_ds
		;wypisz wiadomośćstartową
		call print_intro

		;wczytaj tekst wprowadzony przez użytkownika do bufora
		mov dx, offset $buffer
		mov ah, 0ah
		int 21h
		
		;----------------------------------------------------------
		;wyznaczanie punktów startowych i końcowych na wszystkie 3 argumenty
		;----------------------------------------------------------
		
		;iteruj wskaźnikiem $argX_start aż do momentu jak napotka znak inny niż spacja
		
		;----------------------------------------------------------
		;szukanie wskaznikźw na pierwszy argument
		;inicjalizowanie rejestrów 
		call set_ds
		mov dl, byte ptr ds:[$buffer + 1] ;rozmiar bufora wpisanego przez użytkownika
		mov dh, 0 ;startowanie licznika do iteracji
		mov bx, 2; ustawienie wskaźnika na początek napisu
		
		trim_space1:
			;wczytuj znak po znaku i porównuj
			mov ch, byte ptr ds:[$buffer + bx]
			cmp ch, 9 ; tabulacja
			je continue1
			cmp ch, 32 ; spacja
			jne before_find_arg1
			
			continue1:
			
			cmp dl, dh ;jeżli dotarł do końca znaczy że wystąpił wyjątek
			je throw_exception
			
			inc bx ;przesuń wskaźnik na następny znak
			inc dh ;inkrementuj indeks pętli
		jmp trim_space1
		
		before_find_arg1:
			mov byte ptr ds:[$arg1_start], dh
		
		find_arg1:
			mov ch, byte ptr ds:[$buffer + bx]; załaduj pierwszy znak z bufora o indekxie bx do ch
			;jesli napotkano spacje
			cmp ch, 32 ;32 - asci kod spacji
			je detect_arg1
			;jesli dotarl do konca stringa to znaczy ze nie podano wszystkich argumentów
			cmp dl, dh
			je throw_exception
			
			inc bx ;przesuń wskaźnik na następny znak
			inc dh ;inkrementuj indeks pętli
		jmp find_arg1

		detect_arg1:
			dec dh ;ponieważ dh wskazywało na spacje
			mov byte ptr ds:[$arg1_end], dh
			inc dh
			
		;----------------------------------------------------------
		;szukanie wskazników na pierwszy argument
		inc bx ; przesuń na pierwszy znak za spacje
		inc dh ;inkrementuj indeks pętli
		
		trim_space2:
			mov ch, byte ptr ds:[$buffer + bx]
			cmp ch, 9
			je continue2
			cmp ch, 32
			jne before_find_arg2
			
			continue2:
			
			cmp dl, dh ;jeżli dotarł do końca znaczy że wystąpił wyjątek
			je throw_exception
			
			inc bx ;przesuń wskaźnik na następny znak
			inc dh ;inkrementuj indeks pętli
		jmp trim_space2
		
		before_find_arg2:
			mov byte ptr ds:[$arg2_start], dh
		
		find_arg2:
			mov ch, byte ptr ds:[$buffer + bx]
			;jesli napotkano spacje
			cmp ch, 32
			je detect_arg2
			;jesli dotarl do konca stringa to znaczy ze nie podano wszystkich argumentów
			cmp dl, dh
			je throw_exception
			
			inc bx ;przesuń wskaźnik na następny znak
			inc dh ;inkrementuj indeks pętli
		jmp find_arg2
	
		detect_arg2:
			dec dh ;ponieważ dh wskazywało na spacje
			mov byte ptr ds:[$arg2_end], dh
			inc dh
			
		;----------------------------------------------------------
		;szukanie wskazników na pierwszy argument
		inc bx ; przesuń na pierwszy znak za spacje
		inc dh ; inkrementuj indeks pętli
		
		trim_space3:
			mov ch, byte ptr ds:[$buffer + bx]
			cmp ch, 9
			je continue3
			cmp ch, 32
			jne before_find_arg3
			
			continue3:
			
			cmp dl, dh ;jeżli dotarł do końca znaczy że wystżpił wyjątek
			je throw_exception
			
			inc bx ;move both pointer to next char of string
			inc dh ;increment loop index
		jmp trim_space3
		
		before_find_arg3:
			mov byte ptr ds:[$arg3_start], dh
		
		find_arg3:
			mov ch, byte ptr ds:[$buffer + bx]
			;jesli dotarl do konca stringa to znaczy ze nie podano wszystkich argumentów
			cmp dl, dh
			je detect_arg3
			
			cmp ch, 32
			je detect_arg3
			
			cmp ch, 9
			je detect_arg3
			
			inc bx ;przesuń wskaźnik na następny znak
			inc dh ;inkrementuj indeks pętli
		jmp find_arg3
	
		detect_arg3:
			dec dh ;ponieważ dh wskazywało na spacje
			mov byte ptr ds:[$arg3_end], dh
			inc dh
		
		;----------------------------------------------------------
		;rozpoznawanie wartosci wszystkich 3 argumentów
		;----------------------------------------------------------
		
		;rozpoznawanie pierwszej cyfry
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
		
		;rozpoznawanie operacji arytmetycznej
		mov di, offset $plus
		call compare_for_arg2_fn
		
		mov di, offset $minus
		call compare_for_arg2_fn
		
		mov di, offset $miltiply
		call compare_for_arg2_fn
		
		call throw_exception
		end_switch2:
		
		;rozpoznawanie drugiej cyfry
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
		;przeprwadz operację arytmetyczną
		;----------------------------------------------------------
		  
		call set_ds 
		mov ah, byte ptr ds:[$arg2_value]
		
		cmp ah, 1
		je operation_add
		cmp ah, 2
		je operation_substract
		cmp ah, 3
		je operation_multiply
		
		operation_add:;dodawanie
			mov al, byte ptr ds:[$arg1_value]
			add al, byte ptr ds:[$arg3_value]
			mov byte ptr ds:[$result], al
			call print_result
			jmp end_program
			
		operation_substract:;odejmowanie
			mov al, byte ptr ds:[$arg1_value]
			sub al, byte ptr ds:[$arg3_value]
			mov byte ptr ds:[$result], al
			call print_result
			jmp end_program
			
		operation_multiply:;mnożenie
			mov al, byte ptr ds:[$arg1_value]
			mov bl, byte ptr ds:[$arg3_value]
			mul bl
			mov byte ptr ds:[$result], al
			call print_result
			jmp end_program
		
		; zakoncz program
		end_program:
			mov	ax, 04c00h  
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
	    call set_ds
		;porównywanie pierwszego argumentu
		mov bx, 2; $buffer[2]
		mov bh, 0
		add bl, byte ptr ds:[$arg1_start]
		mov si, 1; $<variabile name>[1]
		mov dh, byte ptr ds:[$arg1_start]
		mov dl, byte ptr ds:[$arg1_end]
		
		;ubliczanie długości pierwszego arguentu
		mov ch, dl
		sub ch, dh
		add ch, 1 ;ponieraż na pierwszym bicie znajduje się długość
		mov ah, ch ;ah zawiera długość pierwszej cyfry
		
		;sprawdz czy dlugosci sa takie same
		cmp ah, ds:[di]
		jne end_compare1
		
		inc di;przejdź do pierwszego znaku
		;jeśli długości sa takie same
		compare_to1:
			mov ch, byte ptr ds:[$buffer + bx] 
			mov cl, ds:[di]
			
			cmp ch, cl
			jne end_compare1
			
			cmp dh, dl
			je is_detect1
			
			inc bx ;inkrementuj index na znak bufora
			inc di ;inkrementuj index na znak porównywanej zmiennej
			inc dh ;inkrementuj index pętli
		jmp compare_to1
		
		is_detect1:
			;zapisz rozpoznaną wartośćdziesiętną, ostanią wartością jest wartosć dziesiętna cyfry
			inc di
			inc di
			mov al, ds:[di]
			mov byte ptr ds:[$arg1_value], al
			;end switch
			jmp end_switch1
			
		end_compare1:
		ret
		
	;-----------------------------------------------------	
	;arg
	;mov di, offset $<variabile name>
	compare_for_arg2_fn:
	    call set_ds
		;porównywanie drugiego argumentu
		mov al, byte ptr ds:[$arg2_start]
		mov bx, ax
		mov bh, 0; potrzeba tylko czesci bl, a rejestr zostanie zapisany do 2 bitowego
		add bx, 2; $buffer[2]
		mov si, 1; $<variabile name>[1]
		mov dh, byte ptr ds:[$arg2_start]
		mov dl, byte ptr ds:[$arg2_end]
		
		;oblicz długość
		mov ch, dl
		sub ch, dh
		add ch, 1 ;ponieważ indeks zaczyna się od 0
		mov ah, ch
		
		;sprawdz czy dlugosci sa takie same
		cmp ah, ds:[di]
		jne end_compare2
		
		inc di;idź do pierwszego indeksu
		;jeśli mają te same długości
		compare_to2:
			mov ch, byte ptr ds:[$buffer + bx] 
			mov cl, ds:[di]
			
			cmp ch, cl
			jne end_compare2
			
			cmp dh, dl
			je is_detect2
			
			inc bx ;inkrementuj index na znak bufora
			inc di ;inkrementuj index na znak porównywanej zmiennej
			inc dh ;inkrementuj index pętli
		jmp compare_to2
		
		is_detect2:
			;zapisz rozpoznaną wartośćdziesiętną, ostanią wartością jest wartosć dziesiętna cyfry
			inc di
			inc di
			mov al, ds:[di]
			mov byte ptr ds:[$arg2_value], al
			;end switch
			jmp end_switch2
			
		end_compare2:
		ret
		
	;-----------------------------------------------------	
	;arg
	;mov di, offset $<variabile name>
	compare_for_arg3_fn: 
	    call set_ds
		mov al, byte ptr ds:[$arg3_start]
		mov bx, ax; $buffer[2] iterate over each char in buffer
		mov bh, 0
		add bx, 2
		mov si, 1; $<variabile name>[1]
		mov dh, byte ptr ds:[$arg3_start]
		mov dl, byte ptr ds:[$arg3_end]
		
		;oblicz długość
		mov ch, dl
		sub ch, dh
		add ch, 1
		mov ah, ch
		
		;sprawdz czy dlugosci sa takie same
		cmp ah, ds:[di]
		jne end_compare3
		
		inc di;idź do pierwszego znaku
		;jeśli są tej samej długości
		compare_to3:
			mov ch, byte ptr ds:[$buffer + bx] 
			mov cl, ds:[di]
			
			cmp ch, cl
			jne end_compare3
			
			cmp dh, dl
			je is_detect3
			
			inc bx ;inkrementuj index na znak bufora
			inc di ;inkrementuj index na znak porównywanej zmiennej
			inc dh ;inkrementuj index pętli
		jmp compare_to3
		
		is_detect3:
			inc di
			inc di
			mov al, ds:[di]
			mov byte ptr ds:[$arg3_value], al
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
		
		call set_ds
		;wypisac liczbe dziesietna slownie
		mov ax, 0
		mov al, byte ptr ds:[$result]
		mov dl, byte ptr ds:[$result]; copy result
		
		;if zero end program
		cmp al, 0
		je print_0
		
		cmp al, 100
		jae is_overflow
		jmp continue
		
		is_overflow:
			mov bx, 65535d
			sub bx, ax
			inc bl
			mov byte ptr ds:[$result], bl
			;print 'minus'
			mov dx, seg $minus
			mov ds, dx ; segment do ds
			mov dx, offset $minus    
			inc dx                                  
			mov ah, 9 ; wypisz stringa pod adresem ds:dx
			int 21h
			call print_separator
			jmp recognise_number_x1
			
		continue:
		
		cmp al, 19
		jg recognise_number_x10
		jmp recognise_number_x1
		
		recognise_number_x10:			
			;if 2_
			mov dh, 0
			mov ah, 0
			mov al, dl
			mov bl, 30d
			div bl
			cmp al, 0
			je print_20
			
			;if 3_
			mov dh, 0
			mov ah, 0
			mov al, dl
			mov bl, 40d
			div bl
			cmp al, 0
			je print_30
			
			;if 4_
			mov dh, 0
			mov ah, 0
			mov al, dl
			mov bl, 50d
			div bl
			cmp al, 0
			je print_40
			
			;if 5_
			mov dh, 0
			mov ah, 0
			mov al, dl
			mov bl, 60d
			div bl
			cmp al, 0
			je print_50
			
			;if 6_
			mov dh, 0
			mov ah, 0
			mov al, dl
			mov bl, 70d
			div bl
			cmp al, 0
			je print_60
			
			;if 7_
			mov dh, 0
			mov ah, 0
			mov al, dl
			mov bl, 80d
			div bl
			cmp al, 0
			je print_70
			
			;if 8_
			mov dh, 0
			mov ah, 0
			mov al, dl
			mov bl, 90d
			div bl
			cmp al, 0
			je print_80
		
		end_recognise_number_x10:
			call print_separator

		recognise_number_x1:
			cmp dl, 10d ;if 10
			je print_10

			cmp dl, 11d ;if 11
			je print_11

			cmp dl, 12d ;if 12
			je print_12

			cmp dl, 13d ;if 13
			je print_13

			cmp dl, 14d ;if 14
			je print_14

			cmp dl, 15d ;if 15
			je print_15

			cmp dl, 16d ;if 16
			je print_16

			cmp dl, 17d ;if 17
			je print_17

			cmp dl, 18d ;if 18
			je print_18

			cmp dl, 19d ;if 19
			je print_19
            
            call set_ds
			;counting modulo
			mov dx, 0   
			mov ax, 0
			mov al, byte ptr ds:[$result]
			mov bx, 10
			div bx 
			;in dx is ax moulo 10
			
			;if 9
			cmp dl, 9d
			je print_9
			
			;if 8
			cmp dl, 8d
			je print_8
			
			;if 7
			cmp dl, 7d
			je print_7
			
			;if 6
			cmp dl, 6d
			je print_6
			
			;if 5
			cmp dl, 5d
			je print_5
			
			;if 4
			cmp dl, 4d
			je print_4
			
			;if 3
			cmp dl, 3d
			je print_3
			
			;if 2
			cmp dl, 2d
			je print_2
			
			;if 1
			cmp dl, 1d
			je print_1
			
		end_recognise_x1:

		ret
	
	;-----------------------------------------------------	
	;printing function
	print_10:
		mov dx, seg $ten
		mov ds, dx ; segment do ds
		mov dx, offset $ten  
		jmp print_and_jmp_end_recognise_x1

	print_11:
		mov dx, seg $eleven
		mov ds, dx ; segment do ds
		mov dx, offset $eleven   
		jmp print_and_jmp_end_recognise_x1

	print_12:
		mov dx, seg $twelve
		mov ds, dx ; segment do ds
		mov dx, offset $twelve  
		jmp print_and_jmp_end_recognise_x1

	print_13:
		mov dx, seg $thirteen
		mov ds, dx ; segment do ds
		mov dx, offset $thirteen  
		jmp print_and_jmp_end_recognise_x1

	print_14:
		mov dx, seg $fourteen
		mov ds, dx ; segment do ds
		mov dx, offset $fourteen  
		jmp print_and_jmp_end_recognise_x1

	print_15:
		mov dx, seg $fiveteen
		mov ds, dx ; segment do ds
		mov dx, offset $fiveteen   
		jmp print_and_jmp_end_recognise_x1

	print_16:
		mov dx, seg $sixteen
		mov ds, dx ; segment do ds
		mov dx, offset $sixteen  
		jmp print_and_jmp_end_recognise_x1

	print_17:
		mov dx, seg $seventeen
		mov ds, dx ; segment do ds
		mov dx, offset $seventeen   
		jmp print_and_jmp_end_recognise_x1

	print_18:
		mov dx, seg $eighteen
		mov ds, dx ; segment do ds
		mov dx, offset $eighteen     
		inc dx                                      
		jmp print_and_jmp_end_recognise_x1

	print_19:
		mov dx, seg $nineteen
		mov ds, dx ; segment do ds
		mov dx, offset $nineteen   
		inc dx                                        
		jmp print_and_jmp_end_recognise_x1
		
	print_20:
		mov dx, seg $twent
		mov ds, dx ; segment do ds
		mov dx, offset $twent    
		jmp print_and_jmp_end_recognise_number_x10
		
	print_30:
		mov dx, seg $thirty
		mov ds, dx ; segment do ds
		mov dx, offset $thirty    
		jmp print_and_jmp_end_recognise_number_x10
		
	print_40:
		mov dx, seg $forty
		mov ds, dx ; segment do ds
		mov dx, offset $forty       
		jmp print_and_jmp_end_recognise_number_x10
		
	print_50:
		mov dx, seg $fifty
		mov ds, dx ; segment do ds
		mov dx, offset $fifty    
		jmp print_and_jmp_end_recognise_number_x10
		
	print_60:
		mov dx, seg $sixty
		mov ds, dx ; segment do ds
		mov dx, offset $sixty      
		jmp print_and_jmp_end_recognise_number_x10
		
	print_70:
		mov dx, seg $seventy
		mov ds, dx ; segment do ds
		mov dx, offset $seventy  
		jmp print_and_jmp_end_recognise_number_x10
		
	print_80:
		mov dx, seg $eighty
		mov ds, dx ; segment do ds
		mov dx, offset $eighty    
		jmp print_and_jmp_end_recognise_number_x10
		
	print_1:
		mov dx, seg $one
		mov ds, dx ; segment do ds
		mov dx, offset $one  
		jmp print_and_jmp_end_recognise_x1
		
	print_2:
		mov dx, seg $two
		mov ds, dx ; segment do ds
		mov dx, offset $two 
		jmp print_and_jmp_end_recognise_x1
		
	print_3:
		mov dx, seg $three
		mov ds, dx ; segment do ds
		mov dx, offset $three  
		jmp print_and_jmp_end_recognise_x1
		
	print_4:
		mov dx, seg $four
		mov ds, dx ; segment do ds
		mov dx, offset $four   
		jmp print_and_jmp_end_recognise_x1
		
	print_5:
		mov dx, seg $five
		mov ds, dx ; segment do ds
		mov dx, offset $five    
		jmp print_and_jmp_end_recognise_x1
		
	print_6:
		mov dx, seg $six
		mov ds, dx ; segment do ds
		mov dx, offset $six     
		jmp print_and_jmp_end_recognise_x1
		
	print_7:
		mov dx, seg $seven
		mov ds, dx ; segment do ds
		mov dx, offset $seven    
		jmp print_and_jmp_end_recognise_x1
		
	print_8:
		mov dx, seg $eight
		mov ds, dx ; segment do ds
		mov dx, offset $eight   
		jmp print_and_jmp_end_recognise_x1
		
	print_9:
		mov dx, seg $nine
		mov ds, dx ; segment do ds
		mov dx, offset $nine    
		jmp print_and_jmp_end_recognise_x1
		
	print_0:
		mov dx, seg $zero
		mov ds, dx ; segment do ds
		mov dx, offset $zero    
		inc dx	
		mov ah, 9 ; wypisz stringa pod adresem ds:dx
		int 21h
		jmp end_program

	print_separator:
		mov dx, seg $separator
		mov ds, dx ; segment do ds
		mov dx, offset $separator                                       
		mov ah, 9 ; wypisz stringa pod adresem ds:dx
		int 21h
		ret
		
	print_and_jmp_end_recognise_number_x10:
		call interrapt_print
		jmp end_recognise_number_x10
		
	print_and_jmp_end_recognise_x1:
		call interrapt_print
		jmp end_recognise_x1
		
	interrapt_print:
		inc dx	
		mov ah, 9 ; wypisz stringa pod adresem ds:dx
		int 21h
		ret    
		
	set_ds:
	    mov ax, seg $one
	    mov ds, ax  
	    ret
		
code1 ends

stos1 segment stack
stos1 ends

end run_program