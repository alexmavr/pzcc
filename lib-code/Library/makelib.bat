@echo off

masm -mx printi.asm;
masm -mx readi.asm;
masm -mx printc.asm;
masm -mx readc.asm;
masm -mx printb.asm;
masm -mx readb.asm;
masm -mx printr.asm;
masm -mx readr.asm;
masm -mx prints.asm;
masm -mx reads.asm;
masm -mx new.asm;
masm -mx dispose.asm;
masm -mx exit.asm;
masm -mx abs.asm;
masm -mx fabs.asm;
masm -mx sqrt.asm;
masm -mx sin.asm;
masm -mx cos.asm;
masm -mx tan.asm;
masm -mx arctan.asm;
masm -mx pi.asm;
masm -mx exp.asm;
masm -mx ln.asm;
masm -mx trunc.asm;
masm -mx round.asm;
masm -mx ord.asm;
masm -mx chr.asm;
masm -mx formati.asm;
masm -mx formatr.asm;
masm -mx parsei.asm;
masm -mx parser.asm;

if exist pcl.lib del pcl.lib

lib pcl.lib /NOIGNORECASE +printi.obj +readi.obj;
lib pcl.lib /NOIGNORECASE +printc.obj +readc.obj;
lib pcl.lib /NOIGNORECASE +printb.obj +readb.obj;
lib pcl.lib /NOIGNORECASE +printr.obj +readr.obj;
lib pcl.lib /NOIGNORECASE +prints.obj +reads.obj;
lib pcl.lib /NOIGNORECASE +new.obj +dispose.obj;
lib pcl.lib /NOIGNORECASE +exit.obj;
lib pcl.lib /NOIGNORECASE +abs.obj fabs.obj +sqrt.obj;
lib pcl.lib /NOIGNORECASE +sin.obj +cos.obj +tan.obj +arctan.obj;
lib pcl.lib /NOIGNORECASE +pi.obj +exp.obj +ln.obj;
lib pcl.lib /NOIGNORECASE +trunc.obj +round.obj;
lib pcl.lib /NOIGNORECASE +ord.obj +chr.obj;
lib pcl.lib /NOIGNORECASE +formati.obj +formatr.obj;
lib pcl.lib /NOIGNORECASE +parsei.obj +parser.obj;

lib pcl.lib /NOIGNORECASE, pcl.lst;

del *.obj
del *.bak
