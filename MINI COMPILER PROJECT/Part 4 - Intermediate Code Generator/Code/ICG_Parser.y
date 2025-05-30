%{
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	#include "lex.yy.c"
	
	void yyerror(char* s);
	int yylex();
	void ins();
	void insV();
	int flag=0;
	#define ANSI_COLOR_RED		"\x1b[31m"
	#define ANSI_COLOR_GREEN	"\x1b[32m"
	#define ANSI_COLOR_CYAN		"\x1b[36m"
	#define ANSI_COLOR_RESET	"\x1b[0m"
	extern char curid[20];
	extern char curtype[20];
	extern char curval[20];
	extern int currnest;
	void deletedata (int );
	int checkScope(char*);
	int check_id_is_func(char *);
        void insertScope(char *,int);
	void insertSymbolTable(char*, char*);
	void insertSymbolTableNesting(char*, int);
	void insertSymbolTableParamsCount(char*, int);
	int getSybolTableParamsCount(char*);
	int check_duplicate(char*);
	int check_declaration(char*, char *);
	int check_params(char*);
	int duplicate(char *s);
	int checkArray(char*);
	char currfunctype[100];
	char currfunc[100];
	char currfunccall[100];
	void insertSymbolTableFunc(char*);
	char getType(char*,int);
	char getfirst(char*);
	void push(char *s);
	void codegen();
	void codeassign();
	char* itoa(int num, char* str, int base);
	void reverse(char str[], int length); 
	void swap(char*,char*);
	void label1();
	void label2();
	void label3();
	void label4();
	void label5();
	void label6();
	void genunary();
	void codegencon();
	void funcgen();
	void funcgenend();
	void arggen();
	void callgen();

	int params_count=0;
	int call_params_count=0;
	int top = 0,count=0,ltop=0,lno=0;
	char temp[3] = "t";
        int array_dim;
%}

%nonassoc IF
%token INT CHAR FLOAT DOUBLE LONG SHORT SIGNED UNSIGNED STRUCT
%token RETURN MAIN
%token VOID
%token WHILE FOR DO 
%token BREAK
%token ENDIF
%expect 1

%token identifier array_identifier func_identifier
%token integer_constant string_constant float_constant character_constant

%nonassoc ELSE

%right leftshift_assignment_operator rightshift_assignment_operator
%right XOR_assignment_operator OR_assignment_operator
%right AND_assignment_operator modulo_assignment_operator
%right multiplication_assignment_operator division_assignment_operator
%right addition_assignment_operator subtraction_assignment_operator
%right assignment_operator

%left OR_operator
%left AND_operator
%left pipe_operator
%left caret_operator
%left amp_operator
%left equality_operator inequality_operator
%left lessthan_assignment_operator lessthan_operator greaterthan_assignment_operator greaterthan_operator
%left leftshift_operator rightshift_operator 
%left add_operator subtract_operator
%left multiplication_operator division_operator modulo_operator

%right SIZEOF
%right tilde_operator exclamation_operator
%left increment_operator decrement_operator 


%start program

%%
program
			: declaration_list;

declaration_list
			: declaration D ;

D
			: declaration_list
			| ;

declaration
			: variable_declaration 
			| function_declaration
			;

variable_declaration
			: type_specifier variable_declaration_list ';' 
			;

variable_declaration_list
			: variable_declaration_list ',' variable_declaration_identifier 
			| variable_declaration_identifier
			;

variable_declaration_identifier 
			: identifier { if(duplicate(curid)){	yyerror("Duplicate\n");	}
					insertSymbolTableNesting(curid,currnest);
					insertScope(curid,currnest);
					ins();
				     }
			
			vdi   
			| array_identifier { if(duplicate(curid))	yyerror("Duplicate\n");
						insertSymbolTableNesting(curid,currnest);
						insertScope(curid,currnest);ins(); 
					}
			vdi
			;			
			

vdi : identifier_array_type | assignment_operator simple_expression  ; 

identifier_array_type
			: '[' initilization_params
			| ;

initilization_params
			: integer_constant ']' initilization {	if($$ < 1) yyerror("Wrong array size\n");
								array_dim = $$;
								insertSymbolTableArrayDimension(curid,array_dim);
								}
			| ']' string_initilization	{	array_dim = -2; 
								insertSymbolTableArrayDimension(curid,array_dim);}
			;

