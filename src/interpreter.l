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
void   yyerror(const char * msg);  
int    lines_in_comments(char* text, int len);

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
comment       ("/""*"+([\n\r]|[^"/*"])*"*"+"/")|("//".*[\n])

%%

{comment}     line += lines_in_comments(yytext,yyleng);
"start"       return START;
"end"         return END;
"print"       return PRINT;
"true"        return TRUE;
"false"       return FALSE;
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
{pi}          return PI;    
{id}          {sprintf(yylval.str,"%s",yytext);return ID;   }
{nb}          {sscanf(yytext,"%lf",&yylval.real);return NB; }
[\n]          line++;
[ \t\r]     
.             {char msg[yyleng+1]; sprintf(msg,"Lexical Error : %s", yytext); yyerror(msg);}

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