;汇编输出 hello world
.386
.model flat,stdcall
option casemap:none
; 汇编语言中大小写不敏感****PROTO 或 proto 都是可以的
includelib		msvcrt.lib
printf			PROTO C :ptr sbyte, :vararg     ;print 函数声明
scanf           PROTO C :ptr sbyte, :vararg     ;scanf 函数声明
start			PROTO C							;start 函数声明（无参数），该函数在hello.asm 中定义

.data

szMsg			sbyte		'Hello World!',0ah,0
sz_in			sbyte		'%d %d %d',0				; scanf的输入格式
sz_out			sbyte		'a=%d b=%d d=%d', 0ah,0 ;printf输出格式
a				sdword		?                   ; 定义三个占双子带符号整形变量，未初始化 ? 表示占位
b				sdword		?
d				sdword		?					; 由于C在汇编中表示C格式，所以定义变量时不能定义c

.code

main			proc
				invoke		printf, offset szMsg
				invoke		scanf, offset sz_in, offset a, offset b, offset d ;输入到a,b,d中
				invoke		printf, offset sz_out, a, b, d
				invoke		start
				ret
main			endp
end				main