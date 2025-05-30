// Variable redeclaration
#include <stdio.h>

int main(){
	int g,h;
	g = h+g;
	int h = g*g;
	return 0;
}
