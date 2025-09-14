#!/bin/sh
#$ -S /bin/sh
#Version1.0	hewm@genomics.org.cn	2021-10-13
echo Start Time : 
date
InFile=../../Basic_Tutorials/example03_GWAS_point/Gwas.data.pvalue.gz
sed -e 's/=point/=shape/'   in2.conf  >  in4.conf
zcat $InFile |egrep  "A02|A04|A06|A08|A10|B02|B04|B06|B08" > A.pvalue
zcat $InFile |egrep  -v "A02|A04|A06|A08|A10|B02|B04|B06|B08" > B.pvalue
../../bin/RectChr   -InConf  in4.conf  -OutPut   OUT4
../../bin/RectChr   -InConf  in5.conf  -OutPut   OUT5
rm  -rf  A.pvalue  B.pvalue 
echo End Time : 
date
