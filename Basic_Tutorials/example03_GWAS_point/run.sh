#!/bin/sh
#$ -S /bin/sh
#Version1.0	hewm@genomics.org.cn	2020-11-09
echo Start Time : 
date
../../bin/RectChr	-InConf	in1.conf	-OutPut	OUT1	
zcat Gwas.data.pvalue.gz |egrep  "A02|A04|A06|A08|A10|B02|B04|B06|B08" > A.pvalue
zcat Gwas.data.pvalue.gz |egrep  -v  "A02|A04|A06|A08|A10|B02|B04|B06|B08" > B.pvalue
../../bin/RectChr	-InConf	in2.conf	-OutPut	OUT2	
rm  A.pvalue  B.pvalue
echo End Time : 
date
