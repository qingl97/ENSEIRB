FFLAGS=-O2

BIN = heat1 heat2

default: $(BIN)
all: default

.f.o:
	mpif77 $(FFLAGS) -c $*.f

.o:
	mpif77 $(FFLAGS) -o $@ $*.o

.f:
	mpif77 $(FFLAGS) -o $@ $*.f

clean:
	rm -f $(BIN) *.o tmp* toto*
