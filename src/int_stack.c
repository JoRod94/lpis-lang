#include "int_stack.h"
#include <stdio.h>
#include <stdlib.h>


void is_init(IntStack *st){
    st->content = (int *) calloc(1, sizeof(int));
    st->size = 1;
    st->curr = 0;
}

void is_push(IntStack *st, int n){
    if(st->curr >= st->size){
        st->content = (int *) realloc(st->content, st->size*2*sizeof(int));
        st->size *= 2;
    }

    st->content[st->curr] = n;
    st->curr++;
}

int is_pop(IntStack *st){
    int res = 0;
    if (st->size == 0)
        fprintf(stderr, "stack empty\n");
    else{
        res = st->content[st->curr-1];
        st->curr--;
        if(st->curr < st->size/2){
            st->content = (int *) realloc(st->content, st->size/2*sizeof(int ));
            st->size /= 2;
        }
    }
    return res;
}

int is_get(IntStack *st, int index){
    return st->content[index];
}

void is_put(IntStack *st, int index, int n){
    st->content[index] = n;
}

int is_top(IntStack *st){
    return st->content[st->curr-1];
}

void is_clear(IntStack *st){
    while(st->curr > 0){
        is_pop(st);
    }
    st->content = (int *) realloc(st->content, sizeof(int ));
}
