.386
.model flat, stdcall
option casemap: none

includelib msvcrt.lib
; 声明要使用的 printf 与 scanf 函数
printf		proto C :dword, :vararg
scanf		proto C :dword, :vararg

.stack		4096	; 定义栈的大小为4KB

.data
	dArray	sdword	20, 15, 70, 30, 32, 89, 12, 0, 1, 13
	Items	equ		($-dArray)/4				;计算数组长度
	szFmt	byte	'dArray[%d] = %d', 0Ah, 0
.code

main proc
	
	mov		ecx, Items-1						; 内层循环控制，同时用作Loop循环
	
Cycle_outer:
	xor		esi, esi							; 用以取数组元素的下标。每次内层循环时都初始化为0
	xor		edx, edx							; 是否发生交换的标识
Cycle_inner:
	mov		eax, dArray[esi*4]
	mov		ebx, dArray[esi*4+4]				
	cmp		eax, ebx
	jle		L1									; 小于等于则跳过交换步骤
	;进行交换
	mov		dArray[esi*4], ebx
	mov		dArray[esi*4+4], eax
	or		edx, 1								; 若内循环发生了交换，则将标识置为1
L1:
	inc		esi
	cmp		esi, ecx
	jb		Cycle_inner
	test	edx, edx
	jz		Print			;若标识为0则未发生交换，循环结束
	loop	Cycle_outer
Print:
	xor		esi, esi
Next:
	invoke	printf, offset szFmt, esi, dArray[esi*4]
	inc		esi
	cmp		esi, Items
	jb		Next
	ret 
main endp
end main