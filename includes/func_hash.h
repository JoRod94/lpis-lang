#ifndef _FUNC_HASH_H
#define _FUNC_HASH_H

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include "strutil.h"

typedef enum {void_func, int_func} func_type;

typedef struct s_func {
    char* name;
    int nr_args;
    func_type type;
} *func;

typedef struct func_hash *func_hash;

func_hash new_func_hash(int size);

void delete_func(func v);

func new_func(char* name, int nr_args, func_type type);

void func_hash_put_var(func_hash* h, func v);

void func_hash_put(func_hash* h, char* name, int nr_args, func_type type);

func func_hash_get(func_hash* h, char* name);


#endif
