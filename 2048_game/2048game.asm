.386
.model flat,stdcall
option casemap:none

includelib user32.lib
includelib kernel32.lib
includelib msvcrt.lib
include windows.inc
include user32.inc
include kernel32.inc
include	msvcrt.inc
include gdi32.inc
includelib gdi32.lib

RGB macro red,green,blue;宏定义RGB颜色
    xor eax,eax  ;eax置零
    mov ah,blue
    shl eax,8  ;左移8位
    mov ah,green
    mov al,red
endm

printf PROTO C :dword,:vararg
scanf  PROTO C :dword,:vararg
strlen PROTO C :dword

.data
hInstance dd ?  ;进程模块句柄
hWinMain  dd ?   ;窗口的句柄

;定义操作矩阵
map			dword	0, 0, 0, 0
			dword	0, 0, 0, 0
			dword	0, 0, 0, 0
			dword	0, 0, 0, 0

testmap		dword	1, 2, 3, 4
			dword	5, 6, 7, 8
			dword	9,10,11,12
			dword	13,14,15,16

mapemptyi	dword	0, 0, 0, 0
			dword	0, 0, 0, 0
			dword	0, 0, 0, 0
			dword	0, 0, 0, 0

score dd 0  ;分数
maxscore dd 0 ; 最高分数
gOver dd 0 ;是否结束表示
Data byte 10 dup(?)  ;将数转化为字符数组
hGame dd 30 dup(?)  ;窗口句柄
flag db 0 
gi dword 0 
gj dword 0
hbru HBRUSH ?  ;画刷
 
.const  ;定义一些字符串常量
szClassName db '2048game',0
szCaptionMain db '2048 game !',0

static db 'static',0 ;文本框的属性
edit db 'edit',0

EmptyText byte ' ',0
szText1 byte "    Welcome to our 2048 game!",0
szText2 byte "    You can use 'W','A','S'and 'D' as up,left,down,",0
szText3 byte "    and right to merge same blocks to get 2048!",0
szScore byte "current score",0
szMaxScore byte "max score",0
szText7 byte "Game Is Over",0
szText6 byte "2048",0

.code
;随机选取一个空块赋值2/4
randomNew       proc
                push    edx
                push    ecx
                push    esi
                ;把当前所有空位下标存入mapemptyi
                xor     eax,eax
                mov     ecx, 15
Lfindemptyi:    cmp     map[ecx*4], 0
                jne     notempty
                mov     mapemptyi[eax*4], ecx
                add     eax, 1
notempty:       sub     ecx, 1
                jge     Lfindemptyi
                mov     esi, eax                                ;总空位数 in esi
                cmp     esi, 0                                  ;若已没有空位，就不再生成新数块
                je      randNewend
                ;确定生成新数的随机空位位置
                call    GetTickCount                            ;获取系统时间到eax中
                mov     ecx,32
Lcrtrand1:      shr     eax,1
                jnc     jmpxor1 
                xor     eax,0edb88320h
jmpxor1:        loop    Lcrtrand1
                mov     ecx, esi
                xor     edx,edx
                div     ecx
                mov     eax, edx                                ;得到0~esi的随机数eax
                mov     esi, mapemptyi[eax*4]                   ;确定的插入位置 in esi
                ;确定随机生成的数值（2或4）
                call    GetTickCount
                mov     ecx,32
Lcrtrand2:      shr     eax,1
                jnc     jmpxor2 
                xor     eax,0edb88320h
jmpxor2:        loop    Lcrtrand2
                mov     ecx, 2
                xor     edx,edx
                div     ecx
                mov     eax, edx                                ;得到0~1的随机数eax
                imul    eax, 2
                add     eax, 2                                  ;eax*2+2,由0或1得到2或4
                mov     map[esi*4], eax
randNewend:     pop     esi
                pop     ecx
                pop     edx
                ret
randomNew       endp

;游戏初始化
GAME_INIT proc
    ;矩阵清零
    mov ecx,16
    mov eax,0
    Matrix_init:
        mov map[eax],0
        add eax,4
        loop Matrix_init
    ;状态清零
    mov gOver,0
	mov score,0
	invoke randomNew
	invoke randomNew
GAME_INIT endp

