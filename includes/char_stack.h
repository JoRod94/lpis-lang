#ifndef CHAR_STACK_H
#define CHAR_STACK_H


struct CharStack {
    char    **content;
    int     size;
    int     curr;
};
typedef struct CharStack CharStack;


void cs_init(CharStack *st);

void cs_push(CharStack *st, char *inst);

void cs_put(CharStack *st, int index, char *inst);

char *cs_pop(CharStack *st);

char *cs_get(CharStack *st, int index);

void cs_clear(CharStack *st);

char *cs_top(CharStack *st);


#endif
