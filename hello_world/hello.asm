;����Windows����UI

;ģʽ����

.386
.model	flat, stdcall
option	casemap: none

;���ļ��Լ�Ҫʹ�õĺ�������
includelib		user32.lib
MessageBoxA		PROTO	:dword, :dword, :dword, :dword

;��ֵαָ��
;MessageBox		equ		<MessageBoxA>
NULL			equ		0
MB_OK			equ		0

.stack			4096

.data
SzTitle			byte	'Hi!', 0
SzMsg			byte	'Hello World!', 0

.code
start:
				invoke	MessageBoxA,
						NULL,                ; �����ڵľ��, ����ʾ�ô��ڵ�������
						offset SzMsg,		 ; ��������
						offset SzTitle,		 ; ����
						MB_OK				 ; ��Ϣ������ʾһ����ť
				ret
end				start

