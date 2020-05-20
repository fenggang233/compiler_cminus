#lab1总结
首先进行该实验时，我选择把实验中需要识别的对象使用正则表达式表示出来。比如：

>ADD [+]
>EQ [=][=]

这样可以保持后面有关识别匹配部分代码的简洁。
值得一提的是在正则表达式语法中，中括号“[]”里的符号表示只取其中一个，因此大于等于使用正则表达式来表述应该是

>[>][=]

而不是

>[>=]

接下来是代码段中%%和%%之间的识别匹配后的具体操作。对于大部分匹配符，只需要在识别后记录开始位置和结束位置，并返回匹配符识别码就可以了，比较特殊的是对注释的识别，由于注释可能会跨行，意味着我们需要记录这个注释跨行数，因此在识别时选择识别“/*”这个标志，然后在匹配后进行的操作里覆盖对注释的匹配。

```C
"/*" {
	int c;
	pos_start = pos_end;
	pos_end += 2;
	while((c=input())!=0){
		pos_end += 1;
		if(c == '\n'){
			++lines;
			pos_end=1;
		}
		else if(c == '*'){
			if((c = input()) == '/'){
				pos_end++;
				return 289;
			}
			else unput(c);
		}
	}
	return 289;
}
```
在设计分析函数analyzer()时，一开始使用的是包含在<io.h>头文件下的_findfirst()等库函数，但在linux下这种操作不适用，于是转而使用<dirent.h>下的opendir(),readdir(),closedir()等函数来实现文件操作。

```C
void getAllTestcase(char filename[][256]){
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
	files_count = i;
        
	closedir(dir);
	return;
}

```
此外在设计main()函数时，要注意由于把lines，pos_start,pos_end设置成了全局变量，因而每读取一个新文件时都要记得把这三个变量初始化。

在设计测试样例时，使用C-minus语言编写了一段程序，特意将其中一个变量名设置为下划线开头制造识别错误，验证后发现除了错误部分，其余识别匹配均正常进行。

##遇到问题

1.首先是flex原理不理解，只是阅读助教编写的文档并不能使我对于flex的使用有一个准确的认识，我觉得最主要的原因可能是没有具体的例子来说明，在学习flex的过程中，我参考了
>https://blog.csdn.net/mist14/article/details/48641349

等一些博客，才最终明白了flex工作的原理。

2.然后是正则表达式的语法问题，这里我参考了
>https://www.runoob.com/regexp/regexp-syntax.html

对于相关知识的学习极大地帮助我完成了这个实验。

3.对于使用C语言进行文件的检索和识别有些生疏，并且事先没有认识到windows下和linux下文件检索方式有所不同，我在实验需要修改的文件里使用相关文件操作前先尝试编写了一个打开文件夹的cpp文件，发现在linux下无法正常运行后，我参考
>https://blog.csdn.net/qq_18144747/article/details/88085857

学习了<dirent.h>下一些基本的函数操作，这些知识帮助我克服了linux下读取文件的困难。

##时间统计
学习flex：阅读助教文档：30分钟
浏览网上flex教程：3个小时
代码编写：3个小时+
测试和debug：1个小时+
