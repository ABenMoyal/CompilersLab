%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int lines = 0;

void printTok(int token);
char* getOutputFileName(char* fileName, char* extension);
void handleRELOP();
void printCenterText(const char *text);
const char* getTokName(Tok tok);
FILE* tokFile;
int tableWidth = 20;

%}

digit		[0-9]
id    		[a-zA-Z]+
ws		    [ \t]+
num 		{digit}+|{digit}*\.{digit}+
relop       ["<"|">"|"<>"|"="]
addop       ["+"|"-"]
mulop       ["*"|"/"|"mod"]
logop       ["&"|"~"|"!"]
%x comment

%%

"/*"		BEGIN comment;
<comment>"*/"	BEGIN INITIAL;
<comment>.|\n	;
^start		{fprintf(yyout,"%d: ",lines); ECHO; return START;}
start		{ECHO; return START;}
^if			{fprintf(yyout,"%d: ",lines); ECHO; return IF;}
if			{ECHO; return IF;}
^else		{fprintf(yyout,"%d: ",lines); ECHO; return ELSE;}
else		{ECHO; return ELSE;}
^do			{fprintf(yyout,"%d: ",lines); ECHO; return DO;}
do			{ECHO; return DO;}
^int 		{fprintf(yyout,"%d: ",lines); ECHO; return INT;}
int 		{ECHO; return INT;}
^endi 		{fprintf(yyout,"%d: ",lines); ECHO; return ENDI;}
endi 		{ECHO; return ENDI;}
^put 		{fprintf(yyout,"%d: ",lines); ECHO; return PUT;}
put 		{ECHO; return PUT;}
^prog 		{fprintf(yyout,"%d: ",lines); ECHO; return PROG;}
prog 		{ECHO; return PROG;}
^get 		{fprintf(yyout,"%d: ",lines); ECHO; return GET;}
get 		{ECHO; return GET;}
^real 		{fprintf(yyout,"%d: ",lines); ECHO; return REAL;}
real 		{ECHO; return REAL;}
^then 		{fprintf(yyout,"%d: ",lines); ECHO; return THEN;}
then 		{ECHO; return THEN;}
^var 		{fprintf(yyout,"%d: ",lines); ECHO; return VAR;}
var 		{ECHO; return VAR;}
^loop 		{fprintf(yyout,"%d: ",lines); ECHO; return LOOP;}
loop 		{ECHO; return LOOP;}
^endl 		{fprintf(yyout,"%d: ",lines); ECHO; return ENDL;}
endl 		{ECHO; return ENDL;}
^until 		{fprintf(yyout,"%d: ",lines); ECHO; return UNTIL;}
until 		{ECHO; return UNTIL;}
^endp 		{fprintf(yyout,"%d: ",lines); ECHO; return ENDP;}
endp 		{ECHO; return ENDP;}
^{num}		{fprintf(yyout,"%d: ",lines); ECHO; return NUMBER;}
{num}		{ECHO; return NUMBER;}
^{id}		{fprintf(yyout,"%d: ",lines); ECHO; return ID;}
{id}		{ECHO; return ID;}
^{ws}		{fprintf(yyout,"%d: ",lines); ECHO; }
{ws}		{ECHO;}

^"<="       {fprintf(yyout,"%d: ",lines); ECHO; return ASSIGNOP;}
"<="       {ECHO; return ASSIGNOP;}
^{relop}     {fprintf(yyout,"%d: ",lines); ECHO; handleRELOP(); return RELOP;}
{relop}     {ECHO; handleRELOP(); return RELOP;}
^{addop}     {fprintf(yyout,"%d: ",lines); ECHO; return ADDOP;}
{addop}     {ECHO; return ADDOP;}
^{mulop}     {fprintf(yyout,"%d: ",lines); ECHO; return MULOP;}
{mulop}     {ECHO; return MULOP;}
^{logop}     {fprintf(yyout,"%d: ",lines); ECHO; return LOGOP;}
{logop}     {ECHO; return LOGOP;}

