.386
.model flat, stdcall
option casemap: none

includelib msvcrt.lib
; 声明要使用的 printf 与 scanf 函数
printf		proto C :dword, :vararg
scanf		proto C :dword, :vararg

.stack		4096	; 定义栈的大小为4KB

.data

SCAN_Fmt	sbyte	'%d', 0
PRIN_Fmt	sbyte	'%d! = %d', 0ah, 0
ERROR_MSG	sbyte	'请输入自然数', 0ah, 0
N			sdword	?
fact		sdword	?
.code

main proc
	invoke	scanf, offset SCAN_Fmt, offset N
	mov		ecx, N
	;shl		ecx, 1				; jiang eax 即 N左移1位 去除最高位在CF中，判断其符号，但会破坏eax
	;jc		ERROR
	test	ecx, ecx				; eax&eax 且不会破坏eax，
	js		ERROR					; 若为负数直接跳转
	
	mov		eax, 1
	; 注意当输入N=0时，C=0 此时会循环最多次
	test	ecx, ecx	
	je		M
L1:
	imul	eax, ecx
	LOOP	L1
M:
	mov		fact, eax
	invoke	printf, offset PRIN_Fmt, N, fact
	ret
ERROR:
	invoke	printf, offset ERROR_MSG
	ret
main endp
end main