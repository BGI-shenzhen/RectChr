#!/bin/sh
#$ -S /bin/sh
#Version1.0	hewm@genomics.org.cn	2020-11-09
echo Start Time : 
date
#  see the Para [ link_direction ] more  help in [in1.conf] 
#../../bin/RectChr	-InConf	in1.conf	-OutPut	OUT1
../../bin/RectChr	-InConf	in2.conf	-OutPut	OUT2
../../bin/RectChr	-InConf	in3.conf	-OutPut	OUT3


#  see the Para [ PairWiseLinkV2 ] more  help in [in4.conf] 
##   PairWiseLinkV2  can diff chr  
../../bin/RectChr	-InConf	in4.conf	-OutPut	OUT4
echo End Time : 
date
