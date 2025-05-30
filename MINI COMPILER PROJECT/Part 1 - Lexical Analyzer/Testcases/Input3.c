#include<stdio.h>

int main(){
	int left, target, right, mid;
	int array[5] = { 0, 1, 5, 7, 10};
	left = 0;
	right = 5;
	target = 1;
	while(left < right){
		mid = (left + right)/2;
		if(array[mid] == target){
			printf("Found");
			break;
		}
		if(array[mid]>target)
			left = mid + 1;
		right = mid - 1;
	}
	if(left>right)	
		printf("Not found");
	return 0;
}