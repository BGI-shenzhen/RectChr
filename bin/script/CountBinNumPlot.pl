#!/usr/bin/perl -w
use strict;
#use Data::Dumper;
use Getopt::Long;

#######################
##USAGE
#######################

sub  usage
{
	print STDERR <<USAGE;

		Usage: perl $0  -InFile SNP.vcf -OutPut SNP.dis
		Version:1.43         hewm\@genomics.cn

		Options

		 -InFile       <s> : InPut File for Count
		 -InList       <s> : InPut File List for Count
		 -OutPut       <s> : OutPut the Stat File

		 -BinSize      <n> : Windows Bin Size for siliding [100000]
		 -ChrColumn    <n> : The Column Number of ChrName [1]
		 -SiteColumn   <n> : The Column Number of Position Site [2]
		 -FilterChr    <s> : Filter the Scaffold Name [scaf]

		 -CountNum     <n> : if you want to the Accumulate Value of Column
		 -MeanValue        : Give out the Mean Value of Accumulate Number

		 -help             : Give out this help doc

USAGE
}

my $InFile;
my $InList;
my $OutPut;
my $help ;
my $MeanValue ;
my $ChrColumn=1;
my $SiteColumn=2;
my $BinSize=100000;
my $CountNum=-1;
my $FilterChr="caf";

GetOptions(
	"InFile:s"=>\$InFile,
	"InList:s"=>\$InList,
	"OutPut:s"=>\$OutPut,
	"BinSize:s"=>\$BinSize,
	"ChrColumn:s"=>\$ChrColumn,
	"SiteColumn:s"=>\$SiteColumn,
	"FilterChr:s"=>\$FilterChr,
	"CountNum:s"=>\$CountNum,
	"help"=>\$help,
	"MeanValue"=>\$MeanValue,
);


if (  defined($help)  )
{
	usage ;
	exit(1) ;
}

if(  (!defined($OutPut))    ||     (  (!defined($InFile))   &&   (!defined($InList))  )  )
{
	usage ;
	exit(1) ;
}
if  (defined($MeanValue))
{
	if  ($CountNum==-1)
	{
		print "\t\t[-MeanValue]  should run with [-CountNum] together"
	}
	#	exit(1);
}

#print "Start Stat ...\n";
open OUT,">$OutPut"  || die "OutPut file can't open $!" ;

$ChrColumn--; $SiteColumn--;
$CountNum--;

my %HashCount;
my %HashSum;
my %MaxLength=();
##############what you want to do #################

