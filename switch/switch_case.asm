.386
.model flat, stdcall
option casemap: none

includelib msvcrt.lib
; ����Ҫʹ�õ� printf �� scanf ����
printf		proto C :dword, :vararg
scanf		proto C :dword, :vararg

.stack		4096	; ����ջ�Ĵ�СΪ4KB

.data

Msg1	byte	'1----create', 0ah				; �˵��ַ���
		byte	'2----update', 0ah
		byte	'3----delete', 0ah
		byte	'4----print',  0ah
		byte	'5----quit', 0ah, 0

Msg2	byte	'input select:', 0ah, 0			; ��ʾ�ַ���
Fmt		byte	'%d', 0							; scanf�ĸ�ʽ�ַ���
op		dword	?								; �û����������

Msg3	byte	'Error!', 0ah, 0					; ����������ʾ���ַ���

MsgC	db		'create a File', 0ah, 0ah , 0	; ѡ��˵�1����ʾ���ַ���
MsgU	db		'update a File', 0ah, 0ah , 0	; ѡ��˵�1����ʾ���ַ���
MsgD	db		'delete a File', 0ah, 0ah , 0	; ѡ��˵�1����ʾ���ַ���
MsgP	db		'print a File', 0ah, 0ah , 0	; ѡ��˵�1����ʾ���ַ���
MsgQ	db		'quit', 0ah, 0					; ѡ��˵�1����ʾ���ַ���

JmpLap	dword	offset CR						; ��ת��, ���������ת�ĵ�ַ
		dword	offset UP						; ��ʵ������������ֱ�Ӳ�����ת��ַ
		dword	offset DE
		dword	offset PR
		dword	offset QU

.code

main:
	invoke	printf, offset Msg1					; ��ӡ�˵�
Rdkb:
	invoke	printf, offset Msg2					; ��ʾ��ʾ��Ϣ
	invoke	scanf,  offset Fmt, offset op		; �����û�����
	cmp		op, 1
	jb		Beep								; �����1 С�����Ϸ�
	cmp		op, 5
	ja		Beep								; �����5 �󣬲��Ϸ�
	mov		ebx, op
	dec		ebx									; �����������ת��Ϊ��ת�������
	mov		eax, JmpLap[ebx*4]					; �õ������ַ
	jmp		eax

Beep:
	invoke	printf, offset Msg3					; ��ʾ�������
	jmp		Rdkb
CR:
	invoke	printf,	offset MsgC
	jmp		main								; �������˵�������ִ��
UP:
	invoke	printf,	offset MsgU
	jmp		main								; �������˵�������ִ��
DE:
	invoke	printf,	offset MsgD
	jmp		main								; �������˵�������ִ��
PR:
	invoke	printf,	offset MsgP
	jmp		main								; �������˵�������ִ��
QU:
	invoke	printf,	offset MsgQ
	ret											; ����
end main