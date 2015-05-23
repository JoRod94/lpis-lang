CC = clang
LEX = flex
YACC = yacc

CFLAGS ?= -Wall -Wextra -pedantic -Wno-unused-function -O2
CPPFLAGS += -Iincludes
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
	@printf "\n## RUNNING YACC $@\n"
	$(YACC) $(YFLAGS) $< -o $@

%.yy.c : %.l
	@printf "\n### RUNNING FLEX $@\n"
	$(LEX) -o $@ $<

%.tab.o : %.tab.c
	@printf "\n### COMPILING $@\n"
	$(COMPILE.c) $(OUTPUT_OPTION) $<

%.yy.o : %.yy.c
	@printf "\n### COMPILING $@\n"
	$(COMPILE.c) $(OUTPUT_OPTION) -Iyacc $<

$(EXEC) : $(O_FILES)
	@printf "\n### LINKING $@\n"
	$(LINK.c) $(OUTPUT_OPTION) $^ $(LOADLIBES) $(LDLIBS)

clean:
	@printf "### CLEANING FILES\n\n"
	@cat .make/asciiart/maid.art
	@echo ""
	$(RM) **/*.o
	$(RM) **/*.yy.c
	$(RM) **/*.h.ghc
	$(RM) **/*.out
	$(RM) **/*.tab.c
	$(RM) **/*.tab.h
	$(RM) **/*.output
	$(RM) $(EXEC)

