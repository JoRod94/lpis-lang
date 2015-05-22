%{

#include <stdio.h>
#include <string.h>

extern int yylex();

void yyerror(char* s);

%}

%token num
%token var

%token WHILE
%token IF
%token ELSEIF
%token ELSE
%token PUT
%token GET
%token INT
%token NOT
%token EQL
%token NOT_EQL
%token GREATER_THAN
%token GREATER_OR_EQL
%token LESS_OR_EQL
%token LESS_THAN
%token AND
%token OR

%%

Programa    : BlocoDecl '%''%' ConjInst
            ;

BlocoDecl   :
            | BlocoDecl Declaracao
            ;

Declaracao  : INT TamanhoArray var ';'
            ;

TamanhoArray:
            | '[' num ']'
            ;

ConjInst    :
            | ConjInst Instrucao ';'
            ;

Instrucao   : Atribuicao
            | OperacaoNum
            | OperacaoLog
            | InstIO
            | InstCond
            | InstCiclo
            ;

Atribuicao  : var '=' Valor
            ;

Valor       : var
            | num
            | OperacaoNum
            ;

InstIO      : PUT Valor
            | GET Valor
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

OperacaoLog : Valor OperadorLog Valor
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

Expn        : OpParenteses
            | OpParenteses '^' Expn
            ;

OpParenteses: '(' Valor ')'
            ;
%%

void yyerror(char* s) {
    printf(s);
}

int main() {
    yyparse();
    return 0;
}

