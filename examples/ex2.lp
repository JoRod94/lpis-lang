
fn main() -> int{
    int i;
    int j;
    int k;

    j = get();
    i = get();
    if( i == j){
        k = get();
        if(i == k){
            put("Same input 3 times");
        }
        elseif(i==2){
            put(k);
        }
        else{
            put("Same input 2 times");
        };
    }
    else{
        put("No repeated input");
    };

    return 1;
}