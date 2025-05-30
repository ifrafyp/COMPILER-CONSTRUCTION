// Mathematical operations for 3 address code
#include <stdio.h>
void main(){
	int a,b,c,d;
	while(a < 10){
		if (a<3){
			if(c<d)
				a = 98;
			else
				a = (d * b + c)/7 + (a*b)%c;
		}
		else
			a++;
	}
	a = b+c;
}
