.386
.model flat, stdcall
option casemap: none

includelib msvcrt.lib
; ����Ҫʹ�õ� printf �� scanf ����
printf		proto C :dword, :vararg
scanf		proto C :dword, :vararg

.stack		4096	; ����ջ�Ĵ�СΪ4KB

.data

Fmt		sbyte		'sum=%d', 0ah, 0
SUM		sdword		?

.code

main proc
	mov		ecx, 100		; ����ѭ������
	xor		eax, eax		; ��¼��͵�ֵ

L1:
	add		eax, ecx		; ��100 �ӵ�1
	loop	L1				; ʹ��loop �������ض�������ѭ��

	mov		SUM, eax
	invoke	printf, offset Fmt, SUM
	ret
main endp
end main