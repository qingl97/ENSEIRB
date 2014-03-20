#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "pnm.h"

#define params 5
#define D 3
// #define RGB2LAB 1
// #define LAB2RGB -1

typedef enum {RGB2LAB, LAB2RGB} ConvertFlag_t;

typedef struct {
     float l;
     float a;
     float b;
}Pixel;

typedef struct {
    int width;
    int height;
    Pixel **pixelsArray;
}ImageLAB;

static float RGB2LMS[D][D] = {
  {0.3811, 0.5783, 0.0402}, 
  {0.1967, 0.7244, 0.0782},  
  {0.0241, 0.1288, 0.8444}
};

static float LMS2RGB[D][D] = {
  { 4.4679, -3.5873,  0.1193}, 
  {-1.2186,  2.3809, -0.1624},  
  { 0.0497, -0.2439,  1.2045}
};

static float M1[D][D] = {
    {1/sqrt(3), 0, 0},
    {0, 1/sqrt(6), 0},
    {0, 0, 1/sqrt(2)}
};

static float M2[D][D] = {
    {1, 1, 1},
    {1, 1, -2},
    {1, -1, 0}
};

static float M3[D][D] = {
    {1, 1, 1},
    {1, 1, -1},
    {1, -2, 0}
};

void usage(char *msg){
    fprintf(stderr, "%s", msg);
    fprintf(stderr, "Usage: ./colorization  ims imt imd nb_samples patchsize\n");
}

void matrix_mul_3X1(float m1[D][D], float m2[D], float res[D]){
    int i,k;
    for(i=0; i<D; i++){
        res[i] = 0;
        for(k=0; k<D; k++){
            res[i] += m1[i][k] * m2[k];    
        }
    }
}

ImageLAB* newImageLAB(int width, int height){
    /* to allocate memory for 2 dimension array */
    Pixel **image = (Pixel**)malloc(height*sizeof(Pixel*));
    if(image == NULL){
        fprintf(stderr, "memory allocation failed! 1\n");
        exit(EXIT_FAILURE);
    }
    for(int i=0; i<height; i++){
        image[i] = (Pixel*)malloc(width*sizeof(Pixel));
        if(image[i] == NULL){
            fprintf(stderr, "memory allocation failed! 2\n");
            exit(EXIT_FAILURE);
        }
    }
    ImageLAB *im = (ImageLAB*)malloc(sizeof(ImageLAB));
    im->width = width;
    im->height = height;
    im->pixelsArray = image;
    return im;
}

void freeImageLAB(ImageLAB *im){
    for(int i=0; i<im->height; i++){
        free(im->pixelsArray[i]);
    }
    free(im->pixelsArray);
    free(im);
}

/* convert color space of the pixel between RGB and LAB(Luminance, Alpha, Beta) */
void convertPixel(unsigned short *pixel_RGB, Pixel *pixel_LAB, ConvertFlag_t flag){
    if(flag == RGB2LAB){
        float p[3], tmp[3], pd[3];
        for(int z=0; z<3; z++){
            p[z] = (float)(pixel_RGB[z]);
        }
        matrix_mul_3X1(RGB2LMS, p, tmp);
        for(int i=0; i<3; i++){
            tmp[i] = log10(tmp[i]); /*ATTENTION*/
        }
        matrix_mul_3X1(M2, tmp, pd);
        matrix_mul_3X1(M1, pd, tmp);
        pixel_LAB->l = tmp[0];
        pixel_LAB->a = tmp[1];
        pixel_LAB->b = tmp[2];
    }

    if(flag == LAB2RGB){
        float p[3], tmp[3], pd[3];
        p[0] = pixel_LAB->l;
        p[1] = pixel_LAB->a;
        p[2] = pixel_LAB->b;
        matrix_mul_3X1(M1, p, tmp);
        matrix_mul_3X1(M3, tmp, pd);
        for(int i=0; i<3; i++){
            pd[i] = pow(10,pd[i]); /*ATTENTION*/
        }
        matrix_mul_3X1(LMS2RGB, pd, tmp);
        for(int z=0; z<3; z++){
            pixel_RGB[z] = tmp[z];
        }
    }
}

/* img_pnm and img_lab must be allocated for memory before using */
void convertColorSpace(pnm img_pnm, ImageLAB *img_lab, ConvertFlag_t flag){
    int width, height;
    if(flag == RGB2LAB){
        width = pnm_get_width(img_pnm);
        height = pnm_get_height(img_pnm);
    }
    if(flag == LAB2RGB){
        width = img_lab->width;
        height = img_lab->height;
    }
    unsigned short *pd_src = pnm_get_image(img_pnm);
    unsigned short *pixel_pnm;

    for(int y=0; y<height; y++){
        for(int x=0; x<width; x++){
            pixel_pnm  = pd_src + pnm_offset(img_pnm, y, x);
            convertPixel(pixel_pnm, &((img_lab->pixelsArray)[y][x]), flag);
        }    
    }
}

float getAverageLuminance(ImageLAB *image){
    int width, height;
    width = image->width;
    height = image->height;
    float tmp = 0;
    for(int i=0; i<height; i++){
        for(int j=0; j<width; j++){
            tmp += image->pixelsArray[i][j].l;
        }
    }
    return tmp/(width*height);
}

float getStandardDeviation(ImageLAB)

void luminanceRemapping(ImageLAB *imSrc, ImageLAB *imTgt){
    /* calculate average luminance*/
    float AvgLumiSrc = getAverageLuminance(imSrc);
    float AvgLumiTgt = getAverageLuminance(imTgt);


}

void colorization(char *path_ims, char *path_imt, char *path_imd, int nb_samples, int patchsize){
    pnm ims = pnm_load(path_ims);
    pnm imt = pnm_load(path_imt);
    int width = pnm_get_width(ims);
    int height = pnm_get_height(ims);
    ImageLAB *imageLAB = newImageLAB(width, height);

    convertColorSpace(ims, imageLAB, RGB2LAB);
    pnm imd = pnm_new(width, height, PnmRawPpm);
    convertColorSpace(imd, imageLAB, LAB2RGB);

    pnm_save(imd, PnmRawPpm, path_imd);
    pnm_free(ims);
    pnm_free(imt);
    pnm_free(imd);
    freeImageLAB(imageLAB);
}


int main(int argc, char *argv[])    
{
	if(argc != (params+1)) {
        usage("Error: number of arguments doesn't match\n");
        exit(EXIT_FAILURE);
    }

    char *path_ims = argv[1];
    char *path_imt = argv[2];
    char *path_imd = argv[3];
    int nb_samples = atoi(argv[4]);
    int patchsize = atoi(argv[5]);

    colorization(path_ims, path_imt, path_imd, nb_samples, patchsize);

    exit(EXIT_SUCCESS);
}