define i32 @main() {
entry:
  %i = alloca i32
  store i32 0, i32* %i
  %j = alloca i32
  store i32 6, i32* %j
  store i32 0, i32* %i
  br label %for

for:                                              ; preds = %forbody, %entry
  %loadtmp = load i32* %i
  %forcond = icmp sge i32 %loadtmp, 14
  br i1 %forcond, label %endfor, label %forbody

forbody:                                          ; preds = %for
  %loadtmp1 = load i32* %j
  %addtmp = add nsw i32 %loadtmp1, 5
  store i32 %addtmp, i32* %j
  %loadtmp2 = load i32* %i
  %addtmp3 = add nsw i32 %loadtmp2, 3
  store i32 %addtmp3, i32* %i
  br label %for

endfor:                                           ; preds = %for
  store i32 54, i32* %i
  %loadtmp4 = load i32* %j
  ret i32 %loadtmp4
}
