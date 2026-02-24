#!/bin/sh
#$ -S /bin/sh
#Version1.0	hewm@genomics.org.cn	2020-11-09
echo Start Time : 
date
../../bin/RectChr	-InConf	in1.conf	-OutPut	OUT1
../../bin/RectChr	-InConf	in2.conf	-OutPut	OUT2


####  chr_zoom_region  to see  the Spe Region ###
#../../bin/RectChr	-InConf	in3.conf	-OutPut	OUT3

echo End Time : 
date
