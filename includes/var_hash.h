#ifndef _VAR_HASH_H
#define _VAR_HASH_H

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include "strutil.h"

typedef enum {array_var, int_var} var_type;

typedef struct s_variable {
    char* name;
    int addr;
    int size;
    var_type type;
    char *scope;
} *variable;

typedef struct var_hash *var_hash;

var_hash new_var_hash(int size);

void delete_variable(variable v);

variable new_variable(char* name, int addr, int size, var_type type, char *scope);

void var_hash_put_var(var_hash* h, variable v);

void var_hash_put(var_hash* h, char* name, int addr, int size, var_type type, char *scope);

variable var_hash_get(var_hash* h, char* name, char *scope);

#endif
