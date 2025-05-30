// C loops
#include <stdio.h>

int main(){
	int i = 1;
	while(i<=5){
		printf("While loop\n");
	}
	for(i=1;i<=5;i++){
		printf("For loop\n");
	}
	i = 1;
	do{
		printf("Do while loop\n");
	}while(i<=5);
	return 0;
}
