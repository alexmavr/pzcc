define i32 @main() {
entry:
  %y2 = alloca [25 x [11 x [10 x i32]]]
  %j = alloca i32
  store i32 5, i32* %j
  %geptmp = getelementptr [25 x [11 x [10 x i32]]]* %y2, i32 0, i32 22, i32 5, i32 2
  store i32 1, i32* %geptmp
  %loadtmp = load i32* %j
  %geptmp1 = getelementptr [25 x [11 x [10 x i32]]]* %y2, i32 0, i32 22, i32 5, i32 2
  %loadtmp2 = load i32* %geptmp1
  %addtmp = add nsw i32 %loadtmp, %loadtmp2
  store i32 %addtmp, i32* %j
  %loadtmp3 = load i32* %j
  %casttmp = uitofp i32 %loadtmp3 to double
  %addtmp4 = fadd double %casttmp, 1.200000e+00
  %k = alloca double
  store double %addtmp4, double* %k
  %t = alloca i8
  store i8 97, i8* %t
  %loadtmp5 = load double* %k
  %addtmp6 = fadd double %loadtmp5, 1.203000e+02
  %loadtmp7 = load i8* %t
  %casttmp8 = uitofp i8 %loadtmp7 to double
  %subtmp = fsub double %addtmp6, %casttmp8
  store double %subtmp, double* %k
  ret i32 %loadtmp3
}