#print $CountNum,"\n";exit;
if  (defined($InFile))
{

	if  ($InFile =~s/\.gz$/\.gz/)
	{
		open FAA,"gzip -cd  $InFile | "  || die "input file can't open $!" ;
	}
	else
	{
		open FAA,"$InFile"  || die "input file can't open $!" ;
	}
	if ( $CountNum < 0 )
	{
		while(<FAA>)
		{
			chomp ;
			next if  ($_=~s/#/#/);
			my @inf=split ;
			my $key1=$inf[$ChrColumn];
			next if ( $key1  =~s/$FilterChr/$FilterChr/);
			my $key2=int($inf[$SiteColumn]/$BinSize);
			$HashCount{$key1}{$key2}++;
			if (!exists $MaxLength{$key1})
			{
				$MaxLength{$key1}=$inf[$SiteColumn];
			}
			elsif  ( $MaxLength{$key1} < $inf[$SiteColumn])
			{
				$MaxLength{$key1}=$inf[$SiteColumn];
			}
		}
	}
	else
	{
		while(<FAA>)
		{
			chomp ;
			next if  ($_=~s/#/#/);
			my @inf=split ;
			my $key1=$inf[$ChrColumn];
			next if ( $key1  =~s/$FilterChr/$FilterChr/);
			my $key2=int($inf[$SiteColumn]/$BinSize);
			$HashCount{$key1}{$key2}++;
			$HashSum{$key1}{$key2}+=$inf[$CountNum];
			if (!exists $MaxLength{$key1})
			{
				$MaxLength{$key1}=$inf[$SiteColumn];
			}
			elsif  ( $MaxLength{$key1} < $inf[$SiteColumn])
			{
				$MaxLength{$key1}=$inf[$SiteColumn];
			}

		}
	}
	close FAA;
}




if  (defined($InList))
{

	if  ($InList =~s/\.gz$/\.gz/)
	{
		open LLL,"gzip -cd  $InList | "  || die "input file can't open $!" ;
	}
	else
	{
		open LLL,"$InList"  || die "input file can't open $!" ;
	}

	while(<LLL>)
	{

		chomp ;
		$InFile =$_ ;

		if  ($InFile =~s/\.gz$/\.gz/)
		{
			open FBB,"gzip -cd  $InFile | "  || die "input file can't open $!" ;
		}
		else
		{
			open FBB,"$InFile"  || die "input file can't open $!" ;
		}
		if ( $CountNum < 0  )
		{
			while(<FBB>)
			{
				chomp ;
				next if  ($_=~s/#/#/);
				my @inf=split ;
				my $key1=$inf[$ChrColumn];
				next if ( $key1  =~s/$FilterChr/$FilterChr/);
				my $key2=int($inf[$SiteColumn]/$BinSize);
				$HashCount{$key1}{$key2}++;
				if (!exists $MaxLength{$key1})
				{
					$MaxLength{$key1}=$inf[$SiteColumn];
				}
				elsif  ( $MaxLength{$key1} < $inf[$SiteColumn])
				{
					$MaxLength{$key1}=$inf[$SiteColumn];
				}

			}
		}
		else
		{
			while(<FBB>)
			{
				chomp ;
				next if  ($_=~s/#/#/);
				my @inf=split ;
				my $key1=$inf[$ChrColumn];
				next if ( $key1  =~s/$FilterChr/$FilterChr/);
				my $key2=int($inf[$SiteColumn]/$BinSize);
				$HashCount{$key1}{$key2}++;
				$HashSum{$key1}{$key2}+=$inf[$CountNum];
				if (!exists $MaxLength{$key1})
				{
					$MaxLength{$key1}=$inf[$SiteColumn];
				}
				elsif  ( $MaxLength{$key1} < $inf[$SiteColumn])
				{
					$MaxLength{$key1}=$inf[$SiteColumn];
				}

			}
		}
		close FBB;

	}
	close LLL;
}



if  ($CountNum < 0 )
{
	print OUT "#CHROM\tStart\tEnd\tNumber\n";

	foreach my $chr (sort keys %MaxLength)
	{		
		my $MaxEEE=$MaxLength{$chr};
		my $MaxCount=int($MaxEEE/$BinSize)-1;
		foreach my $Site (0..$MaxCount)
		{
			next if  (!exists $HashCount{$chr}{$Site});
			my $Start=$Site*$BinSize+1;
			my $End=$Start+$BinSize;
			print OUT "$chr\t$Start\t$End\t$HashCount{$chr}{$Site}\n";
		}
		$MaxCount++;
		next if  (!exists $HashCount{$chr}{$MaxCount});
		my $Start=$MaxCount*$BinSize+1;
		print OUT "$chr\t$Start\t$MaxEEE\t$HashCount{$chr}{$MaxCount}\n";
	}
}
else
{
	if (defined($MeanValue))
	{
		print OUT "#CHROM\tStart\tEnd\tMeanValue\tSumNumber\tCount\n";
		foreach my $chr (sort keys %MaxLength)
		{		
			my $MaxEEE=$MaxLength{$chr};
			my $MaxCount=int($MaxEEE/$BinSize)-1;
			foreach my $Site (0..$MaxCount)
			{
				next if  (!exists $HashCount{$chr}{$Site});
				my $Start=$Site*$BinSize+1;
				my $End=$Start+$BinSize;
				my $bb=$HashSum{$chr}{$Site}/$HashCount{$chr}{$Site};
				print OUT "$chr\t$Start\t$End\t$bb\t$HashSum{$chr}{$Site}\t$HashCount{$chr}{$Site}\n";
			}
			$MaxCount++;
			next if  (!exists $HashCount{$chr}{$MaxCount});
			my $Start=$MaxCount*$BinSize+1;
			my $bb=$HashSum{$chr}{$MaxCount}/$HashCount{$chr}{$MaxCount};
			print OUT "$chr\t$Start\t$MaxEEE\t$bb\t$HashSum{$chr}{$MaxCount}\t$HashCount{$chr}{$MaxCount}\n";
		}


	}
	else
	{

		print OUT "#CHROM\tStart\tEnd\tSum\tCount\n";
		foreach my $chr (sort keys %MaxLength)
		{		
			my $MaxEEE=$MaxLength{$chr};
			my $MaxCount=int($MaxEEE/$BinSize)-1;
			foreach my $Site (0..$MaxCount)
			{
				next if  (!exists $HashCount{$chr}{$Site});
				my $Start=$Site*$BinSize+1;
				my $End=$Start+$BinSize;
				print OUT "$chr\t$Start\t$End\t$HashSum{$chr}{$Site}\t$HashCount{$chr}{$Site}\n";
			}
			$MaxCount++;
			next if  (!exists $HashCount{$chr}{$MaxCount});
			my $Start=$MaxCount*$BinSize+1;
			print OUT "$chr\t$Start\t$MaxEEE\t$HashSum{$chr}{$MaxCount}\t$HashCount{$chr}{$MaxCount}\n";
		}
	}

}


close OUT ;

### swimming in the sky and flying in the sea ####

use FindBin qw($Bin);

my @BBB=split /\//,$OutPut;
my @CCC=split /\./,$BBB[-1];

open (OB,">$OutPut.cofi") || die "output file can't open $!" ;

my $Recht=<<Rect;

SetParaFor= global
File1= $OutPut
title= "$CCC[0]"
Rect

print OB $Recht ;
close OB;



my $RectChr="$Bin/../../bin/RectChr";
if  ( !(-e $RectChr) )
{
        $RectChr=`which RectChr 2> /dev/null `;chomp $RectChr;
		if  ( !(-e $RectChr) )
		{
			$RectChr="$Bin/../RectChr";
		}
        if  ( !(-e $RectChr) )
        {
                print "Can't found the [RectChr] in your \$PATH, plase check and the  run it";
                print "  RectChr  -InConfi  $OutPut.cofi -OutPut $OutPut \n";
				exit (1);
        }
}


system("  $RectChr  -InConfi  $OutPut.cofi -OutPut $OutPut.svg ");



### swimming in the sky and flying in the sea ####

