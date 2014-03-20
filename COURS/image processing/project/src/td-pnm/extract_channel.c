#include <stdlib.h>
#include <stdio.h>
#include <pnm.h>

#define param 3
#define 0 PnmRed
#define 1 PnmGreen
#define 2 PnmBlue

void usage (char *s){
	char* use = "Usage: num ims imd\n";
	fprintf(stderr,use,s);
	exit(EXIT_FAILURE);
}

void process(int canal, char *ims, char *imd){
	
}

int main(int argc, char *argv[]){
	if (argc != (param+1)) usage(argv[0]);	
	
	int canal = atoi(argv[1]);
	char *ims = argv[2];
	char *imd = argv[3];
	
	process(canal, ims, imd);
	exit(EXIT_SUCCESS);
}
