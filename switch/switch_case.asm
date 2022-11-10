.386
.model flat, stdcall
option casemap: none

includelib msvcrt.lib
; 声明要使用的 printf 与 scanf 函数
printf		proto C :dword, :vararg
scanf		proto C :dword, :vararg

.stack		4096	; 定义栈的大小为4KB

.data

.code

main proc

main endp
end main