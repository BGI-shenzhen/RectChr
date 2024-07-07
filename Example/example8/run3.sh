#!/bin/sh
#$ -S /bin/sh
#Version1.0	hewm@genomics.org.cn	2021-10-13
echo Start Time : 
date
sed -e 's/point/shape/'   in2.cofi  >  in4.cofi
zcat Gwas.data.pvlue.gz |egrep  "A02|A04|A06|A08|A10|B02|B04|B06|B08" > A.pvalue
zcat Gwas.data.pvlue.gz |egrep  -v "A02|A04|A06|A08|A10|B02|B04|B06|B08" > B.pvalue
../../bin/RectChr   -InConfi  in4.cofi  -OutPut   OUT4
../../bin/RectChr   -InConfi  in5.cofi  -OutPut   OUT5
echo End Time : 
date
