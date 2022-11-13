.386
.model flat, stdcall
includelib msvcrt.lib

printf		proto C :dword, :vararg
scanf		proto C :ptr sbyte, :vararg

.data
szStr		byte	10 dup(0)

.code
main	proc
	mov		eax, 8142
	cdq						; 对寄存器eax中的整形进行符号扩展，扩展数在edx中
	xor		ecx, ecx		; ecx 存储数据的位数
	mov		ebx, 10			; ebx 中存放除数
	jmp		L0			; 使用while循环而不是do-while循环，先进行一次判断
L1:
	inc		ecx
	div		ebx				; edx:eax / ebx
	push	edx				; 商在eax中，余数在edx中，将余数存入栈中
	cdq						; 符号位扩展
L0:
	test	eax, eax		; 判断eax 是否为0
	jnz		L1				; !=0 继续循环

	test	ecx, ecx		; 测试ecx是否为0
	jz		L3				; 为0直接跳过循环,否则ecx=0将循环max次
	lea		ebx, offset szStr
L2:
	pop		edx				; 从栈中去除一位整数到edx中
	add		dl, '0'		; 将整形数字转化为字符
	mov		[ebx], dl ;
	inc		ebx
	loop L2
L3:
	invoke	printf, offset szStr
	ret
main	endp
end	main