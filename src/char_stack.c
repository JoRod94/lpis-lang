#include "char_stack.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


void cs_init(CharStack *st){
    st->content = (char **) malloc(0);
    st->size = 0;
}

void cs_push(CharStack *st, char *inst){
    st->content = (char **) realloc(st->content, sizeof(char *));
    st->content[st->size-1] = (char *) malloc(strlen(inst));
    st->content[st->size-1] = strdup(inst);
    st->size++;
}

char *cs_pop(CharStack *st){
    char *res = NULL;
    if (st->size == 0)
        fprintf(stderr, "stack empty\n");
    else{
        res = strdup(st->content[st->size-1]);
        free(st->content[st->size-1]);
        st->size--;
    }
    return res;
}

char *cs_get(CharStack *st, int index){
    return strdup(st->content[index]);
}

void cs_put(CharStack *st, int index, char *inst){
    free(st->content[index]);
    st->content[index] = (char *) malloc(strlen(inst));
    st->content[index] = strdup(inst);
}
