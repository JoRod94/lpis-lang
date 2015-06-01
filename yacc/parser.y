%{

#include <stdio.h>
#include <string.h>
#include "char_stack.h"
#include <stdlib.h>
#include "hash.h"

#define LABEL_COUNT_MAX 10

#define S_GREATER_THAN 1
#define S_LESS_THAN 2
#define S_GREATER_OR_EQL 3
#define S_LESS_OR_EQL 4
#define S_EQL 5
#define S_NOT_EQL 6

extern int yylex();

void yyerror(char* s);

CharStack *returnLabels;
CharStack *continueLabels;

int returnLabelCount;
int continueLabelCount;
int endLabelCount;



int sp;

void handleSymbol(int symbol);

void addJzContinueLabel();

void addReturnLabel();

void addEndJump();

hash varHash;
variable found_var;

%}

%token num
%token pal
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
    char *word;
    struct vb{
        char *name;
        int addr;
    } variable;
}

%type <val> num;
%type <val> TamanhoArray;
%type <val> OperadorLog;
%type <word> pal;
%type <word> Variavel;

%%

Programa    : BlocoDecl DECLARATION ConjInst
            ;

BlocoDecl   :
            | BlocoDecl Declaracao
            ;

Declaracao  : INT TamanhoArray pal ';'         { 
                                                    if(hash_get(&varHash, $3) != NULL)
                                                        yyerror("Repeated variable\n");
                                                    else{
                                                        hash_put(&varHash, $3, sp); }
                                                        if($2>=0){
                                                            printf("PUSHN %d\n", $2);
                                                            sp+= $2;
                                                        }
                                                        else{
                                                            printf("PUSHI 0\n");
                                                            sp++;
                                                        }
                                                    }

Variavel    : pal                               {   
                                                    if( ( found_var = hash_get(&varHash, $1) ) == NULL){
                                                        yyerror("Variable not found\n");
                                                        exit(0);
                                                        }
                                                    printf("PUSHI %d\n", found_var->val);
                                                    printf("PUSHI 0\n");
                                                    $$ = strdup($1);
                                                }
            | pal {
                        if( ( found_var = hash_get(&varHash, $1) ) == NULL){
                            yyerror("Variable not found\n");
                            exit(0);
                        }
                        else
                            printf("PUSHI %d\n", found_var->val);
                       } 
                                        '[' OperacaoNum ']'                               
                                                                {$$ = strdup($1);}

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

Atribuicao  : Variavel '=' OperacaoNum              { printf("STORE\n"); }

InstIO      : PUT '(' OperacaoNum ')'               { printf("WRITEI\n");}
            | PUT '(' '"' pal  '"' ')'                { printf("PUSHS %s\nWRITES\n", $4);}
            ;

InstCiclo   : WHILE     {
                        addReturnLabel();
                        }
                            BlocoCond     
                                {
                                    printf("jump %s\n", cs_pop(returnLabels));
                                    printf("%s: ", cs_pop(continueLabels));

                                }                  

BlocoCond   :   '(' ExpressaoLog ')' {addJzContinueLabel();} BlocoCodigo

BlocoCodigo : '{' ConjInst '}'                        ;

InstCond    : IF BlocoCond Alternativa

Alternativa :
            | ListaElseIf ELSE {addEndJump(); printf("%s: ", cs_pop(continueLabels));} BlocoCodigo {printf("ifEnd%d: ", endLabelCount); endLabelCount++;}
            ;

ListaElseIf :
            | ELSEIF {addEndJump();printf("%s: ", cs_pop(continueLabels));} BlocoCond ListaElseIf 
            ;

ExpressaoLog: ExpressaoLog OR ExpLog1       {printf("ADD\nPUSHI 0\nSUP\n");}
            | ExpLog1
            ;

ExpLog1     : ExpLog1 AND ExpLog2           {printf("ADD\nPUSHI 2\nEQUAL\n");}
            | ExpLog2
            ;

ExpLog2     : NOT '(' ExpressaoLog ')'      {printf("NOT\n");}
            | ExpLog0
            ;

ExpLog0     : OperacaoLog
            | '(' ExpressaoLog ')'
            ;

OperacaoLog : OperacaoNum OperadorLog OperacaoNum {handleSymbol($2);}

OperadorLog : GREATER_THAN      {$$ = S_GREATER_THAN;}
            | LESS_THAN         {$$ = S_LESS_THAN;}
            | GREATER_OR_EQL    {$$ = S_GREATER_OR_EQL;}
            | LESS_OR_EQL       {$$ = S_LESS_OR_EQL;}
            | EQL               {$$ = S_EQL;}
            | NOT_EQL           {$$ = S_NOT_EQL;}
            ;

OperacaoNum : Produto                               
            | OperacaoNum '+' Produto               { printf("ADD\n"); }
            | OperacaoNum '-' Produto               { printf("SUB\n"); }
            ;

Produto     : OpParenteses                          
            | Produto '*' OpParenteses              { printf("MUL\n"); }
            | Produto '/' OpParenteses              { printf("DIV\n"); }
            ;

OpParenteses: num                                   { printf("PUSHI %d\n", $1);}
            | Variavel                              { printf("LOAD\n");}
            | GET '(' ')'                           { printf("READ\nATOI\n");}                      
            | '(' OperacaoNum ')'                   
            ;

%%

void yyerror(char* s) {
    printf("\x1b[37;01m%s\x1b[0m", s);
}

void handleSymbol(int symbol){
    switch(symbol){
        case S_GREATER_THAN:
            printf("SUP\n");
            break;
        case S_LESS_THAN:
            printf("INF\n");
            break;
        case S_GREATER_OR_EQL:
            printf("SUPEQ\n");
            break;
        case S_LESS_OR_EQL:
            printf("INFEQ\n");
            break;
        case S_EQL:
            printf("EQUAL\n");
            break;
        case S_NOT_EQL:
            printf("EQUAL\n");
            printf("NOT\n");
            break;
    }
}

void addJzContinueLabel(){
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
    printf("%s: ", label);
}

void addEndJump(){
    printf("jump ifEnd%d\n", endLabelCount);
}

int main() {
    varHash = new_hash(1);
    sp = 0;
    returnLabelCount = 1;
    continueLabelCount = 1;
    endLabelCount = 1;
    returnLabels = (CharStack *) malloc(sizeof(CharStack));
    continueLabels = (CharStack *) malloc(sizeof(CharStack));
    cs_init(returnLabels);
    cs_init(continueLabels);
    yyparse();
    return 0;
}

