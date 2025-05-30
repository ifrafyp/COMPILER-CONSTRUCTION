// C operators
#include <stdio.h>

int main(){
	int a,b,c,d;
	a = b+c;
	b = ((c+d)*a)/(d/b) + (b*4) - (c*d);
	b -= c*d;
	if(c >= 0){
		a++;
	}
	else{
		a--;
	}
	return 0;
}
