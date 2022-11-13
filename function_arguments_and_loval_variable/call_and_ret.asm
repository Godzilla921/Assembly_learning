.386
.model flat, stdcall
includelib msvcrt.lib

printf		proto C :dword, :vararg
scanf		proto C :ptr sbyte, :vararg

.data		; 数据区

szFmt		byte		'%d + %d = %d', 0ah, 0
x			sdword		?						;三个无符号整型数
y			sdword		?
z			sdword		?

.code		; 代码区

addProc1	proc	;相加的两个参数在寄存器 edi, esi中, 返回值在 eax中
	mov		eax, edi
	add		eax, esi
	ret
addProc1	endp


addProc2	proc
	push	eax		; 存储寄存器eax
	mov		eax, x
	add		eax, y
	mov		z, eax
	pop		eax
	ret
addProc2	endp

main		proc
	mov		edi, 10
	mov		esi, 20
	invoke	addProc1
	mov		x, 30
	mov		y, 40
	invoke	addProc2
	invoke	printf, offset szFmt, edi, esi, eax
	invoke	printf, offset szFmt, x, y, z
	ret
main		endp
end		main