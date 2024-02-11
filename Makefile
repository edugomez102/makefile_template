
###############################################################################
# Variable macros
###############################################################################

# Directories

SRC        := src
OBJ        := obj
BIN        := bin
TEST_SRC   := test

# Binaries

APP        := app
TEST_APP   := test

# Compiler

C          := gcc

# Flags

LIBS       :=
INCLUDE    := -Isrc -Isrc/lib

# Object files structure 

MAIN_FILE  := main.c

ALLCS      := $(shell find $(SRC)/ -type f -iname "*.c" -not -name "$(MAIN_FILE)")
ALLCSOBJS  := $(patsubst $(SRC)/%.c,$(OBJ)/$(SRC)/%.o,$(ALLCS))

# Testing

TEST_OBJ   := $(OBJ)/$(TEST_SRC)
TEST_LIB   := -lihct

TEST_ALLCS := $(shell find $(TEST_SRC)/ -type f -iname "*.c")
TEST_OBJS  := $(patsubst $(TEST_SRC)/%.c,$(TEST_OBJ)/%.o,$(TEST_ALLCS))

# Directory management

SUBDIRS    := $(shell find $(SRC)/ -type d)
OBJSUBDIRS := $(patsubst $(SRC)%,$(OBJ)/$(SRC)%,$(SUBDIRS))

# Run binaries after build, default to true

RUN        := 1

###############################################################################
# Config flags
###############################################################################

DEBUG := 1

# Compiler dependent flags

CFLAGS      := 
FLAGS_GCC   := -Wenum-int-mismatch
FLAGS_CLANG := -Wassign-enum

ifeq ($(DEBUG),1)
	CFLAGS += -g -Wall -Wextra -Wpedantic -Wconversion
	CFLAGS += -Wswitch -Wswitch-enum -Wenum-conversion -Wenum-compare -std=c2x
	ifeq ($(C),gcc)
		CFLAGS += $(FLAGS_GCC)
	else ifeq ($(C),clang)
		CFLAGS += $(FLAGS_CLANG)
	endif
else
	CFLAGS += -O2
endif

###############################################################################

.PHONY: print_dir print_test


$(APP) : $(OBJSUBDIRS) $(ALLCSOBJS) 
	$(C) -o $(BIN)/$(APP) $(SRC)/$(MAIN_FILE) $(ALLCSOBJS) $(CFLAGS) $(LIBS) $(INCLUDE)
	@if [ $(RUN) = 1 ]; then \
		./$(BIN)/$(APP); \
	fi

$(OBJ)/$(SRC)/%.o : $(SRC)/%.c
	$(C) -o $@ -c $^ $(CFLAGS) $(INCLUDE)

$(TEST_APP) : $(OBJSUBDIRS) $(TEST_OBJS) $(ALLCSOBJS)
	$(C) -o $(BIN)/$(TEST_APP) $(TEST_OBJS) $(ALLCSOBJS) $(TEST_LIB)
	@if [ $(RUN) = 1 ]; then \
		./$(BIN)/$(TEST_APP); \
	fi

$(TEST_OBJ)/%.o: $(TEST_SRC)/%.c
	$(C) -o $@ -c $^ $(CFLAGS) -Isrc -Isrc/lib


MKDIR   := mkdir -p

$(OBJSUBDIRS): 
	@$(MKDIR) $@
	@$(MKDIR) $(TEST_OBJ)
	@$(MKDIR) $(BIN)

print_dir:
	$(info $(SUBDIRS))
	$(info $(OBJSUBDIRS))
	$(info $(ALLCS))
	$(info $(ALLCSOBJS))

print_test:
	$(info $(TEST_ALLCS))
	$(info $(TEST_OBJS))

clean:
	rm -rf $(OBJ)
	rm -rf $(BIN)

recode: clean $(APP)
retest: clean $(TEST_APP)
