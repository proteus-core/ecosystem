CFLAGS += -DITERATIONS=1500
CFLAGS += -DPERFORMANCE_RUN=1
#CFLAGS += -DVALIDATION_RUN=1

OBJECTS =
OBJECTS += core_list_join.o
OBJECTS += core_main.o
OBJECTS += core_matrix.o
OBJECTS += core_state.o
OBJECTS += core_util.o
OBJECTS += core_portme.o

.PHONY: all
all: core.bin

%.o: %.c $(lastword $(MAKEFILE_LIST)) coremark.h core_portme.h
	$(CC) $(CFLAGS) -DFLAGS_STR="\"$(CFLAGS) $(LDFLAGS)\"" -c $< -o $@

.PHONY: clean
clean:
	$(RM) -r core.bin core.elf core.ihex $(OBJECTS)

include ../Makefile.include
