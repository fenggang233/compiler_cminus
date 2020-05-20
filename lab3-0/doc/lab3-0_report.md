## lab3-0实验报告

姓名 庞继泽

学号 PB17010420

### 实验要求

学习LLVM IR .ll文件的编写语法，学习LLVM c++ api，能够使用定义的api接口编写生成IR代码的cpp代码。

### 实验结果

```C
define dso_local i32 @main() #0 {
  %1 = alloca i32, align 4
  store i32 1, i32* %1, align 4
  %2 = load i32, i32* %1, align 4
  ret i32 %2
}

```
```C
	auto mainFun = Function::Create(FunctionType::get(TYPE32, false),
                                  GlobalValue::LinkageTypes::ExternalLinkage,
                                  "main", module);
    auto bb = BasicBlock::Create(context,"entry",mainFun);
    builder.SetInsertPoint(bb);
    //a
    auto aAlloca = builder.CreateAlloca(TYPE32);
    //a=1
    builder.CreateStore(CONST(1),aAlloca);
    //return_value = a
    auto retLoad = builder.CreateLoad(aAlloca);
    //return return_value
    builder.CreateRet(retLoad);

    builder.ClearInsertionPoint();

```
上文分别是assign.ll和assign_generator.cpp的核心代码，这里只定义了一个basicblock，进行了简单的创建变量，变量赋值和返回。

```C
define dso_local i32 @main() #0 {
    %cmp = icmp sgt i32 2, 1
    ;use constant to reduce the number of var
    br i1 %cmp, label %1, label %2
    ;if judge

; <label>:1:
    ret i32 1
    ;return 1
; <label>:2:
    ret i32 0    
}
```
```C
    auto mainFun = Function::Create(FunctionType::get(TYPE32, false),
                                  GlobalValue::LinkageTypes::ExternalLinkage,
                                  "main", module);
    auto bb = BasicBlock::Create(context, "entry", mainFun);
    builder.SetInsertPoint(bb);
    //(2>1)
    auto icmp = builder.CreateICmpSGT(CONST(2),CONST(1));

    auto trueBB = BasicBlock::Create(context, "trueBB", mainFun);
    auto falseBB = BasicBlock::Create(context,"falseBB", mainFun);
    builder.CreateCondBr(icmp,trueBB,falseBB);
    //true:ret 1
    builder.SetInsertPoint(trueBB);
    builder.CreateRet(CONST(1));
    //false:ret 0
    builder.SetInsertPoint(falseBB);
    builder.CreateRet(CONST(0));

```
上面是if.ll和if_generator.cpp的对应代码，这里原先的c代码有一个if结构，我们定义了三个basicblock，分别是进入判断前，判断为真和判断为假三个block，注意使用br i1 icmp，label %1,label %2与builder.CreateCondBr(icmp,trueBB,falseBB)的对应是在前一个里没有的。

