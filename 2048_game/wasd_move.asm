.386
.model flat, stdcall
option casemap: none

includelib msvcrt.lib
; 声明要使用的 printf 与 scanf 函数
printf		proto	C :dword, :vararg
scanf		proto	C :ptr sbyte, :vararg
getchar		proto	C
exit		proto	C :dword
.stack		4096	; 定义栈的大小为4KB

.data
map			dword	4, 4, 4, 4
			dword	4, 4, 4, 4
			dword	4, 4, 4, 4
			dword	4, 4, 4, 4

testmap		dword	1, 2, 3, 4
			dword	5, 6, 7, 8
			dword	9,10,11,12
			dword	13,14,15,16

out1		byte	'%d,', 0
nextLine	byte	'%c', 0
testMsg		byte	"address=%p", 0ah, 0
szMsgScore_Change	byte	'score = %d,	change = %d', 0ah, 0
score		dword	0

.code
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

move		proc
		local	input:byte						; 定义输入字符
		local	JumpTab[9]:dword				; 跳转表，用以实现switch跳转
		local	change:dword					; 矩阵是否有改变的标志
		mov		JumpTab[0], offset Tabq
		mov		JumpTab[1], offset Tabw
		mov		JumpTab[2], offset TabW
		mov		JumpTab[3], offset Taba
		mov		JumpTab[4], offset TabA
		mov		JumpTab[5], offset Tabs
		mov		JumpTab[6], offset TabS
		mov		JumpTab[7], offset Tabd
		mov		JumpTab[8], offset TabD
		invoke	getchar
		mov		input, al
		invoke	getchar		;吸收回车
		cmp		input, 'q'				; 与字符q比较，相等则退出
		jz		Tabq
		cmp		input, 'w'				; w\W 上移
		jz		Tabw
		cmp		input, 'W'
		jz		TabW
		cmp		input, 'a'				; a\A 左移
		jz		Taba
		cmp		input, 'A'
		jz		TabA
		cmp		input, 's'				; s\S 下移
		jz		Tabs
		cmp		input, 'S'
		jz		TabS
		cmp		input, 'd'				; d\D 右移
		jz		Tabd
		cmp		input, 'D'
		jz		TabD
		mov		eax, 0
		jmp		EXIT
	Tabq:
		mov		eax, 0
		invoke	exit, eax
	Tabw:
	TabW:
		invoke	up
		jmp		EXIT
	Taba:
	TabA:
		invoke	left
		jmp		EXIT
	Tabs:
	TabS:
		invoke	down
		jmp		EXIT
	Tabd:
	TabD:
		invoke	right
	EXIT:
		mov		change, eax
		mov		eax, change
		ret
move		endp

showMap	proc	C
		local	i, j, len:dword
		mov		i, 0
		mov		len, 16
		jmp		CMP1
	Cycle1:
		mov		j, 0			; j = 0
		jmp		CMP2
	Cycle2:
		mov		ebx, i
		mov		esi, j
		mov		edx, map[ebx*4][esi]
		invoke	printf, offset out1, edx
		add		j, 4				; j++
	CMP2:		
		mov		edx, len
		cmp		j,   edx		; j < len
		jl		Cycle2
		invoke	printf, offset nextLine, 0ah
		add		i, 4				; i++
	CMP1:
		mov		edx, len
		cmp		i,	 edx
		jl		Cycle1
		ret
showMap	endp

main		proc
		local	change :dword
		mov		change, 0
		invoke	showMap
		invoke	printf, offset szMsgScore_Change, score, change
		jmp		CMP1
	Cycle1:
		invoke	move
		mov		change, eax
		invoke	showMap
		invoke	printf, offset szMsgScore_Change, score, change
	CMP1:
		mov		eax, 0
		test	eax, eax
		jz		Cycle1
		ret
main		endp
end main