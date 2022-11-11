.586						; 80486开始，浮点运算协处理器集成到CPU的内部
.model flat, stdcall
option casemap: none

includelib msvcrt.lib

; 声明要使用的 printf 与 scanf 函数
printf		proto C :dword, :vararg
scanf		proto C :dword, :vararg

.stack		4096	; 定义栈的大小为4KB

.data
	szMsg	byte	'%.3lf', 0Ah, 0
	some_szMsg	byte	'%08x', 0Ah, 0
	a		real8	3.2
	b		real8	2.6
	m		real8	7.1
	f		real8	?
	h		dword	3.
	g		dword	3
.code

main proc
	finit					; finit 为FPU栈寄存器初始化
	fld		m				; fld 为浮点数入栈
	fld		b				; b 入栈 此时b在寄存器 st(0)中，m在寄存器 st(1)中
	fmul	st(0), st(1)	; 浮点乘，结果保存在st(0) 中
	fld		a				; a在 st(0) m*b在st(1) m在st(2)
	fadd	st(0), st(1)	; m*b+a 在 st(0) 中
	fst		f				; 将栈顶数据保存在内存f 中
	invoke	printf, offset szMsg, f
	invoke	printf, offset some_szMsg, h
	invoke	printf, offset some_szMsg, g
	ret
main endp
end main