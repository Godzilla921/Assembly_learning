.386
.model	flat, stdcall
includelib	msvcrt.lib

printf	proto C :ptr sbyte, :vararg

.data
szOut	byte	'f(%d) = %d ', 0ah, 0

.code

factorial	proc	C	n:dword
	cmp		n, 1
	jle		exitrecurse
	mov		ebx, n
	dec		ebx
	invoke	factorial, ebx
	imul	n
	ret
exitrecurse:
	mov		eax, 1
	ret
factorial	endp

main	proc
	local	n :dword
	local	f :dword
	mov		n, 5
	invoke	factorial, n
	mov		f, eax
	invoke	printf, offset szOut, n, f
	ret
main	endp
end  main