^";"			{fprintf(yyout,"%d: ",lines); ECHO; return SEMICOL;}
";"			{ECHO; return SEMICOL;}
^":"			{fprintf(yyout,"%d: ",lines); ECHO; return COLON;}
":"			{ECHO; return COLON;}
^","			{fprintf(yyout,"%d: ",lines); ECHO; return COMA;}
","			{ECHO; return COMA;}
^"("			{fprintf(yyout,"%d: ",lines); ECHO; return LP;}
"("			{ECHO; return LP;}
^")"			{fprintf(yyout,"%d: ",lines); ECHO; return RP;}
")"			{ECHO; return RP;}
^\n        	{fprintf(yyout,"%d: ",lines); ECHO; lines++;}
\n        	{ECHO; lines++;}
^"\."			{fprintf(yyout,"%d: ",lines); ECHO; return DOT;}
"\."			{ECHO; return 0;}
.			{fprintf(yyout,"\nUnexpected character at line %d: %s\n",lines, yytext); return 0;}
%%

int main(int argc, char** argv)
{
  int token;
  if(argc > 1){
	yyin = fopen(argv[1],"r");
	if(!yyin){
		printf("Failed to open file %s", argv[1]);
		return 1;
	}
  }
  else{
	  printf("Missing argument: input file name");
	  return 1;
  }

  char* LSToutputFileName = getOutputFileName(argv[1], ".lst");
  yyout = fopen(LSToutputFileName, "w");
  char* TOKoutputFileName = getOutputFileName(argv[1], ".tok");
  tokFile = fopen(TOKoutputFileName, "w");
  if(!yyout){
  		printf("Failed to open file %s", LSToutputFileName);
		return 1;
  }
  if(!tokFile){
        printf("Failed to open file %s", TOKoutputFileName);
  		return 1;
  }
  printCenterText("LEXEME");
  printCenterText("TOKEN");
  printCenterText("ATTRIBUTE");
  while( token = yylex()){
        if(token==WS) continue;
        fprintf(tokFile, "\n");
        printCenterText(yytext);
        printCenterText(getTokName(token));
        printCenterText("ATTRIBUTE");
  }
  
  return 0;
}



void handleRELOP(){
 //   if(yytext=="<") yylval=LT;
 //   else if(yytext==">") yylval=GT;
 //   else if(yytext=="<>") yylval=NE;
 //   else if(yytext=="=") yylval=EQ;
}

void printCenterText(const char *text) {
    int padlen = (tableWidth - strlen(text)) / 2;
    fprintf(tokFile ,"%*s%s%*s", padlen, "", text, padlen, "");
}

char* getOutputFileName(char* fileName, char* extension){
    char* dotPos = strstr(fileName, ".sle");
	IF(!dotPos || *(dotPos+4)!=0){
		printf("Wrong argument. file name must end with '.sle'");
		exit(1);
	}
	char* outputName = (char*)calloc(strlen(fileName), 1);
	char* outputNameRunner = outputName;
	char* runnerPointer = fileName;
    
    // copy basename
	while(runnerPointer != dotPos) *outputNameRunner++ = *runnerPointer++;
	// add extension
	while(*extension != 0) *outputNameRunner++ = *extension++;
	*outputNameRunner = 0;
	return outputName;
}

const char* getTokName(Tok tok){
    switch(tok){
        case LOGOP: return "LOGOP";
        case RELOP: return "RELOP";
        case ADDOP: return "ADDOP";
        case ASSIGNOP: return "ASSIGNOP";
        case DOT: return "DOT";
        case MULOP: return "MULOP";
        case COMA: return "COMA";
        case LP: return "LP";
        case RP: return "RP";
        case COLON: return "COLON";
        case SEMICOL: return "SEMICOL";
        case NUMBER: return "NUMBER";
        case ID: return "ID";
        case WS: return "WS";
        case WHILE: return "WHILE";
        case IF: return "IF";
        case ELSE: return "ELSE";
        case START: return "START";
        case DO: return "DO";
        case INT: return "INT";
        case ENDI: return "ENDI";
        case ENDP: return "ENDP";
        case PUT: return "PUT";
        case PROG: return "PROG";
        case GET: return "GET";
        case REAL: return "REAL";
        case LOOP: return "LOOP";
        case THEN: return "THEN";
        case VAR: return "VAR";
        case ENDL: return "ENDL";
        case UNTIL: return "UNTIL";
    }
}

int yywrap()
{
	return 0;
}