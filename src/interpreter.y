%error-verbose 
%{

/*--------------------------------------------------------------------
 * 
 * Includes
 * 
 *------------------------------------------------------------------*/
#include <stdio.h>
#include <iostream>
#include <map>
#include <string>
#include <cmath>
using namespace std;

/*--------------------------------------------------------------------
 * 
 * Flex and error handling function
 * 
 *------------------------------------------------------------------*/

int                 yylex(void);                 
void                yyerror(const char * msg);  

/*--------------------------------------------------------------------
 * 
 * Global variables
 * 
 *------------------------------------------------------------------*/
int                 line = 1;                  
extern FILE*        yyin;               
map<string, double> pile_exec;   

%}

/*--------------------------------------------------------------------
 *
 * Terminal-symbols
 *
 *------------------------------------------------------------------*/
%token START END PRINT
%token ID NB PI TRUE FALSE
%token PLUS MINUS MULT DIV POW MOD
%token ASSIGN
%token SEMICOLON
%token GRT LESS GE LE EQ DIF
%token NOT AND OR
%token LBRACE RBRACE

/*
 * operator-precedence
 * top-0: !
 *     1: ^
 *     2: * / %
 *     3: + -
 *     4: > >= < <=
 *     5: == !=
 *     6: || &&
 */
%left  AND OR
%left  EQ DIF
%left  GE GRT LESS LE
%left  PLUS MINUS 
%left  MULT DIV MOD
%right POW
%left  NOT

/*------------------------------------------------------------------------------
 *
 * symbols' custom types 
 *
 *----------------------------------------------------------------------------*/
%union { char str[0x100]; double real; bool logic;}
%type<real>  NB expr_arth oprd
%type<str>   ID inst PI GE LE EQ DIF GRT LESS logic_opr
%type<logic> cmp expr_log

/*------------------------------------------------------------------------------
 *
 * Start of grammar
 *
 *----------------------------------------------------------------------------*/
%start axiome

%%

/*------------------------------------------------------------------------------
 *
 * Rules
 *
 *----------------------------------------------------------------------------*/

axiome       : START code END
;
code         : inst code 
             | inst 
             |
;
inst         : expr_log  SEMICOLON            { cout << "Logic Expr is" << $1 << endl;} 
             | expr_arth SEMICOLON            {cout << "Expr_Value : "  << $1 << endl;} 
             | ID ASSIGN expr_arth SEMICOLON  {string key($1);pile_exec[key] = $3;}
             | ID ASSIGN NB SEMICOLON         {string key($1);pile_exec[key] = $3;}
             | ID ASSIGN cmp SEMICOLON        {string key($1);pile_exec[key] = $3;}
             | PRINT ID SEMICOLON    {string key($2);
                if(pile_exec.find(key) == pile_exec.end())
                {
                    string msg = string("Undefined Variable \"") + key + string("\"");
                    yyerror(msg.c_str());
                    YYABORT;
                }
                else
                {
                    cout << "PRINT : " << key << " = " << pile_exec[key] << endl;
                }
             }
             | PRINT expr_arth SEMICOLON {cout << "PRINT : " << $2 << endl;}
;
expr_arth  :   LBRACE expr_arth RBRACE    {$$ = $2; }
             | expr_arth PLUS  expr_arth  {$$ = $1+$3;}
             | expr_arth MINUS expr_arth  {$$ = $1-$3;}
             | expr_arth MULT  expr_arth  {$$ = $1*$3;}
             | expr_arth DIV   expr_arth   { if($3!=0) $$ = $1/$3; 
                                            else{yyerror("Division by zero is undefined ! ");
                                                YYABORT;
                                                }
                                            }
             | expr_arth MOD   expr_arth   { if($3!=0) $$ = (int)$1 % (int)$3; 
                                            else{yyerror("Division by zero is undefined ! ");
                                                YYABORT;
                                                }
                                            }                              
             | expr_arth POW  expr_arth  {$$ = pow($1,$3);}
             | oprd { $$ = $1;}
;

expr_log   :   LBRACE expr_log RBRACE  { $$ = $2; }
             | NOT expr_log            { $$ = !$2;}
             | expr_log AND expr_log   { $$ = $1 && $3;}
             | expr_log OR expr_log    { $$ = $1 || $3;}
             | cmp                     { $$ = $1;}
             | oprd                    { $$ = $1;}

;
cmp        : oprd logic_opr oprd
                {
                   if(string($2) == string("=="))
                        { $$ = $1 == $3; }
                   else if (string($2) == string("!="))
                        { $$ = $1 != $3; }
                   else if(string($2) == string(">"))
                        { $$ = $1 > $3; }
                   else if(string($2) == string(">="))
                        { $$ = $1 >= $3; }
                   else if(string($2) == string("<"))
                        { $$ = $1 < $3; }
                   else if(string($2) == string("<="))
                        { $$ = $1 <= $3; }
                }
;
oprd       :  TRUE  {$$ = 1;}
            | FALSE {$$ = 0;}
            | NB    {$$ = $1;}
            | PI    {$$ = M_PI;  }
            | ID    {string key($1);
                if(pile_exec.find(key) == pile_exec.end())
                {
                    string msg = string("Undefined Variable \"") + key + string("\"");
                    yyerror(msg.c_str());
                    YYABORT;
                }
                else
                {
                    $$ = pile_exec[key];
                } 
                }
;

logic_opr  : GRT | LESS | GE | LE | EQ | DIF
            
             
%%
#include "lex.yy.c"

/*------------------------------------------------------------------------------
 * 
 * functions
 * 
 *----------------------------------------------------------------------------*/

void yyerror(const char * msg)
{
cerr << "Line " << line << ": " << msg << endl;
}

int main(int argc,char ** argv)
{

    if(argc == 2)
        {
            yyin = fopen(argv[1],"r");
            if (yyin)
            {

                yyparse();
                return 0;  
            }
            else
            {
                cout << "Source File is not Found" << endl;
                return 2;
            }
        }
        else
        {
            cout << "Usage : intprt <source_file>" << endl;
            return 1;
        }

}
