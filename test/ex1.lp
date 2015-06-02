int z;
int i;
int[20] a;
int result;

%%

fn doMath() -> int{
    %%
    return (1+1);
}

fn main() -> int{

    %%

    i = 5;
    result = 0;
    a[4] = 2;
    a[5] = 7;
    while( a[i]<5) {
        result = result + z;
        i = i + 1 + get() + sum();
        if(i==3){
            put(i);
        }
        elseif(i==4){
            put(i);
        }
        else{
            put(2);
        };
    };

    a[2] = 7;
    put("test");
    put(result);
    writeHi();
    return 1;
}

fn writeHi() -> void{
    %%
    put("hi");
}

