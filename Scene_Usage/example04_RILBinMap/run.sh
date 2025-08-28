#!/bin/sh
#$ -S /bin/sh
#Version1.0	hewm@genomics.org.cn	2020-11-09
echo Start Time : 
date
../../bin/RectChr	-InConf	in1.conf	-OutPut	OUT1	
#https://zhuanlan.zhihu.com/p/360097194
# see paper  https://onlinelibrary.wiley.com/doi/10.1111/eva.70033  Fig4.a by RectChr
echo End Time : 
date
