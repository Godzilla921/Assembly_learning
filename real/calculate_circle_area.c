#define _CRT_SECURE_NO_DEPRECATE
# include "stdio.h"

int main()
{
	float R, S;
	printf("请输入圆的半径: ");
	scanf("%f", &R);
	__asm {
		fld		R
		fld		R
		fmul
		fldpi
		fmul
		fstp	S	
	}
	printf("圆的面积为: %.4f", S);
	return 0;
}