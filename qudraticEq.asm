 .386
 .model flat,stdcall
option casemap:none

include msvcrt.inc
includelib msvcrt.lib
include kernel32.inc
includelib kernel32.lib

 .const

sInviteText		db 'Enter numbers a b and c in equation ax^2 + bx + c = 0', 10
	
sInviteLen 		db 54d
sEnterLength 		db 4d


four 			real8 4.0f
two 			real8 2.0f
						

.data	
FloatEnterA 		db 10, 'a = ', 0
FloatEnterB 		db 10, 'b = ', 0
FloatEnterC 		db 10, 'c = ', 0

InputFormatFloat 	db '%lf'

sFormatImX1		db 'x1 = %lf + %lfi', 10, 0
sFormatImX2		db 'x2 = %lf - %lfi', 10, 0

sFormatX 		db 'x = %lf',10,0
sFormatX1 		db 'x1 = %lf', 10, 0
sFormatX2 		db 'x2 = %lf', 10, 0

NotSquareEquation 	db 'Is not square equation', 10, 0

CoeffA			real8 ?
CoeffB 			real8 ?
CoeffC 			real8 ?

ImSolution 		real8 ?
ReSolution 		real8 ?

root1 			real8 ?
root2 			real8 ?

FlagsChanger 		dw ?
.code

Main PROC
	finit
	invoke 	crt_printf, offset FloatEnterA
	invoke 	crt_scanf, offset InputFormatFloat, offset CoeffA
	invoke 	crt_printf, offset FloatEnterB
	invoke 	crt_scanf, offset InputFormatFloat, offset CoeffB
	invoke 	crt_printf, offset FloatEnterC
	invoke 	crt_scanf, offset InputFormatFloat, offset CoeffC

	fld 	CoeffA
	ftst
	fstsw 	FlagsChanger
	mov 	ah, BYTE PTR FlagsChanger + 1
	sahf 	
	jne 	start

	invoke 	crt_printf, offset NotSquareEquation
	jmp 	end_proc

start:
	fld 	CoeffB
	fmul 	CoeffB
	fld 	CoeffA
	fmul 	four
	fmul 	CoeffC ;DWORD PTR
	fsubrp 	ST(1), ST(0)
	fchs 	

	ftst  	
	fstsw 	FlagsChanger
	mov 	ah, BYTE PTR FlagsChanger + 1
	sahf
	jb 		is_imaginary
	je 		DiscriminantIs0

	fsqrt   

	fld		ST(0)

	
	fsub 	CoeffB
	fdiv 	CoeffA
	fdiv 	two
	
	fstp 	root1
	fchs
	fsub 	CoeffB
	fdiv 	CoeffA
	fdiv 	two
	fstp 	root2

	invoke 	crt_printf, offset sFormatX1, root1
	invoke 	crt_printf, offset sFormatX2, root2
	jmp 	end_proc

is_imaginary:
	fchs 
	fsqrt

	fld 	ST(0)

	fdiv 	CoeffA
	fdiv 	two
	fabs
	fstp 	ImSolution
	
	fld 	CoeffB
	fdiv 	CoeffA
	fdiv 	two
	fchs

	fstp 	ReSolution

	invoke 	crt_printf, offset sFormatImX1, ReSolution, ImSolution
	invoke 	crt_printf, offset sFormatImX2, ReSolution, ImSolution
	jmp 	end_proc

DiscriminantIs0:
	fld 	CoeffB
	fdiv 	CoeffA
	fdiv 	two
	fchs

	fstp 	ReSolution
	invoke 	crt_printf, offset sFormatX,ReSolution
end_proc:
	invoke 	Sleep, 3000
	invoke 	ExitProcess, 0
Main ENDP
end Main
