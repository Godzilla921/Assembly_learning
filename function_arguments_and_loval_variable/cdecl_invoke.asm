.386
.model flat, stdcall
includelib msvcrt.lib

printf		proto C :dword, :vararg
scanf		proto C :ptr sbyte, :vararg

.data		; ������

szFmt		byte		"%d - %d = %d", 0ah, 0

.code		; ������

;----------ע�⣬�ӳ����в��������޸�ebx�Ĵ�����ֵ*****���������޸Ŀ������ö�ջ�洢(push ebx ---- pop ebx)
subProc1	proc	C		a:dword, b:dword		; ʹ��C����
	mov		eax, a									; ȡ����һ������
	sub		eax, b									; ȡ���ڶ�������
	ret												; ����ֵa-b �ڼĴ���eax��
subProc1	endp


subProc2	proc	stdcall	a:dword, b:dword		; ʹ��stdcall����
	mov		eax, a
	sub		eax, b
	ret
subProc2	endp

main		proc
	invoke	subProc1, 20, 10
	invoke	printf, offset szFmt, 20, 10, eax
	invoke	subProc2, 200, 100
	invoke	printf, offset szFmt, 200 ,100, eax
	ret
main		endp
end		main