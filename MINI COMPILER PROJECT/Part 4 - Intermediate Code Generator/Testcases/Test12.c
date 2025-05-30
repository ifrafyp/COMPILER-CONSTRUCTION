// Function parameter number mismatch
#include <stdio.h>

int func1(int a, int b, int c){
	b = a+(c*b);
	return b;
}

int main(){
	int g,h;
	g = func1(g,h);
	return 0;
}
