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
	cdq						; �ԼĴ���eax�е����ν��з�����չ����չ����edx��
	xor		ecx, ecx		; ecx �洢���ݵ�λ��
	mov		ebx, 10			; ebx �д�ų���
	jmp		L0			; ʹ��whileѭ��������do-whileѭ�����Ƚ���һ���ж�
L1:
	inc		ecx
	div		ebx				; edx:eax / ebx
	push	edx				; ����eax�У�������edx�У�����������ջ��
	cdq						; ����λ��չ
L0:
	test	eax, eax		; �ж�eax �Ƿ�Ϊ0
	jnz		L1				; !=0 ����ѭ��

	test	ecx, ecx		; ����ecx�Ƿ�Ϊ0
	jz		L3				; Ϊ0ֱ������ѭ��,����ecx=0��ѭ��max��
	lea		ebx, offset szStr
L2:
	pop		edx				; ��ջ��ȥ��һλ������edx��
	add		dl, '0'		; ����������ת��Ϊ�ַ�
	mov		[ebx], dl ;
	inc		ebx
	loop L2
L3:
	invoke	printf, offset szStr
	ret
main	endp
end	main