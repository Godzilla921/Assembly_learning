.386
.model flat, stdcall
option casemap: none

includelib msvcrt.lib
; ����Ҫʹ�õ� printf �� scanf ����
printf		proto	C :dword, :vararg
scanf		proto	C :ptr sbyte, :vararg

.stack		4096	; ����ջ�Ĵ�СΪ4KB

.data
	StrMsg	byte	'HELLO World!', 0


.code


; �����ַ�ڼĴ��� %ebp��
exchange_letter		proc
	; ��Сд����ת��
	mov		esi, ebp
Next:
	mov		al, [esi]
	test	al, al
	jz		L2
	cmp		al, 'A'			
	jb		L1				; ��'A' Сֱ������
	cmp		al,	'z'			
	ja		L1				; ��'z' �� ֱ������
	cmp		al,	'Z'			
	jbe		L0				; �� 'A'�� �ұ�'Z' С ����ת��
	cmp		al, 'a'
	jae		L0				; �� 'a'�� �ұ�'z' С ����ת��
	jmp		L1
L0:
	xor		al, 00100000B
	mov		[esi], al
L1:
	inc		esi
	jmp		Next
L2:
	invoke	printf, ebp
	ret
exchange_letter	endp

lower proc
	xor		esi, esi
Next:
	mov		al, StrMsg[esi]
	test	al, al
	jz		L2
	cmp		al, 'A'
	jb		L1
	cmp		al, 'Z'
	ja		L1
	add		al, 20h
	mov		StrMsg[esi], al
L1:
	inc		esi
	jmp		Next
L2:
	invoke	printf, offset StrMsg
	ret
lower endp

main	proc
	mov	ebp, offset StrMsg
	invoke	exchange_letter
	ret
main	endp
end main