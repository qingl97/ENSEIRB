ROOT=../..

CC=gcc
CFLAGS= -g -Wall -Wextra -std=c99 -I$(ROOT)/include
LDFLAGS= -std=c99 -I$(ROOT)/include -L$(ROOT)/lib -lbcl -lm

%OBJ= shear.o 

all: shear 

shear: shear.o 
	$(CC)  shear.o $(LDFLAGS) -o shear

shear.o: shear.c 

install : all
	cp shear $(ROOT)/bin/

clean :
	rm -f $(OBJ) shear 


