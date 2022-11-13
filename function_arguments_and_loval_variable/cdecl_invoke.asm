.386
.model flat, stdcall
includelib msvcrt.lib

printf		proto C :dword, :vararg
scanf		proto C :ptr sbyte, :vararg

.data		; 数据区

szFmt		byte		"%d - %d = %d", 0ah, 0

.code		; 代码区

;----------注意，子程序中不能随意修改ebx寄存器的值*****，若必须修改可以利用堆栈存储(push ebx ---- pop ebx)
subProc1	proc	C		a:dword, b:dword		; 使用C规则
	mov		eax, a									; 取出第一个参数
	sub		eax, b									; 取出第二个参数
	ret												; 返回值a-b 在寄存器eax中
subProc1	endp


subProc2	proc	stdcall	a:dword, b:dword		; 使用stdcall规则
	mov		eax, a
	sub		eax, b
	ret
subProc2	endp

main		proc
	invoke	subProc1, 20, 10
	invoke	printf, offset szFmt, 20, 10, eax
	invoke	subProc2, 200, 100
	invoke	printf, offset szFmt, 200 ,100, eax
	ret
main		endp
end		main