;	向上移动函数
up		proc
		local	now, next:dword
		local	i, j, k:dword
		local	len:dword
		local	change:dword

		mov		len, 16			; len = 4
		mov		change, 0		; 是否有合并
	;--------------------------Cycle 11
		mov		j, 0
		jmp		CMP11
	Cycle11:
	;--------------------------Cycle 12
		mov		i, 0
		jmp		CMP12
	Cycle12:
		mov		ebx, i
		mov		esi, j
		mov		eax, map[ebx*4][esi]
		mov		now, eax				; now=map[i][j]
		test	eax, eax
		jz		NEXT11					; now == 0，直接跳过
	;--------------------------Cycle 13
		mov		ecx, i
		add		ecx, 4
		mov		k, ecx					; k = i+1
		jmp		CMP13
	Cycle13:		; 寻找第一个非零整数next 若next==0 则合并
		mov		ebx, k
		mov		esi, j
		mov		eax, map[ebx*4][esi]	
		mov		next, eax				; next=map[k][j]
		test	eax, eax
		jz		NEXT12					; next == 0，直接跳过
		mov		eax, now				; 否则判断next 与  now是否相等，若相等则合并
		mov		ebx, next
		cmp		eax, ebx
		jne		NEXT13					; next!=now
		mov		change, 1				; change = 1 数组有改变
		mov		eax, next
		add		score, eax				; score += next
		add		eax, eax				; eax = 2*eax
		mov		ebx, i
		mov		esi, j
		mov		map[ebx*4][esi], eax	; map[i][j]=2*next
		mov		ebx, k
		mov		map[ebx*4][esi], 0		; map[k][j]=0
	NEXT13:
		mov		k, 16					; 找到了非零数next 退出循环
	NEXT12:
		add		k, 4					; k++
	CMP13:
		mov		edx, len
		cmp		k,	 edx				; k < len
		jl		Cycle13
	;--------------------------Cycle 13
	NEXT11:
		add		i, 4					; i++
	CMP12:
		mov		edx, len
		cmp		i,	 edx		 
		jl		Cycle12					; i < len
	;--------------------------Cycle 12
		add		j, 4					; j++	
	CMP11:
		mov		edx, len
		cmp		j,	 edx		
		jl		Cycle11					; j < len
	;--------------------------Cycle 11

	;;-----------------------------------------------------
	;--------------------------Cycle 21
		mov		j, 0
		jmp		CMP21
	Cycle21:
	;--------------------------Cycle 22
		mov		i, 0
		jmp		CMP22
	Cycle22:
		mov		ebx, i
		mov		esi, j
		mov		eax, map[ebx*4][esi]
		mov		now, eax				; now=map[i][j]
		test	eax, eax
		jnz		NEXT21					; now != 0，直接跳过，目的是找到一个0位置，与其后的第一个非零数进行替换
	;--------------------------Cycle 23
		mov		ecx, i
		add		ecx, 4
		mov		k, ecx					; k = i+1
		jmp		CMP23
	Cycle23:
		mov		ebx, k
		mov		esi, j
		mov		eax, map[ebx*4][esi]	
		mov		next, eax				; next=map[k][j]
		test	eax, eax
		jz		NEXT22					; next == 0
		mov		change, 1				; change = 1 数组有改变
		mov		eax, next
		mov		ebx, i
		mov		esi, j
		mov		map[ebx*4][esi], eax	; map[i][j]=next
		mov		ebx, k
		mov		map[ebx*4][esi], 0		; map[k][j]=0
		mov		k, 16
	NEXT22:
		add		k, 4					; k++
	CMP23:
		mov		edx, len
		cmp		k,	 edx				; k < len
		jl		Cycle23
	;--------------------------Cycle 23
	NEXT21:
		add		i, 4					; i++
	CMP22:
		mov		edx, len
		cmp		i,	 edx		; i < len 
		jl		Cycle22
	;--------------------------Cycle 22
		add		j, 4			; j++	
	CMP21:
		mov		edx, len
		cmp		j,	 edx		; j < len
		jl		Cycle21
	;--------------------------Cycle 21

		mov		eax, change
		ret						; return change
up		endp

