#!/usr/bin/perl -w
use strict;
#explanation:this program is edited to 
#edit by hewm;   Wed Apr 14 11:02:26 CST 2021
#Version 1.0    hewm@genomics.org.cn 

die  "Version 1.0\t2021-04-14;\nUsage: $0 <InPut><Out>\n" unless (@ARGV ==1);

#############Befor  Start  , open the files ####################

foreach my $k (2..79)
{
print "SetParaFor=Level$k\n";
print "File$k=./data/S$k.bin\n";
print "ShowColumn = File$k:4\n";
}
######################swimming in the sky and flying in the sea ###########################
