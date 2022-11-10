.386
.model flat, stdcall
option casemap: none

includelib msvcrt.lib
; 声明要使用的 printf 与 scanf 函数
printf		proto C :dword, :vararg
scanf		proto C :dword, :vararg

.stack		4096	; 定义栈的大小为4KB

.data

Msg1	byte	'1----create', 0ah				; 菜单字符串
		byte	'2----update', 0ah
		byte	'3----delete', 0ah
		byte	'4----print',  0ah
		byte	'5----quit', 0ah, 0

Msg2	byte	'input select:', 0ah, 0			; 提示字符串
Fmt		byte	'%d', 0							; scanf的格式字符串
op		dword	?								; 用户输入的整数

Msg3	byte	'Error!', 0ah, 0					; 输入错误后显示的字符串

MsgC	db		'create a File', 0ah, 0ah , 0	; 选择菜单1后显示的字符串
MsgU	db		'update a File', 0ah, 0ah , 0	; 选择菜单1后显示的字符串
MsgD	db		'delete a File', 0ah, 0ah , 0	; 选择菜单1后显示的字符串
MsgP	db		'print a File', 0ah, 0ah , 0	; 选择菜单1后显示的字符串
MsgQ	db		'quit', 0ah, 0					; 选择菜单1后显示的字符串

JmpLap	dword	offset CR						; 跳转表, 保存五个跳转的地址
		dword	offset UP						; 其实就是在数组中直接查找跳转地址
		dword	offset DE
		dword	offset PR
		dword	offset QU

.code

main:
	invoke	printf, offset Msg1					; 打印菜单
Rdkb:
	invoke	printf, offset Msg2					; 显示提示信息
	invoke	scanf,  offset Fmt, offset op		; 接受用户输入
	cmp		op, 1
	jb		Beep								; 输入比1 小，不合法
	cmp		op, 5
	ja		Beep								; 输入比5 大，不合法
	mov		ebx, op
	dec		ebx									; 将输入的整数转化为跳转表的索引
	mov		eax, JmpLap[ebx*4]					; 得到表项地址
	jmp		eax

Beep:
	invoke	printf, offset Msg3					; 提示输入错误
	jmp		Rdkb
CR:
	invoke	printf,	offset MsgC
	jmp		main								; 跳到主菜单，继续执行
UP:
	invoke	printf,	offset MsgU
	jmp		main								; 跳到主菜单，继续执行
DE:
	invoke	printf,	offset MsgD
	jmp		main								; 跳到主菜单，继续执行
PR:
	invoke	printf,	offset MsgP
	jmp		main								; 跳到主菜单，继续执行
QU:
	invoke	printf,	offset MsgQ
	ret											; 结束
end main