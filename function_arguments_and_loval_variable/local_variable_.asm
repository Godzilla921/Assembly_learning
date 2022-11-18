.386
.model		flat, stdcall
includelib	msvcrt.lib

printf		proto	C	:ptr sbyte, :vararg

.data

	r			dword		10
	s			dword		20
	szMsgOut	byte		'r=%d,  s=%d', 0ah, 0

.code

swap	proc	C	ptr_a:ptr dword, ptr_b:ptr dword
		mov		eax, ptr_a
		mov		ecx, [eax]
		mov		[ebp-4], ecx

		mov		ebx, ptr_b
		mov		edx, [ebx]
		mov		[ebp-8], edx

		mov		ecx, [ebp-8]
		mov		eax, ptr_a
		mov		[eax], ecx

		mov		edx, [ebp-4]
		mov		ebx, ptr_b
		mov		[ebx], edx
		ret
swap	endp

main	proc
		invoke	printf, offset szMsgOut, r, s
		invoke	swap, offset r, offset s
		invoke	printf, offset szMsgOut, r, s
		ret
main	endp
end	 main