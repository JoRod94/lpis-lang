#include "char_stack.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


void cs_init(CharStack *st){
    st->content = (char **) calloc(1, sizeof(char *));
    st->size = 1;
    st->curr = 0;
}

void cs_push(CharStack *st, char *inst){
    if(st->curr >= st->size){
        st->content = (char **) realloc(st->content, st->size*2*sizeof(char *));
        st->size *= 2;
    }

    st->content[st->curr] = (char *) malloc(strlen(inst));
    st->content[st->curr] = strdup(inst);
    st->curr++;
}

char *cs_pop(CharStack *st){
    char *res = NULL;
    if (st->size == 0)
        fprintf(stderr, "stack empty\n");
    else{
        res = strdup(st->content[st->curr-1]);
        st->curr--;
        if(st->curr < st->size/2){
            st->content = (char **) realloc(st->content, st->size/2*sizeof(char *));
            st->size /= 2;
        }
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

void cs_clear(CharStack *st){
    while(st->curr > 0){
        cs_pop(st);
    }
}
