int[3] ary;
int i;

%%

ary[0] = 0;
ary[1] = 2;
ary[2] = 4;

i = 0;

while(i < 3) {
    put ary[i];
    i = i + 1;
};

