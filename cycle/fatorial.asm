.386
.model flat, stdcall
option casemap: none

includelib msvcrt.lib
; ����Ҫʹ�õ� printf �� scanf ����
printf		proto C :dword, :vararg
scanf		proto C :dword, :vararg

.stack		4096	; ����ջ�Ĵ�СΪ4KB

.data

SCAN_Fmt	sbyte	'%d', 0
PRIN_Fmt	sbyte	'%d! = %d', 0ah, 0
ERROR_MSG	sbyte	'��������Ȼ��', 0ah, 0
N			sdword	?
fact		sdword	?
.code

main proc
	invoke	scanf, offset SCAN_Fmt, offset N
	mov		ecx, N
	;shl		ecx, 1				; jiang eax �� N����1λ ȥ�����λ��CF�У��ж�����ţ������ƻ�eax
	;jc		ERROR
	test	ecx, ecx				; eax&eax �Ҳ����ƻ�eax��
	js		ERROR					; ��Ϊ����ֱ����ת
	
	mov		eax, 1
	; ע�⵱����N=0ʱ��C=0 ��ʱ��ѭ������
	test	ecx, ecx	
	je		M
L1:
	imul	eax, ecx
	LOOP	L1
M:
	mov		fact, eax
	invoke	printf, offset PRIN_Fmt, N, fact
	ret
ERROR:
	invoke	printf, offset ERROR_MSG
	ret
main endp
end main