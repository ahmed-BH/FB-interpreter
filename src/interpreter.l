%{

/*--------------------------------------------------------------------
 * 
 * includes
 * 
 *------------------------------------------------------------------*/
#include "interpreter.tab.h"

/*--------------------------------------------------------------------
 * 
 * global variables
 * 
 *------------------------------------------------------------------*/
extern int line;
extern string line_content;
int column = 1;              
void   yyerror(const char * msg);  
int    lines_in_comments(char* text, int len);

/*--------------------------------------------------------------------
 * 
 * macros for yylloc
 * 
 *------------------------------------------------------------------*/
#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = line; \
    yylloc.first_column = column; yylloc.last_column = column + yyleng - 1; \
    column = column + yyleng; line_content += string(yytext); 

%}

/*--------------------------------------------------------------------
 * 
 * flex definitions
 * 
 *------------------------------------------------------------------*/

digit         [0-9]
letter        [A-Za-z]
real          [-]?{digit}+[\.]{digit}+
integer       ([-]?[1-9]{digit}*)|0
nb            ({real}|{integer})
id            {letter}({digit}|{letter}|_|{digit})*
pi            [Pp][Ii]
string        \"[^\"]*\"
comment       ("/""*"+([\n\r]|[^"/*"])*"*"+"/")|("//".*[\n])

%%

{comment}     {line += lines_in_comments(yytext,yyleng); column = 1; line_content = "";}
{string}      {line += lines_in_comments(yytext,yyleng); sprintf(yylval.str,"%s",yytext); return STRING;}
"start"       return START;
"end"         return END;
"print"       return PRINT;
"true"        return TRUE;
"false"       return FALSE;
"["			  return LSBRACE;
"]"			  return RSBRACE;
"("           return LBRACE;        
")"           return RBRACE;        
"+"           return PLUS;          
"-"           return MINUS;         
"*"           return MULT;          
"/"           return DIV;           
"^"           return POW;           
"%"           return MOD;           
">"           {sprintf(yylval.str,"%s",yytext); return GRT; }
"<"           {sprintf(yylval.str,"%s",yytext); return LESS;}
">="          {sprintf(yylval.str,"%s",yytext); return GE;  }
"<="          {sprintf(yylval.str,"%s",yytext); return LE;  }
"=="          {sprintf(yylval.str,"%s",yytext); return EQ;  }
"!="          {sprintf(yylval.str,"%s",yytext); return DIF; }
"!"           return NOT; 
"&&"          return AND; 
"||"          return OR;  
"="           return ASSIGN;        
";"           return SEMICOLON;
","           return COMMA;     
{pi}          return PI;    
{id}          {sprintf(yylval.str,"%s",yytext);return ID; }
{real}        {sscanf(yytext,"%lf",&yylval.real);return REAL; }
{integer}        {sscanf(yytext,"%d",&yylval.integer);return INT; }
[\n]          {line++; column = 1; line_content = "";}
[ \t\r]     
.             {char msg[yyleng+1]; sprintf(msg,"invalid syntax : '%s'", yytext); yyerror(msg);}

%%

int yywrap() {return 1;}
int lines_in_comments(char* text, int len)
{
	int nb = 0;
	for(int i=0; i<len; i++)
	{
		if(text[i] == '\n')
		nb++;
	}
	return nb;
}