#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "pnm.h"

#define params 5
#define PI 3.14159265

int isOutOfRange;
int height, width;
int cntr_x, cntr_y;
double angle;

void usage(char *msg){
    fprintf(stderr, "%s", msg);
    fprintf(stderr, "Usage: ./rotate cntr_x cntr_y angle source_image dest_image\n");
}

/*Map the current pixel at destination image to the pixel at the source image*/
void getLocation(int x, int y, double *x_d, double *y_d){
    // printf("mapping position at source image [%d, %d], %c, %f\n", x, y, dir, angle);

    double tmp_x, tmp_y;
    if(angle == 0.0){
        *x_d = x;
        *y_d = y;
    }
    else if(dir == 'h'){
        tmp_x = x-y*tan(angle*PI/180.0);
        // printf("%f\n", tmp_x);
        if(angle>0){
            if((int)tmp_x>=s_width || (int)tmp_x<0)
                isOutOfRange = 1;
            else{
                *x_d = tmp_x;
                *y_d = y;
                isOutOfRange = 0;
            }
        }
        if(angle<0){
            if(s_width-(d_width-(int)tmp_x)<0 || s_width-(d_width-(int)tmp_x)>=s_width)
                isOutOfRange = 1;
            else{
                *x_d = s_width-(d_width-tmp_x);
                *y_d = y;
                isOutOfRange = 0;
            }
        }
    }
    else if(dir == 'v'){
        if(angle>0){
            tmp_y = y-x*tan(angle*PI/180.0);
            if((int)tmp_y>=s_height || (int)tmp_y<0)
                isOutOfRange = 1;
            else{
                *x_d = x;
                *y_d = tmp_y;
                isOutOfRange = 0;
            }
        }
        if(angle<0){
            tmp_y = y+(d_width-x)*tan(angle*PI/180.0);
            if((int)tmp_y>=s_height || (int)tmp_y<0)
                isOutOfRange = 1;
            else{
                *x_d = x;
                *y_d = tmp_y;
                isOutOfRange = 0;
            }
        }
    }

    // printf("mapped position at [%f, %f]\n", *x_d, *y_d);
}

/*  
    input: the caculated position of mapping pixel in source image
    do bilinear interpolation
    return a array containing the indensities of the caculated pixel values
*/
void bilinear_interpolation(pnm image, double x, double y, unsigned char *pixel){
    // printf("beging interpolation at position [%f, %f]\n", x, y);
    //unsigned char pixel[3];
    double dx, dy;
    int s_x, s_y;
    s_x = (int)x;
    s_y = (int)y;
    dx = x-s_x;
    dy = y-s_y;
    // printf("(%d, %d)\n", s_x, s_y);

    unsigned short* p_image = pnm_get_image(image); 
    unsigned short *val_0;
    unsigned short *val_1;
    unsigned short *val_2;
    unsigned short *val_3;
    val_0 = p_image + pnm_offset(image, s_y, s_x);

    if(s_x==0 || s_y==0 || s_y+1>=height || s_x+1>=width)
        for(int i=0; i<3; i++){
            pixel[i] = *val_0++;
        }
    else {
        val_1 = p_image + pnm_offset(image, s_y+1, s_x);
        val_2 = p_image + pnm_offset(image, s_y, s_x+1);
        val_3 = p_image + pnm_offset(image, s_y+1, s_x+1);

        //printf("\t [%d, %d, %d] [%d, %d, %d] [%d, %d, %d] [%d, %d, %d]\n", *val_0, *(val_0+1), *(val_0+2), *val_1, *(val_1+1), *(val_1+2), *val_2, *(val_2+1), *(val_2+2), *val_3, *(val_3+1), *(val_3+2));

        for(int i=0; i<3; i++){
            pixel[i] = (1-dx)*(1-dy)*(*val_0++) + (1-dx)*dy*(*val_1++) + (1-dy)*dx*(*val_2++) + dx*dy*(*val_3++);
        }
    }
}

/*
    calculate target pixel in the source image
    use bilinear interpolation to calculate indensities of that target pixel
    assign the 
*/
void rotate(char* path_ims, char *path_imd, int x, int y, double angle){
    printf("begin rotate ...\n");

    pnm ims = pnm_load(path_ims);

    /*get the width and height of the source image*/
    s_height = pnm_get_height(ims);
    s_width = pnm_get_width(ims);

    /*iniciate size of the destination image*/
    if(dir == 'h'){
        d_width = s_width + abs(s_height*tan(angle*PI/180.0))+1;
        d_height = s_height;
    }
    if(dir == 'v'){
        d_height = s_height + abs(s_width*tan(angle*PI/180.0))+1;
        d_width = s_width;
    }

    pnm imd = pnm_new(d_width, d_height, PnmRawPpm);

    unsigned char pixel[3];
    unsigned short* pd_image = pnm_get_image(imd);

    /*
    get the mapping pixel in source image, Pm(double x, double y)
    get the pixel indensities of pixel Pm through the bilinear_interpolation method
    assign values to the current pixel of the destination image
    */
    double x_d, y_d;
    unsigned short* tmp;
    for(int y=0; y<d_height; y++){
        for(int x=0; x<d_width; x++){
            tmp  = pd_image + pnm_offset(imd, y, x);
            getLocation(dir, x,y,&x_d,&y_d);
            if(!isOutOfRange){
                bilinear_interpolation(ims, x_d, y_d, pixel);
            }
            for(int z=0; z<3; z++){
                if(isOutOfRange)
                    *tmp = 0;
                else
                    *tmp = pixel[z];
                tmp++;
            }
            //printf("**************************end***************************\n");
        }    
    }

    pnm_save(imd, PnmRawPpm, path_imd);
    pnm_free(imd);
    pnm_free(ims);

    // printf("shearing OK\n");
}

int main(int argc, char* argv[]){
    if(argc != (params+1)) {
        usage("Error: number of arguments doesn't match\n");
        exit(EXIT_FAILURE);
    }

    int cntr_x = atoi(argv[1]);
    int cntr_y = atoi(argv[2]);
    angle = atof(argv[3]);
    char *path_ims = argv[4];
    char *path_imd = argv[5];
    rotate(path_ims, path_imd, cntr_x, cntr_y, angle);

    exit(EXIT_SUCCESS);
}
