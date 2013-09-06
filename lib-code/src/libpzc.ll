; ModuleID = 'libpzc.lli'
target datalayout = "e-p:32:32:32-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:32:64-f32:32:32-f64:32:64-v64:64:64-v128:128:128-a0:0:64-f80:32:32-n8:16:32-S128"
target triple = "i386-pc-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i32, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i32, i32, [40 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }

@used_scanf = global i8 0, align 1
@.str = private unnamed_addr constant [3 x i8] c"%d\00", align 1
@.str1 = private unnamed_addr constant [4 x i8] c"%lf\00", align 1
@.str2 = private unnamed_addr constant [4 x i8] c"%*c\00", align 1
@stdin = external global %struct._IO_FILE*
@.str3 = private unnamed_addr constant [5 x i8] c"true\00", align 1
@.str4 = private unnamed_addr constant [2 x i8] c"1\00", align 1
@.str5 = private unnamed_addr constant [4 x i8] c"%*d\00", align 1
@.str6 = private unnamed_addr constant [4 x i8] c"%*s\00", align 1
@.str7 = private unnamed_addr constant [7 x i8] c"%*.*lf\00", align 1
@.str9 = private unnamed_addr constant [6 x i8] c"false\00", align 1
@.str10 = private unnamed_addr constant [3 x i8] c"%s\00", align 1

; Function Attrs: nounwind
define i32 @READ_INT() #0 {
  %i = alloca i32, align 4
  %1 = call i32 (i8*, ...)* @__isoc99_scanf(i8* getelementptr inbounds ([3 x i8]* @.str, i32 0, i32 0), i32* %i) #3
  store i8 1, i8* @used_scanf, align 1
  %2 = load i32* %i, align 4
  ret i32 %2
}

; Function Attrs: nounwind
declare i32 @__isoc99_scanf(i8* nocapture, ...) #0

; Function Attrs: nounwind
define double @READ_REAL() #0 {
  %i = alloca double, align 8
  %1 = call i32 (i8*, ...)* @__isoc99_scanf(i8* getelementptr inbounds ([4 x i8]* @.str1, i32 0, i32 0), double* %i) #3
  store i8 1, i8* @used_scanf, align 1
  %2 = load double* %i, align 8
  ret double %2
}

; Function Attrs: nounwind
define void @READ_STRING(i32 %size, i8* %s) #0 {
  %1 = load i8* @used_scanf, align 1
  %2 = and i8 %1, 1
  %3 = icmp eq i8 %2, 0
  br i1 %3, label %6, label %4

; <label>:4                                       ; preds = %0
  %5 = tail call i32 (i8*, ...)* @__isoc99_scanf(i8* getelementptr inbounds ([4 x i8]* @.str2, i32 0, i32 0)) #3
  store i8 0, i8* @used_scanf, align 1
  br label %6

; <label>:6                                       ; preds = %4, %0
  %7 = add nsw i32 %size, 1
  %8 = load %struct._IO_FILE** @stdin, align 4
  %9 = tail call i8* @fgets(i8* %s, i32 %7, %struct._IO_FILE* %8) #3
  %10 = tail call i32 @strlen(i8* %s) #4
  %11 = add nsw i32 %10, -1
  %12 = getelementptr inbounds i8* %s, i32 %11
  %13 = load i8* %12, align 1
  %14 = icmp eq i8 %13, 10
  br i1 %14, label %15, label %16

; <label>:15                                      ; preds = %6
  store i8 0, i8* %12, align 1
  br label %16

; <label>:16                                      ; preds = %15, %6
  ret void
}

; Function Attrs: nounwind
declare i8* @fgets(i8*, i32, %struct._IO_FILE* nocapture) #0

; Function Attrs: nounwind readonly
declare i32 @strlen(i8* nocapture) #1

; Function Attrs: nounwind
define i32 @READ_BOOL() #0 {
  %i = alloca [5 x i8], align 1
  %1 = getelementptr inbounds [5 x i8]* %i, i32 0, i32 0
  %2 = load i8* @used_scanf, align 1
  %3 = and i8 %2, 1
  %4 = icmp eq i8 %3, 0
  br i1 %4, label %7, label %5

; <label>:5                                       ; preds = %0
  %6 = call i32 (i8*, ...)* @__isoc99_scanf(i8* getelementptr inbounds ([4 x i8]* @.str2, i32 0, i32 0)) #3
  store i8 0, i8* @used_scanf, align 1
  br label %7

