#!/bin/sh
#$ -S /bin/sh
#Version1.0	hewm@genomics.org.cn	2020-11-09
echo Start Time : 
date
../../bin/RectChr 	-InConfi	in1.cofi	-OutPut	OUT1	
#../../bin/RectChr 	-InConfi	in2.cofi	-OutPut	OUT2	
#../../bin/RectChr 	-InConfi	in3.cofi	-OutPut	OUT3
../../bin/RectChr 	-InConfi	in4.cofi	-OutPut	OUT4
../../bin/RectChr 	-InConfi	in5.cofi	-OutPut	OUT5
# if GenomeB is genetic  map  ,use para [ChrLenUnitRatio]
echo End Time : 
date
