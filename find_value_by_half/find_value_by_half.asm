.386
.model flat, stdcall
option casemap: none

includelib msvcrt.lib

printf		proto C :dword, :vararg
scanf		proto C :dword, :vararg

.stack		4096

.data

sz_scanf_format		sbyte	'%d', 0
sz_printf_num		sbyte	'%d', 0ah, 0
sz_printf_success	sbyte	'成功找到array[%d]=%d, 花费%d次', 0ah, 0
sz_printf_value		sbyte	'array[%d]=%d', 0ah, 0
sz_printf_error		sbyte	'未找到%d', 0ah	,0
; 为数组分配内容 已经排好序了,共十个数据
array		sdword	4,8,8,10,23,43,57,89,99,120
Items		equ		($-array)/4		;统计数组中元素的个数

Value		sdword	?   ;需要查找的值
Index		sdword	?	;该元素在数组中的序号
Count		sdword	?	;总共查找的次数
.code

;打印数组函数 show_array
show_array proc
	mov		ecx, Items		; ecx 寄存器中放置循环的总次数
	xor		ebx, ebx			; ebx 为用来访问数组的下标，使用前先清零
L1:
	mov			eax, array[ebx*4]	;采用比例变址寻址方式
	push		ecx					; 存储ecx yu ebx
	push		ebx
	; 注意调用其他程序后可能会改变寄存器的值，需要将寄存器的值现存入栈，子程序执行结束后在pop出来
	invoke		printf, offset sz_printf_value, ebx, eax
	pop			ebx
	pop			ecx
	inc		ebx				; ebx++
	loop		L1
	ret
show_array endp

; 折半查找算法 要查找的值在Value中
find_value_by_half proc
	mov		Index, -1		;赋初值，未找到
	mov		Count, 0		;初始化查找次数为0
	mov		esi, 0			;初始的查找下界为0
	mov		edi, Items-1	;初始的查找上界为Items-1
	mov		eax, Value		;需要查找的值在寄存器eax中
	;开始执行折半查找
Compare:
	cmp		esi, edi
	jg		NotFound		;下界大于上界，未找到
	inc		Count
	mov		ebx, esi
	add		ebx, edi		;ebx=esi+edi
	sar		ebx, 1			;ebx/=2 算术右移/逻辑右移 都可以
	cmp		eax, array[ebx*4] ;中间值与Value比较
	jz		Found			;找到
	jg		MoveLow			;Value 更大，更新下届
	;jl的情况，更新上界
	mov		edi, ebx
	dec		edi				;上界已比较过，上界减去1
	jmp		Compare
MoveLow:
	mov		esi,ebx			
	inc		esi				;下界已比较过，下界减去1
	jmp		Compare
Found:
	mov		Index, ebx
	invoke	printf, offset sz_printf_success, Index, Value, Count
	ret
NotFound:
	invoke	printf, offset sz_printf_error, Value
	ret
find_value_by_half endp

main proc
	invoke	printf, offset sz_printf_num, Items
	invoke	show_array
	mov		ecx, 5
L1:
	push	ecx
	invoke	scanf,	offset sz_scanf_format,	offset Value ;输入需要查找的值 
	invoke	find_value_by_half
	pop		ecx
	loop	L1
	ret 
main endp
end main