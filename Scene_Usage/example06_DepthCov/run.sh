#!/bin/sh
#$ -S /bin/sh
#Version1.0	hewm@genomics.org.cn	2020-11-09
echo Start Time : 
date
../../bin/RectChr	-InConf	in1.conf	-OutPut	OUT1	
# https://zhuanlan.zhihu.com/p/710303781
echo End Time : 
date
