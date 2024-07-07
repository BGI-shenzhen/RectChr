#!/bin/sh
#$ -S /bin/sh
#Version1.0	hewm@genomics.org.cn	2020-11-09
echo Start Time : 
date
../../bin/RectChr	-InConfi	in.cofi	-OutPut	OUT	
../../bin/RectChr	-InConfi	in2.cofi	-OutPut	OUT2	
echo End Time : 
date
