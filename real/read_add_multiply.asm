.586						; 80486��ʼ����������Э���������ɵ�CPU���ڲ�
.model flat, stdcall
option casemap: none

includelib msvcrt.lib

; ����Ҫʹ�õ� printf �� scanf ����
printf		proto C :dword, :vararg
scanf		proto C :dword, :vararg

.stack		4096	; ����ջ�Ĵ�СΪ4KB

.data
	szMsg	byte	'%.3lf', 0Ah, 0
	some_szMsg	byte	'%08x', 0Ah, 0
	a		real8	3.2
	b		real8	2.6
	m		real8	7.1
	f		real8	?
	h		dword	3.
	g		dword	3
.code

main proc
	finit					; finit ΪFPUջ�Ĵ�����ʼ��
	fld		m				; fld Ϊ��������ջ
	fld		b				; b ��ջ ��ʱb�ڼĴ��� st(0)�У�m�ڼĴ��� st(1)��
	fmul	st(0), st(1)	; ����ˣ����������st(0) ��
	fld		a				; a�� st(0) m*b��st(1) m��st(2)
	fadd	st(0), st(1)	; m*b+a �� st(0) ��
	fst		f				; ��ջ�����ݱ������ڴ�f ��
	invoke	printf, offset szMsg, f
	invoke	printf, offset some_szMsg, h
	invoke	printf, offset some_szMsg, g
	ret
main endp
end main