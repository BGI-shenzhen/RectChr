#!/bin/sh
#$ -S /bin/sh
#Version1.0	hewm@genomics.org.cn	2020-11-09
echo Start Time : 
date
../../bin/RectChr	-InConf	in1.conf	-OutPut	OUT1
#../../bin/RectChr	-InConf	in2.conf	-OutPut	OUT2
../../bin/RectChr	-InConf	in3.conf	-OutPut	OUT3	


##  track_shift_y=20                   #下移 和  track 2 叠在一起 ##
#../../bin/RectChr  -InConf   tmp.conf   -OutPut  tmp

echo End Time : 
date
