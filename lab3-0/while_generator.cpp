#include <llvm/IR/BasicBlock.h>
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/LLVMContext.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/Type.h>
#include <llvm/IR/Verifier.h>

#include <iostream>
#include <memory>

#ifdef DEBUG  // 用于调试信息,大家可以在编译过程中通过" -DDEBUG"来开启这一选项
#define DEBUG_OUTPUT std::cout << __LINE__ << std::endl;  // 输出行号的简单示例
#else
#define DEBUG_OUTPUT
#endif

using namespace llvm;
#define CONST(num) \
  ConstantInt::get(context, APInt(32, num))  //得到常数值的表示,方便后面多次用到

int main(){
    LLVMContext context;
    Type *TYPE32 = Type::getInt32Ty(context);
    IRBuilder<> builder(context);
    auto module = new Module("while", context);
    //main function
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
    builder.ClearInsertionPoint();

    module->print(outs(), nullptr);
    delete module;
    return 0;








}