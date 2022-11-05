 .386
 .model flat,stdcall
option casemap:none

include msvcrt.inc
includelib msvcrt.lib
include kernel32.inc
includelib kernel32.lib

 .const

sEnterFirstNumber  			db 'Enter first number in hex: a = 0x'
sEnterSecondNumber    	db 'Enter second number in hex: b = 0x'
	
sEnterFirstLen 		db 33d
sEnterSecondLen 	db 34d

sAdd 			db 10, 'a + b = 0x'
sSub 			db 10, 'a - b = 0x'
sDiv 			db 10, 'a / b = 0x'
sMul 			db 10, 'a * b = 0x'
sOperationLen		dd 11

check 			db 'a = %d; b = %d', 10, 0
			
maxHexLen		dd 8d
maxReadHexLen		dd 4d

sHexLen 		db 16d

.data	
sHex 			db '0123456789ABCDEF'


buffer 			db 60 dup(?)

decFirstNumber		dd 0
decSecondNumber		dd 0

hexResultNumber		db 8 dup('0')

countChars		dd 0

 .code

HexChar2Dec PROC ;В al лежит символ
  cmp al, 'a'
  jae is_small_letter
  cmp al, 'A'
  jae is_big_letter
  cmp al, '0'
  jae is_number
is_big_letter:
  sub al, 'A'
  add al, 10d
  jmp go_end
is_small_letter:
  sub al, 'a'
  add al, 10d
  jmp go_end
is_number:
  sub al, '0'
go_end:
  ret ;возвращаем dec в al
HexChar2Dec ENDP

Hex2Dec PROC ;В esi хранится ссылка на строку
	LOCAL outputInt 	:DWORD
	LOCAL digitMultiplier 	:DWORD

	mov eax, maxReadHexLen
	cmp countChars, eax
	jna start_calc

	mov countChars, eax

start_calc:
	mov outputInt, 0
	mov digitMultiplier, 1
	add esi, countChars
	dec esi

for_char:
	xor eax, eax
	mov al, [esi]
	call HexChar2Dec

	mul digitMultiplier
	
  add outputInt, eax
  shl digitMultiplier, 4d

  dec esi
  dec countChars
  ;cmp countChars, -1
	jnz for_char

	mov eax, outputInt
	ret
Hex2Dec ENDP ;Результат храниться в eax

Dec2Hex PROC
	xor ebx, ebx
	xor edx, edx

	mov esi, maxHexLen
	dec esi

	mov cx, WORD PTR [maxHexLen]
for_num:
	mov bx, ax
	and bx, 1111b
	mov edx, offset sHex
	mov dl, BYTE PTR [edx + ebx]
	
	mov [hexResultNumber + esi], BYTE PTR dl
	dec esi
	shr eax, 4d

	dec cx
	jnz for_num
	ret
Dec2Hex ENDP

Main PROC
  LOCAL hStdout 	:DWORD
  LOCAL hStdin 		:DWORD

  invoke GetStdHandle, -11
  mov hStdout, eax

  invoke GetStdHandle, -10
  mov hStdin, eax

  invoke WriteConsoleA, hStdout, ADDR sEnterFirstNumber, sEnterFirstLen, 0, 0
  invoke ReadConsole, hStdin, ADDR buffer, 60, ADDR countChars, 0
  sub countChars, 2
	
	mov esi, offset buffer
	call Hex2Dec
	mov decFirstNumber, eax

	invoke WriteConsoleA, hStdout, ADDR sEnterSecondNumber, sEnterSecondLen, 0, 0
	invoke ReadConsole, hStdin, ADDR buffer, 60, ADDR countChars, 0
	sub countChars, 2

	mov esi, offset buffer
	call Hex2Dec
	mov decSecondNumber, eax

	invoke crt_printf, ADDR check, decFirstNumber, decSecondNumber
	
	mov eax, decFirstNumber
	add eax, decSecondNumber

	call Dec2Hex

	invoke WriteConsoleA, hStdout, ADDR sAdd, sOperationLen, 0, 0
	invoke WriteConsoleA, hStdout, ADDR hexResultNumber, maxHexLen, 0, 0

	mov eax, decFirstNumber
	sub eax, decSecondNumber

	call Dec2Hex

	invoke WriteConsoleA, hStdout, ADDR sSub, sOperationLen, 0, 0
	invoke WriteConsoleA, hStdout, ADDR hexResultNumber, maxHexLen, 0, 0

	mov eax, decFirstNumber
	mul decSecondNumber

	call Dec2Hex

	invoke WriteConsoleA, hStdout, ADDR sMul, sOperationLen, 0, 0
	invoke WriteConsoleA, hStdout, ADDR hexResultNumber, maxHexLen, 0, 0

	mov eax, decFirstNumber
	div decSecondNumber

	call Dec2Hex

	invoke WriteConsoleA, hStdout, ADDR sDiv, sOperationLen, 0, 0
	invoke WriteConsoleA, hStdout, ADDR hexResultNumber, maxHexLen, 0, 0

  invoke ExitProcess, 0
Main ENDP
end Main
