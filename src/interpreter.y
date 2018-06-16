%error-verbose 
%{

/*--------------------------------------------------------------------
 * 
 * Console colors (only UNIX)
 * 
 *------------------------------------------------------------------*/
#ifdef _WIN32
    #define GREEN   ""
    #define RED     "" 
    #define RST     ""
    #define BLD     ""
#else
    #define GREEN   "\033[32;1m"
    #define RED     "\033[31;1m" 
    #define RST     "\033[0m"
    #define BLD     "\033[1m"
#endif

#define MAX_ARGS 20
/*--------------------------------------------------------------------
 * 
 * Includes
 * 
 *------------------------------------------------------------------*/
#include <stdio.h>
#include <iostream>
#include <string.h>
#include <string>
#include <cmath>
#include <map>
#include <vector>
#include <typeinfo>
#include <boost/any.hpp>
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
int                     line = 1;      
string                  line_content;            
extern FILE*            yyin;     
string                  filename;          
map<string, boost::any> stack_call;  
struct func_args
{
    double  f_args[MAX_ARGS] ;
    int     size;
}; 

struct return_t
{
    double  result;
    string  error;
};


/*--------------------------------------------------------------------
 * 
 * my includes
 * 
 *------------------------------------------------------------------*/
#include "str_ops.c"
#include "cmath.c"

%}

/*--------------------------------------------------------------------
 *
 * Terminal-symbols
 *
 *------------------------------------------------------------------*/
%token START END PRINT
%token ID INT REAL PI TRUE FALSE
%token PLUS MINUS MULT DIV POW MOD
%token ASSIGN
%token GRT LESS GE LE EQ DIF
%token NOT AND OR
%token LBRACE RBRACE COMMA SEMICOLON LSBRACE RSBRACE
%token STRING

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
%union { 
    char             str[0x100];
    char             charac; 
    double           real; 
    int              integer;
    bool             logic;
    struct func_args t_args;
 }
%type<real>       REAL expr_arth oprd B-IN-func
%type<integer>    INT
%type<str>        ID inst PI GE LE EQ DIF GRT LESS logic_opr STRING expr_str
%type<logic>      cmp expr_log
%type<t_args>     args

/*------------------------------------------------------------------------------
 *
 * track token's location
 *
 *----------------------------------------------------------------------------*/
%locations

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
inst         : expr_log  SEMICOLON            {cout << "Logic Expr      : "  << $1 << endl;} 
             | expr_arth SEMICOLON            {cout << "Arithmetic Expr : "  << $1 << endl;} 
             | ID ASSIGN expr_log SEMICOLON   {string key($1);stack_call[key] = $3;}
             | ID ASSIGN expr_arth SEMICOLON  {string key($1);stack_call[key] = $3;}
             | PRINT expr_arth SEMICOLON      {cout << "PRINT           : " << $2 << endl;}
             | PRINT expr_log SEMICOLON       {cout << "PRINT           : " << $2 << endl;}
             | PRINT expr_str SEMICOLON       {cout << "PRINT           : " << $2 << endl;}
;

expr_str     : expr_str PLUS expr_str     {string tmp = string($1)+string($3); strcpy($$,tmp.c_str());}
             | STRING MULT INT            {string tmp = str_mult($1,(int)$3); strcpy($$,tmp.c_str()); }
             | STRING MULT REAL           {yyerror("can't multiply string by non-int type");YYABORT;}
             | STRING MULT STRING         {yyerror("can't multiply string by non-int type");YYABORT;}
             | STRING LSBRACE INT RSBRACE {
                                            if($3 >= 0 && $3 < strlen($1)-2) // "a" = 3 charac
                                            { 
                                              string tmp(1, $1[$3+1]);
                                              strcpy($$,tmp.c_str());
                                              
                                            }
                                            else
                                            { 
                                                // change next_token loc to dectect the exact error_loc
                                                yylloc.first_column = @3.first_column;
                                                yylloc.last_column = @3.last_column; 
                                                yylloc.first_line  = @3.first_line;
                                                // end
                                              string msg = "string index out of range : given index " + 
                                              to_string($3) + " while string length is " + to_string(strlen($1)-2);
                                              yyerror(msg.c_str());
                                              YYABORT;
                                            }
                                          }
             | STRING                     {string tmp = str($1);strcpy($$,tmp.c_str());}
;

