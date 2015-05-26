#ifndef _HASH_H
#define _HASH_H

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include "strutil.h"

typedef struct s_variable {
    char* name;
    int val;
} *variable;

typedef struct hash *hash;

hash new_hash(int size);

void delete_variable(variable v);

variable new_variable(char* name, int val);

void hash_put_var(hash* h, variable v);

void hash_put(hash* h, char* name, int val);

variable hash_get(hash* h, char* name);

#endif
