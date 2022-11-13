.386
.model	flat, stdcall
includelib msvcrt.lib

printf		proto C :ptr sbyte, :vararg
scanf		proto C :dword,		:vararg

.data
	szMsgOut	byte	'r=%d, s=%d', 0ah, 0
	s			dword	20
	r			dword	40
.code

swap	proc	C	a: ptr dword, b: ptr dword
		local	temp :dword
		mov		eax, a			
		mov		ecx, [eax]		; ecx = *a

		mov		ebx, b
		mov		edx, [ebx]		; edx = *b

		;mov		temp, ecx		; temp = *a
		mov		[eax], edx		; *a = *b
		;mov		ecx, temp		; 由于无法操作两个内存数，故先将其中一个加载到寄存器中
		mov		[ebx], ecx		; *b= temp
		ret
swap	endp

main	proc
	invoke	printf, offset szMsgOut, r, s
	invoke	swap, offset r, offset s
	invoke	printf, offset szMsgOut, r, s
	ret
main	endp
end main