initilization
			: string_initilization
			| array_initialization
			| ;

type_specifier 
			: INT | CHAR | FLOAT  | DOUBLE  
			| LONG long_grammar 
			| SHORT short_grammar
			| UNSIGNED unsigned_grammar 
			| SIGNED signed_grammar
			| VOID  ;

unsigned_grammar 
			: INT | LONG long_grammar | SHORT short_grammar | ;

signed_grammar 
			: INT | LONG long_grammar | SHORT short_grammar | ;

long_grammar 
			: INT  | ;

short_grammar 
			: INT | ;

function_declaration
			: function_declaration_type function_declaration_param_statement ;

function_declaration_type
			: type_specifier identifier '('  { strcpy(currfunctype, curtype);
							strcpy(currfunc, curid);
							check_duplicate(curid); 
							insertSymbolTableFunc(curid);
							ins(); } 
			;

function_declaration_param_statement
			: {	params_count=0;}params ')' {funcgen();} statement { funcgenend(); }
			;

params 
			: parameters_list { 
				insertSymbolTableParamsCount(currfunc, params_count); }
			| { insertSymbolTableParamsCount(currfunc, params_count); }
			;

parameters_list 
			: type_specifier { check_params(curtype);} parameters_identifier_list 
			;

parameters_identifier_list 
			: param_identifier parameters_identifier_list_breakup
			;

parameters_identifier_list_breakup
			: ',' parameters_list 
			| ;

param_identifier 
			: identifier { ins();
					insertScope(curid,1);
					insertSymbolTableNesting(curid,1);
					params_count++; }
			param_identifier_breakup
			;

param_identifier_breakup
			: '[' ']'
			| ;

statement 
			: expression_statment | compound_statement 
			| conditional_statements | iterative_statements 
			| return_statement | break_statement 
			| variable_declaration
			;

compound_statement 
			: {currnest++;} '{'  statment_list  '}' { deletedata(currnest);	currnest--;} 
			;

statment_list 
			: statement statment_list 
			| ;

expression_statment 
			: expression ';' 
			| ';' ;

conditional_statements 
			: IF '(' simple_expression ')' {
				label1();
				if($3!=1)	yyerror("Condition checking is not of type int\n");	}
			statement {	label2();	}  conditional_statements_breakup
			;

conditional_statements_breakup
			: ELSE statement {label3();}
			| {label3();}
			;

iterative_statements 
			: WHILE '(' {label4();} simple_expression ')' {
					label1();
					if($4!=1)	yyerror("Condition checking is not of type int\n");
					}
				statement { label5(); } 
			| FOR '(' expression ';' { label4(); } 
			 simple_expression ';' { label1(); 
						if($6!=1){ yyerror("Condition checking is not of type int\n"); }
					} 
			expression ')' statement { label5(); } 
			| {label4();} DO statement WHILE '(' simple_expression ')'{
					label1();
					label5();
					if($6!=1)	yyerror("Condition checking is not of type int\n");
				}
			';' ;
return_statement 
			: RETURN ';' {
				if(strcmp(currfunctype,"void"))	yyerror("Returning void of a non-void function\n");
				}
			| RETURN expression ';' { 	
				if(!strcmp(currfunctype, "void")){ 
					yyerror("Function is void");
				}
				if((currfunctype[0]=='i' || currfunctype[0]=='c') && $2!=1){
					yyerror("Expression doesn't match return type of function\n");
				}
			   }
			;

break_statement 
			: BREAK ';' ;

string_initilization
			: assignment_operator string_constant {insV();} ;

array_initialization
			: assignment_operator '{' array_int_declarations '}';

array_int_declarations
			: integer_constant array_int_declarations_breakup;

array_int_declarations_breakup
			: ',' array_int_declarations 
			| ;

