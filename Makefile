CC = clang
LEX = flex
YACC = yacc

CFLAGS ?= -Wall -Wextra -pedantic -Wno-unused-function -O2
LDFLAGS += -lfl
YFLAGS += -d
EXEC = parser.out

LEX_FILES = $(shell ls lex/*.l)
YACC_FILES = $(shell ls yacc/*.y)
C_FILES = $(shell ls src/*.c) $(YACC_FILES:%.y=%.tab.c) $(LEX_FILES:%.l=%.yy.c)
O_FILES = $(C_FILES:%.c=%.o)

.PHONY: clean
.SECONDARY:
%.tab.c %.tab.h: %.y
	@echo "\n## RUNNING YACC $@"
	$(YACC) $(YFLAGS) $< -o $@

%.yy.c : %.l
	@echo "\n### RUNNING FLEX $@"
	$(LEX) -o $@ $<

%.tab.o : %.tab.c
	@echo "\n### COMPILING $@"
	$(COMPILE.c) $(OUTPUT_OPTION) $<

%.yy.o : %.yy.c
	@echo "\n### COMPILING $@"
	$(COMPILE.c) $(OUTPUT_OPTION) $<

$(EXEC) : $(O_FILES)
	@echo "\n### LINKING $@"
	$(LINK.c) $(OUTPUT_OPTION) $^ $(LOADLIBES) $(LDLIBS)

clean:
	@echo "### CLEANING FILES\n"
	$(RM) **/*.o
	$(RM) **/*.yy.c
	$(RM) **/*.h.ghc
	$(RM) **/*.out
	$(RM) **/*.tab.c
	$(RM) **/*.tab.h
	$(RM) **/*.output
	$(RM) $(EXEC)

