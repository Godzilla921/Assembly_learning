.386
.model flat, stdcall
option casemap: none

includelib msvcrt.lib
; ����Ҫʹ�õ� printf �� scanf ����
printf		proto C :dword, :vararg
scanf		proto C :dword, :vararg

.stack		4096	; ����ջ�Ĵ�СΪ4KB

.data

.code

main proc

main endp
end main