.386
.model flat, stdcall
option casemap: none

includelib msvcrt.lib
; 声明要使用的 printf 与 scanf 函数
printf		proto C :dword, :vararg
scanf		proto C :dword, :vararg

.stack		4096	; 定义栈的大小为4KB

.data

x			sdword		1,2,3,4,5,6,7,8,9,10		; 带符号数
y			sdword		5,4,3,2,1,10,9,8,7,6		;
len			equ			($-y)/4						; 数组元素的个数
Rule		dword		0000000011011100B			; 逻辑尺，从右往左读，0表示加，1表示减
z			sdword		10 dup(?)					; 重复十次占位符
msg				byte	'len=%d', 0ah, 0
prinf_sz_fmt	byte	'Z[%d]=%d', 0ah, 0

Array		dword		?

.code
; 打印数组函数
; 限长在寄存器esi中
printArray proc
	xor		ebx, ebx		;ebx 寄存器置0， 作为访问数组的下标
	jmp		MID
L1:
	push	esi
	push	ebx
	invoke	printf, offset prinf_sz_fmt, ebx, z[ebx*4]
	pop		ebx
	pop		esi
	inc		ebx
MID:
	cmp		ebx, esi
	jl		L1				; ebx<esi时继续循环
	ret
printArray endp

main proc
	mov		ecx, len								; 存储循环次数
	mov		edx, Rule								;
	xor		ebx, ebx								; 访问数组时的下标
Next:
	mov		eax, x[ebx*4]							; 从x中取出第ebx 个数
	shr		edx, 1									; 逻辑右移一位，移出位在CF中
	jc		Subs										; CF=1	表示减法
	; CF=0 表示加法
	add		eax, y[ebx*4]
	jmp		Result
Subs:
	sub		eax, y[ebx*4]
Result:
	mov		z[ebx*4], eax
	inc		ebx
	loop	Next
	invoke	printf, offset	msg, len


	mov		esi, len
	invoke	printArray

	ret
main endp
end main
