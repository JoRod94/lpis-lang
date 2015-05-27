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


int currPointer;

int inArray;
int hasMain;
int returnNr;

char *currFunc;

void handleSymbol(int symbol);

void addJzContinueLabel();

void addReturnLabel();

void addEndJump();

void setMain();

hash varHash;
hash funcHash;
variable found_var;

%}

%token num
%token var

%token INT
%token VOID

%token WHILE
%token IF
%token ELSEIF
%token ELSE

%token FN
%token ARROW
%token RETURN

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
        int index;
    } variable;
}

%type <val> num;
%type <val> TamanhoArray;
%type <val> OperadorLog;
%type <word> var;
%type <variable> Variavel;

%%

Programa    :BlocoDecl ListaFunc;

ListaFunc   :
            | ListaFunc Funcao

Funcao      : FN var {currFunc = strdup($2);} 
                '(' FuncDeclareArgs ')' ARROW INT '{'
                        {if(strcmp($2, "main") == 0) setMain();
                         //else hash_put(&funcHash, $2, currPointer));
                         currPointer = 0;
                         }
                             BlocoDecl ConjInst '}'    
                                {   
                                    free(currFunc);
                                    if(returnNr == 0){ 
                                        yyerror("ERROR: No return instruction\n");
                                            exit(0);
                                    } 
                                }
            | FN var {currFunc = strdup($2);}
                        '(' FuncDeclareArgs ')' ARROW VOID '{' 
                                    BlocoDecl ConjInst '}'   
                                        {
                                            free(currFunc);
                                            if(returnNr != 0){ 
                                                yyerror("ERROR: Invalid return instruction\n");
                                                exit(0);
                                            } 
                                        }                                 
            ;

FuncCallArgs    :
            | FuncCallArgs INT var ','         /*printf("PUSHL %s", hash_get(&funcHash, currFunc, $3)->name);*/
            | FuncCallArgs INT var             /*printf("PUSHL %s", hash_get(&funcHash, currFunc, $3)->name);*/

FuncDeclareArgs   : 
            | FuncDeclareArgs OperacaoNum ',' /*hash_put(&funcHash, currFunc, $3, currPointer )*/
            | FuncDeclareArgs OperacaoNum     /*hash_put(&funcHash, currFunc, $3, currPointer )*/

BlocoDecl   :
            | BlocoDecl Declaracao
            ;

Declaracao  : INT TamanhoArray Variavel ';'         {   printf("VARIABLE NAME: %s\n", $3.name);
                                                        /*if(currFunc)
                                                            hash_put(&funcHash, currFunc, $3.name, currPointer);
                                                        else */
                                                            hash_put(&varHash, $3.name, currPointer);
                                                        if($2>=0){
                                                            printf("PUSHN %d\n", $2);
                                                            currPointer+= $2;
                                                        }
                                                        else{
                                                            printf("PUSHI 0\n");
                                                            currPointer++;
                                                        }
                                                    }

Variavel    : var                                   {$$.name = $1; $$.index = -1;}
            | var '[' num ']'                       {$$.name = $1; $$.index = $3;}

TamanhoArray:                                       {$$ = -1;}
            | '[' num ']'                           {$$ = $2;}

ConjInst    :
            | ConjInst Instrucao ';'
            ;

Instrucao   : Atribuicao
            | InstIO
            | InstCond
            | InstCiclo
            | Return
            | CallFunc
            ;

CallFunc    : var '(' FuncCallArgs ')' ;

Return      : RETURN OperacaoNum {printf("RETURN\n"); returnNr++;}

Atribuicao  : Variavel '=' OperacaoNum              {   
                                                        if( ( found_var = hash_get(&varHash, $1.name) ) == NULL){
                                                                yyerror("Variable not found\n");
                                                            }
                                                        if($1.index < 0){
                                                            printf("STOREG %d\n", found_var->val);

                                                        }
                                                        else{
                                                            printf("STOREG %d\n", found_var->val + $1.index);    
                                                        }
                                                    }

InstIO      : PUT OperacaoNum                       { printf("WRITEI\n");}
            | GET OperacaoNum
            ;

