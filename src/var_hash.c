#include "var_hash.h"

typedef struct bucket_node {
    variable var;
    struct bucket_node* next;
} bucket_node, *bucket;

struct var_hash {
    int size;
    int n_elements;
    bucket *table;
};

static void delete_bucket(bucket b);
static int __get_bucket_addr(var_hash h, char *name,char *scope,  bucket** ret);

void delete_var_hash(var_hash h) {
    if(!h)
        return;

    for(int i = 0; i < h -> n_elements; i++)
        delete_bucket(h -> table[i]);

    free(h);
}

void delete_variable(variable v) {
    free(v -> name);
    free(v);
}

static void delete_bucket(bucket b) {
    if(!b)
        return;

    bucket tmp;
    for(bucket it = b; it; it = tmp) {
        tmp = it -> next;
        delete_variable(it->var);
        free(it);
    }
}

variable new_variable(char* name, int addr, int size, var_type type, char *scope) {
    

    variable var = (variable)malloc(sizeof(struct s_variable));
    var -> name = strdup(name);
    var -> addr = addr;
    var -> size = size;
    var -> type = type;
    var -> scope = strdup(scope);
    return var;
}

static variable new_var_from(variable v) {
    variable var = (variable)malloc(sizeof(struct s_variable));
    var -> name = strdup(v -> name);
    var -> addr = v -> addr;
    var -> size = v -> size;
    var -> type = v -> type;
    var -> scope = strdup( v -> scope);
    return var;
}

static bucket new_bucket(variable v) {
    bucket b = (bucket)malloc(sizeof(bucket_node));
    b -> var = new_var_from(v);
    b -> next = NULL;
    return b;
}

// djb2 hash function by Dan Berstein
static unsigned int djb2_hash(char* str) {
    unsigned int hash = 5381;
    int c;

    while ( (c = *str++) )
        hash = ((hash << 5) + hash) ^ c;

    return hash;
}

static void resize_var_hash(var_hash *h) {
    int new_size = (*h) -> size * 2;
    var_hash new = new_var_hash(new_size);
    new -> n_elements = (*h) -> n_elements;

    for(int i = 0; i < (*h) -> size; i++) {
        bucket b = (*h)->table[i];
        if(b) {
            bucket* addr;
            __get_bucket_addr(new, b -> var -> name, b->var->scope, &addr);
            *addr = b;
        }
    }

    free(*h);
    *h = new;
}

/* Finds the address where the pointer should be (whether or not it is there)
 * So that we can add it if we want
 * returns 0 if it exists, 1 otherwise
 */
static int __get_bucket_addr(var_hash h, char *name, char *scope, bucket** ret) {
    char *key = name;
    char* lower_key = str_to_lower(key);
    unsigned int i = djb2_hash(lower_key) % (h -> size);
    free(lower_key);
    int found = 0;
    bucket* it = &(h -> table)[i];
    bucket* head = it;

    // try to find it in the current bucket
    while(*it && !found) {
        if( strcasecmp( (*it) -> var -> name, key) == 0 && strcasecmp( (*it) -> var -> scope, scope) == 0)
            found = 1;
        else
            it = &( (*it) -> next );
    }

    // if we found a bucket, we need to return it
    if(*it)
        *ret = it;
    else
        *ret = head; // otherwise return where it should be (head of the bucket)

    // returning the flag
    return found;
}

void hash_put_var(var_hash *h, variable v) {
    bucket new, *ret;

    if((*h) -> n_elements == (*h) -> size)
        resize_var_hash(h);

    // if we haven't found it, we will have the head of the bucket where we must add it
    // so we create it, set it to point to the current head (since our new will be the new head)
    // and then we need to set the current head to point to the new head (*ret = new)
    if (! __get_bucket_addr(*h, v->name, v->scope,  &ret) ) {
        new = new_bucket(v);
        new -> next = *ret;
        ++( (*h) -> n_elements );
        *ret = new;
    }
    else{
        (*ret) -> var -> addr = v -> addr;
        (*ret) -> var -> size = v -> size;
        (*ret) -> var -> type = v -> type;
        (*ret) -> var -> scope = strdup(v -> scope);
    }
}

void var_hash_put(var_hash *h, char* name, int addr, int size, var_type type, char *scope) {
    variable v = new_variable(name, addr, size, type, scope);
    hash_put_var(h, v);
}

variable var_hash_get(var_hash *h, char* name, char *scope) {
    bucket* ret;
    if (! __get_bucket_addr(*h, name,scope, &ret) )
        return NULL;

    else
        return new_var_from( (*ret) -> var );
}

var_hash new_var_hash(int size) {
    var_hash h = (var_hash)malloc(sizeof(struct var_hash));
    h -> size = size;
    h -> n_elements = 0;
    h -> table = (bucket*)calloc(size, sizeof(bucket));
    return h;
}