;	向左移动函数
left		proc
		local	now, next:dword
		local	i, j, k:dword
		local	len:dword
		local	change:dword

		mov		len, 16			; len = 4
		mov		change, 0		; 是否有合并
		;--------------------------Cycle 11
		mov		i, 0
		jmp		CMP11
	Cycle11:
	;--------------------------Cycle 12
		mov		j, 0
		jmp		CMP12
	Cycle12:
		mov		ebx, i
		mov		esi, j
		mov		eax, map[ebx*4][esi]
		mov		now, eax				; now=map[i][j]
		test	eax, eax
		jz		NEXT11					; now == 0
	;--------------------------Cycle 13
		mov		ecx, j
		add		ecx, 4
		mov		k, ecx					; k = j+1
		jmp		CMP13
	Cycle13:
		mov		ebx, i
		mov		esi, k
		mov		eax, map[ebx*4][esi]	
		mov		next, eax				; next=map[i][k]
		test	eax, eax
		jz		NEXT12					; next == 0
		mov		eax, now
		mov		ebx, next
		cmp		eax, ebx
		jne		NEXT13					; next!=now
		mov		change, 1				; change = 1 数组有改变
		mov		eax, next
		add		score, eax				; score += next
		add		eax, eax				; eax = 2*eax
		mov		ebx, i
		mov		esi, j
		mov		map[ebx*4][esi], eax	; map[i][j]=2*next
		mov		esi, k
		mov		map[ebx*4][esi], 0		; map[i][k]=0
	NEXT13:
		mov		k, 16
	NEXT12:
		add		k, 4					; k++
	CMP13:
		mov		edx, len
		cmp		k,	 edx				; k < len
		jl		Cycle13
	;--------------------------Cycle 13
	NEXT11:
		add		j, 4					; j++
	CMP12:
		mov		edx, len
		cmp		j,	 edx		; j < len 
		jl		Cycle12
	;--------------------------Cycle 12
		add		i, 4			; i++	
	CMP11:
		mov		edx, len
		cmp		i,	 edx		; i < len
		jl		Cycle11
	;--------------------------Cycle 11

	;;-----------------------------------------------------
	;--------------------------Cycle 21
		mov		i, 0
		jmp		CMP21
	Cycle21:
	;--------------------------Cycle 22
		mov		j, 0
		jmp		CMP22
	Cycle22:
		mov		ebx, i
		mov		esi, j
		mov		eax, map[ebx*4][esi]
		mov		now, eax				; now=map[i][j]
		test	eax, eax
		jnz		NEXT21					; now != 0
	;--------------------------Cycle 23
		mov		ecx, j
		add		ecx, 4
		mov		k, ecx					; k = j+1
		jmp		CMP23
	Cycle23:
		mov		ebx, i
		mov		esi, k
		mov		eax, map[ebx*4][esi]	
		mov		next, eax				; next=map[i][k]
		test	eax, eax
		jz		NEXT22					; next == 0
		mov		change, 1				; change = 1 数组有改变
		mov		eax, next
		mov		ebx, i
		mov		esi, j
		mov		map[ebx*4][esi], eax	; map[i][j]=next
		mov		esi, k
		mov		map[ebx*4][esi], 0		; map[i][k]=0
		mov		k, 16
	NEXT22:
		add		k, 4					; k++
	CMP23:
		mov		edx, len
		cmp		k,	 edx				; k < len
		jl		Cycle23
	;--------------------------Cycle 23
	NEXT21:
		add		j, 4					; j++
	CMP22:
		mov		edx, len
		cmp		j,	 edx		; j < len 
		jl		Cycle22
	;--------------------------Cycle 22
		add		i, 4			; i++	
	CMP21:
		mov		edx, len
		cmp		i,	 edx		; i < len
		jl		Cycle21
	;--------------------------Cycle 21

		mov		eax, change
		ret						; return change
left		endp

