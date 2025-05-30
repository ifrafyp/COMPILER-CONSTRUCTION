// User-defined functions and function call

#include <stdio.h>

int addfunc(int a,int b){
	return a+b;
}

void main()
{
	int a,b,sum;
	a = 0;
	while(a<3){
		b = 0;
		while(b<9){
			sum = addfunc(a,b);
			b++;
		}
		++a;
	}
	
}
