define i32 @main() {
entry:
  %i = alloca i32
  store i32 0, i32* %i
  %j = alloca i32
  store i32 6, i32* %j
  %k = alloca i32
  store i32 255, i32* %k
  store i32 0, i32* %i
  br label %for

for:                                              ; preds = %endfor3, %entry
  %loadtmp = load i32* %i
  %forcond = icmp sge i32 %loadtmp, 14
  br i1 %forcond, label %endfor, label %forbody

forbody:                                          ; preds = %for
  store i32 64, i32* %j
  br label %for1

endfor:                                           ; preds = %for
  store i32 54, i32* %i
  %loadtmp16 = load i32* %k
  ret i32 %loadtmp16

for1:                                             ; preds = %forbody2, %forbody
  %loadtmp4 = load i32* %j
  %forcond5 = icmp sle i32 %loadtmp4, 32
  br i1 %forcond5, label %endfor3, label %forbody2

forbody2:                                         ; preds = %for1
  %loadtmp6 = load i32* %k
  %addtmp = add nsw i32 %loadtmp6, 1
  store i32 %addtmp, i32* %k
  %loadtmp7 = load i32* %j
  %addtmp8 = sub nsw i32 %loadtmp7, 1
  store i32 %addtmp8, i32* %j
  br label %for1

endfor3:                                          ; preds = %for1
  %loadtmp9 = load i32* %i
  %addtmp10 = add nsw i32 %loadtmp9, 1
  store i32 %addtmp10, i32* %i
  br label %for
}

