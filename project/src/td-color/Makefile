ROOT=../..

CC=gcc
CFLAGS= -g -Wall -Wextra -std=c99 -I$(ROOT)/include
LDFLAGS= -std=c99 -I$(ROOT)/include -L$(ROOT)/lib -lbcl -lm

OBJ= colorization

all:  colorization
.PHONY : all

colorization: colorization.o
	$(CC)  colorization.o $(LDFLAGS) -o colorization

colorization.o: colorization.c

install : all
	cp rotate $(ROOT)/bin/

clean :
	rm -f $(OBJ)


