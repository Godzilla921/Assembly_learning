.386
.model flat, stdcall
option casemap: none

includelib msvcrt.lib

printf		proto C :dword, :vararg
scanf		proto C :dword, :vararg


.data

in_		byte	'%d %d',0
out_	byte	'max(%d,%d)=%d', 0ah, 0
out2_	byte	'sign=%d', 0ah, 0
a		sdword	?
b		sdword	?
value	sdword  -1
.code

;�Ƚ�MAX1(A,B)�Ĵ�С(�з�����)�����������ֵ A�ڼĴ���esi�У�B�ڼĴ���edi��
MAX1 proc
	mov		eax, esi
	cmp		eax, edi
	jge		AisLarger
	mov		eax, edi  ;����B���󣬰�B����eax�Ĵ����в�����i
AisLarger:
	ret		;����ֵ�ڼĴ���eax��
MAX1 endp

;�Ƚ�MAX2(A,B)�Ĵ�С(�޷�����)�����������ֵ A�ڼĴ���esi�У�B�ڼĴ���edi��
MAX2 proc
	mov		eax, esi
	cmp		eax, edi
	jae		AisLarger
	mov		eax, edi  ;����B���󣬰�B����eax�Ĵ����в�����i
AisLarger:
	ret		;����ֵ�ڼĴ���eax��
MAX2 endp	

sign_of_num proc
	xor eax, eax
	test value, 80000000H
	jnz Label1
	mov eax, 1 
Label2:
	ret
Label1:
	mov eax,-1
	jmp Label2
sign_of_num endp

main proc
	invoke	scanf, offset in_, offset a, offset b
	mov		esi, a  ;��a bֵ����Ĵ���esi edi�� ��Ϊ�βδ�������MAX1
	mov		edi, b
	invoke	MAX1
	invoke	printf, offset out_, a, b, eax
	invoke	MAX2
	invoke	printf, offset out_, a, b, eax
	invoke	sign_of_num
	invoke	printf, offset out2_, eax
	ret
main endp
end main