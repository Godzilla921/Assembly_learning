;������ hello world
.386
.model flat,stdcall
option casemap:none
; ��������д�Сд������****PROTO �� proto ���ǿ��Ե�
includelib		msvcrt.lib
printf			PROTO C :ptr sbyte, :vararg     ;print ��������
scanf           PROTO C :ptr sbyte, :vararg     ;scanf ��������
start			PROTO C							;start �����������޲��������ú�����hello.asm �ж���

.data

szMsg			sbyte		'Hello World!',0ah,0
sz_in			sbyte		'%d %d %d',0				; scanf�������ʽ
sz_out			sbyte		'a=%d b=%d d=%d', 0ah,0 ;printf�����ʽ
a				sdword		?                   ; ��������ռ˫�Ӵ��������α�����δ��ʼ�� ? ��ʾռλ
b				sdword		?
d				sdword		?					; ����C�ڻ���б�ʾC��ʽ�����Զ������ʱ���ܶ���c

.code

main			proc
				invoke		printf, offset szMsg
				invoke		scanf, offset sz_in, offset a, offset b, offset d ;���뵽a,b,d��
				invoke		printf, offset sz_out, a, b, d
				invoke		start
				ret
main			endp
end				main