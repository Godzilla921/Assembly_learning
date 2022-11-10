.386
.model flat, stdcall
option casemap: none

includelib msvcrt.lib
; 声明要使用的 printf 与 scanf 函数
printf		proto C :dword, :vararg
scanf		proto C :dword, :vararg

.stack		4096	; 定义栈的大小为4KB

.data

Fmt		sbyte		'sum=%d', 0ah, 0
SUM		sdword		?

.code

main proc
	mov		ecx, 100		; 控制循环次数
	xor		eax, eax		; 记录求和的值

L1:
	add		eax, ecx		; 从100 加到1
	loop	L1				; 使用loop 来控制特定次数的循环

	mov		SUM, eax
	invoke	printf, offset Fmt, SUM
	ret
main endp
end main