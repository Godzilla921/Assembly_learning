.386
.model flat, stdcall
option casemap: none

includelib msvcrt.lib
; ����Ҫʹ�õ� printf �� scanf ����
printf		proto C :dword, :vararg
scanf		proto C :dword, :vararg

.stack		4096	; ����ջ�Ĵ�СΪ4KB

.data

x			sdword		1,2,3,4,5,6,7,8,9,10		; ��������
y			sdword		5,4,3,2,1,10,9,8,7,6		;
len			equ			($-y)/4						; ����Ԫ�صĸ���
Rule		dword		0000000011011100B			; �߼��ߣ������������0��ʾ�ӣ�1��ʾ��
z			sdword		10 dup(?)					; �ظ�ʮ��ռλ��
msg				byte	'len=%d', 0ah, 0
prinf_sz_fmt	byte	'Z[%d]=%d', 0ah, 0

Array		dword		?

.code
; ��ӡ���麯��
; �޳��ڼĴ���esi��
printArray proc
	xor		ebx, ebx		;ebx �Ĵ�����0�� ��Ϊ����������±�
	jmp		MID
L1:
	push	esi
	push	ebx
	invoke	printf, offset prinf_sz_fmt, ebx, z[ebx*4]
	pop		ebx
	pop		esi
	inc		ebx
MID:
	cmp		ebx, esi
	jl		L1				; ebx<esiʱ����ѭ��
	ret
printArray endp

main proc
	mov		ecx, len								; �洢ѭ������
	mov		edx, Rule								;
	xor		ebx, ebx								; ��������ʱ���±�
Next:
	mov		eax, x[ebx*4]							; ��x��ȡ����ebx ����
	shr		edx, 1									; �߼�����һλ���Ƴ�λ��CF��
	jc		Subs										; CF=1	��ʾ����
	; CF=0 ��ʾ�ӷ�
	add		eax, y[ebx*4]
	jmp		Result
Subs:
	sub		eax, y[ebx*4]
Result:
	mov		z[ebx*4], eax
	inc		ebx
	loop	Next
	invoke	printf, offset	msg, len


	mov		esi, len
	invoke	printArray

	ret
main endp
end main
