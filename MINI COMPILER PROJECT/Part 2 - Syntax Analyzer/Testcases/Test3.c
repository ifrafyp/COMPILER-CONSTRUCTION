#include<stdio.h>

int main()
{
  int var1,var2;
  /*Nested
  if-else 
  consdition*/
  if (var1!=var2)
  {
    if(var1>0)
    printf("Var1 is positive");
       
	printf("var1 is not equal to var2\n");
  }
  else if (var1 > var2)
  {
	         printf("var1 is greater than var2\n");
  }
  else if (var2 > var1){
	printf("var2 is greater than var1\n");
  }
        else
        {
	printf("var1 is equal to var2\n");
  }


  //Nexted while loop
  int a=10,c=0;
	while(a>0)
	{
		while(a>5){  c+=a;  }
	}
return 0;
}
