#include "char_stack.h"
#include "int_stack.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#define ADDR_LENGTH 8


void write_condition(CharStack *instructions, char *condition){
    char *inst = (char *) malloc(5+strlen(condition));
    sprintf(inst, "TEST %s", condition);
    printf("ADFSADGDSGS\n");
    cs_push(instructions, inst);
}

void startLoop(CharStack *instructions,IntStack *continueIndexs, IntStack *returnAddrs, char *condition){
    is_push(returnAddrs, instructions->size-1);
    printf("Size after push in startLoop: %d\n", returnAddrs->size);
    write_condition(instructions, condition);
    printf("Size after write_condition in startLoop: %d\n", returnAddrs->size);
    is_push(continueIndexs, instructions->size-1);
    cs_push(instructions, "temp");
}

void endLoop(CharStack *instructions, IntStack *continueIndexs, IntStack *returnAddrs){
    char *jumpInst = (char *) malloc(5+ADDR_LENGTH);
    printf("uiui8 %d\n", returnAddrs->size);
    sprintf(jumpInst, "jump %d", is_pop(returnAddrs));
    printf("asfasfasfasf \n");
    cs_push(instructions, jumpInst);

    char *jzInst = (char *) malloc(3+ADDR_LENGTH);
    sprintf(jzInst, "jz %d", instructions->size-1);
    cs_put(instructions, is_pop(continueIndexs), jzInst);
}

int main(int argc, char **argv){
    CharStack *instructions = (CharStack *) malloc(sizeof(CharStack));
    IntStack *continueIndexs = (IntStack *) malloc(sizeof(IntStack));
    IntStack *returnAddrs = (IntStack *) malloc(sizeof(IntStack));

    cs_init(instructions);
    is_init(continueIndexs);
    printf("Size before init: %d\n", returnAddrs->size);
    is_init(returnAddrs);
    printf("Size after init %d\n", returnAddrs->size);
    startLoop(instructions,continueIndexs,returnAddrs, "COND");
    printf("Size after startLoop: %d\n", returnAddrs->size);
    cs_push(instructions, "codigo");

    endLoop(instructions, continueIndexs, returnAddrs);
    printf("Size after endLoop: %d\n", returnAddrs->size);

    int i;
    for(i =0; i<instructions->size; i++){
        printf("%s\n", cs_get(instructions, i));
    }

    return 0;

}