 .386
 .model flat,stdcall
option casemap:none

include msvcrt.inc
includelib msvcrt.lib
include kernel32.inc
includelib kernel32.lib
include \masm32\include\windows.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\masm32.lib

 .const


half				real8 0.5f
							

.data	
sFormatDouble 			db '%lf', 0
sFormatInteger 			db '%d', 0
sFormatString 			db '%s', 0

sEnterEpsilon			db 'Enter Epsilon: ', 0
sEnterX				db 'Enter X: ', 0
sFormatI 			db 'i', 0
sFormatNewLine			db 10, 0

sFormatRoot			db 'sqrt(1 + x) = %lf', 0

one 				dd 1
two 				dd 2
oneTens 			real8 0.1f

epsilonNumber			real8 ?
precision 			real8 1.0f
xNumber 			real8 ?
is_img 				db 0

answer 				real8 1.f
answerBuffer			db 100 dup(0)
status 				dw ?

counter 			db 0

.code

getPrecision PROC 
  fild one
  xor ecx, ecx
for_precision:
  inc cx
  add counter, 1
  fmul oneTens
  
  fcom epsilonNumber
  fstsw status
  
  mov ah, BYTE PTR status + 1
  sahf
  
  jae for_precision
  
  ret
getPrecision ENDP ; Return precision to cx 

Main PROC
  finit
  invoke crt_printf, offset sEnterEpsilon
  invoke crt_scanf, offset sFormatDouble, offset epsilonNumber
  invoke crt_printf, offset sEnterX
  invoke crt_scanf, offset sFormatDouble, offset xNumber
  
  fld xNumber
  fiadd one
  fstp xNumber

  mov eax, DWORD PTR [xNumber + 4]
  shr eax, 31
  mov is_img, al
  
  fld xNumber
  fabs
  fstp xNumber

iter:
  fld xNumber
  fdiv answer
  fadd answer
  fidiv two
  
  fld answer
  fxch ST(1)
  fst answer
  fxch ST(1)

  fsub ST(0), ST(1)
  fabs
  
  
  fcomp epsilonNumber
  
  fstsw status
  
  mov ah, BYTE PTR status + 1
  sahf
  

  jae iter
  
  lea esi, answerBuffer

  invoke FloatToStr, answer, esi

  invoke getPrecision

  
  inc ecx 
  mov dl, 0
  mov [answerBuffer + ecx], BYTE PTR dl

  invoke crt_printf, offset sFormatString, offset answerBuffer

  cmp is_img, 0
  je end_proc

  invoke crt_printf, offset sFormatI
  
end_proc:
  invoke Sleep, 10000
  invoke ExitProcess, 0
Main ENDP
end Main
