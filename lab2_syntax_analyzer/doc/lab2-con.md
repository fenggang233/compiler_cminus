#lab2实验报告

##实验要求
学习Bison，使用Bison进行语法分析并在分析过程中构建语法树

##实验设计
使用条件编译跳过了EOL，注释，空白符，也就是在lab2进行时，在yylex（）函数中对于这些识别不返回值。
构建语法树有两个选择，一个是把所有属性值重定义为为SyntaxTreeNode类型，这样做的代价是需要大幅修改yylex（）的识别过程，在识别每个终结符时就创建相应的叶子节点传递给yylval。
另一种方法是定义yylval为union类型，对于非终结符，把他们的属性值定义为SyntaxTreeNode类型，对于某些特定的终结符则定义成便于传递信息的类型（比如字符串类型）。
除此之外，lab2实验过程只要根据Bison语法编写即可。

##实验结果
对于文件：
```C
int foo(int a, int b[]) {
	return 1;
}

int main(void) {
	return 0;
}

```

识别结果为：
```C
>--+ program
|  >--+ declaration-list
|  |  >--+ declaration-list
|  |  |  >--+ declaration
|  |  |  |  >--+ fun-declaration
|  |  |  |  |  >--+ type-specifier
|  |  |  |  |  |  >--* int
|  |  |  |  |  >--* foo
|  |  |  |  |  >--* (
|  |  |  |  |  >--+ params
|  |  |  |  |  |  >--+ param-list
|  |  |  |  |  |  |  >--+ param-list
|  |  |  |  |  |  |  |  >--+ param
|  |  |  |  |  |  |  |  |  >--+ type-specifier
|  |  |  |  |  |  |  |  |  |  >--* int
|  |  |  |  |  |  |  |  |  >--* a
|  |  |  |  |  |  |  >--* ,
|  |  |  |  |  |  |  >--+ param
|  |  |  |  |  |  |  |  >--+ type-specifier
|  |  |  |  |  |  |  |  |  >--* int
|  |  |  |  |  |  |  |  >--* b
|  |  |  |  |  |  |  |  >--* []
|  |  |  |  |  >--* )
|  |  |  |  |  >--+ compound-stmt
|  |  |  |  |  |  >--* {
|  |  |  |  |  |  >--+ local-declarations
|  |  |  |  |  |  |  >--* epsilon
|  |  |  |  |  |  >--+ statement-list
|  |  |  |  |  |  |  >--+ statement-list
|  |  |  |  |  |  |  |  >--* epsilon
|  |  |  |  |  |  |  >--+ statement
|  |  |  |  |  |  |  |  >--+ return-stmt
|  |  |  |  |  |  |  |  |  >--* return
|  |  |  |  |  |  |  |  |  >--+ expression
|  |  |  |  |  |  |  |  |  |  >--+ simple-expression
|  |  |  |  |  |  |  |  |  |  |  >--+ additive-expression
|  |  |  |  |  |  |  |  |  |  |  |  >--+ term
|  |  |  |  |  |  |  |  |  |  |  |  |  >--+ factor
|  |  |  |  |  |  |  |  |  |  |  |  |  |  >--* 1
|  |  |  |  |  |  |  |  |  >--* ;
|  |  |  |  |  |  >--* }
|  |  >--+ declaration
|  |  |  >--+ fun-declaration
|  |  |  |  >--+ type-specifier
|  |  |  |  |  >--* int
|  |  |  |  >--* main
|  |  |  |  >--* (
|  |  |  |  >--+ params
|  |  |  |  |  >--* void
|  |  |  |  >--* )
|  |  |  |  >--+ compound-stmt
|  |  |  |  |  >--* {
|  |  |  |  |  >--+ local-declarations
|  |  |  |  |  |  >--* epsilon
|  |  |  |  |  >--+ statement-list
|  |  |  |  |  |  >--+ statement-list
|  |  |  |  |  |  |  >--* epsilon
|  |  |  |  |  |  >--+ statement
|  |  |  |  |  |  |  >--+ return-stmt
|  |  |  |  |  |  |  |  >--* return
|  |  |  |  |  |  |  |  >--+ expression
|  |  |  |  |  |  |  |  |  >--+ simple-expression
|  |  |  |  |  |  |  |  |  |  >--+ additive-expression
|  |  |  |  |  |  |  |  |  |  |  >--+ term
|  |  |  |  |  |  |  |  |  |  |  |  >--+ factor
|  |  |  |  |  |  |  |  |  |  |  |  |  >--* 0
|  |  |  |  |  |  |  |  >--* ;
|  |  |  |  |  >--* }

```
举例：对于return 0；识别为：首先识别token RETURN，NUMBER，SEMICOLON，随后expression→simple-expression→additive-expression→ term → factor → NUMBER，联合分号和RETURN识别为return-stmt。

##实验总结

首先进行该实验，需要掌握Bison的语法规则，特别是Bison里文法表达式的写法。

