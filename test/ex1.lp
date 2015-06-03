int z;
int i;
int[20] a;
int result;

%%



fn writeHi(int a, int b, int c,) -> void{
    %%
    put("hi");
}

fn main() -> int{

    %%

    i = 5;
    result = 0;
    a[4] = 2;
    a[5] = 7;
    while( a[i]<5) {
        result = result + z;
        i = i + 1 + get();
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
    writeHi(5,6,7,);
    return 1;
}