expr_arth  :   LBRACE expr_arth RBRACE    {$$ = $2; }
             | expr_arth PLUS  expr_arth  {$$ = $1+$3;}
             | expr_arth MINUS expr_arth  {$$ = $1-$3;}
             | expr_arth MULT  expr_arth  {$$ = $1*$3;}
             | expr_arth DIV   expr_arth   { if($3) $$ = $1/$3; 
                                            else{
                                                // change next_token loc to dectect the exact error_loc
                                                yylloc.first_column = @3.first_column;
                                                yylloc.last_column = @3.last_column; 
                                                yylloc.first_line  = @3.first_line;
                                                // end
                                                yyerror("Division by zero is undefined ! ");
                                                YYABORT;
                                                }
                                            }
             | expr_arth MOD   expr_arth   { if($3) $$ = (int)$1 % (int)$3; 
                                            else{
                                                // change next_token loc to dectect the exact error_loc
                                                yylloc.first_column = @3.first_column;
                                                yylloc.last_column = @3.last_column; 
                                                yylloc.first_line  = @3.first_line;
                                                // end
                                                yyerror("Division by zero is undefined ! ");
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

logic_opr  : GRT | LESS | GE | LE | EQ | DIF
;

oprd       :  TRUE    {$$ = true;}
            | FALSE   {$$ = false;}
            | REAL    {$$ = $1;}
            | INT     {$$ = $1;}
            | PI      {$$ = M_PI;}
            | ID    {string key($1);
                if(stack_call.find(key) == stack_call.end())
                {
                    // change next_token loc to dectect the exact error_loc
                    yylloc.first_column = @1.first_column;
                    yylloc.last_column = @1.last_column; 
                    yylloc.first_line  = @1.first_line;
                    // end
                    string msg = string("Variable \"") + key + string("\" is not declared");
                    yyerror(msg.c_str());
                    YYABORT;
                }
                else
                {
                    // support for dynamically typed variables
                    if(stack_call[key].type() == typeid(double))
                        $$ = boost::any_cast<double>(stack_call[key]);
                    else if(stack_call[key].type() == typeid(int))
                        $$ = boost::any_cast<int>(stack_call[key]);
                    else if(stack_call[key].type() == typeid(bool))
                        $$ = boost::any_cast<bool>(stack_call[key]);
                    else
                    {
                        // change next_token loc to dectect the exact error_loc
                        yylloc.first_column = @1.first_column;
                        yylloc.last_column = @1.last_column; 
                        yylloc.first_line  = @1.first_line;
                        // end
                        string msg = string("not supported type for a Variable");
                        yyerror(msg.c_str());
                        YYABORT;
                    }

                } 
                }
            | B-IN-func
;

B-IN-func  : ID LBRACE args RBRACE 
          { return_t func_res = built_in_func($1, $3) ;
            if(func_res.error != "")
            {
                // change next_token loc to dectect the exact error_loc
                yylloc.first_column = @1.first_column;
                yylloc.last_column = @4.last_column; 
                yylloc.first_line  = @1.first_line;
                // end
              yyerror(func_res.error.c_str());
              YYABORT;
            }
            else
            {
             $$ = func_res.result;
            }
         }
;

args       : expr_arth COMMA args 
            {
              $$.size = 1 + $3.size;
              $$.f_args[0] = $1;
              for(int i=1; i < $$.size; i++)
              {
                $$.f_args[i] = $3.f_args[i-1];
              }                              
            }
           | expr_arth { $$.size = 1;
                    $$.f_args[0] = $1;
                  }
           | {$$.size = 0;}
;
             
%%
#include "lex.yy.c"

/*------------------------------------------------------------------------------
 * 
 * functions
 * 
 *----------------------------------------------------------------------------*/
void yyerror(const char * msg)
{
    if(yylloc.first_line)
    {
        cerr <<BLD<< filename << ":"<< yylloc.first_line << ":" << yylloc.first_column << RST ;
        cerr <<BLD<< RED<<" error : " << RST << msg << endl;        
    }
    else
    {
        cerr << RED << "Error : " << RST << msg << endl;
    }

    /*--------------------------------------------------------------------
     * 
     * nicely print the error
     *
     *------------------------------------------------------------------*/
    cerr <<BLD<< filename <<":"<< yylloc.first_line<<RST << "\t" << line_content << endl;
    int nb_spaces = filename.size() + to_string(yylloc.first_line).size();
    for(int i=1; i <= nb_spaces ; i++)
        cerr << " ";
    cerr << "\t";
    for(int i=1; i < yylloc.first_column; i++)
        cerr << GREEN << "." << RST;
    for(int i=yylloc.first_column; i<= yylloc.last_column; i++ )
        cerr << RED << "^" << RST;
    cerr << endl;

}


int main(int argc, char ** argv)
{

    if(argc == 2)
        {
            yyin = fopen(argv[1],"r");
            if (yyin)
            {
                filename = string(argv[1]);
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