expression 
			: mutable assignment_operator {push("=");} expression   {   
									if($1==1 && $4==1)  $$=1;
			                                                else {
										$$=-1;
										yyerror("Type mismatch\n");
									} 
			                                                codeassign();
			                                            }
			| mutable addition_assignment_operator { push("+="); } expression {  
									if($1==1 && $4==1)   $$=1; 
			                                                else {
										$$=-1;
										yyerror("Type mismatch\n");
									} 
			                                                codeassign();
			                                         }
			| mutable subtraction_assignment_operator { push("-="); } expression  {	  
									if($1==1 && $4==1)	$$=1; 
			                                                else {
										$$=-1;
										yyerror("Type mismatch\n");
									} 
			                                                codeassign();
			                                         }
			| mutable multiplication_assignment_operator { push("*="); } expression {
									if($1==1 && $4==1)	$$=1; 
			                                                else {
										$$=-1;
										yyerror("Type mismatch\n");
									}
			                                                codeassign(); 
			                                         }
			| mutable division_assignment_operator { push("/="); }expression { 
									if($1==1 && $4==1)	$$=1; 
			                                                else {
										$$=-1;
										yyerror("Type mismatch\n");
									} 
			                                                codeassign(); 
			                                         }
			| mutable modulo_assignment_operator { push("%="); }expression { 
									if($1==1 && $3==1)      $$=1; 
			                                                else {
										$$=-1;
										yyerror("Type mismatch\n"); 
									} 
			                                                codeassign();
								}
			| mutable increment_operator 		{ push("++"); if($1 == 1) $$=1; else $$=-1; genunary(); }
			| mutable decrement_operator  		{ push("--"); if($1 == 1) $$=1; else $$=-1; }
			| increment_operator mutable		{ push("++"); if($1 == 1) $$=1; else $$=-1; genunary(); }
			| decrement_operator mutable		{ push("--"); if($1 == 1) $$=1; else $$=-1; }
			| simple_expression { if($1 == 1) $$=1; else $$=-1; } ;


simple_expression 
			: simple_expression OR_operator and_expression {
				push("||");} {if($1 == 1 && $3==1) $$=1; else $$=-1; codegen();}
			| and_expression {if($1 == 1) $$=1; else $$=-1;};

and_expression 
			: and_expression AND_operator {push("&&");} 
			unary_relation_expression  {if($1 == 1 && $3==1) $$=1; else $$=-1; codegen();}
			  |unary_relation_expression {if($1 == 1) $$=1; else $$=-1;} ;


unary_relation_expression 
			: exclamation_operator { push("!"); } unary_relation_expression {if($2==1) $$=1; else $$=-1; codegen();} 
			| regular_expression {if($1 == 1) $$=1; else $$=-1;} ;

regular_expression 
			: regular_expression relational_operators sum_expression {if($1 == 1 && $3==1) $$=1; else $$=-1; codegen();}
			  | sum_expression {if($1 == 1) $$=1; else $$=-1;} ;
			
relational_operators 
			: greaterthan_assignment_operator {push(">=");} | lessthan_assignment_operator {push("<=");} 
			| greaterthan_operator {push(">");}| lessthan_operator {push("<");}| equality_operator {push("==");}
			| inequality_operator {push("!=");}
			;

sum_expression 
			: sum_expression sum_operators term  {if($1 == 1 && $3==1) $$=1; else $$=-1; codegen();}
			| term {if($1 == 1) $$=1; else $$=-1;};

sum_operators 
			: add_operator {push("+");}
			| subtract_operator {push("-");} ;

term
			: term MULOP factor {if($1 == 1 && $3==1) $$=1; else $$=-1; codegen();}
			| factor {if($1 == 1) $$=1; else $$=-1;} ;

MULOP 
			: multiplication_operator {push("*");}| division_operator {push("/");} | modulo_operator {push("%");} ;

factor 
			: immutable {if($1 == 1) $$=1; else $$=-1;} 
			| mutable {if($1 == 1) $$=1; else $$=-1;} ;

mutable 
			: identifier {
						  push(curid);
						  if(check_id_is_func(curid))
						  {yyerror("Function name used as Identifier\n"); exit(8);}
			              if(!checkScope(curid))
			              {printf("%s\n",curid);yyerror("Undeclared\n");exit(0);} 
			              if(!checkArray(curid))
			              {printf("%s\n",curid);yyerror("Array ID has no subscript\n");exit(0);}
			              if(getType(curid,0)=='i' || getType(curid,1)== 'c')
			              $$ = 1;
			              else
			              $$ = -1;
			              }
			| array_identifier { if(!checkScope(curid)){
							printf("%s\n",curid);
							yyerror("Undeclared\n"); }
					} '[' expression ']' 
			                   { if(getType(curid,0)=='i' || getType(curid,1)== 'c')
			              		$$ = 1;
						else $$ = -1;
			              	  };

