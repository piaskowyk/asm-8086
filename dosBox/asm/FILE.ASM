.model SMALL
.386

.data
	tekst db "Hello World!\n"
.stack 100h
.code
	.startup
        mov eax, 4
        mov ebx, 1
	mov ecx, offset tekst
	mov edx, 13
	int 80h
        .exit
end
