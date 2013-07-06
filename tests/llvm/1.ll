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
  %loadtmp666 = load i32* %no
  ret i32 %loadtmp666
}
