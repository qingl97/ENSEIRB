/* Post processor for the m4 output file (ccdefs.m4) */

#define BUFFERLEN	4096

#include <stdio.h>
#include <string.h>

#define isspace(c) ((c)==' ' || (c)=='\t')
#define isalnum(c) ( ((c)>='a' && (c)<='z') ||	\
                     ((c)>='A' && (c)<='Z') || 	\
                     ((c)>='0' && (c)<='9') )
#define isseperator(c) (!isalnum(c) && c!='_')

char line[BUFFERLEN], line1[BUFFERLEN], line_save[BUFFERLEN];
char *saved_line=NULL;

void delete_spaces0(char *src, char *dest);
void delete_spaces1(char *s);

int main(void)
{
    int mode=0, lineno=0;

    do {
	if (fgets(line, sizeof(line), stdin)==NULL) break;
        if (line[strlen(line)-1] == '\n') line[strlen(line)-1] = '\0';
	lineno++;
        /* skip comment lines */
        if ( line[0]=='*' || line[0]=='c' || line[0]=='C') {
	    if (strncmp(line, "*m4:", 4)) {
	        if (saved_line!=NULL) {
	            puts(saved_line); saved_line=NULL;
	        }
		puts(line);
		continue;
	    }
        }
        /* Check for labels (only possible outside of do-loop expansion) */

	delete_spaces0(line, line1);
	if (!strlen(line1)) continue;	/* discard blank lines */
/*		printf("mode=%d, \"%s\" \"%s\"\n", mode, line, line1);*/
	if (!mode) {
	    if (!strcmp(line1,"*m4: start expansion")) {
		mode=1; saved_line=NULL;
		puts(line1);
		continue;
	    }
	    puts(line);
	    continue;
	}
	/* Now within texts resulted from do loop expansions */
	if (!strcmp(line1,"*m4: end expansion")) {
	    if (saved_line!=NULL) puts(saved_line);
            puts(line1);
	    mode=0; saved_line=NULL; continue;
	}
	delete_spaces1(line1);
	if (line1[0]>='0' && line1[0]<='9') {
	    int i, j;
	    /* process label */
	    for (i=1; line1[i]>='0' && line1[i]<='9'; i++);
	    if (i>5) {
		fprintf(stderr,"Line %d: invalid label.\n",lineno);
		return 1;
	    }
	    for (j=i; isspace(line1[j]); j++);
	    strncpy(line,line1,i); strcpy(line+6,line1+j);
	    while (i<6) line[i++]=' ';
	} else if (line1[0]=='&') {
  	    /* try to combine continuation line with the previous line */
	    if (saved_line==NULL) {
		fprintf(stderr,"Line %d: unexpected continuation line.\n",lineno);
		return 1;
	    }
	    if (strlen(saved_line)+strlen(line1)-1<=72) {
		char c1=saved_line[strlen(saved_line)-1], c2=line1[1];
		if ( !isseperator(c1) && !isseperator(c2) )
		    strcat(saved_line," ");
		strcat(saved_line,line1+1);
		continue;
	    }
	    sprintf(line,"     &%s",line1+1);
	} else {
	    sprintf(line,"      %s",line1);
	}
	if (saved_line!=NULL) puts(saved_line);
	strcpy(saved_line=line_save, line);
    } while (1);

    return 0;
}

void delete_spaces0(char *src, char *dest)
/* delete leading/trailing spaces */
{
    while (isspace(*src)) src++;
    strcpy(dest,src);

    src=dest+strlen(dest)-1;
    while (src>=dest && isspace(*src)) src--;
    src[1]='\0';

    if (dest[0]=='&' && isspace(dest[1])) {
	for (src=dest+2; isspace(*src); src++);
	strcpy(dest+1,src);
    }

    /* replace '|' bye '_' */
    for (src=dest; *src; src++) if (*src=='|') *src='_';
}

void delete_spaces1(char *s)
/* delete extra interword spaces */
{
    char *p;
    int c1,c2;

    while (*s) {
	if (!isspace(*s)) {s++; continue;}
	for (p=s; isspace(*p); p++);
	c1=*(s-1); c2=*p;
	if ( isseperator(c1) || isseperator(c2) ) {
	    strcpy(s,p); s++;
	} else {
	    strcpy(s+1,p); s++;
	}
    }
}
