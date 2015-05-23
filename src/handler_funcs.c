Queue q;
int sp;


Queue nestedIndexes;
Queue nestedWhileJumps;

void startLoop(char *condition){
    writeCondition(condition);
    nestedIndexes.push(sp);
    char *jumpInst = (char *) malloc(5+ADDRESS_LENGTH);
    sprintf(jumpInst, "jump %s", sp);
    nestedWhileJumps.push(jumpInst);
}


void finishLoop(){
    q.put(nestedWhileJumps.pop(), sp);

    char *jzInst = (char *) malloc(3+ADDRESS_LENGTH);
    sprintf(jzInst, "jz %s", nestedIndexes.pop() );
    q.put(tempIndex, jzInst);
}


void startIf(char *condition){
    writeCondition(condition);
    nestedIndexes.push(sp);
}

void endIf(){
    q.put(nestedWhileJumps.pop(), sp);
}
