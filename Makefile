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

NO_COLOR=\x1b[0m
GREEN=\x1b[32;01m
YELLOW=\x1b[33;01m
BLUE=\x1b[34;01m
RED=\x1b[31;01m
WHITE=\x1b[37;01m

.PHONY: clean
.SECONDARY:
%.tab.c %.tab.h: %.y
	@printf "\n$(GREEN)YACC $(WHITE)GENERATING $@\n$(NO_COLOR)"
	$(YACC) $(YFLAGS) $< -o $@

%.yy.c : %.l
	@printf "\n$(YELLOW)FLEX $(WHITE)GENERATING $@\n$(NO_COLOR)"
	$(LEX) -o $@ $<

%.tab.o : %.tab.c
	@printf "\n$(BLUE)COMPILING $(WHITE)$@\n$(NO_COLOR)"
	$(COMPILE.c) $(OUTPUT_OPTION) $<

%.yy.o : CPPFLAGS += -Iyacc
%.yy.o : %.yy.c
	@printf "\n$(BLUE)COMPILING $(WHITE)$@\n$(NO_COLOR)"
	$(COMPILE.c) $(OUTPUT_OPTION) $<

$(EXEC) : $(O_FILES)
	@printf "\n$(RED)LINKING $(WHITE)$@$(NO_COLOR)\n"
	$(LINK.c) $(OUTPUT_OPTION) $^ $(LOADLIBES) $(LDLIBS)

debug: CFLAGS:=$(filter-out -O2,$(CFLAGS))
debug: CFLAGS += -g -DDEBUG
debug: YFLAGS += -v
debug: $(EXEC)

leak-check: CFLAGS:=$(filter-out -O2,$(CFLAGS))
leak-check: CFLAGS += -g
leak-check: $(EXEC)
	 $(VALGRIND)./$(EXEC)

osx: LDFLAGS:=$(filter-out -lfl,$(LDFLAGS))
osx: LDFLAGS+= -ll
osx: $(EXEC)

osx_debug: CFLAGS:=$(filter-out -O2,$(CFLAGS))
osx_debug: CFLAGS += -g -DDEBUG
osx_debug: YFLAGS += -v
osx_debug: LDFLAGS:=$(filter-out -lfl,$(LDFLAGS))
osx_debug: LDFLAGS+= -ll
osx_debug: $(EXEC)

clean:
	@printf "$(WHITE)\tCLEANING UP\n\n"
	@cat .make/asciiart/maid.art
	@printf "$(NO_COLOR)\n"
	$(RM) **/*.o
	$(RM) **/*.yy.c
	$(RM) **/*.h.ghc
	$(RM) **/*.out
	$(RM) **/*.tab.c
	$(RM) **/*.tab.h
	$(RM) **/*.output
	$(RM) $(EXEC)

