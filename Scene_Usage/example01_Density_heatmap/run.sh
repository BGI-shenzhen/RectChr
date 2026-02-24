#!/bin/sh
#$ -S /bin/sh
#Version1.0	hewm@genomics.org.cn	2020-11-09
echo Start Time : 
date
../../bin/RectChr -InConf	in1.conf	-OutPut	OUT1	

####  run  SNP_density  for VCF File  example ####
#perl  ../../bin/script/CountBinNumPlot.pl   -InFile  in.vcf.gz   -OutPut   SNP_density
#perl  ../../bin/script/CountBinNumPlot.pl   -InFile  in.vcf.gz   -OutPut   SNP_density -BinSize 100000
###  run gene_density  for gFF File  example ####
#cat  Ref.gff |awk '$3=="mRNA"' >mRNA.gff
#perl ../../bin/script/CountBinNumPlot.pl   -InFile  mRNA.gff     -SiteColumn  4   -OutPut  gene_density



../../bin/RectChr -InConf	in2.conf	-OutPut	OUT2	
echo End Time : 
date