;	向右移动函数
right		proc
		local	now, next:dword
		local	i, j, k:dword
		local	len:dword
		local	change:dword

		mov		len, 16			; len = 4
		mov		change, 0		; 是否有合并
		;--------------------------Cycle 11
		mov		i, 0
		jmp		CMP11
	Cycle11:
	;--------------------------Cycle 12
		mov		j, 12			; j = 3
		jmp		CMP12
	Cycle12:
		mov		ebx, i
		mov		esi, j
		mov		eax, map[ebx*4][esi]
		mov		now, eax				; now=map[i][j]
		test	eax, eax
		jz		NEXT11					; now == 0
	;--------------------------Cycle 13
		mov		ecx, j
		sub		ecx, 4
		mov		k, ecx					; k = j-1
		jmp		CMP13
	Cycle13:
		mov		ebx, i
		mov		esi, k
		mov		eax, map[ebx*4][esi]	
		mov		next, eax				; next=map[i][k]
		test	eax, eax
		jz		NEXT12					; next == 0
		mov		eax, now
		mov		ebx, next
		cmp		eax, ebx
		jne		NEXT13					; next!=now
		mov		change, 1				; change = 1 数组有改变
		mov		eax, next
		add		score, eax				; score += next
		add		eax, eax				; eax = 2*eax
		mov		ebx, i
		mov		esi, j
		mov		map[ebx*4][esi], eax	; map[i][j]=2*next
		mov		esi, k
		mov		map[ebx*4][esi], 0		; map[i][k]=0
	NEXT13:
		mov		k, -1
	NEXT12:
		sub		k, 4					; k++
	CMP13:
		cmp		k, 0					
		jge		Cycle13					; k >= 0
	;--------------------------Cycle 13
	NEXT11:
		sub		j, 4					; j --
	CMP12:
		cmp		j,	 0				
		jge		Cycle12					; j >= 0 
	;--------------------------Cycle 12
		add		i, 4			; i++	
	CMP11:
		mov		edx, len
		cmp		i,	 edx		; i < len
		jl		Cycle11
	;--------------------------Cycle 11

	;;-----------------------------------------------------
	;--------------------------Cycle 21
		mov		i, 0
		jmp		CMP21
	Cycle21:
	;--------------------------Cycle 22
		mov		j, 12
		jmp		CMP22
	Cycle22:
		mov		ebx, i
		mov		esi, j
		mov		eax, map[ebx*4][esi]
		mov		now, eax				; now=map[i][j]
		test	eax, eax
		jnz		NEXT21					; now != 0
	;--------------------------Cycle 23
		mov		ecx, j
		sub		ecx, 4
		mov		k, ecx					; k = j-1
		jmp		CMP23
	Cycle23:
		mov		ebx, i
		mov		esi, k
		mov		eax, map[ebx*4][esi]	
		mov		next, eax				; next=map[i][k]
		test	eax, eax
		jz		NEXT22					; next == 0
		mov		change, 1				; change = 1 数组有改变
		mov		eax, next
		mov		ebx, i
		mov		esi, j
		mov		map[ebx*4][esi], eax	; map[i][j]=next
		mov		esi, k
		mov		map[ebx*4][esi], 0		; map[i][k]=0
		mov		k, -1
	NEXT22:
		sub		k, 4					; k --
	CMP23:
		cmp		k, 0					; k >= 0
		jge		Cycle23
	;--------------------------Cycle 23
	NEXT21:
		sub		j, 4			; j --
	CMP22:
		cmp		j, 0 			; j >=0 
		jge		Cycle22
	;--------------------------Cycle 22
		add		i, 4			; i++	
	CMP21:
		mov		edx, len
		cmp		i,	 edx		; i < len
		jl		Cycle21
	;--------------------------Cycle 21

		mov		eax, change
		ret						; return change
right		endp

