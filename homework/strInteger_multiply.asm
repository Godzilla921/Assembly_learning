.386
.model flat, stdcall
option casemap: none

includelib msvcrt.lib

; 声明要使用的 printf,scanf,strlen 函数
	printf		proto	C :dword, :vararg
	scanf		proto	C :ptr sbyte, :vararg
	strlen		proto	C :dword
.stack		4096	; 定义栈的大小为4KB

.data
	szMsg		byte	'请输入两个长正整数', 0ah, 0
	szScanf		byte	'%s',0				; 输出数字格式
	szPrint		byte	'%s * %s = %s', 0ah, 0
	szNumInfo		byte	'num%d : ',0
	num1		byte	1000 dup(0)		; 两个乘数
	num2		byte	1000 dup(0)
	num			byte	2000 dup(0)		; 存放结果
.code
	;----------------------------------------
	; 去除字符整数开头输入的0
	str_re_head0	proc	C	str_:ptr dword
			local	len:dword
			invoke	strlen, str_
			mov		len, eax
			xor		esi, esi
			mov		ebx, str_			; ebx 中存储数组的首地址
			jmp		CMP1				
		Cycle1:
			mov		al, byte ptr[ebx][esi]
			cmp		al, '0'
			jnz		OUT1				; 遇到第一个非'0'字符跳出循环
			inc		esi
		CMP1:
			cmp		esi, len
			jl		Cycle1				; esi < len
		OUT1:
			test	esi, esi			; 
			jz		OUT3				; 若开头没有0，则直接跳过
			cmp		esi, len			;
			jz		OUT2				; 若全为0 
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
		OUT2:									; 全为0时，只留一个为0
			mov		byte ptr[ebx][0], '0'
			mov		byte ptr[ebx][1], 0
			ret
	str_re_head0	endp
	;----------------------------------------
	; 字符串反转函数, 利用栈对字符串进行反转
	str_reverse		proc	C   str_:ptr dword
		xor		ecx, ecx	; ecx初始化为0，用以记录字符串的长度
		mov		ebx, str_	; 字符数组初始地址
		jmp		T
	L1:
		push	eax			; 字符入栈
		inc		ebx			; 更新指针
		inc		ecx			; 记录字符串的长度
	T:
		mov		al,byte ptr[ebx]	; 从数组取出一个字符
		test	al, al
		jnz		L1					; 若为 0 及遇到空字符，字符串入栈完毕

		test	ecx, ecx	; 先判断字符串是否为空
		jz		Doop		; 若为空字符串直接返回
		mov		ebx, str_	; 非空则进行出栈，得到反序的字符串
	L2:
		pop		eax			; 从栈中取出一个字符
		mov		byte ptr[ebx], al
		inc		ebx			; 更新指针
		loop	L2
	Doop:
		ret 
	str_reverse		endp
	;----------------------------------------
	big_data_multiply	proc	C	str_num1:ptr dword, str_num2:ptr dword, str_num:ptr dword
		; ----------------------------------------------  ; 局部变量定义
		local	mul_cf:dword		; 乘法进位，用以保存按位相乘后的进位
		local	add_cf:dword		; 加法进位，用以保存将乘的结果加到num中时产生的进位
		local	mol_:dword			; 存储mul%10 的中间变量
		local	mul_:dword			; 存储n1*n2+mul_cf的中间变量
		local	n1,n2,nn:dword		; n1=num1[i] n2=num2[j] n3=num[index]
		local	ten_ :dword			; 用以除10的常量
		local	i, j, index:dword	; 遍历三个数组的下标
		; ----------------------------------------------
		mov		eax, 10
		mov		ten_, eax				; 初始化局部变量ten = 10,作为除数
		mov		mul_cf, 0				; 第一次运算时 乘法与加法进位均为零
		mov		add_cf, 0
		; ----------------------------------------------
		; 先判断是否有一个数字为0, 若是则直接返回 0 
		mov		ebx, str_num1
		mov		al, byte ptr [ebx]		; 取出num1的第一个字符
		cmp		al, '0'
		jz		zeroJudge				; 若num1=0 直接返回 0
		mov		ebx, str_num2			
		mov		al, byte ptr [ebx]		; 判断num2 是否为0 
		cmp		al, '0'				
		jnz		Start					
	zeroJudge:
		mov		ebx, str_num
		mov		byte ptr [ebx], '0'		; 返回结果0
		mov		eax, str_num
		ret
		; --------------------------------------------------
		; 从这里开始整数相乘算法
		; 思路: 从num1 中取出一个整数与num2中的每个数字相乘，及时将相乘的的结果更新到数组num中
		; 根据乘法的原理，第i次循环时，需要从第i位开始更新num数组之后的值
		; 由于数字是从低位开始处理，故先对num1, num2数组反序
		; 求得的num数组也是反序的，最后要再反序一次转为正序
	Start:
		; 将两个字符串反转，便于从低位开始进行相乘并求和
		invoke	str_reverse, str_num1
		invoke	str_reverse, str_num2

		mov		i, 0							
		jmp		Mid_1							; 使用 while 循环，先跳转到判断位置
	Circle_num1:		; 外循环 遍历数组num1
			sub		eax, '0'					; ASCII转化为整数
			mov		n1, eax						; n1=num1[i] - '0'
				mov		j, 0					; j=0
				jmp		Mid_2					; 使用while 循环，先跳转到判断位置
		;---------------------------------------------------------------------------------------------
		Circle_num2:	; 内循环，遍历num2 用num1中的n1与num2中的每一位相乘，并及时将结果加入num数组中
				sub		eax, '0'
				mov		n2, eax					; n2 = num2[j] - '0'
				mov		eax, n1
				mul		n2						; eax=n1*n2	即 eax= num[i]*num[j] (已转化为整数)
				add		eax, mul_cf				; 乘法时，来源有两个，数字相乘的结果n1*n2以及乘法进位mul_cf
				mov		mul_, eax				; mul_= num1[i]*num2[j]+mul_cf
				xor		edx, edx				; 相除时，高32位零扩展
				div		ten_					; edx:eax/10
				mov		mul_cf, eax				; mul_cf= mul_ / 10 更新乘法进位
				mov		mol_, edx				; mol_= mul_ % 10	更新取模值

				mov		ebx, str_num
				mov		esi, index
				mov		al, byte ptr [ebx][esi]	; eax=num[index], 取出nn
				test	eax, eax					; 这一步是判断从num数组中取出的是数字还是空
				jz		zero_1						; 若是字符数字需要转化为整数
				sub		eax, '0'
			zero_1:
				mov		nn, eax						; nn=(num[ii]=='\0')? 0:(num[ii]-'0');

				mov		eax, nn						; 更新num[index]值的来源有三个
				add		eax, mol_					; num[index]本身，加法进位add_cf与乘法余位mol_
				add		eax, add_cf					; eax=nn+mol_+add_cf 

				xor		edx, edx
				div		ten_						; edx:eax /10
				mov		add_cf, eax					; add_cf=(nn+mul%10+add_cf)/10; 更新加法进位
				add		edx, '0'					; 整数转化为字符串
				mov		ebx, str_num
				mov		esi, index
				mov		byte ptr [ebx][esi], dl		; 更新num[index]
				inc		index						; index更新
			Mid_2:
				mov		ebx, str_num2
				mov		esi, j
				mov		al, byte ptr [ebx][esi]		; al=num2[j]，寄存器变址寻址
				inc		j							; j++
				test	eax, eax
				jnz		Circle_num2					; 非零继续循环
		;---------------------------------------------------------------------------------------------
				jmp		Mid_12	; 使用while 循环，先跳转到判断位置
		Remainder:				; 若仍有进位位，则处理循环直至进位位为0，同时下一轮循环的mul_cf与add_cf已清零
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
				jnz		Remainder				; 仍有进位，继续循环
		;---------------------------------------------------------------------------------------------
		Mid_1:
			mov		esi, i
			mov		index, esi					; index=i, 第i次循环就从第i位开始更新num
			mov		ebx, str_num1
			mov		al, byte ptr [ebx][esi]		; al=num1[i], 寄存器变址寻址
			inc		i							; i++
			test	al, al
			jnz		Circle_num1					; 非0继续循环

		invoke	str_reverse, str_num1
		invoke	str_reverse, str_num2
		invoke	str_reverse, str_num

		ret
	big_data_multiply	endp
	;----------------------------------------
	main		proc
			; 输入两个十进制整数
			invoke	printf, offset szNumInfo, 1
			invoke	scanf, offset szScanf, offset num1
			invoke	printf, offset szNumInfo, 2
			invoke	scanf, offset szScanf, offset num2
			; 对两个字符整数进行处理，去除开头的0以及重复的0
			invoke	str_re_head0, offset num1
			invoke	str_re_head0, offset num2
			; 相乘
			invoke	big_data_multiply,offset num1,offset num2,offset num
			; 打印结果
			invoke	printf, offset szPrint, offset num1, offset num2, offset num
			ret
	main		endp
	end main