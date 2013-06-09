@l = constant i32 106
@lk = constant i32 106
@jjjj = global i32 0
@jjjk = global double 0.000000e+00
@jjjl = global i8 0
@jjjp = global i1 false

define i32 @main() {
entry:
  %kk = alloca i8
  store i8 54, i8* %kk
  %jk = alloca i1
  store i1 true, i1* %jk
  %jj = alloca i1
  store i1 true, i1* %jj
  %boo = alloca i1
  store i1 true, i1* %boo
  %boon = alloca i1
  store i1 true, i1* %boon
  %asdasd = alloca i1
  store i1 true, i1* %asdasd
  %asdasd2 = alloca i1
  store i1 true, i1* %asdasd2
  %g = alloca i1
  store i1 true, i1* %g
  %loadtmp = load i1* %jj
  %loadtmp1 = load i1* %boo
  %loadtmp2 = load i1* %boon
  %andtmp = and i1 %loadtmp1, %loadtmp2
  %ortmp = or i1 %loadtmp, %andtmp
  %ndk = alloca i1
  store i1 %ortmp, i1* %ndk
  %loadtmp3 = load i1* %ndk
  store i1 %loadtmp3, i1* %ndk
  %loadtmp4 = load i32* @jjjj
  %addtmp = add nsw i32 %loadtmp4, 3
  store i32 %addtmp, i32* @jjjj
  %loadtmp5 = load i32* @jjjj
  store i32 %loadtmp5, i32* @jjjj
  %n = alloca i8
  store i8 97, i8* %n
  %p = alloca i8
  store i8 97, i8* %p
  %pp = alloca i8
  store i8 97, i8* %pp
  %ppp = alloca i8
  store i8 97, i8* %ppp
  %pppp = alloca i8
  store i8 97, i8* %pppp
  %a = alloca i1
  store i1 true, i1* %a
  %pk = alloca i1
  store i1 true, i1* %pk
  %pkk = alloca i1
  store i1 false, i1* %pkk
  %b = alloca i1
  store i1 false, i1* %b
  %k = alloca double
  store double -1.000000e+00, double* %k
  %k0 = alloca double
  store double 5.000000e+00, double* %k0
  %ka = alloca double
  store double -6.000000e+00, double* %ka
  %kb = alloca double
  store double -6.000000e+00, double* %kb
  %kc = alloca double
  store double 4.200000e+01, double* %kc
  %d = alloca double
  store double 6.150000e+01, double* %d
  %ddk = alloca i1
  store i1 true, i1* %ddk
  %ddj = alloca i1
  store i1 true, i1* %ddj
  %ddl = alloca i1
  store i1 true, i1* %ddl
  %ddr = alloca i1
  store i1 true, i1* %ddr
  %ddp = alloca i1
  store i1 true, i1* %ddp
  %ddq = alloca i1
  store i1 true, i1* %ddq
  %ddo = alloca i1
  store i1 true, i1* %ddo
  %ddz = alloca i1
  store i1 false, i1* %ddz
  %ddx = alloca i1
  store i1 false, i1* %ddx
  %loadtmp6 = load i1* %ddj
  %loadtmp7 = load i1* %ddr
  %andtmp8 = and i1 %loadtmp6, %loadtmp7
  %loadtmp9 = load i1* %ddk
  %andtmp10 = and i1 %andtmp8, %loadtmp9
  %loadtmp11 = load i1* %ddl
  %andtmp12 = and i1 %andtmp10, %loadtmp11
  %loadtmp13 = load i1* %ddz
  %ortmp14 = or i1 %andtmp12, %loadtmp13
  store i1 %ortmp14, i1* %ddx
  %c = alloca i8
  store i8 115, i8* %c
  %s = alloca [10 x i8]
  ret i32 %loadtmp5
}

