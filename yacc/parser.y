%{

#include <stdio.h>
#include <string.h>
#include "../src/char_stack.h"
#include <stdlib.h>

#define LABEL_COUNT_MAX 10

extern int yylex();

void yyerror(char* s);

CharStack *returnLabels;
CharStack *continueLabels;

int returnLabelCount;
int continueLabelCount;

int sp;

int inArray;

void addContinueLabel(){
    char *label = (char *) malloc(10+LABEL_COUNT_MAX);
    sprintf(label, "continuel%d", continueLabelCount);
    continueLabelCount++;
    cs_push(continueLabels, label);
    printf("jz %s\n", label);
}

void addReturnLabel(){
    char *label = (char *) malloc(7+LABEL_COUNT_MAX);
    sprintf(label, "returnl%d", returnLabelCount);
    returnLabelCount++;
    cs_push(returnLabels, label);
    printf("%s: NOP\n", label);
}

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

%union{
    int val;
    struct vb{
        char *name;
        int index;
    } variable;
}

%type <val> num;
%type <val> TamanhoArray;
%type <variable.name> var;
%type <variable> Variavel;

%type <val> OperacaoNum;
%type <val> Produto;
%type <val> OpParenteses;
%%

Programa    : BlocoDecl DECLARATION ConjInst
            ;

BlocoDecl   :
            | BlocoDecl Declaracao
            ;

Declaracao  : INT TamanhoArray Variavel ';'         {
                                                        //HASHPUT $3.name COM SP
                                                        if($2>=0){
                                                            printf("PUSHN %d\n", $2);
                                                            sp+= $2;
                                                        }
                                                        else{
                                                            printf("PUSHI 0\n");
                                                            sp++;
                                                        }
                                                    }

Variavel    : var                                                   {$$.name = $1; $$.index = -1;}
            | var '[' {inArray = 1;} OperacaoNum {inArray = 0;}']'    {$$.name = $1; $$.index = $4;}

TamanhoArray:                                       {$$ = -1;}
            | '[' num ']'                           {$$ = $2;}

ConjInst    :
            | ConjInst Instrucao ';'
            ;

Instrucao   : Atribuicao
            | InstIO
            | InstCond
            | InstCiclo
            ;

Atribuicao  : Variavel '=' OperacaoNum              {
                                                        if($1.index < 0){
                                                            printf("STOREG HASHGET_NORMAL\n");
                                                        }
                                                        else{
                                                            printf("STOREG HASHGET_COMSOMA\n");    
                                                        }
                                                    }

InstIO      : PUT OperacaoNum                       { printf("WRITEI\n");}
            | GET OperacaoNum
            ;

InstCiclo   : WHILE     {
                        addReturnLabel();
                        }
                            BlocoCond     
                            {
                                printf("jump %s\n", cs_pop(returnLabels));
                                printf("%s: NOP\n", cs_pop(continueLabels));

                            }                  

BlocoCond   :   '(' ExpressaoLog ')' 
                                    {addContinueLabel();} 
                                                BlocoCodigo
	       | '(' OperacaoNum ')' BlocoCodigo

BlocoCodigo : '{' ConjInst '}'                        ;

InstCond    : IF BlocoCond Alternativa {printf("%s: NOP\n", cs_pop(continueLabels));}
            ;

Alternativa :
            | ListaElseIf ELSE BlocoCodigo
            ;

ListaElseIf :
            | ELSEIF BlocoCond  {printf("%s: NOP\n", cs_pop(continueLabels));}  ListaElseIf 
            ;

ExpressaoLog: ExpressaoLog OR ExpLog1
            | ExpLog1
            ;

ExpLog1     : ExpLog1 AND ExpLog2
            | ExpLog2
            ;

ExpLog2     : NOT '(' ExpressaoLog ')'
            | ExpLog0
            ;

ExpLog0     : OperacaoLog
            | '(' ExpressaoLog ')'
            ;

OperacaoLog : OperacaoNum OperadorLog OperacaoNum
            ;

OperadorLog : GREATER_THAN
            | LESS_THAN
            | GREATER_OR_EQL
            | LESS_OR_EQL
            | EQL
            | NOT_EQL
            ;

OperacaoNum : Produto                               { $$ = $1; }
            | OperacaoNum '+' Produto               {
                                                     $$ = $1 + $3;
                                                     if(!inArray) printf("ADD\n");
                                                    }
            | OperacaoNum '-' Produto               {
                                                     $$ = $1 + $3;
                                                     if(!inArray) printf("SUB\n");}
            ;

Produto     : OpParenteses                          { $$ = $1; }
            | Produto '*' OpParenteses              {
                                                     $$ = $1 * $3;
                                                     if(!inArray) printf("MUL\n");
                                                    }
            | Produto '/' OpParenteses              {
                                                     $$ = $1 / $3;
                                                     if(!inArray) printf("DIV\n");
                                                    }
            ;

OpParenteses: num                                   { 
                                                        $$ = $1;
                                                        if(!inArray) printf("PUSHI %d\n", $1);}
            | Variavel                              {   //$$ = HASHGET
                                                        if($1.index < 0){
                                                            //$$ = HASHGET
                                                            if(!inArray) printf("PUSHG HASHGET_NORMAL\n");
                                                        }
                                                        else{
                                                            //$$ = HASHGET
                                                            if(!inArray) printf("PUSHG HASHGET_COMSOMA\n");
                                                        }
                                                    }
            | '(' OperacaoNum ')'                   { $$ = $2;}
            ;

%%

void yyerror(char* s) {
    printf("\x1b[37;01m%s\x1b[0m", s);
}



int main() {
    inArray = 0;
    sp = 0;
    returnLabelCount = 1;
    continueLabelCount = 1;
    returnLabels = (CharStack *) malloc(sizeof(CharStack));
    continueLabels = (CharStack *) malloc(sizeof(CharStack));
    cs_init(returnLabels);
    cs_init(continueLabels);
    yyparse();
    return 0;
}