;	向下移动函数
down		proc
		local	now, next:dword
		local	i, j, k:dword
		local	len:dword
		local	change:dword

		mov		len, 16			; len = 4
		mov		change, 0		; 是否有合并
		;--------------------------Cycle 11
		mov		j, 0
		jmp		CMP11
	Cycle11:
	;--------------------------Cycle 12
		mov		i, 12			; i = 3
		jmp		CMP12
	Cycle12:
		mov		ebx, i
		mov		esi, j
		mov		eax, map[ebx*4][esi]
		mov		now, eax				; now=map[i][j]
		test	eax, eax
		jz		NEXT11					; now == 0
	;--------------------------Cycle 13
		mov		ecx, i
		sub		ecx, 4
		mov		k, ecx					; k = i-1
		jmp		CMP13
	Cycle13:
		mov		ebx, k
		mov		esi, j
		mov		eax, map[ebx*4][esi]	
		mov		next, eax				; next=map[k][j]
		test	eax, eax
		jz		NEXT12					; next == 0
		mov		eax, now
		mov		ebx, next
		cmp		eax, ebx
		jne		NEXT13					; next!=now
		mov		change, 1				; change = 1 数组有改变
		mov		eax, next
		add		score, eax				; score += next
		add		eax, eax				; eax = 2*eax
		mov		ebx, i
		mov		esi, j
		mov		map[ebx*4][esi], eax	; map[i][j]=2*next
		mov		ebx, k
		mov		map[ebx*4][esi], 0		; map[k][j]=0
	NEXT13:
		mov		k, -1
	NEXT12:
		sub		k, 4					; k++
	CMP13:
		cmp		k, 0					
		jge		Cycle13					; k >= 0
	;--------------------------Cycle 13
	NEXT11:
		sub		i, 4					; i --
	CMP12:
		cmp		i,	 0				
		jge		Cycle12					; i >= 0 
	;--------------------------Cycle 12
		add		j, 4			; j++	
	CMP11:
		mov		edx, len
		cmp		j,	 edx		; j < len
		jl		Cycle11
	;--------------------------Cycle 11

	;;-----------------------------------------------------
	;--------------------------Cycle 21
		mov		j, 0
		jmp		CMP21
	Cycle21:
	;--------------------------Cycle 22
		mov		i, 12
		jmp		CMP22
	Cycle22:
		mov		ebx, i
		mov		esi, j
		mov		eax, map[ebx*4][esi]
		mov		now, eax				; now=map[i][j]
		test	eax, eax
		jnz		NEXT21					; now != 0
	;--------------------------Cycle 23
		mov		ecx, i
		sub		ecx, 4
		mov		k, ecx					; k = i-1
		jmp		CMP23
	Cycle23:
		mov		ebx, k
		mov		esi, j
		mov		eax, map[ebx*4][esi]	
		mov		next, eax				; next=map[k][j]
		test	eax, eax
		jz		NEXT22					; next == 0
		mov		change, 1				; change = 1 数组有改变
		mov		eax, next
		mov		ebx, i
		mov		esi, j
		mov		map[ebx*4][esi], eax	; map[i][j]=next
		mov		ebx, k
		mov		map[ebx*4][esi], 0		; map[k][j]=0
		mov		k, -1
	NEXT22:
		sub		k, 4					; k --
	CMP23:
		cmp		k, 0					; k >= 0
		jge		Cycle23
	;--------------------------Cycle 23
	NEXT21:
		sub		i, 4			; i --
	CMP22:
		cmp		i, 0 			; i >=0 
		jge		Cycle22
	;--------------------------Cycle 22
		add		j, 4			; j++	
	CMP21:
		mov		edx, len
		cmp		j,	 edx		; j < len
		jl		Cycle21
	;--------------------------Cycle 21

		mov		eax, change
		ret						; return change
down		endp

;    判断游戏是否结束
gameOver        proc
                push    esi
                push    edi
                mov     gOver, 1                                ;init gOver = true
                mov     esi, 12                                 ;i in esi, for(i=3;i>=0;i--)
Lwai:           mov     edi, 12                                 ;j in edi, for(j=3;j>=0;j--)
Lnei:           cmp     map[esi*4][edi], 0                      ;if(map[i][j] == 0), game not over
                je      gameNotOver
                cmp     esi, 1                                  ;if(i >= 1)
                jl      jmpcmp1
                mov     eax, map[esi*4][edi]
                cmp     map[esi*4-16][edi], eax                 ;if(map[i][j] == map[i-1][j]), game not over
                je      gameNotOver
jmpcmp1:        cmp     edi, 1                                  ;if(j >= 1)
                jl      jmpcmp2
                mov     eax, map[esi*4][edi]
                cmp     map[esi*4][edi-4], eax                  ;if(map[i][j] == map[i][j-1]), game not over
                je      gameNotOver
jmpcmp2:        sub     edi, 4
                jge     Lnei
                sub     esi, 4
                jge     Lwai
                jmp     gameOverEnd
gameNotOver:    mov     eax, map[esi*4][edi]
                mov     gOver, 0
gameOverEnd:    pop     edi
                pop     esi
                ret
gameOver        endp

;将数字转换成字符数组，在窗口以文本形式输出
change_to_char proc far C uses eax esi ecx,number:dword
	;保护两个寄存器不变
	push eax
	push ecx
	;清空寄存器
	xor eax,eax
	xor edx,edx
	xor ebx,ebx
	
	mov eax,number  ;被除数放到eax中
	mov ecx,10
	
	;依次压入栈
L_first:
	;ebx：number位数
	inc ebx ;eax/ecx，商在eax中，余数在edx中
	idiv ecx
	add edx,30H	;转换为字符
	push edx	;压栈
	xor edx,edx ;清零
	cmp eax,0    ;商是否为0
	jg L_first 
	mov esi,0 ; esi=0，表示第esi个字符
