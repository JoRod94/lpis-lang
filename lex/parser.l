
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
#define COMMA       ','

#define PLUS        '+'
#define MINUS       '-'
#define MULT        '*'
#define DIV         '/'

%}



_NUM                -?[0-9]+
_STRINGVAL           \"[^" \t\n]+\"
_IDENT              [a-zA-Z_0-9]+
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
_ARROW              ->
_VOID               void
_RETURN             return
_FN                 fn
_COMMA              ,


%option yylineno
%%

{_NUM}          { yylval.val = atoi(yytext); return num; }
{_WHILE}        { return WHILE; }
{_IF}           { return IF; }
{_ELSE}         { return ELSE; }
{_ELSEIF}       { return ELSEIF; }
{_INT}          { return INT; }
{_PUT}          { return PUT; }
{_GET}          { return GET; }
{_GRT}          { return GREATER_THAN; }
{_GRT_EQL}      { return GREATER_OR_EQL; }
{_LSS}          { return LESS_THAN; }
{_LSS_EQL}      { return LESS_OR_EQL; }
{_EQL}          { return EQL; }
{_NOT_EQL}      { return NOT_EQL; }
{_NOT}          { return NOT; }
{_ATRBN}        { return ATRIBUTION; }
{_SEMI}         { return SEMICOLON; }
{_PLUS}         { return PLUS; }
{_MINUS}        { return MINUS; }
{_DIV}          { return DIV; }
{_ARROW}        { return ARROW; }
{_VOID}         { return VOID; }
{_FN}           { return FN; }
{_RETURN}       { return RETURN; }
{_CLOSE_PAR}    { return CLOSE_PAR; }
{_OPEN_PAR}     { return OPEN_PAR; }
{_O_SQR_BRKT}   { return O_SQR_BRKT; }
{_C_SQR_BRKT}   { return C_SQR_BRKT; }
{_O_BRACKETS}   { return O_BRACKETS; }
{_C_BRACKETS}   { return C_BRACKETS; }
{_COMMA}        { return COMMA; }
{_IDENT}          { yylval.word = strdup(yytext); return ident; }
{_STRINGVAL}     { yylval.word = strdup(yytext); return stringval; }
[ \t\n]     ;
.               { return ERROR; }

