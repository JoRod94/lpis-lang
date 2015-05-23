%{

#include <stdio.h>
#include <string.h>

extern int yylex();

void yyerror(char* s);

%}

%token num
%token var

%token INT

%token WHILE
%token IF
%token ELSEIF
%token ELSE

%token PUT
%token GET

%token NOT
%token EQL
%token NOT_EQL
%token GREATER_THAN
%token GREATER_OR_EQL
%token LESS_OR_EQL
%token LESS_THAN
%token AND
%token OR

%token DECLARATION

%token ERROR

%%

Programa    : BlocoDecl DECLARATION ConjInst
            ;

BlocoDecl   :
            | BlocoDecl Declaracao
            ;

Declaracao  : INT TamanhoArray Variavel ';'
            ;

Variavel    : var
            | var '[' OperacaoNum ']'

TamanhoArray:
            | '[' num ']'
            ;

ConjInst    :
            | ConjInst Instrucao ';'
            ;

Instrucao   : Atribuicao
            | InstIO
            | InstCond
            | InstCiclo
            ;

Atribuicao  : Variavel '=' OperacaoNum
            ;

InstIO      : PUT OperacaoNum
            | GET OperacaoNum
            ;

InstCiclo   : WHILE BlocoCond
            ;

BlocoCond   : '(' ExpressaoLog ')' BlocoCodigo
            ;

BlocoCodigo : '{' ConjInst '}'
            ;

InstCond    : IF BlocoCond Alternativa
            ;

Alternativa :
            | ListaElseIf ELSE BlocoCodigo
            ;

ListaElseIf :
            | ELSEIF BlocoCond ListaElseIf
            ;

ExpressaoLog: ExpressaoLog OR ExpLog1
            | ExpLog1
            ;

ExpLog1     : ExpLog1 AND ExpLog2
            | ExpLog2
            ;

ExpLog2     : NOT '(' ExpressaoLog ')'
            | ExpLog0

ExpLog0     : OperacaoLog
            | '(' ExpressaoLog ')'
            ;

OperacaoLog : OperacaoNum OperadorLog OperacaoNum
            |

OperadorLog : GREATER_THAN
            | LESS_THAN
            | GREATER_OR_EQL
            | LESS_OR_EQL
            | EQL
            | NOT_EQL
            ;

OperacaoNum : Produto
            | OperacaoNum '+' Produto
            | OperacaoNum '-' Produto
            ;

Produto     : Expn
            | Produto '*' Expn
            | Produto '/' Expn
            ;

Expn        : OpParenteses '^' Expn
            | OpParenteses
            ;

OpParenteses: num
            | Variavel
            | '(' OperacaoNum ')'
            ;

%%

void yyerror(char* s) {
    printf("\x1b[37;01m%s\x1b[0m", s);
}

int main() {
    yyparse();
    return 0;
}

