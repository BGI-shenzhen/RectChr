#!/bin/sh
echo Start Time : 
date
perl ../../bin/script/GenotypeShow.pl	in.vcf.gz	chr2:22759380:22775500	sample.order.list	OutRegion
#perl ../../bin/script/GenotypeShow.pl	in.vcf.gz	chr2:22759380:22775500		OutRegion
# https://zhuanlan.zhihu.com/p/358342096
echo End Time : 
date
