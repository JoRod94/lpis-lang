/*PLANO GERAL*/

//Inicializacao (int b)

hash.put("b", sp)
ident : pushi 0

//Inicializacao Array (int b[12])
hash.put("b", sp)
ident : alloc 12

//Declaracao (b=0;)

ident : pushi 0
ident : storel hash.get("b")


//Declaracao com calculo (b = b+1)

ident : pushg hash.get("b")
ident : pushi 1
ident : add
ident : storel hash.get("b")

//Escrever para output (put b)

ident : pushg hash.get("b")
ident : write(i/f) (verifica no prog se é inteiro ou float)

//Escrever string para output(put "String")
ident : pushs OBTER ENDEREÇO STRING
ident : writes

//Logica

// ==   ( b == 2)
ident : pushg hash.get("b")
ident : pushi 2
ident : equal
(vai ser usado para outras coisas tipo IF ou ciclo)

// !=  (b != 2)
ident : pushg hash.get("b")
ident : pushi 2
ident : equal
ident : not

// <=   (b <= 2)
ident : pushg hash.get("b")
ident : pushi 2
ident : infeq

//Ciclo while  (while (b != 2))

ident : pushg hash.get("b")
ident : pushi 2
ident : equal
ident : not
ident : jz continueEnd
ident : INSTRUCOES
ident : jump returnEnd

~~~~~~~~~ COMO FAZER EM C ~~~~~~~~
returnEnd = sp;

ident : pushg hash.get("b")
ident : pushi 2
ident : equal
ident : not

POR LIXO NA QUEUE (vai-se preencher isto depois);
sitio_do_lixo = currQueueIndex;

ident : CORPO_CICLO
ident : jump returnEnd

continueEnd = sp;
queue[sitio_do_lixo] = continueEnd;

ident : pushg hash.get("b")
ident : pushi 2
ident : equal
ident : not
ident : jz continueEnd
ident : CORPO_CICLO
ident : jump returnEnd

//IF    (if( b != 2))
ident : pushg hash.get("b")
ident : pushi 2
ident : equal
ident : not
ident : jz continueEnd
ident : CORPO_IF



