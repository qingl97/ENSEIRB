#include <stdlib.h>
#include <stdio.h>
#include <pnm.h>
#define param 2

void usage (char *s){
	char* use = "Usage: ./color2mean image_source image_destination\n";
	fprintf(stderr,use,s);
	exit(EXIT_FAILURE);
}

void process(char* path_ims, char *path_imd){
	pnm ims = pnm_load(path_ims);
	int height = pnm_get_height(ims);
	int width = pnm_get_width(ims);
	pnm imd = pnm_new(width, height, PnmRawPpm);

	unsigned short *p_ims = pnm_get_image(ims);
	unsigned short *p_imd = pnm_get_image(imd);
	int mean=0;
	
	printf("P2\n");
	printf("%d %d\n", width, height);
	printf("255\n");

	for(int y=0; y<height; y++){
		for(int x=0; x<width; x++){
			unsigned short *tmp = p_ims + pnm_offset(ims, y, x);//
			for(int z=0; z<3; z++){
			 	mean += *tmp;
			 	tmp++;
			}
			mean = mean/3;
			printf("%d ", mean);
		}    
		printf("\n");	
	}
	
	pnm_save(imd, PnmRawPpm, path_imd);
  	pnm_free(imd);
  	pnm_free(ims);
}

int main(int argc, char *argv[]){
	if (argc != (param+1)) usage(argv[0]);
	char *ims, *imd;
	ims = argv[1];
	imd = argv[2];
	
	process(ims, imd);
	return EXIT_SUCCESS;
}
