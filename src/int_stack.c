#include "int_stack.h"
#include <stdio.h>
#include <stdlib.h>


void is_init(IntStack *st){
    st->content = (int *) malloc(0);
    st->size = 0;
}

void is_push(IntStack *st, int val){
    st->content = (int *) realloc(st->content, sizeof(int));
    st->content[st->size-1] = val;
    st->size++;

}

int is_pop(IntStack *st){
    int res = -1;
    if (st->size == 0)
        fprintf(stderr, "stack empty\n");
    else{
        printf("ADFADF %d\n", st->size);
        res = st->content[st->size-1];

        st->size--;
    }
    return res;
}

int is_get(IntStack *st, int index){
    return st->content[index];
}

void is_put(IntStack *st, int index, int val){
    st->content[index] = val;
}