```C
define dso_local i32 @main() #0 {
    %1 = alloca i32, align 4
    ;a
    %2 = alloca i32, align 4
    ;i
    store i32 10, i32* %1, align 4
    store i32 0, i32* %2, align 4
    ;assign value
    br label %3


;while-condition lable
; <label>:3:
    %4 = load i32, i32* %2, align 4
    %cmp = icmp slt i32 %4, 10
    br i1 %cmp, label %5, label %10

;while-body label
; <label>:5:
    %6 = load i32, i32* %2,align 4
    %7 = add nsw i32 %6,1
    store i32 %7, i32* %2, align 4
    ;i = i+1
    %8 = load i32, i32* %1, align 4
    %9 = add nsw i32 %8,%7
    store i32 %9,i32* %1, align 4
    ;a=a+i
    br label %3
    ;return while-condition
    

;while-end label
; <label>:10:
    %11  =load i32, i32* %1,align 4
    ret i32 %11

    
}

```
```C
    auto mainFun = Function::Create(FunctionType::get(TYPE32, false),
                                  GlobalValue::LinkageTypes::ExternalLinkage,
                                  "main", module);
    auto bb = BasicBlock::Create(context, "entry", mainFun);
    builder.SetInsertPoint(bb);
    auto aAlloca = builder.CreateAlloca(TYPE32);
    auto iAlloca = builder.CreateAlloca(TYPE32);
    //a=10;i=0
    builder.CreateStore(CONST(10),aAlloca);
    builder.CreateStore(CONST(0),iAlloca);

   
    //entry->whileCond
    //whileCond->whileBody or whileEnd
    //whileBody->whileCond
    auto whileCond = BasicBlock::Create(context,"whileCond",mainFun);
    auto whileBody = BasicBlock::Create(context,"whileBody",mainFun);
    auto whileEnd  = BasicBlock::Create(context,"whileEnd",mainFun);
    builder.CreateBr(whileCond);
    builder.SetInsertPoint(whileCond);
    auto iLoad = builder.CreateLoad(iAlloca);
    auto icmp = builder.CreateICmpSLT(iLoad,CONST(10));
    builder.CreateCondBr(icmp,whileBody,whileEnd);

    builder.SetInsertPoint(whileBody);
    auto aLoad = builder.CreateLoad(aAlloca);
    iLoad = builder.CreateLoad(iAlloca);
    //i = i + 1;a = a + i
    auto iAdd = builder.CreateNSWAdd(iLoad,CONST(1));
    auto aAdd = builder.CreateNSWAdd(aLoad,iAdd);
    builder.CreateStore(iAdd,iAlloca);
    builder.CreateStore(aAdd,aAlloca);
    builder.CreateBr(whileCond);

    builder.SetInsertPoint(whileEnd);
    auto retval = builder.CreateLoad(aAlloca);
    builder.CreateRet(retval);
```
上面两段代码是while.ll与while_generator.cpp的主要对应代码。在llvm中，while与if所展现出的结构都是通过分支来构建的，具体的构建方法则取决于编写者，这里我们构建了四个basicblock，分别对应着进入while判断之前，while条件判断块，while判断满足后的行为块，和退出while循环后的end块。这里注意使用builder.CreateBr()来进行不需要分支的块之间的转移。
```C
define dso_local i32 @callee(i32) #0 {
    %2 = alloca i32,align 4
    store i32 %0, i32* %2,align 4
    %3 = load i32, i32* %2,align 4
    %4 = mul nsw i32 %3,2
    ;%4  = 2*a
    ret i32 %4
    ;return 2*a
}

define dso_local i32 @main() #0 {
    %1 = call i32 @callee(i32 10)
    ;call callee()
    ret i32 %1
}
```

```C
auto calleeFun = Function::Create(FunctionType::get(TYPE32,Ints, false),
                                  GlobalValue::LinkageTypes::ExternalLinkage,
                                  "callee", module);
    auto bb = BasicBlock::Create(context, "entry", calleeFun);
    builder.SetInsertPoint(bb);
    auto aAlloca = builder.CreateAlloca(TYPE32);
    

    std::vector<Value *> args;  //获取gcd函数的参数,通过iterator
    for (auto arg = calleeFun->arg_begin(); arg != calleeFun->arg_end(); arg++) {
        args.push_back(arg);
    }
    //pass the args
    builder.CreateStore(args[0],aAlloca);
    auto aLoad = builder.CreateLoad(aAlloca);
    //return-value = 2*a
    auto retval = builder.CreateNSWMul(CONST(2),aLoad);
    builder.CreateRet(retval);
    //main
    auto mainFun = Function::Create(FunctionType::get(TYPE32, false),
                                  GlobalValue::LinkageTypes::ExternalLinkage,
                                  "main", module);
    bb = BasicBlock::Create(context, "entry", mainFun);
    builder.SetInsertPoint(bb);
    auto call = builder.CreateCall(calleeFun,{CONST(10)});
    builder.CreateRet(call);
```
上面两段代码是call.ll和call_generator.cpp的对应主要代码，在原c代码中，需要一个callee函数和一个main函数，除此之外没有while，if所对应的分支结构。因此我只构建了两个basicblock，分别对应callee（）和main()。






### 实验难点

1.vs code配置，不过这个应该属于个人问题，我之前没有接触过vs code，使用起来有点不习惯。而且这次实验完成后，我的vs code可以进行代码补全，头文件识别等，但编译和运行还是必须通过shell，如果后面两个实验需要更加依赖vs code，希望助教在这一点上可以做一些讲解。
2.c++语法，之前没有接触过c++，翻了翻博客大概能看懂一些，但是不知道后面的实验有多依赖c++能力？毕竟大家的C++并没有太接受过训练。
3.根据助教的generator文件我可以大概地学会使用里面用到的函数，表达，但还是仅限于照葫芦画瓢的地步，远不能十分熟练地运用。

### 实验总结

基本掌握了简单的llvm ir文件语法，学习了llvm C++ api接口，为后面的实验做准备。
