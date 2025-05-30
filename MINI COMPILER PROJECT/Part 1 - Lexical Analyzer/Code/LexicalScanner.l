%{
#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <string.h>
int var=0,i,nc=0,commLine=0,flag=0;
int lineNumber=1;
int cBrac=0;

FILE *Smbl,*Cnst;						// Smbl for symbol, Cnst for constants
char *Mul_comment,*inputFile, Sng_comment[1000];

void insertToTable(char *yytext,char type);
void storeMultiLineComment(char *yytext);
void storeSingleLineComment(char *yytext);

struct Node {
	char *tname;
	int av;
	struct Node *next;
}*head=NULL;

%}

assignment =
arithmatic \+|\-|\*|\/|\%
datatype "int"|"char"|"float"|"void"
digit  [0-9]
keyword	"auto"|"break"|"case"|"char"|"const"|"continue"|"default"|"do"|"double"|"else"|"enum"|"extern"|"float"|"for"|"goto"|"if"|"int"|"long"|"register"|"return"|"short"|"signed"|"sizeof"|"static"|"struct"|"switch"|"typedef"|"union"|"unsigned"|"void"|"volatile"|"while"
letter  [a-zA-Z]
logical \&|\^|\~
modifiers "long"|"short"
multilinecommentstart (\/\*)
multilinecommentend (\*\/)
newline "\n"
puncuator \(|\)|\[|\]|\;|\,|\:|\.
quote \'|\"|\\
relational >|<|<=|>=|!=|==
sign "signed"|"unsigned"
singlelinecomment (\/\/.*)
whitespace [ \t]+
identifier ({letter}({letter}|{digit})*)|"_"({letter}|{digit})+ 

%x COMMENT_DETECTION

%%

^#([-a-zA-Z0-9.]|{relational}|{whitespace})* {
	insertToTable(yytext,'d'); //preprocessor directive rule
	printf("%s : %d : Preprocessor rule found - %s\n",inputFile,lineNumber,yytext);
	}

{keyword} insertToTable(yytext,'k');
{sign}?{whitespace}{modifiers}?{whitespace}{datatype} insertToTable(yytext,'k'); //keyword rule

^{datatype}{whitespace}*{identifier}\(.*\)  {	int i,j=0;char temp1[50]={'\0'}, temp2[50]={'\0'};
												for(i=0;yytext[i]!=' ';i++)
												{
													temp1[i] = yytext[i];
												}
												
												insertToTable(temp1,'k');
												for(;yytext[i]!='(';i++){
													temp2[j]=yytext[i];
													j++;
												}

												insertToTable(temp2,'j');  //procedure rule
											}
											
{identifier}\[{digit}*\] {	int i,j=0;char temp[50]={'\0'};
							
							for(i=0;yytext[i]!='[';i++)
							{
								temp[j] = yytext[i];
								j++;
							}

								insertToTable(temp,'a'); // array rule
						}
						
\*{identifier} {	int i,j=0;char temp[50]={'\0'};
					for(i=1;yytext[i]!='\0';i++)
					{
						temp[j++] = yytext[i];
					}
						insertToTable(temp,'q'); // pointer rule
				}
				
{identifier} {
	insertToTable(yytext,'i'); // variable rule
	printf("%s : %d : Identifier found - %s\n",inputFile,lineNumber,yytext);
	}
{digit}+ {
	insertToTable(yytext,'c'); //integer constants rule
	printf("%s : %d : Integer found - %s\n",inputFile,lineNumber,yytext);
	}
{digit}+({letter}|{digit})+|"_" { printf("%s : %d : Invalid Identifier - %s\n",inputFile,lineNumber,yytext); } // invalid identifier

                                        
{relational} insertToTable(yytext,'r'); //operator rules
{logical} insertToTable(yytext,'l');
{arithmatic} insertToTable(yytext,'o');
{assignment} insertToTable(yytext,'e');
{puncuator} insertToTable(yytext,'p');