L_second:
	
	dec ebx 
	pop eax ;将栈中的字符出栈存到eax中
	mov byte ptr Data[esi],al
	inc esi
	cmp ebx,0
	jg L_second
	
	;循环结束，末尾赋'\0'
	mov Data[esi],0
	pop ecx
	pop eax
	ret
change_to_char endp

UpdataGame proc far C uses eax esi ecx edx,hWnd,wParam
;16个方块
	mov gi,16
	mov edx,0
Loop1:
	push edx
	;转换值
	invoke change_to_char,dword ptr map[edx*4]
	pop edx
	;设置控件中的值
	push edx
	.if Data[0] =='0'
		invoke SetWindowText,hGame[edx*4],offset EmptyText
		
	.else
		invoke SetWindowText,hGame[edx*4],offset Data
	.endif
	pop edx
	inc edx
	dec gi
	cmp gi,0
	jg Loop1
L7:
	;设置分数的值
	invoke change_to_char,score
	invoke SetWindowText,hGame[80],offset Data
	invoke change_to_char,maxscore
	invoke SetWindowText,hGame[88],offset Data
	xor eax,eax
	ret

UpdataGame endp

CreateBack proc far C uses eax esi ecx edx,hWnd
	local @hFont:HFONT
	local @logfont:LOGFONT
	
	invoke RtlZeroMemory,addr @logfont,sizeof @logfont
	mov @logfont.lfCharSet,RUSSIAN_CHARSET
	mov @logfont.lfHeight,-45
	mov @logfont.lfWeight,800
	invoke CreateFontIndirect,addr @logfont
	mov @hFont,eax

	;i=0，无条件跳转L2
	mov gi,0
	jmp L2
	
	;i++
L1:
	mov eax,gi
	add eax,1
	mov gi,eax

	;i<4?L3：L7
L2:
	cmp gi,4
	jge L7
	
	;j=0，jmp L5
L3:
	mov gj,0
	jmp L5
L4:
	;j++
	mov eax,gj
	add eax,1
	mov gj,eax

	;j<4?L6:L1
L5:
	cmp gj,4
	jge L1

	;绘制100*100的矩形框
L6:
	;eax=i*100+140，绘制的x坐标，140为起始坐标
	imul eax,gi,100
	add eax,180
	;ecx=j*100+100，绘制的y坐标，100为起始坐标
	imul ecx,gj,100
	add ecx,70

	;edx=i*4+j，表示第[i][j]个方块
	imul edx,gi,4
	add edx,gj
	push edx
	;gameMat[i][j]的值转为字符数组存到Data中，dword：*4
	invoke change_to_char,dword ptr map[edx*4]
	.IF Data[0] =='0'
		;创建静态控件，居中有边框
		invoke CreateWindowEx,NULL,offset static,offset EmptyText,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE,ecx,eax,100,100,\  
		hWnd,edx,hInstance,NULL  ;句柄为edx
	.else
		invoke CreateWindowEx,NULL,offset static,offset Data,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE or ES_READONLY,ecx,eax,100,100,\ 
		hWnd,edx,hInstance,NULL  ;句柄为edx
	.endif
	pop edx
	;存储窗口句柄，句柄返回值在eax中
	mov hGame[edx*4],eax
	;调用SendMessage改变字体
	invoke SendMessage,eax,WM_SETFONT,@hFont,4
	;push eax
	;RGB 255,235,205
	;invoke CreateSolidBrush,eax
	;mov hbru,eax
	;pop eax
	;invoke SendMessage,ebx,WM_CTLCOLORSTATIC,eax,2
	jmp L4
