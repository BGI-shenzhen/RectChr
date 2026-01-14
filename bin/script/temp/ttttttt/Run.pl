#!/usr/bin/perl -w
use strict;
#explanation:this program is edited to
#edit by liaojing;   Thu Aug 14 16:01:30 CST 2025
#Version 1.0    liaojing@genomics.org.cn

die  "Version 1.0\t2025-08-14;\nUsage: $0 <InPut><Out>\n" unless (@ARGV ==2);

#############Befor  Start  , open the files ####################

open (IA,"$ARGV[0]") || die "input file can't open $!";

#open (OA,">$ARGV[1]") || die "output file can't open $!";

################ Do what you want to do #######################
my %Hash=();
while(<IA>)
{
	chomp ;
	my @inf=split /\t/;
	my $ID=$inf[0];
	my $VV=$inf[-1];
	$ID=~s/ //g;
	$VV=~s/ //g;
	$Hash{$ID}=$VV;
}
close IA;

my %UU=();
$UU{"point"}="点";
$UU{"point"}="点";
$UU{"shape"}="形状";
$UU{"line"}="线条";
$UU{"lines"}="线条";
$UU{"histogram"}="柱状图";
$UU{"hist"}="柱状图";
$UU{"heatmap"}="热图";
$UU{"highlights"}="高亮";
$UU{"highlight"}="高亮";
$UU{"text"}="文本";
$UU{"ridgeline"}="山脊线";
$UU{"pairWiselink"}="彩虹链接";
$UU{"pairwiselink"}="彩虹链接";
$UU{"PairWiseLink"}="彩虹链接";
$UU{"links"}="自连接";
$UU{"LinkS"}="自连接";
$UU{"heatmapanimated"}="动态热图";
$UU{"histanimated"}="动态直方图";

#点(scatter/point)、形状(shape)、线(line)、柱状图(histogram)、热图(heatmap/highlights)、高亮显示(heatmap/highlights)、文本(text)、山脊线(ridgeline) 、彩虹链接(PairWiseLink)、自连接(LinkS)、动态热图(heatmapAnimated)、动态直方图(histAnimated)形式

open (IB,"$ARGV[1]") || die "input file can't open $!";

