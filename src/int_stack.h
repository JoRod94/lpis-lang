#ifndef INT_STACK_H
#define INT_STACK_H


struct IntStack {
    int    *content;
    int     size;
};
typedef struct IntStack IntStack;


void is_init(IntStack *st);

void is_push(IntStack *st, int val);

void is_put(IntStack *st, int index, int val);

int is_pop(IntStack *st);

int is_get(IntStack *st, int index);



#endif