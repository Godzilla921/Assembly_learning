.386
.model flat, stdcall
option casemap: none

includelib msvcrt.lib

printf		proto C :dword, :vararg
scanf		proto C :dword, :vararg


.data

in_		byte	'%d %d',0
out_	byte	'max(%d,%d)=%d', 0ah, 0
out2_	byte	'sign=%d', 0ah, 0
a		sdword	?
b		sdword	?
value	sdword  -1
.code

;比较MAX1(A,B)的大小(有符号数)，并返回最大值 A在寄存器esi中，B在寄存器edi中
MAX1 proc
	mov		eax, esi
	cmp		eax, edi
	jge		AisLarger
	mov		eax, edi  ;否则B更大，把B放入eax寄存器中并返回i
AisLarger:
	ret		;返回值在寄存器eax中
MAX1 endp

;比较MAX2(A,B)的大小(无符号数)，并返回最大值 A在寄存器esi中，B在寄存器edi中
MAX2 proc
	mov		eax, esi
	cmp		eax, edi
	jae		AisLarger
	mov		eax, edi  ;否则B更大，把B放入eax寄存器中并返回i
AisLarger:
	ret		;返回值在寄存器eax中
MAX2 endp	

sign_of_num proc
	xor eax, eax
	test value, 80000000H
	jnz Label1
	mov eax, 1 
Label2:
	ret
Label1:
	mov eax,-1
	jmp Label2
sign_of_num endp

main proc
	invoke	scanf, offset in_, offset a, offset b
	mov		esi, a  ;将a b值放入寄存器esi edi中 作为形参传给函数MAX1
	mov		edi, b
	invoke	MAX1
	invoke	printf, offset out_, a, b, eax
	invoke	MAX2
	invoke	printf, offset out_, a, b, eax
	invoke	sign_of_num
	invoke	printf, offset out2_, eax
	ret
main endp
end main