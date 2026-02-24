#!/usr/bin/perl -w
use strict;
#explanation:this program is edited to
#edit by liaojing;   Tue Sep 30 16:21:56 CST 2025
#Version 1.0    liaojing@genomics.org.cn

die  "Version 1.0\t2025-09-30;\nUsage: $0 <Flag><Number>\n" unless (@ARGV ==2);
use FindBin qw($Bin $RealBin);
use lib "$RealBin/../bin/svg_kit/";
use lib "$RealBin/../bin/lib/";
use ColorPaletteManager;

#############Befor  Start  , open the files ####################


#open (OA,">$ARGV[1]") || die "output file can't open $!" ;

################ Do what you want to do #######################
my @Arry=();
my @colors=();
open (IA,"$ARGV[0]") || die "input file can't open $!";
while(<IA>)
{
	chomp ;
	my @inf=split ;
	my ($R,$G,$B)=ColorPaletteManager::HTML2RGB($inf[0]);
	my $BB="rgb($R,$G,$B)";
	push @Arry,$BB;
	push @colors,$inf[0];
	#print "rgb($R,$G,$B)\n";
}

close IA;

sub get_colors {
    my $n = shift;
    my $m = scalar @colors;
    my @result;

    if ($n == $m) {
        # 当 n 等于 m 时，返回整个颜色系列
        @result = @colors;
    } elsif ($n < $m) {
        # 当 n 小于 m 时，从颜色系列中等分选取 n 种颜色
        for (my $i = 0; $i < $n; $i++) {
            my $index = int($i * $m / $n);
            push @result, $colors[$index];
        }
    } else {
        # 当 n 大于 m 时，让颜色更均匀分布
        for (my $i = 0; $i < $n; $i++) {
            my $index = int($i * $m / $n);
            # 避免相邻颜色重复
            my $offset = 0;
            while ($i > 0 && $colors[($index + $offset) % $m] eq $result[-1]) {
                $offset++;
            }
            push @result, $colors[($index + $offset) % $m];
        }
    }

    return @result;
}

my $n = $ARGV[1]; 
my @selected_colors = get_colors($n);
foreach my $color (@selected_colors) {
    print "$color\n";
}
#close OA ;

######################swimming in the sky and flying in the sea ##########################
