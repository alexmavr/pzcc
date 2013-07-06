define i32 @main() {
entry:
  %no = alloca i32
  store i32 0, i32* %no
  %k = alloca i32
  store i32 7, i32* %k
  br label %while

while:                                            ; preds = %whilebody, %entry
  br i1 true, label %whilebody, label %endwhile

whilebody:                                        ; preds = %while
  br label %endwhile
  br label %while

endwhile:                                         ; preds = %whilebody, %while
  br label %while1

while1:                                           ; preds = %whilebody2, %endwhile
  %loadtmp = load i32* %no
  %eqtmp = icmp eq i32 %loadtmp, 0
  %whilecond = icmp ne i1 %eqtmp, false
  br i1 %whilecond, label %whilebody2, label %endwhile3

whilebody2:                                       ; preds = %while1
  store i32 1, i32* %no
  br label %while1

endwhile3:                                        ; preds = %while1
  br label %while4

while4:                                           ; preds = %whilebody5, %whilebody5, %endwhile3
  %loadtmp7 = load i32* %no
  %lesstmp = icmp slt i32 %loadtmp7, 3
  %whilecond8 = icmp ne i1 %lesstmp, false
  br i1 %whilecond8, label %whilebody5, label %endwhile6

whilebody5:                                       ; preds = %while4
  %loadtmp9 = load i32* %no
  %addtmp = add nsw i32 %loadtmp9, 1
  store i32 %addtmp, i32* %no
  %loadtmp10 = load i32* %k
  %addtmp11 = add nsw i32 %loadtmp10, 1
  store i32 %addtmp11, i32* %k
  br label %while4
  %loadtmp12 = load i32* %k
  %addtmp13 = add nsw i32 %loadtmp12, 1
  store i32 %addtmp13, i32* %k
  br label %while4

endwhile6:                                        ; preds = %while4
  %loadtmp110 = load i32* %k
  ret i32 %loadtmp110
}