InstCiclo   : WHILE     {addReturnLabel();}
                            BlocoCond     
                                {printf("JUMP %s\n", cs_pop(returnLabels));
                                    printf("%s: NOP\n", cs_pop(continueLabels));}                  

BlocoCond   :   '(' ExpressaoLog ')' {addJzContinueLabel();} BlocoCodigo

BlocoCodigo : '{' ConjInst '}'                        ;

InstCond    : IF BlocoCond Alternativa

Alternativa :
            | ListaElseIf ELSE 
                            {addEndJump(); 
                                printf("%s: NOP\n", cs_pop(continueLabels));} 
                                    BlocoCodigo 
                                        {printf("ifEnd%d: NOP\n", endLabelCount); 
                                            endLabelCount++;}

ListaElseIf :
            |   ELSEIF
                    {addEndJump();
                        printf("%s: NOP\n", cs_pop(continueLabels));} 
                            BlocoCond ListaElseIf 

ExpressaoLog: ExpressaoLog OR ExpLog1               {printf("ADD\nPUSHI 0\nSUP\n");}
            | ExpLog1
            ;

ExpLog1     : ExpLog1 AND ExpLog2                   {printf("ADD\nPUSHI 2\nEQUAL\n");}
            | ExpLog2
            ;

ExpLog2     : NOT '(' ExpressaoLog ')'              {printf("NOT\n");}
            | ExpLog0
            ;

ExpLog0     : OperacaoLog
            | '(' ExpressaoLog ')'
            ;

OperacaoLog : OperacaoNum OperadorLog OperacaoNum   {handleSymbol($2);}

OperadorLog : GREATER_THAN                          {$$ = S_GREATER_THAN;}
            | LESS_THAN                             {$$ = S_LESS_THAN;}
            | GREATER_OR_EQL                        {$$ = S_GREATER_OR_EQL;}
            | LESS_OR_EQL                           {$$ = S_LESS_OR_EQL;}
            | EQL                                   {$$ = S_EQL;}
            | NOT_EQL                               {$$ = S_NOT_EQL;}
            ;

OperacaoNum : Produto                               
            | OperacaoNum '+' Produto               {
                                                    printf("ADD\n");
                                                    }
            | OperacaoNum '-' Produto               {
                                                    printf("SUB\n");}
            ;

Produto     : OpParenteses                          
            | Produto '*' OpParenteses              {
                                                    printf("MUL\n");
                                                    }
            | Produto '/' OpParenteses              {
                                                    printf("DIV\n");
                                                    }
            ;

OpParenteses: num                                   { 
                                                        printf("PUSHI %d\n", $1);}
            | Variavel                              {   
                                                        if( ( found_var = hash_get(&varHash, $1.name) ) == NULL){
                                                                yyerror("Variable not found\n");
                                                        }
                                                        if($1.index < 0){
                                                            printf("PUSHG %d\n", found_var->val );
                                                        }
                                                        else{
                                                            printf("PUSHG %d\n", found_var->val + $1.index);
                                                        }
                                                    }
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
    printf("\nJZ %s\n", label);
}

void addReturnLabel(){
    char *label = (char *) malloc(7+LABEL_COUNT_MAX);
    sprintf(label, "returnl%d", returnLabelCount);
    returnLabelCount++;
    cs_push(returnLabels, label);
    printf("%s: NOP\n", label);
}

void addEndJump(){
    printf("JUMP ifEnd%d\n", endLabelCount);
}

void setMain(){
    hasMain = 1;
    printf("START\n");

}

int main() {
    returnNr = 0;
    hasMain = 0;
    inArray = 0;
    currPointer = 0;
    returnLabelCount = 1;
    continueLabelCount = 1;
    endLabelCount = 1;
    currFunc = NULL;

    varHash = new_hash(1);
    funcHash = new_hash(1);

    returnLabels = (CharStack *) malloc(sizeof(CharStack));
    continueLabels = (CharStack *) malloc(sizeof(CharStack));
    cs_init(returnLabels);
    cs_init(continueLabels);

    yyparse();
    if(!hasMain)
        yyerror("No main defined\n");
    return 0;
}