\"(.)*\" {
	insertToTable(yytext,'s'); //string constants rule
	printf("%s : %d : String constant found - %s\n",inputFile,lineNumber,yytext);
	}
L?\"(\\.|[^\\"])*	{
				if(nc<=0) //invalid String
				printf("%s : %d : String does not end\n",inputFile,lineNumber);	
			}
[-+]?{digit}*\.?{digit}+([eE][-+]?{digit}+)? insertToTable(yytext,'f');  // float constant rule
\'({letter}|{digit})\' {	char temp[50]={'\0'};
							temp[0] = yytext[1];
							printf("%s : %d : Character constant found - '%c'\n",inputFile,lineNumber,temp[0]);
							insertToTable(temp,'z');  // character constant rule
						}
\'({letter}|{digit})({letter}|{digit})+\' {printf("%s : %d : Invalid Character constant - %s\n",inputFile,lineNumber,yytext);}

{quote} ;
{whitespace} ;
{newline} lineNumber++;

"{"  { 	cBrac++;
	insertToTable(yytext,'p');
	 }

"}"  {	cBrac--;
	insertToTable(yytext,'p');
	 }

{singlelinecomment} {
	printf("%s : %d : Single comment found\n",inputFile,lineNumber);
	storeSingleLineComment(yytext);	
	}

{multilinecommentstart}  {  
                BEGIN(COMMENT_DETECTION);
                nc++;
                commLine++;
                storeMultiLineComment("\n\n");
            }

<COMMENT_DETECTION>{multilinecommentstart} { 
                            nc++;
                            if(nc>1)
                            {
								printf("%s : %d : Nested Comment found\n",inputFile,lineNumber);
                                flag++;
                            }
                         }

<COMMENT_DETECTION>{multilinecommentend} {
                            if(nc>0)
                                nc--;
                            else
			    	printf("%s : %d : Error:Closing comment found before opening\n",inputFile,lineNumber);
                            
                            if(nc==0){
				printf("%s : %d : Multi-line comment found\n",inputFile,lineNumber);
                            	BEGIN(INITIAL);
			    }
                    }

<COMMENT_DETECTION>\n   {  
                 commLine++;
                 lineNumber++;
                 storeMultiLineComment("\n");
                }

<COMMENT_DETECTION>. {storeMultiLineComment(yytext);}


%%

int main(int argc,char **argv)
{
	Mul_comment = (char*)malloc(100*sizeof(char));
	yyin=fopen(argv[1],"r");
	inputFile=argv[1];

	Smbl=fopen("Symbol Table.txt","w");				 //File to write and save Symbol Table for given input
	fprintf(Smbl,"\t\t\t\t\t\t\t\t\t\t Symbol Table:\n\n\n\n \t\tLine Number\t\t\tLexeme\t\t\t\tType\t\t\tAttribute Value\n");

	Cnst=fopen("Constant Table.txt","w");				// File to write and Constant Table for given input
	fprintf(Cnst,"\t\t\t\t\t\t\t\t\t\t Constants Table:\n\n\n\n \t\tLine Number\t\t\tLexeme\t\t\tType\t\t\tAttribute Value\n");

	yyout=fopen("Tokens List.txt","w");				// File to write all token in source program
	fprintf(yyout,"\t\t\t\t\t\t\t\t\t\t Token List:\n\n\n\n \t\tLine Number\t\t\tLexeme\t\t\tToken\t\t\t\tAttribute Value\n");

	yylex();
	
    	if(nc!=0)
    		printf("%s : %d : Comment does not end\n",inputFile,lineNumber);
    		
    	if(cBrac!=0)
    		printf("%s : %d : Unbalanced Braces {}\n",inputFile,lineNumber);
    
    	fprintf(yyout,"\n");
    	if(flag > 0)
    	{
			commLine = 0;
			fprintf(yyout,"\n\nComment (%d lines):\n",commLine);
			printf("\n%s : %d Nested comment(s) found\n",inputFile,flag);
    	}
    	else
    	{
	    	int i;
		fprintf(yyout,"\n\nMultiLineComment (%d lines):\n\n",commLine);
		fputs(Mul_comment,yyout);
		fprintf(yyout,"\n\nSingleLineComment :\n\n");
		fputs(Sng_comment,yyout);
	}
    
	fclose(yyout);
	fclose(Smbl);
	fclose(Cnst);	
}

