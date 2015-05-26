#include "hash.h"

typedef struct bucket_node {
    variable var;
    struct bucket_node* next;
} bucket_node, *bucket;

struct hash {
    int size;
    int n_elements;
    bucket *table;
};

static void delete_bucket(bucket b);
static int __get_bucket_addr(hash h, char* key, bucket** ret);

void delete_hash(hash h) {
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
    delete_bucket(b -> next);
    delete_variable(b -> var);
    free(b);
}

variable new_variable(char* name, int val) {
    variable var = (variable)malloc(sizeof(struct s_variable));
    var -> name = strdup(name);
    var -> val = val;
    return var;
}

static variable new_var_from(variable v) {
    variable var = (variable)malloc(sizeof(struct s_variable));
    var -> name = strdup(v -> name);
    var -> val = v -> val;
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

static void resize_hash(hash *h) {
    int new_size = (*h) -> size * 2;
    hash new = new_hash(new_size);
    new -> n_elements = (*h) -> n_elements;

    for(int i = 0; i < (*h) -> size; i++) {
        bucket b = (*h)->table[i];
        bucket* addr;
        __get_bucket_addr(new, b -> var -> name, &addr);
        *addr = b;
    }

    *h = new;
}

/* Finds the address where the pointer should be (whether or not it is there)
 * So that we can add it if we want
 * returns 0 if it exists, 1 otherwise
 */
static int __get_bucket_addr(hash h, char* key, bucket** ret) {
    char* lower_key = str_to_lower(key);
    unsigned int i = djb2_hash(lower_key) % (h -> size);
    free(lower_key);
    int found = 0;
    bucket* it = &(h -> table)[i];
    bucket* head = it;

    // try to find it in the current bucket
    while(*it && !found) {
        if( strcasecmp( (*it) -> var -> name, key) == 0 )
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

void hash_put_var(hash *h, variable v) {
    bucket new, *ret;

    if((*h) -> n_elements == (*h) -> size)
        resize_hash(h);

    // if we haven't found it, we will have the head of the bucket where we must add it
    // so we create it, set it to point to the current head (since our new will be the new head)
    // and then we need to set the current head to point to the new head (*ret = new)
    if (! __get_bucket_addr(*h, v -> name, &ret) ) {
        new = new_bucket(v);
        new -> next = *ret;
        ++( (*h) -> n_elements );
        *ret = new;
    }
    else
        (*ret) -> var -> val = v -> val;
}

void hash_put(hash *h, char* name, int val) {
    variable v = new_variable(name, val);
    hash_put_var(h, v);
}

variable hash_get(hash *h, char* name) {
    bucket* ret;
    if (! __get_bucket_addr(*h, name, &ret) )
        return NULL;

    else
        return new_var_from( (*ret) -> var );
}

hash new_hash(int size) {
    hash h = (hash)malloc(sizeof(struct hash));
    h -> size = size;
    h -> n_elements = 0;
    h -> table = (bucket*)calloc(size, sizeof(bucket));
    return h;
}

