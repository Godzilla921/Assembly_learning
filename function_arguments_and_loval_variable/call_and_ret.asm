.386
.model flat, stdcall
includelib msvcrt.lib

printf		proto C :dword, :vararg
scanf		proto C :ptr sbyte, :vararg

.data		; ������

szFmt		byte		'%d + %d = %d', 0ah, 0
x			sdword		?						;�����޷���������
y			sdword		?
z			sdword		?

.code		; ������

addProc1	proc	;��ӵ����������ڼĴ��� edi, esi��, ����ֵ�� eax��
	mov		eax, edi
	add		eax, esi
	ret
addProc1	endp


addProc2	proc
	push	eax		; �洢�Ĵ���eax
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