bison 里面 ”:” 代表一个 “->” ，同一个非终结符的不同产生式用 “|” 隔开，用 ”;” 结束表示一个非终结符产生式的结束；每条产生式的后面花括号内是一段 C 代码、这些代码将在该产生式被应用时执行，这些代码被称为 action ，产生式的中间以及 C 代码内部可以插入注释（稍后再详细解释本文件中的这些代码）；产生式右边是 ε 时，不需要写任何符号，一般用一个注释 /* empty */ 代替。

bison 会将 Productions 段里的第一个产生式的左边的非终结符（本文件中为 S ）当作语法的起始符号，同时，为了保证起始符号不位于任何产生式的右边， bison 会自动添加一个符号（如 S’ ）以及一条产生式（如 S’ -> S ），而将这个新增的符号当作解析的起始符号。

产生式中的非终结符不需要预先定义， bison 会自动根据所有产生式的左边来确定哪些符号是非终结符；终结符中，单字符 token （ token type 值和字符的 ASCII 码相同）也不需要预先定义，在产生式内部直接用单引号括起来就可以了，其他类型的 token 则需要预先在 Definitions 段中定义好。

此外，应该注意到，这次实验中需要考虑运算符的优先级问题，这一点可以通过在Definitions 段中加以定义

```C
%left '+' '-'
%left '*' '/'
```

其中的 %left 表明这些符号是左结合的。同一行的符号优先级相同，下面行的符号的优先级高于上面的。

bison 将根据自定义语法文件生成一个函数 int yyparse (void) （在 y.tab.c 文件中），该函数按 LR(1) 解析流程对词法分析得到的 token stream 进行解析，每当它需要读入下一个符号时，它就执行一次 x = yylex() ，每当它要执行一个折叠动作时，这个折叠动作所应用的产生式后面的花括号里面的 C 代码将被执行，执行完后才将相应的状态出栈。

yyparse 函数不仅维持一个状态栈，它还维持一个符号属性栈，当它执行 shift 动作时，它除了将相应的状态压入状态栈之外，还会将一个类型为 YYSTYPE （默认和 int 相同）、名为 yylval 的全局变量的数值压入到属性栈内，而在 reduce 动作时，可以用 $1, $2, ... $n 来引用属性栈的属性， reduce 动作不仅将相应的状态出栈，还会将同样数量的属性出栈，这些属性和 reduce 产生式的右边的符号是一一对应的，同时，用 $$ 代表产生式左边的终结符，在 reduce 动作里可以设置 $$ 的值，当执行 goto 动作时，除了将相应的状态入栈，还会将 $$ 入栈。

#实验难点

首先是在对cminus文件进行分析时，需要跳过EOL，空白符和注释，但是这些内容会经过lab1实现的lexical_analyzer.l中定义的操作进行返回，由于Bison直接调用yylex（）函数，而我们不能约束yylex（）读取这些符号时不进行操作，只能选择在读取时不返回数值，这里我使用条件编译，若需要结合Bison使用，则读取这三个符号时不返回token值。

此外，由于这次实验是借助Bison构建语法树，符号属性不能是int类型而应该是定义好的SyntaxTreeNode类型，而当读取终结符时，（特别是Identifier，number等需要具体值的终结符），我们又需要属性值是相应的字符串，这就需要对yylval进行自定义。

```C
%union {

    struct _SyntaxTreeNode* nd;
    char* cd;
}
%type <nd>program declaration-list declaration var-declaration type-specifier fun-declaration params param-list param compound-stmt local-declarations statement-list statement expression-stmt selection-stmt iteration-stmt return-stmt expression var simple-expression relop additive-expression addop term mulop factor call args arg-list
%token <cd>IDENTIFIER 284 NUMBER 285 ARRAY 286

```

这样我们就对yylval的值进行了自定义，并且对于非终结符，它的属性值是SyntaxTreeNode类型，非终结符则使用char*类型。

#建议

在自学了Bison的语法后，我可以基本看懂一个简单的Bison例子，但是构建语法树和使用Bison进行简单的语法分析差别还是很大的，然后实验引导对此只字不提，我对着实验要求愣了一下午也没想明白怎么通过属性构建语法树，虽然有了库函数，但这是我们第一次接触Bison，真正的难点应该是理解Bison中属性操作的意义，但是这方面的引导接近是0，还有关于自定义yylval的部分，实验代码中贴心的注明了%union部分需要补足，实验引导又是一个只字不提，结果就是我在实验开始时压根没想过属性值还可以修改类型，还可以使用属性值建立语法树。综上，这次实验要求很明白，引导接近0，所以获取到的信息全部需要google，然后lab2的一些操作可能可以不需要修改lab1，但是通过修改lab1也是可以实现的，但是这样一来我就需要一边做lab2，一边小心地保证lab1不出现问题，况且实验检查的晚，直到我lab2做完，lab1也没有检查，请问如果是lab1不小心有bug，那不是非常难修改吗？为什么要把实验设计成增量式的而不是独立的，之前的lab最好由助教提供统一版本。