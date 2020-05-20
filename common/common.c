#include "common.h"

int getAllTestcase(char filename[][256])
{
	/// \todo student should fill this function
        DIR *dir;
	struct dirent *ptr;
	int i = 0;
	int length;
	
	dir = opendir("./testcase");
	
	while((ptr = readdir(dir)) != NULL){
		length = strlen(ptr->d_name);
		if(strcmp(&ptr->d_name[length-7],".cminus")==0){
			strcpy(filename[i++],ptr->d_name);
                        
		}
	
	}
	
        
	closedir(dir);
	return i;
}

