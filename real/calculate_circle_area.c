#define _CRT_SECURE_NO_DEPRECATE
# include "stdio.h"

int main()
{
	float R, S;
	printf("������Բ�İ뾶: ");
	scanf("%f", &R);
	__asm {
		fld		R
		fld		R
		fmul
		fldpi
		fmul
		fstp	S	
	}
	printf("Բ�����Ϊ: %.4f", S);
	return 0;
}