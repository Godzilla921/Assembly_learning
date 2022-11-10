.386
.model flat, stdcall
option casemap: none

includelib msvcrt.lib

printf		proto C :dword, :vararg
scanf		proto C :dword, :vararg

.stack		4096

.data

sz_scanf_format		sbyte	'%d', 0
sz_printf_num		sbyte	'%d', 0ah, 0
sz_printf_success	sbyte	'�ɹ��ҵ�array[%d]=%d, ����%d��', 0ah, 0
sz_printf_value		sbyte	'array[%d]=%d', 0ah, 0
sz_printf_error		sbyte	'δ�ҵ�%d', 0ah	,0
; Ϊ����������� �Ѿ��ź�����,��ʮ������
array		sdword	4,8,8,10,23,43,57,89,99,120
Items		equ		($-array)/4		;ͳ��������Ԫ�صĸ���

Value		sdword	?   ;��Ҫ���ҵ�ֵ
Index		sdword	?	;��Ԫ���������е����
Count		sdword	?	;�ܹ����ҵĴ���
.code

;��ӡ���麯�� show_array
show_array proc
	mov		ecx, Items		; ecx �Ĵ����з���ѭ�����ܴ���
	xor		ebx, ebx			; ebx Ϊ��������������±꣬ʹ��ǰ������
L1:
	mov			eax, array[ebx*4]	;���ñ�����ַѰַ��ʽ
	push		ecx					; �洢ecx yu ebx
	push		ebx
	; ע����������������ܻ�ı�Ĵ�����ֵ����Ҫ���Ĵ�����ֵ�ִ���ջ���ӳ���ִ�н�������pop����
	invoke		printf, offset sz_printf_value, ebx, eax
	pop			ebx
	pop			ecx
	inc		ebx				; ebx++
	loop		L1
	ret
show_array endp

; �۰�����㷨 Ҫ���ҵ�ֵ��Value��
find_value_by_half proc
	mov		Index, -1		;����ֵ��δ�ҵ�
	mov		Count, 0		;��ʼ�����Ҵ���Ϊ0
	mov		esi, 0			;��ʼ�Ĳ����½�Ϊ0
	mov		edi, Items-1	;��ʼ�Ĳ����Ͻ�ΪItems-1
	mov		eax, Value		;��Ҫ���ҵ�ֵ�ڼĴ���eax��
	;��ʼִ���۰����
Compare:
	cmp		esi, edi
	jg		NotFound		;�½�����Ͻ磬δ�ҵ�
	inc		Count
	mov		ebx, esi
	add		ebx, edi		;ebx=esi+edi
	sar		ebx, 1			;ebx/=2 ��������/�߼����� ������
	cmp		eax, array[ebx*4] ;�м�ֵ��Value�Ƚ�
	jz		Found			;�ҵ�
	jg		MoveLow			;Value ���󣬸����½�
	;jl������������Ͻ�
	mov		edi, ebx
	dec		edi				;�Ͻ��ѱȽϹ����Ͻ��ȥ1
	jmp		Compare
MoveLow:
	mov		esi,ebx			
	inc		esi				;�½��ѱȽϹ����½��ȥ1
	jmp		Compare
Found:
	mov		Index, ebx
	invoke	printf, offset sz_printf_success, Index, Value, Count
	ret
NotFound:
	invoke	printf, offset sz_printf_error, Value
	ret
find_value_by_half endp

main proc
	invoke	printf, offset sz_printf_num, Items
	invoke	show_array
	mov		ecx, 5
L1:
	push	ecx
	invoke	scanf,	offset sz_scanf_format,	offset Value ;������Ҫ���ҵ�ֵ 
	invoke	find_value_by_half
	pop		ecx
	loop	L1
	ret 
main endp
end main