#open (OA,">$ARGV[1]") || die "output file can't open $!";
my $SetParaFor="ALL";
my $MaxLevel=1;
while(<IB>) {
	chomp;
	my $Flag=0;
	if  ($_=~s/^#//)
	{
		$Flag=1;
	}
	s/^\s+|\s+$//g;
	next if /^#/ || !length($_) || !/=+/;
	$_=~s/^ +//;  $_=~s/\r$//g;
	$_=~s/ +$//;    next if(/^#/);  next if(/^$/);
	next if (!($_ =~ /=/));
	my @bbb=split /\#\#/,$_;    $_=$bbb[0];
	$_=~s/^ +//;    $_=~s/ +$//;    next if(/^#/);  next if(/^$/);
	$_=~s/\"#/UUUU/g;
	@bbb=();    @bbb=split /\#/,$_; $_=$bbb[0];
	$_=~s/UUUU/\"#/g;
	$_=~s/\"//g;
	$_=~s/^ +//;    $_=~s/ +$//;
	next if (!($_=~s/=/=/))  ;
	my ($Para,$InfoPara) = split(/\s*=\s*/,$_);

	$Para =~ s/^\s+|\s+$//g;
	$InfoPara =~ s/^\s+|\s+$//g;
	$InfoPara=~s/^ +// ;  $InfoPara=~s/ +$//;
	$InfoPara=~s/^\t+// ;  $InfoPara=~s/\t+$//;
	$InfoPara=~s/^ +// ;  $InfoPara=~s/ +$//;

	next if  ( $Para eq "");


	if ($Para eq 'SetParaFor') {
		my $AAAA="$Para=$InfoPara";
		if ($Flag!=0)
		{
			 $AAAA="#$Para=$InfoPara";
		}


		$InfoPara =~ s/Level//g;
		$InfoPara =~ s/Track//g;
		$InfoPara =~ s/track//g;
		$SetParaFor = $InfoPara;
		my $Ano="设置全局范围(global)相关变量";

		if ( $InfoPara =~ /^\d+$/)
		{
			$MaxLevel = $InfoPara if $InfoPara > $MaxLevel;
			$Ano="开始设置第$InfoPara个Track的相关参数";
			# $AAAA="$Para=$InfoPara";
		}
		elsif ($InfoPara eq "ALL")
		{
			$Ano="设置所有Track的相关参数";
		}
		elsif ($InfoPara eq "global")
		{

		}
		else
		{
			print "\tBad\t$_\n";
			exit;
		}




		my $formatted = sprintf("%-30s", substr($AAAA, 0, 30));

		print "\n";
		print $formatted,"\t##$Ano\n\n";

		#my $formatted = sprintf("%-40s", substr($AAAA, 0, 40));
		#print $formatted,"\t##$Ano\n";


	} elsif ($Para =~ s/File//) {
		

		if ($Para < 1) {
			log_message('error', "Para FileN; The N number should start from 1,but File$Para found $InfoPara");
		}
		my $AAAA="File$Para=$InfoPara";
		if ($Flag!=0)
		{
			 $AAAA="#$AAAA";
		}

		my $Ano="输入第$Para个File的路径";

		my $formatted = sprintf("%-40s", substr($AAAA, 0, 40));
		print $formatted,"\t##$Ano\n";

	} else {
		my $Ano=$Hash{$Para}; $Ano||="NA";
		my $AAAA="$Para=$InfoPara";
		if ($InfoPara=~s/^#/#/)
		{
			$AAAA="$Para=\"$InfoPara\"";
		}
		 if ($Flag!=0)
		 {
			 $AAAA="#$AAAA";
		 }
		
		 if  ( $Para  eq "plot_type")
		 {
			 my $bbbttt=lc($InfoPara);
			 if  (exists $UU{$InfoPara} )
			 {
			 $Ano="为track$SetParaFor设置绘图方式$InfoPara($UU{$bbbttt})";
		 	}
			else
			{
				$Ano="非关健词,即此track仅画背色";
			}
		 }
		 elsif (( $Para  eq "background_show" )  && ( $InfoPara<1))
		 {
			 $Ano="该track不显示背色";
		 }
		 elsif (( $Para  eq "background_color" )  && ( $InfoPara eq "#FFFFFF"))
		 {
			 $Ano="设背色为白色,实不画";
		 #background_color		 	
		 }
		 elsif (( $Para  eq "xaxis_tick_show" )  && ( $InfoPara<1))
		 {
			 $Ano="不显示X轴刻度标签";
		 }
		 elsif (( $Para  eq "yaxis_tick_show" )  && ( $InfoPara<1))
		 {
			 $Ano="不显示Y轴刻度标签";
		 }
		 elsif (( $Para  eq "colormap_legend_show" )  && ( $InfoPara<1))
		 {
			 $Ano="不显该track$SetParaFor的图例";
		 }
		 elsif (( $Para  eq "track_height" )  && (length($InfoPara)>0) && ( $InfoPara>38))
		 {
			 $Ano="该track$SetParaFor的height调高些";
		 }
		 elsif (( $Para  eq "track_height" ) && (length($InfoPara)>0)  && ( $InfoPara<15))
		 {
			 $Ano="该track$SetParaFor的height调低些";
		 }
		 elsif (( $Para  eq "canvas_height_ratio" )  && ( $InfoPara<0.95))
		 {
			 $Ano="整体画布最下面有空白则截取缩小高度";
		 }
		 elsif (( $Para  eq "canvas_width_ratio" )  && ( $InfoPara<0.95))
		 {
			 $Ano="整体画布最右面有空白则截取缩小宽度";
		 }
		 elsif (( $Para  eq "track_num" )  && (length($InfoPara)>0) &&( $InfoPara>=1))
		 {
			 $Ano="总绘图层数(track_num)为$InfoPara,默认会自动推断";
		 }
		 elsif (( $Para  eq "colormap_nlevels" )  && ( $InfoPara>1))
		 {
			 $Ano="设track$InfoPara的颜色渐变等级为$InfoPara";
			 #colormap_nlevels		颜色渐变等级数量
		 }
		 elsif (( $Para  eq "chr_orientation" )  && ( length($InfoPara)>2))
		 {
			 if ( ($InfoPara eq "horizontal")  ||  ($InfoPara eq "horizontal")) 
			 {
			 	$Ano="染色体排列方向为水平(horizontal),横排";
			 }
			 else
			 {
			 	$Ano="染色体排列方向为坚直(vertical),纵排";
			 }
		 }
		 elsif (( $Para  eq "colormap_brewer_name" )  && ( length($InfoPara)>2))
		 {
			 $Ano="使用预设调Rcolorbrewer的$InfoPara色板";
		 }
		 elsif (( $Para  eq "cap_max_value" ) && ( length($InfoPara)>0) && ($InfoPara>0))
		 {
			 $Ano="对数值限制最大值上限为$InfoPara,高于$InfoPara则置为$InfoPara,裁断";
		 }
		 elsif (( $Para  eq "log_p" )  && ($InfoPara>0))
		 {
			 $Ano="对数值进行-log10转换";
		 }
		 elsif (( $Para  eq "chr_order" )  && ( length($InfoPara)>3))
		 {
			 if  ($InfoPara=~s/,/,/g)
			 {
				 $Ano="指定只画这几条染色体和这个顺序";
			 }
			 else
			 {
				 $Ano="指定只画这条$InfoPara染色体";
			 }

			 #colormap_nlevels		颜色渐变等级数量
		 }
		elsif (( $Para  eq "cutoff_y" )  || ( $Para  eq "cutoff1_y" ) || ( $Para  eq "cutoff2_y" ) )
		 {
			 $Ano="设cutline线值为$InfoPara";
		 }




		 #track_num               指定绘图层数（track数量），默认根据File1中的列数自动推断








		my $formatted = sprintf("%-40s", substr($AAAA, 0, 40));
		print $formatted,"\t##$Ano\n";
	}
}

close IB;


#close OA ;

######################swimming in the sky and flying in the sea ##########################
