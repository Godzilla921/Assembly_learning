.386
.model flat, stdcall
option casemap: none

includelib msvcrt.lib
; 声明要使用的 printf 与 scanf 函数
printf		proto	C :dword, :vararg
scanf		proto	C :ptr sbyte, :vararg

.stack		4096	; 定义栈的大小为4KB

.data
	StrMsg	byte	'HELLO World!', 0


.code


; 数组地址在寄存器 %ebp中
exchange_letter		proc
	; 大小写进行转换
	mov		esi, ebp
Next:
	mov		al, [esi]
	test	al, al
	jz		L2
	cmp		al, 'A'			
	jb		L1				; 比'A' 小直接跳过
	cmp		al,	'z'			
	ja		L1				; 比'z' 大 直接跳过
	cmp		al,	'Z'			
	jbe		L0				; 比 'A'大， 且比'Z' 小 进行转换
	cmp		al, 'a'
	jae		L0				; 比 'a'大， 且比'z' 小 进行转换
	jmp		L1
L0:
	xor		al, 00100000B
	mov		[esi], al
L1:
	inc		esi
	jmp		Next
L2:
	invoke	printf, ebp
	ret
exchange_letter	endp

lower proc
	xor		esi, esi
Next:
	mov		al, StrMsg[esi]
	test	al, al
	jz		L2
	cmp		al, 'A'
	jb		L1
	cmp		al, 'Z'
	ja		L1
	add		al, 20h
	mov		StrMsg[esi], al
L1:
	inc		esi
	jmp		Next
L2:
	invoke	printf, offset StrMsg
	ret
lower endp

main	proc
	mov	ebp, offset StrMsg
	invoke	exchange_letter
	ret
main	endp
end main