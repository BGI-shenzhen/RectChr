#!/usr/bin/perl -w
use strict;
#explanation:this program is edited to 
#edit by hewm;   Wed Mar 24 17:17:20 CST 2021
#Version 1.0    hewm@genomics.org.cn 

die  "Version 1.0\t2021-03-24;\nUsage: $0 <InPut><Out>\n" unless (@ARGV ==1);

#############Befor  Start  , open the files ####################

my $A=`grep  -n ^BEGIN{  $ARGV[0] ` ; my @AA=split /\:/,$A; my $AAA=$AA[0];
my $B=`grep  -n \\\$SVGTest=   $ARGV[0]  |grep -v my  ` ; my @BB=split /\:/,$B; my $BBB=$BB[0];
my $C=`grep  -n  \"my \\\$InConfi;\"   $ARGV[0]   ` ;     my @CC=split /\:/,$C; my $CCC=$CC[0];
my $D=`grep  -n  \"\\\$PTypeLink==1\"   $ARGV[0]   ` ;    my @DD=split /\:/,$D; my $DDD=$DD[0];
my $E=`grep  -n  \"my \\\$FlagValueThis"   $ARGV[0]   ` ;    my @EE=split /\:/,$E; my $EEE=$EE[0];

#print $EEE,"\n"; exit;
my $FFF=$EEE+1000;
my $temmp=`wc  -l $ARGV[0]`; chomp $temmp ; my @EEttt=split /\s+/,$temmp; my $TTT=$EEttt[0];

my @Start=();
my @End=();
my @Name=();

$Start[0]=$AAA;    $End[0]=$BBB-1;    $Name[0]="PreT";
$Start[1]=$AAA;    $End[1]=$BBB-1;    $Name[1]="Pre";
$Start[2]=$BBB+1;  $End[2]=$CCC-1;    $Name[2]="Pre2";
$Start[3]=$CCC+31; $End[3]=$DDD-1;    $Name[3]="pac.gz";
$Start[4]=$DDD+5;  $End[4]=$EEE-3;    $Name[4]="cc";
$Start[5]=$EEE;    $End[5]=$FFF;      $Name[5]="aa";
$Start[6]=$FFF+1;  $End[6]=$TTT;      $Name[6]="eet.txt";


foreach my $k (1..6)
{
	my $Tail=$End[$k]-$Start[$k]+1;
	`head  -n $End[$k]  $ARGV[0] | tail -n $Tail   > $Name[$k].tmp `;
#	`head  -n $End[$k]  $ARGV[0] | tail -n $Tail   > W.$k.$Name[$k].tmp `;
	`gzip  $Name[$k].tmp ; mv   $Name[$k].tmp.gz    $Name[$k] `;
}



######################swimming in the sky and flying in the sea ###########################