immutable 
			: '(' expression ')' {if($2==1) $$=1; else $$=-1;}
			| call {if($1==-1) $$=-1; else $$=1;}
			| constant {if($1==1) $$=1; else $$=-1;};

call
			: identifier '('{

			             if(!check_declaration(curid, "Function")){
					 yyerror("Function not declared"); } 
			             insertSymbolTableFunc(curid); 
				     strcpy(currfunccall,curid);
				     if(getType(curid,0)=='i' || getType(curid,1)== 'c')
						$$ = 1;
			             else       $$ = -1;
					call_params_count=0; }
			 arguments ')' { if(strcmp(currfunccall,"printf")){ 
					   if(getSymbolTableParamsCount(currfunccall)!=call_params_count){	
					      yyerror("Number of arguments in function call doesn't match number of parameters");
					   }
				         }
				         callgen();  
			               }
			;

arguments 
			: arguments_list | ;

arguments_list 
			: arguments_list ',' exp { call_params_count++; }  
			| exp { call_params_count++; };

exp : identifier {arggen(1);} | integer_constant {arggen(2);} 
	| string_constant {arggen(3);} | float_constant {arggen(4);} 
	| character_constant {arggen(5);} ;

constant 
			: integer_constant 	{  insV(); codegencon(); $$=1; } 
			| string_constant	{  insV(); codegencon(); $$=-1; } 
			| float_constant	{  insV(); codegencon(); } 
			| character_constant	{  insV(); codegencon(); $$=1; } ;

%%

extern FILE *yyin;
extern int yylineno;
extern char *yytext;
void insertSymbolTableType(char *,char *);
void insertSymbolTableValue(char *, char *);
void insertCT(char *, char *);
void showSymbolTable();
void showConstantTable();

struct stack
{
	char value[100];
	int labelvalue;
}s[100],label[100];


void push(char *x)
{
	strcpy(s[++top].value,x);
}

void swap(char *x, char *y)
{
	char temp = *x;
	*x = *y;
	*y = temp;
}

void reverse(char str[], int length) 
{ 
    int start = 0; 
    int end = length -1; 
    while (start < end) 
    { 
        swap((str+start), (str+end)); 
        start++; 
        end--; 
    } 
} 
  
char* itoa(int num, char* str, int base) 
{ 
    int i = 0; 
    int isNegative = 0; 
  
   
    if (num == 0) 
    { 
        str[i++] = '0'; 
        str[i] = '\0'; 
        return str; 
    } 
  
    if (num < 0 && base == 10) 
    { 
        isNegative = 1; 
        num = -num; 
    } 
  
   
    while (num != 0) 
    { 
        int rem = num % base; 
        str[i++] = (rem > 9)? (rem-10) + 'a' : rem + '0'; 
        num = num/base; 
    } 
  
    if (isNegative) 
        str[i++] = '-'; 
  
    str[i] = '\0'; 
  
   
    reverse(str, i); 
  
    return str; 
} 

void codegen()
{
	strcpy(temp,"t");
	char buffer[100];
	itoa(count,buffer,10);
	strcat(temp,buffer);
	printf("%s = %s %s %s\n",temp,s[top-2].value,s[top-1].value,s[top].value);
	top = top - 2;
	strcpy(s[top].value,temp);
	count++; 
}

void codegencon()
{
	strcpy(temp,"t");
	char buffer[100];
	itoa(count,buffer,10);
	strcat(temp,buffer);
	printf("%s = %s\n",temp,curval);
	push(temp);
	count++;
	
}

int isunary(char *s)
{
	if(strcmp(s, "--")==0 || strcmp(s, "++")==0)
	{
		return 1;
	}
	return 0;
}

void genunary()
{
	char temp1[100], temp2[100], temp3[100];
	strcpy(temp1, s[top].value);
	strcpy(temp2, s[top-1].value);

	if(isunary(temp1))
	{
		strcpy(temp3, temp1);
		strcpy(temp1, temp2);
		strcpy(temp2, temp3);
	}
	strcpy(temp, "t");
	char buffer[100];
	itoa(count, buffer, 10);
	strcat(temp, buffer);
	count++;

	if(strcmp(temp2,"--")==0)
	{
		printf("%s = %s - 1\n", temp, temp1);
		printf("%s = %s\n", temp1, temp);
	}

	if(strcmp(temp2,"++")==0)
	{
		printf("%s = %s + 1\n", temp, temp1);
		printf("%s = %s\n", temp1, temp);
	}

	top = top -2;
}

