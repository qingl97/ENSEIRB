#include <stdlib.h>
#include <stdio.h>

static void process(int r, int g, int b, int w, int h){
	int i,j;
	
	printf("P3\n");
	printf("%d %d\n", w, h);
	printf("255\n");
	
	for(i=0; i<h; i++){
		for(j=0; j<w; j++){
			printf("%d %d %d ", r, g, b);	
		}
		printf("\n");	
	}
}

void usage (char *s){
	char* use = "Usage: %s <r[0,255]> <g[0,255]> <b[0,255}> <width> <height>\n";
	fprintf(stderr,use,s);
	exit(EXIT_FAILURE);
}

#define param 5

int main(int argc, char *argv[]){
	if (argc != (param+1)) usage(argv[0]);
	/* etc */
	int r,g,b,w,h;
	
	r = atoi(argv[1]);
	g = atoi(argv[2]);
	b = atoi(argv[3]);
	w = atoi(argv[4]);
	h = atoi(argv[5]);
	
	process(r, g, b, w, h);
	return EXIT_SUCCESS;
}
