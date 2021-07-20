#!/usr/bin/perl -w
use strict;
use FindBin qw($Bin);
#explanation:this program is edited to  VCF2GenotypShow
#edit by hewm;   Mon Jun 28 09:30:07 CST 2021

die  "\tVersion 1.0\thewm2008\t2021-06-28;\n\tUsage: $0 <InPut.vcf><chr:start:end><Out>\n\tUsage: $0 <InPut.vcf><chr:start:end><Sub_or_OrderSample><Out>\n" unless (@ARGV ==4 || @ARGV ==3);

#############Befor  Start  , open the files ####################

my $InFile=$ARGV[0] ;
if  ($InFile =~s/\.gz$/\.gz/)
{
	open IA,"gzip -cd  $InFile | "  || die "input file can't open $!" ;
}
else
{
	open IA,"$InFile"  || die "input file can't open $!" ;
}

my @BBB=split /\:/,$ARGV[1];

if ($#BBB!=2)
{
	print "Error InPut Region Format wrong,shoud be : chr1:100:200\n";
	exit;
}
my $chr=$BBB[0];
my $start=$BBB[1];
my $End=$BBB[2];


my $AA=1;
my @head=();
while($AA)
{
	$_=<IA>;
	next if  ($_=~s/##/##/);
	chomp ;
	@head=split ;
	$AA=0;
	if ($head[0] ne  "#CHROM")
	{
		print "Error : VCF Head Some thing wrong,Can't find the [#CHROM] ...\n";
		exit;
	}
}



my $OutPut=$ARGV[2];
my %hashSample=();
#my %hashCor=();
my $Count=0;

if ($#ARGV==3)
{
	$OutPut=$ARGV[3];
	open (IB,"<$ARGV[2]") || die "output file can't open $!" ;
	my %tmpTT=();
	foreach my $k (9..$#head)
	{
		$tmpTT{$head[$k]}=$k;
	}
	while(<IB>)
	{
		chomp ;
		my @inf=split ;
		if (!exists $tmpTT{$inf[0]} )
		{
			print "sub sample Can't find sample $inf[0]\n";
		}
		else
		{
			$hashSample{$Count}=$tmpTT{$inf[0]};
			$Count++;
		}
	}
	close IB;
}
else
{
	foreach my $k (9..$#head)
	{
		$hashSample{$Count}=$k;
		$Count++;
	}
}
$Count--;

if ($Count<5)
{
	print "Too Low Sample to genotype Show\n";
	exit ;
}

open (OA,">$OutPut.genotype") || die "output file can't open $!" ;


################ Do what you want to do #######################
my %Genotype=();

my $SNPNumber=0;
while(<IA>) 
{ 
	chomp ; 
	my @inf=split ;
	next if  ($inf[0] ne $chr);
	next if  ($inf[1] < $start);
	next if  ($inf[1] > $End);
	next if  ($inf[4] =~s/,/,/);  ## filter muti base
	$SNPNumber++;
	foreach my $k (0..$Count)
	{
		my $GG="MISS";
		my @CCC=split /\:/,$inf[$hashSample{$k}];
		my @DDD=split //,$CCC[0];
		if ($DDD[0] eq ".")
		{
		}
		elsif (($DDD[0] eq "0")  && ($DDD[0] eq $DDD[2]) )
		{
			$GG="Ref";
		}
		elsif (($DDD[0] ne "0")  && ($DDD[0] eq $DDD[2]) )
		{
			$GG="ALT";
		}
		else
		{
			$GG="Hete";
		}
		$Genotype{$hashSample{$k}}{$SNPNumber}=$GG;
	}
}

close IA;

foreach my $k (0..$Count)
{
	my $sample=$hashSample{$k};
	my $GG=$Genotype{$sample}{1};
	my $SNP_Start=1;
	my $SNP_End=1;
	foreach my $kk (2..$SNPNumber)
	{
		my $BGG=$Genotype{$sample}{$kk};
		if  ( $GG ne $BGG)
		{
			$SNP_End+=0.01;
			print OA "$head[$sample]\t$SNP_Start\t$SNP_End\t$GG\n";
			$SNP_End-=0.01;
			$GG=$BGG;
			$SNP_Start=$kk;
			$SNP_End=$kk;
		}
		else
		{
			$SNP_End=$kk;
		}
	}
	$SNP_End+=0.01;
	print OA "$head[$sample]\t$SNP_Start\t$SNP_End\t$GG\n";	
}

close OA;





if ($SNPNumber<10)
{

	print "In This Region $ARGV[1] ,bi-SNP Number is too low, only $SNPNumber, leave ...\n";
	exit;
}
elsif ($SNPNumber>1000)
{
	print "Too Many SNP number... try show it\n";
}


open (OB,">$OutPut.cofi") || die "output file can't open $!" ;
open (OC,">$OutPut.col") || die "output file can't open $!" ;
print OC "Ref=\"#e41a1c\"\n";
print OC "ALT=\"#4daf4a\"\n";
print OC "Hete=\"#ffffb3\"\n";
print OC "MISS=\"#CCCCCC\"\n";
close OC;

my $ChrWidth=sprintf("%.1f",1200.0/$Count);
$Count++;
my $strokeWidth=sprintf("%.1f",1200.0/$SNPNumber);

my $SizeGradienRatio=1.0;
#$SizeGradienRatio=sprintf("%.1f",20.0/$ChrWidth);  if ($SizeGradienRatio>1) {$SizeGradienRatio=1;}

print "In This Region $ARGV[1] ,bi-SNP Number is $SNPNumber, SampleNumer is $Count ,ChrWidth=$ChrWidth,strokeWidth=$strokeWidth...\n";

my $AAA=int($ChrWidth/2);
my $BBB=$ChrWidth*6;


my $Recht=<<Rect;

SetParaFor = global
File1 = $OutPut.genotype
ShowColumn = File1:4
ChrSpacingRatio =0      # Chr之间取消空隙
ColorsConf = $OutPut.col
Main="Region $ARGV[1] genotype"
# Chromosomes_order = A8, A9...A20,SpeSample1.B1,....B20,SpeSample2,...  ## 这儿定义顺序，样品过多 我这只例示
## ## 这儿定义顺序，样品过多 我这只例示   亚群过滤 插入一个or多个空白的样品


SetParaFor = Level1
PType = heatmap
ChrWidth=$ChrWidth           #  样品过多，400个样品    2.5*400 即画布深度为1000  ，可以用body=1200 /样品数定义chr的宽度
crBG="#FFFFFF" 
strokeWidthBG=0
strokewidth=$strokeWidth
#SizeGradienRatio=$SizeGradienRatio
ShiftGradienX=$AAA
ShiftGradienY=-$BBB

Rect

print OB $Recht ;
close OB;

my $RectChr="$Bin/../RectChr";
if  ( !(-e $RectChr) )
{
	$RectChr=`which RectChr 2> /dev/null `;chomp $RectChr;
	if  ( !(-e $RectChr) )
	{
		print "Can't found the [RectChr] in your \$PATH, plase check and the  run it";
		print "  RectChr  -InConfi  $OutPut.cofi -OutPut $OutPut \n";
	}
}


system("  $RectChr  -InConfi  $OutPut.cofi -OutPut $OutPut");

######################swimming in the sky and flying in the sea ###########################