L7:
	;绘制游戏说明
	;push eax
	;RGB 192,192,192
	;invoke CreateSolidBrush,eax
	;mov hbru,eax
	;pop eax
	invoke CreateWindowEx,NULL,offset edit,offset szText1,\
	WS_CHILD or WS_VISIBLE OR WS_DISABLED,50,100,330,24,hWnd,16,hInstance,NULL
	MOV hGame[64],eax

	invoke CreateWindowEx,NULL,offset edit,offset szText2,\
	WS_CHILD or WS_VISIBLE OR WS_DISABLED,50,120,330,24,hWnd,17,hInstance,NULL
	mov hGame[68],eax
	
	invoke CreateWindowEx,NULL,offset edit,offset szText3,\
	WS_CHILD or WS_VISIBLE OR WS_DISABLED,50,140,330,15,hWnd,19,hInstance,NULL
	mov hGame[72],eax


	;绘制分数框
	invoke CreateWindowEx,NULL,offset edit,offset szScore,\
	WS_CHILD or WS_VISIBLE OR WS_DISABLED,280,30,100,30,hWnd,19,hInstance,NULL
	mov hGame[76],eax

	invoke change_to_char,score
	invoke CreateWindowEx,NULL,offset edit,offset Data,\
	WS_CHILD or WS_VISIBLE OR WS_DISABLED,280,45,100,15,hWnd,20,hInstance,NULL
	mov hGame[80],eax

	invoke CreateWindowEx,NULL,offset edit,offset szMaxScore,\
	WS_CHILD or WS_VISIBLE OR WS_DISABLED,400,30,100,30,hWnd,21,hInstance,NULL
	mov hGame[84],eax

	invoke change_to_char,maxscore
	invoke CreateWindowEx,NULL,offset edit,offset Data,\
	WS_CHILD or WS_VISIBLE OR WS_DISABLED,400,45,100,15,hWnd,22,hInstance,NULL
	mov hGame[88],eax
	
	invoke change_to_char,2048
	invoke CreateWindowEx,NULL,offset edit,offset Data,\
	WS_CHILD or WS_VISIBLE or SS_CENTER or SS_CENTERIMAGE,50,30,200,50,hWnd,23,hInstance,NULL
	MOV hGame[92],eax
	invoke SendMessage,eax,WM_SETFONT,@hFont,4
	xor eax,eax
	ret

CreateBack endp


_ProcWinMain proc uses ebx edi esi hWnd,uMsg,wParam,lParam ;窗口回调函数,参数分别为窗口句柄，消息类型，消息参数
	local @stPs:PAINTSTRUCT
	local @stRect:RECT
	local @hDc
	LOCAL @oldPen:HPEN
	local @hBm
	
	mov eax,uMsg  ;uMsg是消息类型，如下面的WM_PAINT,WM_CREATE

	.if eax==WM_PAINT  ;绘图消息，利用GDI图形设备接口绘图
		invoke BeginPaint,hWnd,addr @stPs
		
		mov @hDc,eax
		;invoke GetClientRect,hWnd,addr @stRect
		;invoke DrawText,@hDc,addr szText1,-1,addr @stRect,DT_SINGLELINE or DT_CENTER or DT_VCENTER
		;mov eax,@stPs.rcPaint.right
		;sub eax,@stPs.rcPaint.left
		;mov ecx,@stPs.rcPaint.bottom
		;sub ecx,@stPs.rcPaint.top
		;invoke BitBlt,@hDc,@stPs.rcPaint.left,@stPs.rcPaint.top,eax,ecx,hDcBack,@stPs.rcPaint.left,@stPs.rcPaint.top,SRCCOPY
		
		invoke EndPaint,hWnd,addr @stPs
	;----------------------------------------------------------------------------------------
	.elseif eax==WM_CLOSE  ;窗口关闭消息
		;invoke _DeleteBack
		invoke DestroyWindow,hWinMain
		invoke PostQuitMessage,NULL
	;----------------------------------------------------------------------------------------
	.elseif eax==WM_CREATE  ;创建窗口，绘制界面
		mov eax,hWnd
		mov hWinMain,eax
		RGB 210, 180,140
		invoke CreateSolidBrush,eax
		mov hbru,eax
		mov eax,hWinMain
		invoke CreateBack,hWnd

	.elseif eax==WM_CTLCOLORSTATIC
		;mov ebx,wParam
		;RGB 210, 180,140
		;invoke SetTextColor,ebx, eax;  //白色
		RGB 210, 180,140
        invoke SetBkColor,wParam,eax;  //翠绿色
		mov eax,hbru
		ret
		
	.elseif eax== WM_CHAR
		MOV edx,wParam
		;如果为W则向上移动
		
		mov flag,0
		.if edx == 'W' || edx == 'w'
			invoke up;合并 并 计算分数
			mov flag,1
		
		.elseif edx == 'A' || edx == 'a'
			invoke left;合并 并 计算分数
			mov flag,1

		.elseif edx == 'S' || edx == 's'
			invoke down;合并 并 计算分数
			mov flag,1
			
		.elseif edx == 'D' || edx == 'd'
			invoke right;合并 并 计算分数
			mov flag,1
		.endif

		.if flag==1
			.if eax == 1
				invoke randomNew  ;如果可以向上移动，在随机位置产生一个2
			.endif
			;更新界面
			invoke UpdataGame,hWnd,wParam
		.endif
		
		End_round:
			;判断游戏是否结束
			invoke gameOver
			;如果游戏结束，绘制失败弹窗
			.if gOver == 1
				invoke MessageBox,hWinMain,offset szText7,offset szText6,MB_OK
				;重新开始游戏
				.if eax == IDOK
					mov esi,score
					cmp esi,maxscore
					jle initialize
					mov maxscore,esi
					initialize:
						invoke GAME_INIT
						invoke UpdataGame,hWnd,wParam
				.endif
			.endif
	
	.else  ;否则按默认处理方法处理消息
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam
		ret
	.endif

	xor eax,eax
	ret