void codeassign()
{
	printf("%s = %s\n",s[top-2].value,s[top].value);
	top = top - 2;
}

void label1()
{
	strcpy(temp,"L");
	char buffer[100];
	itoa(lno,buffer,10);
	strcat(temp,buffer);
	printf("IF not %s GoTo %s\n",s[top].value,temp);
	label[++ltop].labelvalue = lno++;
}

void label2()
{
	strcpy(temp,"L");
	char buffer[100];
	itoa(lno,buffer,10);
	strcat(temp,buffer);
	printf("goto %s\n",temp);
	strcpy(temp,"L");
	itoa(label[ltop].labelvalue,buffer,10);
	strcat(temp,buffer);
	printf("%s:\n",temp);
	ltop--;
	label[++ltop].labelvalue=lno++;
}

void label3()
{
	strcpy(temp,"L");
	char buffer[100];
	itoa(label[ltop].labelvalue,buffer,10);
	strcat(temp,buffer);
	printf("%s:\n",temp);
	ltop--;
	
}

void label4()
{
	strcpy(temp,"L");
	char buffer[100];
	itoa(lno,buffer,10);
	strcat(temp,buffer);
	printf("%s:\n",temp);
	label[++ltop].labelvalue = lno++;
}


void label5()
{
	strcpy(temp,"L");
	char buffer[100];
	itoa(label[ltop-1].labelvalue,buffer,10);
	strcat(temp,buffer);
	printf("goto %s:\n",temp);
	strcpy(temp,"L");
	itoa(label[ltop].labelvalue,buffer,10);
	strcat(temp,buffer);
	printf("%s:\n",temp);
	ltop = ltop - 2;
    
   
}

void funcgen()
{
	printf("Func BEGIN %s\n",currfunc);
}

void funcgenend()
{
	printf("Func END\n\n");
}

void arggen(int i)
{
    if(i==1)
    {
	printf("refparam %s\n", curid);
	}
	else
	{
	printf("refparam %s\n", curval);
	}
}

void callgen()
{
	printf("refparam result\n");
	push("result");
	printf("call %s, %d\n",currfunccall,call_params_count);
}



int main(int argc , char **argv)
{
	yyin = fopen(argv[1], "r");
	yyparse();

	if(flag == 0)
	{
		printf(ANSI_COLOR_GREEN "STATUS: PARSING COMPLETE - VALID" ANSI_COLOR_RESET "\n");
		int i;
                for(i=0;i<160;i++)
                printf("=");
                printf("\n");
		printf("%75s" ANSI_COLOR_CYAN "SYMBOL TABLE" ANSI_COLOR_RESET "\n", " ");
                for(i=0;i<160;i++)
		printf("=");
                printf("\n\n\n");
		showSymbolTable();
                printf("\n\n===========================================================================\n");
		printf("%30s" ANSI_COLOR_CYAN "CONSTANT TABLE" ANSI_COLOR_RESET "\n", " ");
		printf("===========================================================================\n\n\n");
		showConstantTable();
	}
}

void yyerror(char *s)
{
	printf(ANSI_COLOR_RED "Line no : %d %s at token *%s*\n", yylineno, s, yytext);
	flag=1;
	printf(ANSI_COLOR_RED "STATUS: PARSING FAILED - INVALID\n" ANSI_COLOR_RESET);
	int i;
        for(i=0;i<160;i++)
        printf("=");
        printf("\n");
	printf("%75s" ANSI_COLOR_CYAN "SYMBOL TABLE" ANSI_COLOR_RESET "\n", " ");
        for(i=0;i<160;i++)
		printf("=");
        printf("\n\n\n");
	showSymbolTable();
        printf("\n\n===========================================================================\n");
	printf("%30s" ANSI_COLOR_CYAN "CONSTANT TABLE" ANSI_COLOR_RESET "\n", " ");
	printf("===========================================================================\n\n\n");
	showConstantTable();
	exit(7);
}

void ins()
{
	insertSymbolTableType(curid,curtype);
}

void insV()
{
	insertSymbolTableValue(curid,curval);
}

int yywrap()
{
	return 1;
}
