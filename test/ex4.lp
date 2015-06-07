int a;
int[20] b;
int c;

fn sum_b() -> int{
    int i;
    int result;
    i = 0;
    result = 0;
    while(i<20){
        result = result + b[i];
        i = i+1;
    };
    return result;
}

fn main() -> int{
    int i;
    int array_sum;
    i = 0;
    while(i<20){
        b[i] = i;
        i = i + 1;
    };

    array_sum = sum_b();

    if(array_sum == 0){
        put("wrong");
    }
    else{
        put("possibly correct");
    };


    return 1;
}