.386
.model flat, stdcall
option casemap: none

includelib msvcrt.lib

; ����Ҫʹ�õ� printf,scanf,strlen ����
	printf		proto	C :dword, :vararg
	scanf		proto	C :ptr sbyte, :vararg
	strlen		proto	C :dword
.stack		4096	; ����ջ�Ĵ�СΪ4KB

.data
	szMsg		byte	'������������������', 0ah, 0
	szScanf		byte	'%s',0				; ������ָ�ʽ
	szPrint		byte	'%s * %s = %s', 0ah, 0
	szNumInfo		byte	'num%d : ',0
	num1		byte	1000 dup(0)		; ��������
	num2		byte	1000 dup(0)
	num			byte	2000 dup(0)		; ��Ž��
.code
	;----------------------------------------
	; ȥ���ַ�������ͷ�����0
	str_re_head0	proc	C	str_:ptr dword
			local	len:dword
			invoke	strlen, str_
			mov		len, eax
			xor		esi, esi
			mov		ebx, str_			; ebx �д洢������׵�ַ
			jmp		CMP1				
		Cycle1:
			mov		al, byte ptr[ebx][esi]
			cmp		al, '0'
			jnz		OUT1				; ������һ����'0'�ַ�����ѭ��
			inc		esi
		CMP1:
			cmp		esi, len
			jl		Cycle1				; esi < len
		OUT1:
			test	esi, esi			; 
			jz		OUT3				; ����ͷû��0����ֱ������
			cmp		esi, len			;
			jz		OUT2				; ��ȫΪ0 
			sub		len, esi			; len -= esi
			xor		ecx, ecx
			jmp		CMP2
		Cycle2:
			mov		edi, ecx
			add		edi, esi
			mov		al, byte ptr[ebx][edi]
			mov		edi, ecx
			mov		byte ptr[ebx][edi], al		; num[ecx]=num[ecx+esi];
			inc		ecx
		CMP2:
			cmp		ecx, len
			jl		Cycle2						; ecx < len
			mov		edi, ecx
			mov		byte ptr[ebx][edi], 0		; num[ecx]=0		
		OUT3:
			ret
		OUT2:									; ȫΪ0ʱ��ֻ��һ��Ϊ0
			mov		byte ptr[ebx][0], '0'
			mov		byte ptr[ebx][1], 0
			ret
	str_re_head0	endp
	;----------------------------------------
	; �ַ�����ת����, ����ջ���ַ������з�ת
	str_reverse		proc	C   str_:ptr dword
		xor		ecx, ecx	; ecx��ʼ��Ϊ0�����Լ�¼�ַ����ĳ���
		mov		ebx, str_	; �ַ������ʼ��ַ
		jmp		T
	L1:
		push	eax			; �ַ���ջ
		inc		ebx			; ����ָ��
		inc		ecx			; ��¼�ַ����ĳ���
	T:
		mov		al,byte ptr[ebx]	; ������ȡ��һ���ַ�
		test	al, al
		jnz		L1					; ��Ϊ 0 ���������ַ����ַ�����ջ���

		test	ecx, ecx	; ���ж��ַ����Ƿ�Ϊ��
		jz		Doop		; ��Ϊ���ַ���ֱ�ӷ���
		mov		ebx, str_	; �ǿ�����г�ջ���õ�������ַ���
	L2:
		pop		eax			; ��ջ��ȡ��һ���ַ�
		mov		byte ptr[ebx], al
		inc		ebx			; ����ָ��
		loop	L2
	Doop:
		ret 
	str_reverse		endp
	;----------------------------------------
	big_data_multiply	proc	C	str_num1:ptr dword, str_num2:ptr dword, str_num:ptr dword
		; ----------------------------------------------  ; �ֲ���������
		local	mul_cf:dword		; �˷���λ�����Ա��水λ��˺�Ľ�λ
		local	add_cf:dword		; �ӷ���λ�����Ա��潫�˵Ľ���ӵ�num��ʱ�����Ľ�λ
		local	mol_:dword			; �洢mul%10 ���м����
		local	mul_:dword			; �洢n1*n2+mul_cf���м����
		local	n1,n2,nn:dword		; n1=num1[i] n2=num2[j] n3=num[index]
		local	ten_ :dword			; ���Գ�10�ĳ���
		local	i, j, index:dword	; ��������������±�
		; ----------------------------------------------
		mov		eax, 10
		mov		ten_, eax				; ��ʼ���ֲ�����ten = 10,��Ϊ����
		mov		mul_cf, 0				; ��һ������ʱ �˷���ӷ���λ��Ϊ��
		mov		add_cf, 0
		; ----------------------------------------------
		; ���ж��Ƿ���һ������Ϊ0, ������ֱ�ӷ��� 0 
		mov		ebx, str_num1
		mov		al, byte ptr [ebx]		; ȡ��num1�ĵ�һ���ַ�
		cmp		al, '0'
		jz		zeroJudge				; ��num1=0 ֱ�ӷ��� 0
		mov		ebx, str_num2			
		mov		al, byte ptr [ebx]		; �ж�num2 �Ƿ�Ϊ0 
		cmp		al, '0'				
		jnz		Start					
	zeroJudge:
		mov		ebx, str_num
		mov		byte ptr [ebx], '0'		; ���ؽ��0
		mov		eax, str_num
		ret
		; --------------------------------------------------
		; �����￪ʼ��������㷨
		; ˼·: ��num1 ��ȡ��һ��������num2�е�ÿ��������ˣ���ʱ����˵ĵĽ�����µ�����num��
		; ���ݳ˷���ԭ����i��ѭ��ʱ����Ҫ�ӵ�iλ��ʼ����num����֮���ֵ
		; ���������Ǵӵ�λ��ʼ�������ȶ�num1, num2���鷴��
		; ��õ�num����Ҳ�Ƿ���ģ����Ҫ�ٷ���һ��תΪ����
	Start:
		; �������ַ�����ת�����ڴӵ�λ��ʼ������˲����
		invoke	str_reverse, str_num1
		invoke	str_reverse, str_num2

		mov		i, 0							
		jmp		Mid_1							; ʹ�� while ѭ��������ת���ж�λ��
	Circle_num1:		; ��ѭ�� ��������num1
			sub		eax, '0'					; ASCIIת��Ϊ����
			mov		n1, eax						; n1=num1[i] - '0'
				mov		j, 0					; j=0
				jmp		Mid_2					; ʹ��while ѭ��������ת���ж�λ��
		;---------------------------------------------------------------------------------------------
		Circle_num2:	; ��ѭ��������num2 ��num1�е�n1��num2�е�ÿһλ��ˣ�����ʱ���������num������
				sub		eax, '0'
				mov		n2, eax					; n2 = num2[j] - '0'
				mov		eax, n1
				mul		n2						; eax=n1*n2	�� eax= num[i]*num[j] (��ת��Ϊ����)
				add		eax, mul_cf				; �˷�ʱ����Դ��������������˵Ľ��n1*n2�Լ��˷���λmul_cf
				mov		mul_, eax				; mul_= num1[i]*num2[j]+mul_cf
				xor		edx, edx				; ���ʱ����32λ����չ
				div		ten_					; edx:eax/10
				mov		mul_cf, eax				; mul_cf= mul_ / 10 ���³˷���λ
				mov		mol_, edx				; mol_= mul_ % 10	����ȡģֵ

				mov		ebx, str_num
				mov		esi, index
				mov		al, byte ptr [ebx][esi]	; eax=num[index], ȡ��nn
				test	eax, eax					; ��һ�����жϴ�num������ȡ���������ֻ��ǿ�
				jz		zero_1						; �����ַ�������Ҫת��Ϊ����
				sub		eax, '0'
			zero_1:
				mov		nn, eax						; nn=(num[ii]=='\0')? 0:(num[ii]-'0');

				mov		eax, nn						; ����num[index]ֵ����Դ������
				add		eax, mol_					; num[index]�����ӷ���λadd_cf��˷���λmol_
				add		eax, add_cf					; eax=nn+mol_+add_cf 

				xor		edx, edx
				div		ten_						; edx:eax /10
				mov		add_cf, eax					; add_cf=(nn+mul%10+add_cf)/10; ���¼ӷ���λ
				add		edx, '0'					; ����ת��Ϊ�ַ���
				mov		ebx, str_num
				mov		esi, index
				mov		byte ptr [ebx][esi], dl		; ����num[index]
				inc		index						; index����
			Mid_2:
				mov		ebx, str_num2
				mov		esi, j
				mov		al, byte ptr [ebx][esi]		; al=num2[j]���Ĵ�����ַѰַ
				inc		j							; j++
				test	eax, eax
				jnz		Circle_num2					; �������ѭ��
		;---------------------------------------------------------------------------------------------
				jmp		Mid_12	; ʹ��while ѭ��������ת���ж�λ��
		Remainder:				; �����н�λλ������ѭ��ֱ����λλΪ0��ͬʱ��һ��ѭ����mul_cf��add_cf������
				mov		ebx, str_num
				mov		esi, index
				mov		al, byte ptr [ebx][esi]		; eax=num[index]
				test	eax, eax					; 
				jz		zero_2
				sub		eax, '0'
			zero_2:
				mov		nn, eax					; nn=(num[ii]=='\0')? 0:(num[ii]-48);

				mov		eax, nn
				add		eax, add_cf
				add		eax, mul_cf				; eax = nn+add_cf+mul_cf
				xor		edx, edx
				div		ten_					;
				mov		add_cf, eax				; add_cf=(nn+add_cf+mul_cf)/10;
				add		edx, '0'
				mov		ebx, str_num
				mov		esi, index
				mov		byte ptr [ebx][esi], dl	;num[index++]=(nn+add_cf+mul_cf)%10+48;
				inc		index
				mov		mul_cf, 0
			Mid_12:
				mov		eax, add_cf
				or		eax, mul_cf
				test	eax, eax				
				jnz		Remainder				; ���н�λ������ѭ��
		;---------------------------------------------------------------------------------------------
		Mid_1:
			mov		esi, i
			mov		index, esi					; index=i, ��i��ѭ���ʹӵ�iλ��ʼ����num
			mov		ebx, str_num1
			mov		al, byte ptr [ebx][esi]		; al=num1[i], �Ĵ�����ַѰַ
			inc		i							; i++
			test	al, al
			jnz		Circle_num1					; ��0����ѭ��

		invoke	str_reverse, str_num1
		invoke	str_reverse, str_num2
		invoke	str_reverse, str_num

		ret
	big_data_multiply	endp
	;----------------------------------------
	main		proc
			; ��������ʮ��������
			invoke	printf, offset szNumInfo, 1
			invoke	scanf, offset szScanf, offset num1
			invoke	printf, offset szNumInfo, 2
			invoke	scanf, offset szScanf, offset num2
			; �������ַ��������д���ȥ����ͷ��0�Լ��ظ���0
			invoke	str_re_head0, offset num1
			invoke	str_re_head0, offset num2
			; ���
			invoke	big_data_multiply,offset num1,offset num2,offset num
			; ��ӡ���
			invoke	printf, offset szPrint, offset num1, offset num2, offset num
			ret
	main		endp
	end main