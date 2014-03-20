#include <stdlib.h>
#include <stdio.h>
#include <pnm.h>

void usage (char *s){
	char* use = "Usage: x0 y0 w h ims imd\n";
	fprintf(stderr,use,s);
	exit(EXIT_FAILURE);
}

void process(int posx, int posy, int width, int height, char* path_ims, char *path_imd){
	pnm ims = pnm_load(path_ims);
	pnm imd = pnm_load(path_imd);

	//unsigned short *p_ims = pnm_get_image(ims);
	//unsigned short *p_imd = pnm_get_image(imd);
	
	//unsigned short *p_s = p_ims + pnm_offset(ims, posx, posy);
	//unsigned short *p_d;
	
	for(int y=0; y<height; y++){
		for(int x=0; x<width; x++){
			
			unsigned short red = pnm_get_component(ims, posx, posy, PnmRed);
			unsigned short green = pnm_get_component(ims, posx, posy, PnmGreen);
			unsigned short blue = pnm_get_component(ims, posx, posy, PnmBlue);
		  	
		  	pnm_set_component(imd, x, y, PnmRed, red);
		  	pnm_set_component(imd, x, y, PnmGreen, green);
		  	pnm_set_component(imd, x, y, PnmBlue, blue);
		  	
		  	posx++;
		}    
		posy++;
	}
	
	pnm_save(imd, PnmRawPpm, path_imd);
  	pnm_free(imd);
  	pnm_free(ims);
}

int main(int argc, char *argv[]){
	if (argc != (param+1)) usage(argv[0]);
	
	int x0, y0, w, h;
	char *ims, *imd;
	x0 = atoi(argv[1]);
	y0 = atoi(argv[2]);
	w = atoi(argv[3]);
	h = atoi(argv[4]);
	ims = argv[5];
	imd = argv[6];
	
	process(x0, y0, w, h, ims, imd);
	return EXIT_SUCCESS;
}
