#!/usr/bin/perl -w
use strict;
#edit by hewm;   Fri Oct 10 11:41:55 CST 2025

die  "Version 1.43\t2025-10-10;\nUsage: $0 <Flag>\nUsage: $0 <Flag><Num>\n" unless (@ARGV ==1 || @ARGV ==2);

use FindBin qw($Bin $RealBin);
# Import configuration loader and plotting modules

use lib "$Bin/../lib";
use lib "$Bin/../svg_kit/";
use lib "$RealBin/../lib";


use ColorPaletteManager;
use ColorPaletteManager qw(%MAX_COLOR_COUNT %QualColNum RGB2HTML HTML2RGB GetColGradien);
my @ColorGradientArray=();
my $ColFlag=$ARGV[0];
my $NumGradien=8;
	if (@ARGV ==1)
	{
		if  (exists $MAX_COLOR_COUNT{$ColFlag})
		{
			$NumGradien=$MAX_COLOR_COUNT{$ColFlag};
		}
	}
	else
	{
	    $NumGradien=$ARGV[1];
	}

#############Befor  Start  , open the files ####################
	if  (exists $QualColNum{$ColFlag})
	{
		my $MaxCol=$QualColNum{$ColFlag};
		if  ($NumGradien>$MaxCol)
		{
			print "For RColor qualitative  Brewer Diverging palettes  Max Col only $MaxCol, so we change $NumGradien ----> $MaxCol\n";
			$NumGradien=$MaxCol;
		}
	}

	if (!exists $MAX_COLOR_COUNT{$ColFlag} )
	{
	        my $file="$RealBin/../../ColorsBrewer/$ColFlag";
            if (-e $file)
            {
                my $count=` wc  -l  $file | awk '{print \$1}' `;
                chomp $count ;

                if (@ARGV ==1  )
                {
					$NumGradien=$count;
                }
				else
				{
					if ($NumGradien>$count)
					{
						 print "Color Brewer $ColFlag at $file only nlevels = $count, but input colormap_nlevels $NumGradien  > $count,  Changed  to $count\n";
						 $NumGradien=$count;
					}
					elsif ($NumGradien<$count)
					{
					  print "Color Brewer $ColFlag at $file only nlevels = $count, but input colormap_nlevels $NumGradien  < $count,  Changed  to $count\n";
					     $NumGradien=$count;
					}
				}
			}
			else
			{
				print "RColor Brewer must be in specified name like Set3/Dark2/Reds ... or color FileName at the Dir ColorsBrewer $file,  but $ColFlag is not valid\n Changed $ColFlag  --->  'GnYlRd'\n See: https://www.r-graph-gallery.com/38-rcolorbrewers-palettes.html\n";
				$ColFlag='GnYlRd';
			}
	}

my %HashConfi=();
   $HashConfi{"global"}{RealBin}="$RealBin/../";


my $NumGradien2=GetColGradien($ColFlag,$NumGradien,\@ColorGradientArray,\%HashConfi);
$NumGradien--;

if ($NumGradien>$NumGradien2)
{
	$NumGradien=$NumGradien2;
}


foreach my $a(0..$NumGradien)
{
	my $html=RGB2HTML($ColorGradientArray[$a]);
	my $b=$a+1;
	print "$b\t$ColorGradientArray[$a]\t$html\n";
}


######################swimming in the sky and flying in the sea ##########################