void storeSingleLineComment(char *yytext)
{
	int length = strlen(yytext);
	int i, j;
	char *extra;
	extra = (char*)malloc((length+1)*sizeof(char));
	for(j=2,i=0;yytext[j]!='\0';j++,i++)
	{
		extra[i] = yytext[j];
	}	
	strcat(extra,"\n");	//To print on new line
	strcat(Sng_comment,extra);	//Copy to list of single comments
}
void storeMultiLineComment(char *yytext)
{
    int len1, len2;
    char *extra;

    len1 = strlen(Mul_comment);
    len2 = strlen(yytext);
    extra = (char*)malloc((len1+1)*sizeof(char));
    strcpy(extra,Mul_comment);
    Mul_comment = (char*)malloc((len1+len2+1)*sizeof(char));
    strcat(extra,yytext);
    strcpy(Mul_comment,extra);
}
void insertToTable(char *yytext,char type)
{
    int l1 = strlen(yytext), i;
	
    
    char token[30];
    struct Node *current = NULL, *temp = NULL;

    switch(type)
    {
	case 'd': strcpy(token,"Preprocessor Statement");break;

        case 'k': strcpy(token,"Keyword");break;
         
        case 'j': strcpy(token,"Procedure");break;              
       
        case 'a': strcpy(token,"Array");break;

	case 'q': strcpy(token,"Pointer");break;
        
        case 'i': strcpy(token,"Identifier");break;
	 	
	case 'r': strcpy(token,"Relational Op");break;

        case 'p': strcpy(token,"Punctuator");break;
       	
       	case 'o': strcpy(token,"Arithmetic Op");break;   
        
        case 'c': strcpy(token,"Integer Constant");break;

        case 'f': strcpy(token,"Float Constant");break;

        case 'z': strcpy(token,"Character Constant");break;                                
      	
      	case 'e': strcpy(token,"Assignment Op");break;
      	
      	case 'l': strcpy(token,"Logical Op");break;	
    	
    	case 's': strcpy(token,"String Literal");break;
    }

    if(nc<=0)
    {
	    current = head;
	    for(i=0;i<var;i++)
	    {    	
	    	if(strcmp(current->tname,yytext)==0)
	    		{
	    			break;
	    		}
	    		current = current->next;
	    }

	    if(i==var)
	    {    	
	    	temp = (struct Node *)malloc(sizeof(struct Node));
	    	temp->av = i;
	    	temp->tname = (char *)malloc(sizeof(char)*(l1+1));
	    	strcpy(temp->tname,yytext);
	    	temp->next = NULL;

	    	if(head==NULL)
	    	{    		
	    		head = temp;
	    	}
	    	else
	    	{
	    		current = head;
	    		while(current->next!=NULL)
	    		{
	    			current = current->next;
	    		}    
		    	current->next = temp;
		}
		   	
    		var++;	
	    }
    }

	if(type =='i' || type == 'a' || type == 'q' || type=='j')
	{	
		fprintf(Smbl,"\n%25d%30s%30s%30d",lineNumber,yytext,token,i);
	}
	switch(type)
	{		
		case 'c' : fprintf(Cnst,"\n%25d%30s%20s%30d",lineNumber,yytext,"int",i);
				    break;

		case 'f' : fprintf(Cnst,"\n%25d%30s%20s%30d",lineNumber,yytext,"float",i);
				    break;

		case 'z' : fprintf(Cnst,"\n%25d%30s%20s%30d",lineNumber,yytext,"char",i);
				    break;
	}

   	fprintf(yyout,"\n%25d%30s%30s%30d",lineNumber,yytext,token,i);
}
                                                                                                    
int yywrap()
{
 return(1);
}