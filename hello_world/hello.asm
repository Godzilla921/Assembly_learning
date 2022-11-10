;调用Windows界面UI

;模式定义

.386
.model	flat, stdcall
option	casemap: none

;库文件以及要使用的函数声明
includelib		user32.lib
MessageBoxA		PROTO	:dword, :dword, :dword, :dword

;等值伪指令
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
						NULL,                ; 父窗口的句柄, 及显示该窗口的上下文
						offset SzMsg,		 ; 正文内容
						offset SzTitle,		 ; 标题
						MB_OK				 ; 消息框中显示一个按钮
				ret
end				start

