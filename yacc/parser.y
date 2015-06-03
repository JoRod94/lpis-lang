%{

#include <stdio.h>
#include <string.h>
#include "char_stack.h"
#include <stdlib.h>
#include "var_hash.h"
#include "func_hash.h"

#define LABEL_COUNT_MAX 10

#define S_GREATER_THAN 1
#define S_LESS_THAN 2
#define S_GREATER_OR_EQL 3
#define S_LESS_OR_EQL 4
#define S_EQL 5
#define S_NOT_EQL 6

extern int yylex();

void yyerror(char* s);

//Funções de Produções
void declaracao(int size, char *name);
char *variavel1(char *name);
void variavel2a(char *name);
char *variavel2b(char *name);
void declFuncao1a(char *name);
void declFuncao1b();
void declFuncao2a(char *name);
void declFuncao2b();
void chamadaFuncao(char *name, int argNr);
void instCiclo();
void finishIfBlock();

CharStack *returnLabels;
CharStack *continueLabels;
CharStack *currArgs;

int returnLabelCount;
int continueLabelCount;
int endLabelCount;

int hasMain;
int currReturnNr;

char *currFunc;
int currPointer;

void handleSymbol(int symbol);
void addJzContinueLabel();
void addReturnLabel();
void setIfMain(char *name);
void setCurrDeclFunc(char *name);

var_hash varHash;
func_hash funcHash;

variable found_var;
func found_func;

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

%token ARROW
%token FN
%token VOID

%token RETURN

%token DECLARATION

%token ERROR

%union{
    int val;
    char *word;
}

%type <val> num;
%type <val> TamanhoArray;
%type <val> OperadorLog;
%type <val> ValoresArgs;
%type <word> pal;
%type <word> Variavel;

%%

Programa    : BlocoDecl DECLARATION {printf("PUSHA main\nCALL\n");} ConjFunc
            ;

BlocoDecl   :
            | BlocoDecl Declaracao
            ;

Declaracao  : INT TamanhoArray pal ';' {declaracao($2,$3);}

Variavel    : pal   { $$ = variavel1($1);}
            | pal   { variavel2a($1);}      '[' OperacaoNum ']'     {$$ = variavel2b($1);}

TamanhoArray:                                       {$$ = -1;}
            | '[' num ']'                           {$$ = $2;}

ConjFunc    :
            | ConjFunc DeclFuncao ;

DeclFuncao  : FN pal '(' ListaArgs ')' ARROW INT {declFuncao1a($2);} '{' BlocoDecl DECLARATION ConjInst '}' {declFuncao1b();}                        


            | FN pal '(' ListaArgs ')' ARROW VOID {declFuncao2a($2);} '{' BlocoDecl DECLARATION ConjInst '}' {declFuncao2b();} 

ListaArgs   :
            | ListaArgs INT pal ',' {cs_push(currArgs, $3);}


ConjInst    :
            | ConjInst Instrucao ';'
            ;

Instrucao   : Atribuicao
            | InstIO
            | InstCond
            | InstCiclo
            | ChamadaFuncao         
            | RETURN OperacaoNum    {currReturnNr++; printf("RETURN\n"); }
            ;

Atribuicao  : Variavel '=' OperacaoNum              { printf("STORE\n"); }

InstIO      : PUT '(' OperacaoNum ')'               { printf("WRITEI\n");}
            | PUT '(' '"' pal  '"' ')'              { printf("PUSHS %s\nWRITES\n", $4);}
            ;

ChamadaFuncao : pal '(' ValoresArgs ')' {chamadaFuncao($1,$3);}

ValoresArgs   : {$$ = 0;}
              | ValoresArgs num ',' { printf("PUSHI %d\n", $2); $$++; }

InstCiclo   : WHILE {addReturnLabel();} BlocoCond {instCiclo();}                  

BlocoCond   :   '(' ExpressaoLog ')'    {addJzContinueLabel();}    BlocoCodigo  ;

BlocoCodigo : '{' ConjInst '}' ;

InstCond    : IF BlocoCond Alternativa ;

Alternativa :
            | ListaElseIf ELSE {finishIfBlock();} BlocoCodigo {printf("ifEnd%d: ", endLabelCount); endLabelCount++;}
            ;

ListaElseIf :
            | ELSEIF {finishIfBlock();} BlocoCond ListaElseIf   ;
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
            | Variavel                              { printf("LOADN\n");}
            | GET '(' ')'                           { printf("READ\nATOI\n");}
            | ChamadaFuncao                         
            | '(' OperacaoNum ')'                   
            ;

%%

void declaracao(int size, char *name){     
    if(var_hash_get(&varHash, name, currFunc) != NULL)
        yyerror("Repeated variable\n");
    else{
        if(size>=0){
            printf("PUSHN %d\n", size);
            var_hash_put(&varHash, name, currPointer, size, array_var, currFunc);
            currPointer+= size;
        }
        else{
            printf("PUSHI 0\n");
            var_hash_put(&varHash, name, currPointer, 0, int_var, currFunc);
            currPointer++;
        }
    }
}

char *variavel1(char *name){
    if( ( found_var = var_hash_get(&varHash, name, currFunc) ) == NULL){
        if(( found_var = var_hash_get(&varHash, name, "global") ) == NULL){    
            yyerror("Variable not found\n");
            exit(0);
        }
    }
    if( strcmp(found_var->scope, currFunc) != 0 && strcmp(found_var->scope, "global") != 0){
        yyerror("Out of scope variable\n");
        exit(0);
    }

    printf("PUSHI %d\n", found_var->addr);
    printf("PUSHI 0\n");
    if(found_var->type != int_var)
        yyerror(" WARNING: Didn't index array, defaulted to 0 \n");
    return strdup(name);
}

void variavel2a(char *name){
    if( ( found_var = var_hash_get(&varHash, name, currFunc) ) == NULL){
        if(( found_var = var_hash_get(&varHash, name, "global") ) == NULL){    
            yyerror("Variable not found\n");
            exit(0);
        }
    }
    printf("PUSHI %d\n", found_var->addr);
}

char *variavel2b(char *name){
    if( ( found_var = var_hash_get(&varHash, name, currFunc) ) == NULL){
        if(( found_var = var_hash_get(&varHash, name, "global") ) == NULL){    
            yyerror("Exceptional Error\n");
            exit(0);
        }
    }
    if(found_var->type != array_var){
        yyerror("Tried to index a non-array variable");
        exit(0);
    }
    return strdup(name);
}

void declFuncao1a(char *name){
    setCurrDeclFunc(name);
    if( (found_func = func_hash_get(&funcHash, name)) ){
        yyerror("Repeated Function");
        exit(0);
    }
    setIfMain(name);
    
    func_hash_put(&funcHash, name, currArgs->curr);
    if(strcmp("main", name) != 0) 
        printf("f_%s: ", name);
    if(currArgs)
        currPointer = 0-(currArgs->curr);
    else
        currPointer = 0;
    while(currPointer < 0){
        var_hash_put(&varHash, cs_pop(currArgs), currPointer, 0, int_var, currFunc );
        currPointer++;
    }
    cs_clear(currArgs);
}

void declFuncao1b(){
    if(currReturnNr == 0){
        yyerror("No return instruction");
        exit(0);
    }
    currReturnNr = 0;
    if(hasMain)
        printf("STOP\n");
}

void declFuncao2a(char *name){
    setCurrDeclFunc(name);
    if( (found_func = func_hash_get(&funcHash, name)) ){
        yyerror("Repeated Function");
        exit(0);
    }

    func_hash_put(&funcHash, name, currArgs->curr);
    printf("f_%s: ", name);
    currPointer = 0-(currArgs->curr);
    while(currPointer < 0){
        var_hash_put(&varHash, cs_pop(currArgs), currPointer, 0, int_var, currFunc );
        currPointer++;
    }
    cs_clear(currArgs);
}

void declFuncao2b(){
    if(currReturnNr > 0){
        yyerror("Too many return instructions");
        exit(0);
    }
    currReturnNr = 0;
}

void chamadaFuncao(char *name, int argNr){
    if( (found_func = func_hash_get(&funcHash, name)) == NULL ){
        yyerror("Function not found\n");
        exit(0);
    }
    if( argNr != found_func->nr_args){
        yyerror("Wrong number of arguments\n");
        exit(0);
    }
    printf("PUSHA f_%s\nCALL\n", name); 
}

void instCiclo(){
    printf("jump %s\n", cs_pop(returnLabels));
    printf("%s: ", cs_pop(continueLabels));
}

void finishIfBlock(){
    printf("jump ifEnd%d\n", endLabelCount);
    printf("%s: ", cs_pop(continueLabels));
}


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


void setIfMain(char *name){
    if(!strcmp(name, "main")){
        if(hasMain){
            yyerror("Repeated main function");
            exit(0);
        }
        hasMain = 1;
        printf("main: ");
    }
}

void setCurrDeclFunc(char *name){
    if( !strcmp(name, "get") 
     || !strcmp(name, "put")
     || !strcmp(name, "global")
     ){
        yyerror("Invalid name");
        exit(0);
    }
    currFunc = strdup(name);
}

int main() {
    currFunc = strdup("global");
    funcHash = new_func_hash(1);
    varHash = new_var_hash(1);
    currPointer = 0;
    hasMain = 0;
    currReturnNr = 0;
    returnLabelCount = 1;
    continueLabelCount = 1;
    endLabelCount = 1;
    currArgs = (CharStack *) malloc(sizeof(CharStack));
    returnLabels = (CharStack *) malloc(sizeof(CharStack));
    continueLabels = (CharStack *) malloc(sizeof(CharStack));
    cs_init(returnLabels);
    cs_init(continueLabels);
    cs_init(currArgs);
    yyparse();
    if(!hasMain)
        yyerror("\nNo main function defined");
    return 0;
}

