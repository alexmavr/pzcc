define i32 @main() {
entry:
  %ok = alloca i32
  store i32 9, i32* %ok
  %no = alloca i32
  store i32 8, i32* %no
  %loadtmp = load i32* %no
  %eqtmp = icmp eq i32 %loadtmp, 8
  %ifcond = icmp ne i1 %eqtmp, false
  br i1 %ifcond, label %then, label %else

then:                                             ; preds = %entry
  store i32 0, i32* %no
  %loadtmp1 = load i32* %ok
  %eqtmp2 = icmp eq i32 %loadtmp1, 9
  %ifcond3 = icmp ne i1 %eqtmp2, false
  br i1 %ifcond3, label %then4, label %else5

else:                                             ; preds = %entry
  br label %ifmerge

ifmerge:                                          ; preds = %else, %ifmerge6
  %loadtmp7 = load i32* %no
  store i32 %loadtmp7, i32* %ok
  %loadtmp8 = load i32* %ok
  ret i32 %loadtmp8

then4:                                            ; preds = %then
  store i32 4, i32* %no
  br label %ifmerge6

  else5:                                            ; preds = %then
  store i32 3, i32* %no
  br label %ifmerge6

ifmerge6:                                         ; preds = %else5, %then4
  br label %ifmerge
}
