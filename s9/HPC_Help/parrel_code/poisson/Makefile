FFLAGS=-O2

BIN = poisson0 poisson1 poisson2 poisson3 poisson4

default: $(BIN)
all: default

.f.o:
	mpif77 $(FFLAGS) -c $*.f

.o:
	mpif77 $(FFLAGS) -o $@ $*.o

.f:
	mpif77 $(FFLAGS) -o $@ $*.f

clean:
	rm -f $(BIN) *.o result.dat
