.386
.model flat, stdcall
option casemap: none

includelib msvcrt.lib
; ����Ҫʹ�õ� printf �� scanf ����
printf		proto C :dword, :vararg
scanf		proto C :dword, :vararg

.stack		4096	; ����ջ�Ĵ�СΪ4KB

.data
	dArray	sdword	20, 15, 70, 30, 32, 89, 12, 0, 1, 13
	Items	equ		($-dArray)/4				;�������鳤��
	szFmt	byte	'dArray[%d] = %d', 0Ah, 0
.code

main proc
	
	mov		ecx, Items-1						; �ڲ�ѭ�����ƣ�ͬʱ����Loopѭ��
	
Cycle_outer:
	xor		esi, esi							; ����ȡ����Ԫ�ص��±ꡣÿ���ڲ�ѭ��ʱ����ʼ��Ϊ0
	xor		edx, edx							; �Ƿ��������ı�ʶ
Cycle_inner:
	mov		eax, dArray[esi*4]
	mov		ebx, dArray[esi*4+4]				
	cmp		eax, ebx
	jle		L1									; С�ڵ�����������������
	;���н���
	mov		dArray[esi*4], ebx
	mov		dArray[esi*4+4], eax
	or		edx, 1								; ����ѭ�������˽������򽫱�ʶ��Ϊ1
L1:
	inc		esi
	cmp		esi, ecx
	jb		Cycle_inner
	test	edx, edx
	jz		Print			;����ʶΪ0��δ����������ѭ������
	loop	Cycle_outer
Print:
	xor		esi, esi
Next:
	invoke	printf, offset szFmt, esi, dArray[esi*4]
	inc		esi
	cmp		esi, Items
	jb		Next
	ret 
main endp
end main