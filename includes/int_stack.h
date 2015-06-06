#ifndef INT_STACK_H
#define INT_STACK_H


struct IntStack {
    int     *content;
    int     size;
    int     curr;
};
typedef struct IntStack IntStack;


void is_init(IntStack *st);

void is_push(IntStack *st, int n);

void is_put(IntStack *st, int index, int n);

int is_pop(IntStack *st);

int is_get(IntStack *st, int index);

void is_clear(IntStack *st);

int is_top(IntStack *st);


#endif