_ProcWinMain endp

_WinMain proc  ;窗口程序
	local @myWndClass:WNDCLASSEX ;WNDCLASSEX类型的窗口类，定义窗口属性（图标，光标，背景色）
    ;WNDCLASSEX 类型结构定义
    ;typedef struct _WNDCLASSEX {
    ;   UINT       cbSize;                   扩展的大小. 自己WndClass本身大小.
    ;   UINT       style;                    风格
    ;   WNDPROC    lpfnWndProc;              窗口回调.消息都要进入这个回调
    ;   int        cbClsExtra;              
    ;   int        cbWndExtra;  
    ;   HINSTANCE  hInstance;                实例句柄
    ;   HICON      hIcon;                    图标
    ;   HCURSOR    hCursor;                  光标
    ;   HBRUSH     hbrBackground;            背景
    ;   LPCTSTR    lpszMenuName;             菜单名称
    ;   LPCTSTR    lpszClassName;            类名称
    ;   HICON      hIconSm;                  最小化图标
    ;} WNDCLASSEX, *PWNDCLASSEX; 
	local @message:MSG  ;传递的消息（MSG类型）
	
	invoke GetModuleHandle,NULL  ;获取已经载入进程空间的模块句柄
	mov hInstance,eax  ;把该句柄的值放在hinstance中
	invoke RtlZeroMemory,addr @myWndClass,sizeof @myWndClass  ;myWndClass初始化

	;设置窗口类
	push hInstance  ;实例句柄			
	pop @myWndClass.hInstance
	mov @myWndClass.cbSize,sizeof WNDCLASSEX  ;结构体的大小
	mov @myWndClass.style,CS_HREDRAW or CS_VREDRAW
	mov @myWndClass.lpfnWndProc,offset _ProcWinMain  ;窗口回调函数为procwinmain
	mov @myWndClass.lpszClassName,offset szClassName
	
	RGB 240,240,200
	invoke CreateSolidBrush,eax
	mov @myWndClass.hbrBackground,eax

	invoke RegisterClassEx,addr @myWndClass  ;注册窗口类，注册前先填写参数WNDCLASSEX结构
  
   ;建立并显示窗口
	invoke CreateWindowEx,WS_EX_CLIENTEDGE,offset szClassName,offset szCaptionMain,WS_OVERLAPPEDWINDOW,300,80,550,700,NULL,NULL,hInstance,NULL
    mov hWinMain,eax  
	invoke ShowWindow,hWinMain,SW_SHOWNORMAL  ;显示窗口，函数传递的参数是窗口的句柄
	invoke UpdateWindow,hWinMain  ;刷新窗口客户区

	.while TRUE  ;进入无限的消息获取和处理的循环
		invoke GetMessage,addr @message,NULL,0,0  ;从消息队列中取出第一个消息，放在stMsg结构中
        .break .if eax==0
		invoke TranslateMessage,addr @message  ;把基于键盘扫描码的按键信息转换成对应的ASCII码
		invoke DispatchMessage,addr @message  ;找到程序的窗口回调函数，来处理消息
	.endw
	ret
_WinMain endp

main proc
	;初始化游戏参数
	invoke GAME_INIT
	;显示窗口
	call _WinMain
	invoke ExitProcess,NULL
	ret

main endp
end main