.586
.model		flat, stdcall
option		casemap:none

includelib	msvcrt.lib

printf		proto	C :dword, :vararg
scanf		proto	C :ptr sbyte, :vararg

.stack		4096

.data
	szMsg_help	byte	'请输入圆的半径:',0	
	szMsg1		byte	'%lf', 0
	szMsg2		byte	'圆的面积为: %.4lf', 0ah, 0
	R			real8	?
	S			real8	?

.code

main		proc
	finit
	invoke		scanf, offset szMsg1, offset R
	fld			R
	fld			R
	fmul
	fldpi
	fmul
	fstp		S
	invoke		printf, offset szMsg2, S
	ret
main		endp
end		main