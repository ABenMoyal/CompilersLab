%{
#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>

int yyerror(char* s);
void ourError(char* s);
int yylex();
%}

%token DOT COMA LP RP COLON SEMICOL NUMBER ID WS RELOP WHILE IF ELSE START DO INT ENDI ENDP PUT PROG GET REAL LOOP THEN VAR ENDL UNTIL LT GT NE EQ
%left ADDOP MULOP
%right ASSIGNOP LOGOP

%%
program: programStart declarations START stmtList ENDP DOT  {return 0;}
;
programStart: PROG ID SEMICOL 
| error  {ourError("Program should start with 'prog ID ;'");}
;
declarations: VAR declList SEMICOL  {}
| error  {ourError("Declerations list should start with 'var' and end with ';'");}
;
declList: declList COMMA ID COLON type  
			| ID COLON type
| error  {ourError("Each declaration should be in format ID:Type (seperated with ',')");}
;
type:  INT  
	|  REAL 
| error  {ourError("Type should be 'int' or 'real'");}
;  
stmtList: stmtList statement SEMICOL 
			| 
			| error {ourError("For Debug!!!!!!!!");}  /* Debug Mode. TODO: Remove */
;
statement: ID ASSIGNOP expression  
			| PUT expression  
			| GET ID  
			| IF boolExp THEN stmtList ELSE stmtList ENDI
			| IF boolExp THEN stmtList  ENDI
			| LOOP boolExp DO stmtList ENDL 
			| DO stmtList UNTIL boolExp ENDL 
;
boolExp: expression case expression
;
case: RELOP 
	| LOGOP
;
expression: expression ADDOP term  
		|  term
;
term: term MULOP factor 
		| factor
;
factor: ID
		|  NUMBER
		|  (expression)	
;

%%

int main(int argc, char* argv[]){
	char* outputFileName = getOutputFileName(argv[1], ".lst");
}

void yyerror(char *errorMsg) {
	printf(yyout, "%s\n", errorMsg);
	printf(stderr, "%s\n", errorMsg);  /* Debug Mode. TODO: Remove*/
}

void ourError(char *errorMsg) {
	printf(yyout, "Line: %d\t", lines);
	printf(stderr, "Line: %d\t", lines);
	yyerror(errorMsg);
	printf("Prog Failed");
	exit(1);
}




