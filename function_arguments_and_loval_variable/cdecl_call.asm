.386
.model flat, stdcall
includelib msvcrt.lib

printf		proto C :dword, :vararg
scanf		proto C :ptr sbyte, :vararg

.data		; ������

szFmt		byte		"%d - %d = %d", 0ah, 0
szFmt2		byte		"z = %d", 0ah, 0
szFmt3		byte		"z = %x", 0ah, 0
x			dword		?
y			sdword		?
z			dword		?
.code		; ������

subProc1	proc				; ����ͨ����ջ����
	push	ebp					; ����ebp�Ĵ�����ֵ
	mov		ebp, esp		
	mov		eax, dword ptr [ebp+8]		; ȡ����һ������  ������ջʱ�������󣬳�սʱ��������
	sub		eax, dword ptr [ebp+12]		; ȡ���ڶ�������
	pop		ebp					; �ָ�ebp�Ĵ�����ֵ
	ret
subProc1	endp


subProc2	proc
	push	ebp
	mov		ebp, esp
	mov		eax, dword ptr [ebp+8]
	sub		eax, dword ptr [ebp+12]
	pop		ebp
	ret	8
subProc2	endp

main		proc
	push	-20
	push	-10
	call	subProc1		;subProc1(-10, -20)
	add		esp, 8
	invoke	printf, offset szFmt, -10, -20, eax
	push	200
	push	100
	call	subProc2		;subProc2(100, 200)
	invoke	printf, offset szFmt, 100, 200, eax
	mov		x, -1
	mov		y, -1
	mov		eax, x
	add		eax, y
	mov		z, eax
	invoke	printf, offset szFmt2, z
	invoke	printf, offset szFmt3, z
	ret
main		endp
end		main