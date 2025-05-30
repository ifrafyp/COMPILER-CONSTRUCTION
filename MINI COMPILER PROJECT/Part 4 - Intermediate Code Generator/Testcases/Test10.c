// C functions
#include <stdio.h>

void func1(int a, int b){
	b = b * 10;
	a *= 100;
}

int func2(int a){
	return a*a;
}
float func3(int b){
	return b*10.0;
}

int main(){
	int g,h;
	func1(g,h);
	g = func2(h);
	float i;
	func3(i);
	return 0;
}
