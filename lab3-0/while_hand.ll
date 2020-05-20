; MoudleID = 'while.c'
source_filename = "while.c"
;the source_filename above can be none since i write it on my own
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"
;copy from the gcd.ll

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

attributes #0 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 8.0.1 (tags/RELEASE_801/final)"}
