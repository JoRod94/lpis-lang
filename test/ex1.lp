int z;
int i;
int[20] a;
int result;


fn writeHello() -> void{
    put("hello\n");
}

fn soma(int a, int b) -> int{
    return a+b;
}

fn main() -> int{
    int inFunction;
    

    i = -5;
    result = 0;
    a[4] = 2;
    a[5] = 7;
    while( a[i]<5) {
        result = result + z;
        i = i + 1 + get();
        if(i==3){
            put(i);
            if(i==2){
                put("ad");
            }
            else{
                put("add");
            };
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
    i = i + soma(5,6);
    writeHello();
    return 1;
}

