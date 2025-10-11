#!/bin/sh
#$ -S /bin/sh
#Version1.0	hewm@genomics.org.cn	2021-10-13
echo Start Time : 
date
InFile=../../Basic_Tutorials/example03_GWAS_point/Gwas.data.pvalue.gz
zcat $InFile |egrep  "A02|A04|A06|A08|A10|B02|B04|B06|B08" > A.pvalue
zcat $InFile |egrep  -v "A02|A04|A06|A08|A10|B02|B04|B06|B08" > B.pvalue
../../bin/RectChr   -InConf  in3.conf  -OutPut   OUT3
rm  A.pvalue  B.pvalue
echo End Time : 
date