; <label>:7                                       ; preds = %5, %0
  %8 = load %struct._IO_FILE** @stdin, align 4
  %9 = call i8* @fgets(i8* %1, i32 6, %struct._IO_FILE* %8) #3
  %10 = call i32 @strlen(i8* %1) #4
  %11 = add nsw i32 %10, -1
  %12 = getelementptr inbounds [5 x i8]* %i, i32 0, i32 %11
  %13 = load i8* %12, align 1
  %14 = icmp eq i8 %13, 10
  br i1 %14, label %15, label %READ_STRING.exit

; <label>:15                                      ; preds = %7
  store i8 0, i8* %12, align 1
  br label %READ_STRING.exit

READ_STRING.exit:                                 ; preds = %15, %7
  %16 = call i32 @strcmp(i8* %1, i8* getelementptr inbounds ([5 x i8]* @.str3, i32 0, i32 0)) #4
  %17 = icmp eq i32 %16, 0
  br i1 %17, label %21, label %18

; <label>:18                                      ; preds = %READ_STRING.exit
  %19 = call i32 @strcmp(i8* %1, i8* getelementptr inbounds ([2 x i8]* @.str4, i32 0, i32 0)) #4
  %20 = icmp eq i32 %19, 0
  %. = zext i1 %20 to i32
  ret i32 %.

; <label>:21                                      ; preds = %READ_STRING.exit
  ret i32 1
}

; Function Attrs: nounwind readonly
declare i32 @strcmp(i8* nocapture, i8* nocapture) #1

; Function Attrs: nounwind
define void @WRITE_INT(i32 %a, i32 %w) #0 {
  %1 = tail call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([4 x i8]* @.str5, i32 0, i32 0), i32 %w, i32 %a) #3
  ret void
}

; Function Attrs: nounwind
declare i32 @printf(i8* nocapture, ...) #0

; Function Attrs: nounwind
define void @WRITE_STRING(i8* %a, i32 %w) #0 {
  %1 = tail call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([4 x i8]* @.str6, i32 0, i32 0), i32 %w, i8* %a) #3
  ret void
}

; Function Attrs: nounwind
define void @WRITE_REAL(double %a, i32 %w, i32 %d) #0 {
  %1 = tail call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([7 x i8]* @.str7, i32 0, i32 0), i32 %w, i32 %d, double %a) #3
  ret void
}

; Function Attrs: nounwind
define void @WRITE_CHAR(i8 signext %a, i32 %w) #0 {
  %1 = sext i8 %a to i32
  %putchar = tail call i32 @putchar(i32 %1) #3
  ret void
}

; Function Attrs: nounwind
define void @WRITE_BOOL(i32 %a, i32 %w) #0 {
  %1 = icmp eq i32 %a, 1
  %. = select i1 %1, i8* getelementptr inbounds ([5 x i8]* @.str3, i32 0, i32 0), i8* getelementptr inbounds ([6 x i8]* @.str9, i32 0, i32 0)
  %2 = tail call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([3 x i8]* @.str10, i32 0, i32 0), i8* %.) #3
  ret void
}

; Function Attrs: nounwind readnone
define double @pi() #2 {
  ret double 0x400921FB54442D18
}

; Function Attrs: nounwind
define double @arctan(double %x) #0 {
  %1 = tail call double @atan(double %x) #3
  ret double %1
}

; Function Attrs: nounwind
declare double @atan(double) #0

; Function Attrs: nounwind
define double @ln(double %x) #0 {
  %1 = tail call double @log(double %x) #3
  ret double %1
}

; Function Attrs: nounwind
declare double @log(double) #0

; Function Attrs: nounwind readnone
define i32 @TRUNC(double %x) #2 {
  %1 = tail call double @trunc(double %x) #5
  %2 = fptosi double %1 to i32
  ret i32 %2
}

; Function Attrs: nounwind readnone
declare double @trunc(double) #2

; Function Attrs: nounwind readnone
define i32 @ROUND(double %x) #2 {
  %1 = tail call double @round(double %x) #5
  %2 = fptosi double %1 to i32
  ret i32 %2
}

; Function Attrs: nounwind readnone
declare double @round(double) #2

; Function Attrs: nounwind
declare i32 @putchar(i32) #3

attributes #0 = { nounwind "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readonly "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind readnone "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind }
attributes #4 = { nounwind readonly }
attributes #5 = { nounwind readnone }
