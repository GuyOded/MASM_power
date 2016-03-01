.486
.model flat
option casemap: none

include \masm32\include\kernel32.inc
includelib \masm32\lib\kernel32.lib

	Pow PROTO NEAR32 C
.data
base dd 0FFFFFFFEh
exponent dd 05h
.code

_start:
	call main
	xor eax, eax
	invoke ExitProcess, eax
	
main proc
	;----push parameters and call procedure----;
	push exponent
	push base
	call Pow
	
	add esp, 8
	ret
main endp

;---------------Power(base:DWORD, exp:DWORD) cdecl-----------------;
;calculates base^exponent to eax according to cdecl
;eax will contain -1 in case of a calculation error or register overflow
baseParam equ dword ptr [ebp + 8]
expParam equ dword ptr [ebp + 12]
Pow proc NEAR32 C
	push ebp
	mov ebp, esp
	
	;initialize registers
	mov ecx, expParam
	mov eax, 1h
	xor edx, edx;set edx to 0 so it would not interfere with imul
	
	cmp ecx, 0
	je EndProcedure
	jl InsertError
MultiplicationLoop:
	imul baseParam
	;if edx = 0xFFFFFFFF assume that the result is negative and continue the loop
	;skip the overflow check
	cmp edx, -1
	je ContinueLoop
	cmp edx, 0;check if eax is overflowed
	jne InsertError
ContinueLoop:
	loop MultiplicationLoop
	jmp EndProcedure

InsertError:
	mov eax, -1

EndProcedure:
	pop ebp
	ret
Pow endp	

END _start