#include "func_hash.h"

typedef struct bucket_node {
    func fun;
    struct bucket_node* next;
} bucket_node, *bucket;

struct func_hash {
    int size;
    int n_elements;
    bucket *table;
};

static void delete_bucket(bucket b);
static int __get_bucket_addr(func_hash h, char* key, bucket** ret);

void delete_func_hash(func_hash h) {
    if(!h)
        return;

    for(int i = 0; i < h -> n_elements; i++)
        delete_bucket(h -> table[i]);

    free(h);
}

void delete_func(func f) {
    free(f -> name);
    free(f);
}

static void delete_bucket(bucket b) {
    if(!b)
        return;

    bucket tmp;
    for(bucket it = b; it; it = tmp) {
        tmp = it -> next;
        delete_func(it->fun);
        free(it);
    }
}

func new_func(char* name, int nr_args, func_type type) {
    
    func fun = (func)malloc(sizeof(struct s_func));
    fun -> name = strdup(name);
    fun -> nr_args = nr_args;
    fun -> type = type;
    return fun;
}

static func new_fun_from(func f) {
    func fun = (func)malloc(sizeof(struct s_func));
    fun -> name = strdup(f -> name);
    fun -> nr_args = f -> nr_args;
    fun -> type = f -> type;
    return fun;
}

static bucket new_bucket(func f) {
    bucket b = (bucket)malloc(sizeof(bucket_node));
    b -> fun = new_fun_from(f);
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

static void resize_func_hash(func_hash *h) {
    int new_size = (*h) -> size * 2;
    func_hash new = new_func_hash(new_size);
    new -> n_elements = (*h) -> n_elements;

    for(int i = 0; i < (*h) -> size; i++) {
        bucket b = (*h)->table[i];
        if(b) {
            bucket* addr;
            __get_bucket_addr(new, b -> fun -> name, &addr);
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
static int __get_bucket_addr(func_hash h, char* key, bucket** ret) {
    char* lower_key = str_to_lower(key);
    unsigned int i = djb2_hash(lower_key) % (h -> size);
    free(lower_key);
    int found = 0;
    bucket* it = &(h -> table)[i];
    bucket* head = it;

    // try to find it in the current bucket
    while(*it && !found) {
        if( strcasecmp( (*it) -> fun -> name, key) == 0 )
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

void hash_put_fun(func_hash *h, func f) {
    bucket new, *ret;

    if((*h) -> n_elements == (*h) -> size)
        resize_func_hash(h);

    // if we haven't found it, we will have the head of the bucket where we must add it
    // so we create it, set it to point to the current head (since our new will be the new head)
    // and then we need to set the current head to point to the new head (*ret = new)
    if (! __get_bucket_addr(*h, f -> name, &ret) ) {
        new = new_bucket(f);
        new -> next = *ret;
        ++( (*h) -> n_elements );
        *ret = new;
    }
    else{
        (*ret) -> fun -> nr_args = f -> nr_args;
        (*ret) -> fun -> type = f -> type;

    }
}

void func_hash_put(func_hash *h, char* name, int nr_args, func_type type) {
    func f = new_func(name, nr_args, type);
    hash_put_fun(h, f);
}

func func_hash_get(func_hash *h, char* name) {
    bucket* ret;
    if (! __get_bucket_addr(*h, name, &ret) )
        return NULL;

    else
        return new_fun_from( (*ret) -> fun );
}

func_hash new_func_hash(int size) {
    func_hash h = (func_hash)malloc(sizeof(struct func_hash));
    h -> size = size;
    h -> n_elements = 0;
    h -> table = (bucket*)calloc(size, sizeof(bucket));
    return h;
}


