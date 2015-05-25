%{
#include "parser.tab.h"


#define OPEN_PAR    '('
#define CLOSE_PAR   ')'
#define O_SQR_BRKT  '['
#define C_SQR_BRKT  ']'
#define O_BRACKETS  '{'
#define C_BRACKETS  '}'

#define ATRIBUTION  '='
#define SEMICOLON   ';'

#define PLUS        '+'
#define MINUS       '-'
#define MULT        '*'
#define DIV         '/'

%}

_NUM                -?[0-9]+
_VAR                [a-zA-Z_]+
_WHILE              while
_IF                 if
_ELSE               else
_ELSEIF             elseif
_AND                &&
_OR                 ||
_GRT_EQL            \>=
_GRT                \>
_LSS_EQL            \<=
_LSS                \<
_EQL                ==
_NOT_EQL            !=
_INT                int
_NOT                !
_PUT                put
_GET                get
_DECL               %%
_CLOSE_PAR          \)
_OPEN_PAR           \(
_O_SQR_BRKT         \[
_C_SQR_BRKT         \]
_O_BRACKETS         \{
_C_BRACKETS         \}
_ATRBN              =
_SEMI               ;
_PLUS               \+
_MINUS              -
_MULT               \*
_DIV                \\
_EXPN               \^

%%

{_NUM}          { /*printf("num ");*/ yylval.val = atoi(yytext); return num; }
{_WHILE}        { /*printf("WHILE ");*/ return WHILE; }
{_IF}           { /*printf("IF ");*/ return IF; }
{_ELSE}         { /*printf("ELSE ");*/ return ELSE; }
{_ELSEIF}       { /*printf("ELSEIF ");*/ return ELSEIF; }
{_INT}          { /*printf("INT ");*/ return INT; }

{_PUT}          { /*printf("PUT ");*/ return PUT; }
{_GET}          { /*printf("GET ");*/ return GET; }

{_GRT}          { /*printf("GREATER_THAN ");*/ return GREATER_THAN; }
{_GRT_EQL}      { /*printf("GREATER_OR_EQL ");*/ return GREATER_OR_EQL; }
{_LSS}          { /*printf("LESS_THAN ");*/ return LESS_THAN; }
{_LSS_EQL}      { /*printf("LESS_OR_EQL ");*/ return LESS_OR_EQL; }
{_EQL}          { /*printf("EQL ");*/ return EQL; }
{_NOT_EQL}      { /*printf("NOT_EQL ");*/ return NOT_EQL; }
{_NOT}          { /*printf("NOT ");*/ return NOT; }

{_DECL}         { /*printf("DECLARATION ");*/ return DECLARATION; }
{_VAR}          { /*printf("var ");*/ yylval.variable.name = strdup(yytext); return var; }

{_ATRBN}        { /*printf("ATRIBUTION ");*/ return ATRIBUTION; }
{_SEMI}         { /*printf("SEMICOLON ");*/ return SEMICOLON; }
{_PLUS}         { /*printf("PLUS ");*/ return PLUS; }
{_MINUS}        { /*printf("MINUS ");*/ return MINUS; }
{_DIV}          { /*printf("DIV ");*/ return DIV; }

{_CLOSE_PAR}    { /*printf("_CLOSE_PAR ");*/ return CLOSE_PAR; }
{_OPEN_PAR}     { /*printf("_OPEN_PAR ");*/ return OPEN_PAR; }
{_O_SQR_BRKT}   { /*printf("_O_SQR_BRKT ");*/ return O_SQR_BRKT; }
{_C_SQR_BRKT}   { /*printf("_C_SQR_BRKT ");*/ return C_SQR_BRKT; }
{_O_BRACKETS}   { /*printf("_O_BRACKETS ");*/ return O_BRACKETS; }
{_C_BRACKETS}   { /*printf("_C_BRACKETS ");*/ return C_BRACKETS; }
[ \t\n]     ;
.               { /*printf("ERROR ");*/ return ERROR; }

