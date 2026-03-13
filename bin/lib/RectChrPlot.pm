package RectChrPlot;
use strict;

our @EXPORT_OK = qw(RectChrPlot );
use ColorPaletteManager qw (RGB2HTML HTML2RGB  GetColGradien SVGgetShape); 
use LocalUtils;
#use LocalUtils qw (CheckValueNow svg2PNGfuntion update_value_color_map update_value_color_map2); 


sub RectChrPlot
{

my ($HashConfi_ref, $ValueToCustomColor_ref,$hashChr_ref,$ShowColumn_ref, $FileData_ref, $FileRow_ref,$ChrArry_ref,$widthForPerChr,$ChrMax,$total_chr_length,
$RegionStart,$bin,$axis_label,$ChrCount,$color_gradient_scale,$chr_spacing,$Bodyheight,$fontsize, $height,$width,$NumberLevel)=@_;


my $precision_format="%.0f";
my $chr_name_ratio=$HashConfi_ref->{global}{chr_label_size_ratio};

print STDERR "Start draw... SVG info: ChrNumber :$ChrCount Track Number is $NumberLevel, SVG (width,height) = ($width,$height)\n";

$ChrCount--;

### Horizontal layout adjustments if chromosomes are horizontal ###
#my $all_chromosomes_spacing=0;
my $LegendOffsetRatio = $HashConfi_ref->{global}{"Legend_OffsetRatio"} // 0.5;
if ($HashConfi_ref->{"global"}{"chr_orientation"} ne "vertical")
{
	#	$all_chromosomes_spacing=$ChrCount*$chr_spacing;
	$ChrMax=$total_chr_length;
	if  ($LegendOffsetRatio>0.2){$LegendOffsetRatio=0.2;}
}

### Adjust vertical layout based on legend size##
my $MaxGradien=$HashConfi_ref->{"global"}{"MaxGradien"};

my $Y2=$HashConfi_ref->{"global"}{"canvas_margin_top"}+$LegendOffsetRatio*$Bodyheight+$HashConfi_ref->{"ALL"}{"colormap_legend_sizeratio"}*$color_gradient_scale*($MaxGradien+1);
if ($Y2 > $height)
{
	$color_gradient_scale=int($color_gradient_scale*0.88)+1;
	if  ($LegendOffsetRatio>0.05){$LegendOffsetRatio=0.05;}
    $Y2=$HashConfi_ref->{"global"}{"canvas_margin_top"}+$LegendOffsetRatio*$Bodyheight+$HashConfi_ref->{"ALL"}{"colormap_legend_sizeratio"}*$color_gradient_scale*($MaxGradien);
	if ($Y2 > $height)
	{
		$height=$Y2+10+$color_gradient_scale;
	}
}


my $ColorBarSize=$HashConfi_ref->{ALL}{"colormap_legend_sizeratio"}*$color_gradient_scale;

########## Create SVG canvas ############
my $CanvasHeight=$height;
my $CanvasWidth=$width;


if ((exists $HashConfi_ref->{"global"}{"canvas_height_ratio"})  &&  ($HashConfi_ref->{"global"}{"canvas_height_ratio"}>0.1))
{
	$CanvasHeight=$CanvasHeight*$HashConfi_ref->{"global"}{"canvas_height_ratio"};
}

if ((exists $HashConfi_ref->{"global"}{"canvas_width_ratio"})  &&  ($HashConfi_ref->{"global"}{"canvas_width_ratio"}>0.1))
{
	$CanvasWidth=$CanvasWidth*$HashConfi_ref->{"global"}{"canvas_width_ratio"};
}


$HashConfi_ref->{"global"}{"canvas_margin_Width"}=$CanvasWidth;
$HashConfi_ref->{"global"}{"canvas_margin_Height"}=$CanvasHeight;
my $svg = SVG->new('width',$CanvasWidth,'height',$CanvasHeight);


##################     # Axis drawing and chromosome label positioning  ###############
my $YY3=$HashConfi_ref->{"global"}{"canvas_margin_top"}+$HashConfi_ref->{"global"}{"xaxis_shift_y"};
my $YY1=$YY3-$fontsize*0.75;
my $YY2=$YY1+$fontsize*0.25;
my $XX1=$HashConfi_ref->{"global"}{"canvas_margin_left"}+$HashConfi_ref->{"global"}{"canvas_body"};
my $XX2=$XX1+$HashConfi_ref->{"global"}{"stroke-width"};
my $ScaleNum=$HashConfi_ref->{"global"}{"axis_tick_num"}; if ($ScaleNum<1) {$ScaleNum=-1;}
   if ($HashConfi_ref->{"global"}{"xaxis_tick_show"}<1) {$ScaleNum=-1;}
   if ((exists ($HashConfi_ref->{"ALL"}{"xaxis_tick_show"})) &&  ($HashConfi_ref->{"ALL"}{"xaxis_tick_show"} <1)) {$ScaleNum=-1;}
my $ScaleNumChrMax=$ScaleNum;
# Axis drawing and chromosome label positioning
my $BinXX=($HashConfi_ref->{"global"}{"canvas_bodyOO"})/$ScaleNum;
if (exists $HashConfi_ref->{"global"}{"axis_tick_interval"}  )
{
	$ScaleNumChrMax=$ChrMax*1.0/$HashConfi_ref->{"global"}{"axis_tick_interval"};	
	if ($ScaleNumChrMax  < 2   ||  $ScaleNumChrMax >100 ) 
	{
		print "Pare [axis_tick_interval] set is too small or too big, we use axis_tick_num = $ScaleNum \n ";
		$ScaleNumChrMax=$ScaleNum;
	}
	$BinXX=($HashConfi_ref->{"global"}{"canvas_bodyOO"})/$ScaleNumChrMax;
	$ScaleNum=int($ScaleNumChrMax);
}

my $axis_cor=$HashConfi_ref->{"global"}{"fill"};
my $axis_tickcor='black';
if  (exists $HashConfi_ref->{"global"}{"xaxis_tick_color"})
{
	$axis_cor=$HashConfi_ref->{"global"}{"xaxis_tick_color"};
	$axis_tickcor=$axis_cor;
}

foreach my $k (0..$ScaleNum)
{
	$XX1=$HashConfi_ref->{"global"}{"canvas_margin_left"}+$k*$BinXX;
	my $VV=int($ChrMax*$k/($bin*$ScaleNumChrMax)+$RegionStart/$bin);
	if ($axis_label eq "kb")	{ $VV= sprintf ("%.1f",($RegionStart/$bin+$ChrMax*$k/($bin*$ScaleNumChrMax))*1.0);}

	if ( !exists $HashConfi_ref->{"global"}{"axis_text_angle"})
	{
		$svg->text('text-anchor','middle','x',$XX1,'y',$YY1-0.60*$fontsize,'-cdata',"$VV $axis_label",'font-family',$HashConfi_ref->{"global"}{"font-family"},'font-size',$fontsize);
	}
	else
	{
		my $XXRR= $XX1;
		my $YYRR= $YY1;
		my $rotate=$HashConfi_ref->{"global"}{"axis_text_angle"};
		$svg->text('text-anchor','start','x',$XX1,'y',$YYRR,'-cdata',"$VV $axis_label",'font-family',$HashConfi_ref->{"global"}{"font-family"},'font-size',$fontsize,'transform',"rotate($rotate,$XXRR,$YYRR)");
	}
	
	my $YY4=$YY3;
	if ((exists $HashConfi_ref->{"global"}{"xaxis_tick_direction"})  && ($HashConfi_ref->{"global"}{"xaxis_tick_direction"}  eq "Up") )
	{
		$YY4=$YY1+$YY2-$YY3;
	}
	$svg->line('x1',$XX1,'y1',$YY1,'x2',$XX1,'y2',$YY4,'stroke',$axis_tickcor,'stroke-width',$HashConfi_ref->{"global"}{"stroke-width"},'fill',$axis_cor); #X
}

if (exists $HashConfi_ref->{"global"}{"title"})
{
	my $colr="blue";
	my $MainRatioFontSize=1;
	my $ShiftMainX=0;
	my $ShiftMainY=0;
	if (exists $HashConfi_ref->{"global"}{"title_color"})	{	$colr=$HashConfi_ref->{"global"}{"title_color"};	}
	if (exists $HashConfi_ref->{"global"}{"title_size"})	{	$MainRatioFontSize=$HashConfi_ref->{"global"}{"title_size"};	}
	if (exists $HashConfi_ref->{"global"}{"title_shift_x"})	{	$ShiftMainX=$HashConfi_ref->{"global"}{"title_shift_x"};	}
	if (exists $HashConfi_ref->{"global"}{"title_shift_y"})	{	$ShiftMainY=$HashConfi_ref->{"global"}{"title_shift_y"};	}
	my $MainXX1=($HashConfi_ref->{"global"}{"canvas_margin_left"}+$XX1)/2+$ShiftMainX;
	my $MainYY1=($YY1-2*$fontsize)+$ShiftMainY;
	my $Mainfortsize=$fontsize*1.2*$MainRatioFontSize;
	$svg->text('text-anchor','middle','x',$MainXX1,'y',$MainYY1,'-cdata',$HashConfi_ref->{"global"}{"title"},'font-family',$HashConfi_ref->{"global"}{"font-family"},'font-size',$Mainfortsize,'font-weight',"bold",'fill',$colr);
	#$svg->text('text-anchor','middle','x',$MainXX1,'y',$MainYY1,'-cdata',$HashConfi_ref->{"global"}{"title"},'font-family',$HashConfi_ref->{"global"}{"font-family"},'font-size',$Mainfortsize,'stroke',$colr,'fill',$colr);


}




$XX1=$HashConfi_ref->{"global"}{"canvas_margin_left"}-$HashConfi_ref->{"global"}{"stroke-width"};
my $path = $svg->get_path(
	x => [$XX1, $XX1, $XX2,$XX2],
	y => [$YY1, $YY2, $YY2,$YY1],
	-type => 'polygon');

if ($ScaleNum>0)
{
	$svg->polygon(
		%$path,
		style => {
			'fill'           => $axis_cor,
			'stroke'         => 'black',
			'stroke-width'   => 0,
			'stroke-opacity' => $HashConfi_ref->{ALL}{"stroke-opacity"},
			'fill-opacity'   => $HashConfi_ref->{ALL}{"fill-opacity"},
		},
	);
}

my %hashYY1=();
my %hashYY2=();
my %hashXX1=();

$XX1=$HashConfi_ref->{"global"}{"canvas_margin_left"};
my $EndCurveOUT=0;

######### Loop over each chromosome and draw background track(s)###########
foreach my $thisChr (0..$#$ChrArry_ref)
{
	my $ThisChrName=$ChrArry_ref->[$thisChr];
	$XX2=($hashChr_ref->{$ThisChrName}/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_bodyOO"}+$XX1;  #   - $all_chromosomes_spacing 
	
	my $Y1=$HashConfi_ref->{"global"}{"canvas_margin_top"}+$thisChr*($widthForPerChr+$chr_spacing)+$chr_spacing;

	if ($HashConfi_ref->{"global"}{"chr_orientation"} ne "vertical")
	{
		$Y1=$HashConfi_ref->{"global"}{"canvas_margin_top"}+$chr_spacing;
		$EndCurveOUT=-2;
	}

	my $yaxis_tick_show=0;
	foreach my $Level (1..$NumberLevel)
	{ 
		$XX1+=$HashConfi_ref->{$Level}{track_shift_x};
		$XX2+=$HashConfi_ref->{$Level}{track_shift_x};
		$YY1=$Y1+$HashConfi_ref->{$Level}{track_shift_y};
		$YY2=$YY1+$HashConfi_ref->{$Level}{"track_height"};
		$hashYY1{$ThisChrName}{$Level}=$YY1;
		$hashXX1{$ThisChrName}{$Level}=$XX1;
		$hashYY2{$ThisChrName}{$Level}=$YY2;
		$Y1=$YY2-($HashConfi_ref->{$Level}{track_shift_y});
		if ((exists $HashConfi_ref->{$Level}{"yaxis_tick_show"}) && ($HashConfi_ref->{$Level}{"yaxis_tick_show"} > 0))
		{
			$yaxis_tick_show++;
		}
		if (!( ($HashConfi_ref->{$Level}{"background_color"}  eq  "#FFFFFF" )  && ($HashConfi_ref->{$Level}{"bg_stroke_color"} eq  "#FFFFFF") ) && (! (exists $HashConfi_ref->{$Level}{"background_show"}  &&  $HashConfi_ref->{$Level}{"background_show"}==0) ) )
		{
			my $Mid=($YY1+$YY2)/2;
			my $AA=$HashConfi_ref->{$Level}{"track_bg_height_ratio"}*$HashConfi_ref->{$Level}{"track_height"}/2;
			$YY1=$Mid-$AA;
			$YY2=$Mid+$AA;
			my $BGCorThisChr=$HashConfi_ref->{$Level}{"background_color"} ;
			if (exists 	$ValueToCustomColor_ref->{$ThisChrName}) {$BGCorThisChr=$ValueToCustomColor_ref->{$ThisChrName};}

			if ($HashConfi_ref->{$Level}{"bg_end_arc"}==0)
			{
				$path = $svg->get_path(
					x => [$XX1, $XX1, $XX2,$XX2],
					y => [$YY1, $YY2, $YY2,$YY1],
					-type => 'polygon');
				$svg->polygon(
					%$path,
					style => {
						'fill'           => $BGCorThisChr,
						'stroke'         => $HashConfi_ref->{$Level}{"bg_stroke_color"},
						'stroke-width'   => $HashConfi_ref->{$Level}{"bg_stroke_width"},
						'stroke-opacity' => $HashConfi_ref->{$Level}{"stroke-opacity"},
						'fill-opacity'   => $HashConfi_ref->{$Level}{"fill-opacity"},
					},
				);
			}
			else
			{
				my $EndCurveRadian=int($HashConfi_ref->{$Level}{"track_height"}/10)+1;
				if ($EndCurveRadian<3){	$EndCurveRadian=3;}
				if (exists $HashConfi_ref->{$Level}{"bg_end_arc_division"})
				{
					if ($HashConfi_ref->{$Level}{"bg_end_arc_division"}>=2)
					{
						$EndCurveRadian=$HashConfi_ref->{$Level}{"bg_end_arc_division"};
					}
					else
					{
						print "Track(Level) $Level Para bg_end_arc_division must >=2 ,so we chang it to be 2\n";
						$EndCurveRadian=2;$HashConfi_ref->{$Level}{"bg_end_arc_division"}=2;
					}
				}
				my $HH=($YY2-$YY1)/$EndCurveRadian;
				if (($HH*2)>abs($XX2-$XX1)) {$HH=abs($XX2-$XX1)*0.48;}
				my $HM=($YY2-$YY1)-$HH-$HH;
				if  ((exists  $HashConfi_ref->{$Level}{"bg_end_offset"}) &&  ($EndCurveOUT> -1)) {$XX1=$XX1-$HH;$XX2=$XX2+$HH;$EndCurveOUT=$HH;}
				my $P1_X=$XX1+$HH;  my $P1_Y=$YY1;
				my $P1Q_X=$XX1;  my $P1Q_Y=$YY1;
				my $P2_X=$XX1;  my $P2_Y=$YY1+$HH;
				my $P3_X=$XX1;  my $P3_Y=$P2_Y+$HM;
				my $P2Q_X=$XX1;  my $P2Q_Y=$YY2;
				my $P4_X=$XX1+$HH;  my $P4_Y=$YY2;
				my $P3Q_X=$XX2;  my $P3Q_Y=$YY2;
				my $P6_X=$XX2-$HH;  my $P6_Y=$YY2;
				my $P7_X=$XX2;  my $P7_Y=$YY2-$HH;
				my $P8_X=$XX2;  my $P8_Y=$P7_Y-$HM;
				my $P4Q_X=$XX2;  my $P4Q_Y=$YY1;
				my $P9_X=$XX2-$HH;  my $P9_Y=$YY1;
				$svg->path(
					'd'=>"M$P1_X $P1_Y Q $P1Q_X $P1Q_Y , $P2_X $P2_Y L  $P3_X $P3_Y  Q $P2Q_X $P2Q_Y , $P4_X $P4_Y   L $P6_X $P6_Y  Q $P3Q_X $P3Q_Y , $P7_X $P7_Y  L $P8_X $P8_Y Q $P4Q_X $P4Q_Y ,$P9_X $P9_Y  Z",
					style => {
						'fill'           =>  $BGCorThisChr,
						'stroke'         =>  $HashConfi_ref->{$Level}{"bg_stroke_color"},
						'stroke-width'   =>  $HashConfi_ref->{$Level}{"bg_stroke_width"},
						'stroke-opacity' =>  $HashConfi_ref->{$Level}{"stroke-opacity"},
						'fill-opacity'   =>  $HashConfi_ref->{$Level}{"fill-opacity"},
					},
				);
				if  ((exists  $HashConfi_ref->{$Level}{"bg_end_offset"}) &&  ($EndCurveOUT> 0)) {$XX1=$XX1+$HH;$XX2=$XX2-$HH;}
			}
		}
		if  ($Level !=$NumberLevel)
		{
			$Y1+=$HashConfi_ref->{$Level}{"track_height"}*$HashConfi_ref->{$Level}{"padding_ratio"};
		}
		$XX2-=$HashConfi_ref->{$Level}{track_shift_x};
	}

	my $ChrNameRatio=$HashConfi_ref->{"ALL"}{"chr_label_size_ratio"}; $ChrNameRatio||=1;
	my $AAAfontsize=$fontsize*$ChrNameRatio;
	my $ShiftChrNameX=$HashConfi_ref->{"ALL"}{"chr_label_shift_x"};
	my $fontsizeShift=1.2;
	if  ($yaxis_tick_show>0)
	{
		$fontsizeShift=2.68;
	}
	my $ShiftChrNameY=$HashConfi_ref->{"ALL"}{"chr_label_shift_y"};

	my $XX3tmp=$XX1+$ShiftChrNameX-$AAAfontsize*$chr_name_ratio*$fontsizeShift;
	

	if ($EndCurveOUT>0){$XX3tmp=$XX3tmp-$EndCurveOUT;}
	#	if ($XX3tmp<0) {$XX3tmp=0;}
	my $TextYY=($hashYY1{$ThisChrName}{1}+$hashYY2{$ThisChrName}{$NumberLevel})*0.5+$ShiftChrNameY+($AAAfontsize*0.5);
	my $ChrTextAnchor='end';
	if ( $HashConfi_ref->{"global"}{"chr_orientation"} ne "vertical" )
	{
		 $TextYY=$hashYY2{$ThisChrName}{$NumberLevel}+$ShiftChrNameY+$AAAfontsize*1.0;
		 $XX3tmp=($XX2-$XX1)*0.5+$XX1;
		 $ChrTextAnchor='middle';
	}
	if ($HashConfi_ref->{"global"}{"chr_label_rotation"}==0)
	{
			$svg->text('text-anchor',$ChrTextAnchor,'x',$XX3tmp,'y',$TextYY,'-cdata',$ThisChrName,'font-family',$HashConfi_ref->{"global"}{"font-family"},'font-size',$AAAfontsize);
	}
	else
	{
			$XX3tmp=$XX1-$AAAfontsize*1.1+$ShiftChrNameX;
			my $rotate=$HashConfi_ref->{"global"}{"chr_label_rotation"};
			$svg->text('text-anchor',$ChrTextAnchor,'x',$XX3tmp,'y',$TextYY,'-cdata',$ThisChrName,'font-family',$HashConfi_ref->{"global"}{"font-family"},'font-size',$AAAfontsize,'transform',"rotate($rotate,$XX3tmp,$TextYY)");
	}

	if ( $HashConfi_ref->{"global"}{"chr_orientation"} ne "vertical" )
	{
		$XX1=$XX2+$chr_spacing;
	}
	else
	{
		$XX1=$HashConfi_ref->{"global"}{"canvas_margin_left"};
	}
}


my $SetParaFor=$#$ChrArry_ref ;
if ($HashConfi_ref->{"global"}{"chr_orientation"} ne "vertical")
{
	$SetParaFor=0;
}





$chr_name_ratio=$chr_name_ratio-0.3;

########## Plotting loop: draw data based on plot_type (e.g., heatmap, line, scatter, etc.)#############
print "Track(Level) $NumberLevel\n";
foreach my $Level  (1..$NumberLevel)
{
	if  (exists  $HashConfi_ref->{$Level}{"label"})
	{
		foreach my $thisChr (0..$SetParaFor)
		{
			my $ThisChrName=$ChrArry_ref->[$thisChr];
			my $NYY2=$hashYY2{$ThisChrName}{$Level};
			my $NYY1=$hashYY1{$ThisChrName}{$Level};
			my $NXX1=$hashXX1{$ThisChrName}{$Level};
			my $colr="green";
			my $NameRatioFontSize=1;
			my $ShiftNameX=0;
			my $ShiftNameY=0;
			my $NameRotate=0;
			my $textanchor="end";
			if (exists $HashConfi_ref->{$Level}{"label_color"})	{	$colr=$HashConfi_ref->{$Level}{"label_color"};	}
			if (exists $HashConfi_ref->{$Level}{"label_size"})	{	$NameRatioFontSize=$HashConfi_ref->{$Level}{"label_size"};	}
			if (exists $HashConfi_ref->{$Level}{"label_shift_x"})	{	$ShiftNameX=$HashConfi_ref->{$Level}{"label_shift_x"};	}
			if (exists $HashConfi_ref->{$Level}{"label_shift_y"})	{	$ShiftNameY=$HashConfi_ref->{$Level}{"label_shift_y"};	}
			if (exists $HashConfi_ref->{$Level}{"label_angle"})	{	$NameRotate=$HashConfi_ref->{$Level}{"label_angle"}; $textanchor="middle";	}
			elsif  ( ($NYY2-$NYY1)> 3*$fontsize )			{   $NameRotate=-90; $textanchor="middle"; }
			my $NameXX1=$NXX1+$ShiftNameX-$fontsize*0.8;
			my $NameYY1=($NYY1+$NYY2)/2+$ShiftNameY;
			my $Namefortsize=$fontsize*0.6*$NameRatioFontSize;
			$svg->text('text-anchor',$textanchor,'x',$NameXX1,'y',$NameYY1,'-cdata',$HashConfi_ref->{$Level}{"label"},'font-family',$HashConfi_ref->{"global"}{"font-family"},'font-size',$Namefortsize,'stroke',$colr,'fill',$colr,'transform',"rotate($NameRotate,$NameXX1,$NameYY1)");
		}
	}



    ##### Build value-color map based on data range and colormap settings#####
	my %FlagValue=();
	$HashConfi_ref->{$Level}{"IsNumber"}=1;
	$HashConfi_ref->{$Level}{"TotalValue"}=0;
	my $PlotInfo=$ShowColumn_ref->[$Level-1];
	my $PlotArryNum=$#$PlotInfo+1;
	for (my $i=0; $i<$PlotArryNum; $i++)
	{
		my $NowPlot=$PlotInfo->[$i];
		my $FileNow=$NowPlot->[0];
		my $CoumnNow=$NowPlot->[1];

		if(( $HashConfi_ref->{$Level}{"plot_type"}  eq  "LinkSelf" )   || ( $HashConfi_ref->{$Level}{"plot_type"}  eq  "LinkS" )   ||  (  $HashConfi_ref->{$Level}{"plot_type"}  eq  "PairWiseLinkV2")  ||   (  $HashConfi_ref->{$Level}{"plot_type"}  eq  "pairwiselinkV2") )
		{
			next if ($i>0) ;
		}

		my $StartCount=0;
		if ( defined($FileData_ref->[$FileNow][0][0])  && ($FileData_ref->[$FileNow][0][0] =~s/#/#/)  )
		{
			$StartCount=1;
		}

		for ( ; $StartCount<$FileRow_ref->[$FileNow]; $StartCount++)
		{
			my $ValueNowAA=$FileData_ref->[$FileNow][$StartCount][$CoumnNow] ;
			next if  ($ValueNowAA eq "NA");	
			$ValueNowAA=LocalUtils::CheckValueNow($HashConfi_ref,$Level,$ValueNowAA);

			$FlagValue{$ValueNowAA}++;
			$HashConfi_ref->{$Level}{"TotalValue"}++;
			if ($ValueNowAA=~s/\./\./)
			{
				$precision_format="%.2f";
			}
			if ( $ValueNowAA  =~ /^-?(0|([1-9][0-9]*))(\.[0-9]+)?([eE][-+]?[0-9]+)?$/)
			{

			}
			elsif (!( $ValueNowAA  =~ /^[+-]?\d+(\.\d+)?$/ ))
			{
				$HashConfi_ref->{$Level}{"IsNumber"}=0;
			}
		}
	}

	if (exists $HashConfi_ref->{$Level}{"as_flag"} ) {	  $HashConfi_ref->{$Level}{"IsNumber"}=0; }
	my @ValueArry= sort  keys  %FlagValue ;

	if ($HashConfi_ref->{$Level}{"IsNumber"}==1 )
	{
		@ValueArry= sort {$a<=>$b} @ValueArry;
	}


	my $ValueMin=$ValueArry[0];  if  (!defined($ValueMin)) {$ValueMin=0;}
	my $ValueCount=$#ValueArry;
	my $ValueMax=$ValueArry[$ValueCount]; if  (!defined($ValueMax)) {$ValueMax=0;}
	
	my ($StartCountBin,$EndCountBin,$MinCutValue,$MaxCutValue)=LocalUtils::compute_data_boundaries(
		\@ValueArry, 
		\%FlagValue, 
		$HashConfi_ref->{$Level}{"TotalValue"},
		$HashConfi_ref->{$Level}{"lower_outlier_ratio"},
		$HashConfi_ref->{$Level}{"upper_outlier_ratio"}
		); 

	
	if (exists $HashConfi_ref->{$Level}{"Ymax"})
	{
		if ($HashConfi_ref->{$Level}{"Ymax"}>=$MaxCutValue)
		{
			$MaxCutValue=$HashConfi_ref->{$Level}{"Ymax"};
		}
		else
		{
			my $eeetmp=$HashConfi_ref->{$Level}{"Ymax"};
			print "InPut Para For [Track(Level) $Level] YMax  $eeetmp  must > $MaxCutValue \t since the data max Value is $MaxCutValue\n";
		}
	}
	else
	{
		$HashConfi_ref->{$Level}{"Ymax"}=$MaxCutValue;
	}
	

	if (exists $HashConfi_ref->{$Level}{"Ymin"})
	{
		if  ($HashConfi_ref->{$Level}{"Ymin"}> $MinCutValue )
		{
			my $eeetmp=$HashConfi_ref->{$Level}{"Ymin"};
			print "InPut -YMin For [Track(Level) $Level] $eeetmp must < $ValueMin \t since the data min Value is $MinCutValue\n";
		}
		else
		{
			$MinCutValue=$HashConfi_ref->{$Level}{"Ymin"};
		}
	}
	else
	{
		$HashConfi_ref->{$Level}{"Ymin"}= $MinCutValue;
	}

	if  ($HashConfi_ref->{$Level}{"Ymin"}  eq  $HashConfi_ref->{$Level}{"Ymax"})
	{
		print STDERR "[WARNING] [ track(Level) $Level ] Ymax == Ymin :$HashConfi_ref->{$Level}{Ymin}, pls check,This may cause other errors later\n";	
	}
	if ($HashConfi_ref->{$Level}{"IsNumber"}==1 )
	{
		foreach my $key (0..$ValueCount)
		{
			my $VCount=$ValueArry[$key];
			if ( $VCount  <= $MinCutValue )
			{
				$StartCountBin=$key;
			}
			if ( $VCount <= $MaxCutValue )
			{
				$EndCountBin=$key;
			}
		}
	}
	else
	{		
		foreach my $key (0..$ValueCount)
		{
			my $VCount=$ValueArry[$key];
			if ( $VCount le  $MinCutValue)
			{
				$StartCountBin=$key;
			}
			if ($VCount le $MaxCutValue)
			{
				$EndCountBin=$key;
			}
		}
	}



	my %ValueToColor=();
	my @ColorGradientArray=();
	my @ValueLabelsGradient=();
	my $GradientSteps=1;
	my $Precision=$precision_format;
	if (exists $HashConfi_ref->{$Level}{"axis_tick_precision"} )
	{
		my $Num=int($HashConfi_ref->{$Level}{"axis_tick_precision"});
		$Precision="%.$Num"."f";
	}

	if ( ( $HashConfi_ref->{$Level}{"IsNumber"}==1 )   &&  ( abs($ValueMax)<0.01 )  &&  ( abs($ValueMin)<0.01 ) )
	{
		my $e='e';	my $f='f';
		$Precision =~ s/$f/$e/g;
	}

	my $NumGradien= $HashConfi_ref->{$Level}{"colormap_nlevels"};
	if ($ValueCount<$NumGradien)
	{
		$HashConfi_ref->{$Level}{"colormap_nlevels"}=$ValueCount+1;
		$NumGradien=  $ValueCount+1;
		$EndCountBin=$ValueCount;$StartCountBin=0;
		$MaxCutValue=$ValueMax  ; $MinCutValue=$ValueMin;
	}
	if ($EndCountBin<($NumGradien-2))
	{
		$EndCountBin=$NumGradien-2;
		$MaxCutValue=$ValueArry[$EndCountBin];
	}
	if ($EndCountBin==$ValueCount)
	{
		if  (($EndCountBin-$StartCountBin)<($NumGradien-2))
		{
			$StartCountBin=$EndCountBin+2-$NumGradien;
		}
	}
	else
	{
		if  (($EndCountBin-$StartCountBin)<($NumGradien-3))
		{
			$StartCountBin=$EndCountBin+3-$NumGradien;
		}
	}
	if ($StartCountBin<0) {$StartCountBin=0;}


	if ( exists $HashConfi_ref->{$Level}{"colormap_brewer_name"}  )
	{
		if ( $HashConfi_ref->{$Level}{"colormap_brewer_name"}  eq  "NANA" )
		{
			if ($HashConfi_ref->{$Level}{"IsNumber"}==1 )
			{
				$HashConfi_ref->{$Level}{"colormap_brewer_name"}="GnYlRd";
				$HashConfi_ref->{$Level}{"colormap_nlevels"}=10;
				$NumGradien=10;
				if (($HashConfi_ref->{$Level}{"plot_type"}  eq  "lines")  || ( $HashConfi_ref->{$Level}{"plot_type"}  eq  "line"))
				{
					$HashConfi_ref->{$Level}{"colormap_brewer_name"}="Dark2";
					$HashConfi_ref->{$Level}{"colormap_nlevels"}=8;
					$NumGradien=8;
				}
				elsif (($HashConfi_ref->{$Level}{"plot_type"}  eq  "scatter" )  || ( $HashConfi_ref->{$Level}{"plot_type"}  eq  "point" ) || ( $HashConfi_ref->{$Level}{"plot_type"}  eq  "points" ))
				{
					if  ($PlotArryNum>1) { $HashConfi_ref->{$Level}{"colormap_brewer_name"}="Set1"; $HashConfi_ref->{$Level}{"colormap_nlevels"}=9;$NumGradien=9;}
				}

			}
			else
			{
				$HashConfi_ref->{$Level}{"colormap_brewer_name"}="Paired";
				$HashConfi_ref->{$Level}{"colormap_nlevels"}=8;
				$NumGradien=8;
			}
		}
		elsif ($HashConfi_ref->{$Level}{"colormap_brewer_name"} eq "NA")
		{
			if ($HashConfi_ref->{$Level}{"IsNumber"}==1 )
			{
				$HashConfi_ref->{$Level}{"colormap_brewer_name"}="GnYlRd";
				if (($HashConfi_ref->{$Level}{"plot_type"}  eq  "lines")  || ( $HashConfi_ref->{$Level}{"plot_type"}  eq  "line"))
				{
					$HashConfi_ref->{$Level}{"colormap_brewer_name"}="Dark2";
				}
				elsif (($HashConfi_ref->{$Level}{"plot_type"}  eq  "scatter" )  || ( $HashConfi_ref->{$Level}{"plot_type"}  eq  "point" ) || ( $HashConfi_ref->{$Level}{"plot_type"}  eq  "points" ))
				{
					if  ($PlotArryNum>1) { $HashConfi_ref->{$Level}{"colormap_brewer_name"}="Set1"; }
				}
			}
			else
			{
				$HashConfi_ref->{$Level}{"colormap_brewer_name"}="Paired";
			}
		}
		if ($ValueCount<$NumGradien)
		{
			$HashConfi_ref->{$Level}{"colormap_nlevels"}=$ValueCount+1;
			$NumGradien=  $ValueCount+1;
			$EndCountBin=$ValueCount;$StartCountBin=0;
			$MaxCutValue=$ValueMax  ; $MinCutValue=$ValueMin;
		}
		if ($EndCountBin<($NumGradien-2))
		{
			$EndCountBin=$NumGradien-2;
		}
		if ($EndCountBin==$ValueCount)
		{
			if  (($EndCountBin-$StartCountBin)<($NumGradien-2))
			{
				$StartCountBin=$EndCountBin+2-$NumGradien;				 
			}
		}
		else
		{
			if  (($EndCountBin-$StartCountBin)<($NumGradien-3))
			{
				$StartCountBin=$EndCountBin+3-$NumGradien;
			}
		}
		if ($StartCountBin<0) {$StartCountBin=0;}


		my $ColFlag=$HashConfi_ref->{$Level}{"colormap_brewer_name"};
		GetColGradien($ColFlag,$NumGradien,\@ColorGradientArray,$HashConfi_ref);
		
		if  (exists  $HashConfi_ref->{$Level}{"colormap_reverse"})
		{
			my @cccTmpCor=();
			foreach my $k (0..$#ColorGradientArray)
			{
				my $Tho=$#ColorGradientArray-$k;
				$cccTmpCor[$Tho]=$ColorGradientArray[$k];
			}
			foreach my $k (0..$#ColorGradientArray)
			{
				$ColorGradientArray[$k]=$cccTmpCor[$k];
			}
		}
		$GradientSteps=$NumGradien-1;

		if ($HashConfi_ref->{$Level}{"IsNumber"}==1 )
		{
			my $ShiftTmpEnd=$NumGradien-1;
			if ($EndCountBin< $ValueCount)
			{
				my $tttEnd=$EndCountBin+1;
				my $VV=$ValueArry[$tttEnd];
				$VV=sprintf ($Precision,$VV*1.0);
				$ValueLabelsGradient[$ShiftTmpEnd]=">$VV";
				foreach my $k ($tttEnd..$ValueCount)
				{
					my $VV=$ValueArry[$k];   $ValueToColor{$VV}=$ColorGradientArray[$ShiftTmpEnd];
					if (exists $ValueToCustomColor_ref->{$VV} ) {$ValueToColor{$VV}=$ValueToCustomColor_ref->{$VV};}
				}
				$NumGradien--;
				$ShiftTmpEnd--;
			}

			my $ShiftTmpStart=0;
			if ($StartCountBin>0)
			{
				my $VV=$ValueArry[$StartCountBin];
				$VV=sprintf ($Precision,$VV*1.0);
				$ValueLabelsGradient[0]="<$VV";
				my $tttEnd=$StartCountBin-1;
				foreach my $k (0..$tttEnd)
				{
					my $VV=$ValueArry[$k];   $ValueToColor{$VV}=$ColorGradientArray[$ShiftTmpStart];
					if (exists $ValueToCustomColor_ref->{$VV} ) {$ValueToColor{$VV}=$ValueToCustomColor_ref->{$VV};}
				}
				$NumGradien--;
				$ShiftTmpStart=1;
			}


			my $Diff=1;
			if ($NumGradien>1)
			{
				$Diff=($MaxCutValue-$MinCutValue)/($NumGradien-1);
				if ($Diff==0) {$Diff=1;}
			}

			LocalUtils::update_value_color_map(\%ValueToColor,\@ValueArry,\@ColorGradientArray,$StartCountBin,
			$EndCountBin,$MinCutValue,$Diff,$ShiftTmpStart,$ValueToCustomColor_ref);

			my $Shift=$ShiftTmpStart;

			foreach my $k ($ShiftTmpStart..$ShiftTmpEnd)
			{
				my $MinAA=$MinCutValue+($k-$Shift)*$Diff;
				$MinAA=sprintf ($Precision,$MinAA*1.0);
				$ValueLabelsGradient[$k]="$MinAA";
			}
		}
		else
		{
			my $ShiftTmpEnd=$NumGradien-1;
			if ($EndCountBin< $ValueCount)
			{
				my $tttEnd=$EndCountBin+1;
				my $VV=$ValueArry[$tttEnd];
				$ValueLabelsGradient[$ShiftTmpEnd]="$VV";
				foreach my $k ($tttEnd..$ValueCount)
				{
					my $VV=$ValueArry[$k];   $ValueToColor{$VV}=$ColorGradientArray[$ShiftTmpEnd];
					if (exists $ValueToCustomColor_ref->{$VV} ) {$ValueToColor{$VV}=$ValueToCustomColor_ref->{$VV};}
				}
				$NumGradien--;
				$ShiftTmpEnd--;
			}
			my $ShiftTmpStart=0;
			if ($StartCountBin>0)
			{
				my $VV=$ValueArry[$StartCountBin];
				$ValueLabelsGradient[0]="<$VV";
				my $tttEnd=$StartCountBin-1;
				foreach my $k (0..$tttEnd)
				{
					my $VV=$ValueArry[$k];   $ValueToColor{$VV}=$ColorGradientArray[$ShiftTmpStart];
					if (exists $ValueToCustomColor_ref->{$VV} ) {$ValueToColor{$VV}=$ValueToCustomColor_ref->{$VV};}
				}
				$NumGradien--;
				$ShiftTmpStart=1;
			}

			my $Diff=1;
			if ($NumGradien>1)
			{
				$Diff=($EndCountBin-$StartCountBin)/($NumGradien-1);
				if ($Diff==0) {$Diff=1;}
			}

			LocalUtils::update_value_color_map2(\%ValueToColor,\@ValueLabelsGradient,\@ValueArry,\@ColorGradientArray,$StartCountBin,$EndCountBin,$Diff,$ShiftTmpStart,$ValueToCustomColor_ref);

		}
	}
	elsif  ($ValueCount==2)
	{
		my $VV=$ValueArry[0];
		if (exists $ValueToCustomColor_ref->{$VV} ) {$HashConfi_ref->{$Level}{"colormap_low_color"}=$ValueToCustomColor_ref->{$VV};}
		$ValueToColor{$VV}=$HashConfi_ref->{$Level}{"colormap_low_color"};$ColorGradientArray[0]=$HashConfi_ref->{$Level}{"colormap_low_color"}; $ValueLabelsGradient[0]=$VV;
		$VV=$ValueArry[1];
		if (exists $ValueToCustomColor_ref->{$VV} ) {$HashConfi_ref->{$Level}{"colormap_mid_color"}=$ValueToCustomColor_ref->{$VV};}
		$ValueToColor{$VV}=$HashConfi_ref->{$Level}{"colormap_mid_color"};$ColorGradientArray[1]=$HashConfi_ref->{$Level}{"colormap_mid_color"}; $ValueLabelsGradient[1]=$VV;
		$VV=$ValueArry[2];
		if (exists $ValueToCustomColor_ref->{$VV} ) {$HashConfi_ref->{$Level}{"colormap_high_color"}=$ValueToCustomColor_ref->{$VV};}
		$ValueToColor{$VV}=$HashConfi_ref->{$Level}{"colormap_high_color"};$ColorGradientArray[2]=$HashConfi_ref->{$Level}{"colormap_high_color"}; $ValueLabelsGradient[2]=$VV;
		$GradientSteps=2;
	}
	elsif ($ValueCount < 2)
	{
		my $VV=$ValueArry[0];
		if (exists $ValueToCustomColor_ref->{$VV} ) {$HashConfi_ref->{$Level}{"colormap_low_color"}=$ValueToCustomColor_ref->{$VV};}
		$ValueToColor{$VV}=$HashConfi_ref->{$Level}{"colormap_low_color"};$ColorGradientArray[0]=$HashConfi_ref->{$Level}{"colormap_low_color"}; $ValueLabelsGradient[0]=$VV;
		if ($ValueCount==0) {$ValueArry[1]=$ValueArry[0];}
		$VV=$ValueArry[1]; 
		if (exists $ValueToCustomColor_ref->{$VV} ) {$HashConfi_ref->{$Level}{"colormap_high_color"}=$ValueToCustomColor_ref->{$VV};}
		$ValueToColor{$VV}=$HashConfi_ref->{$Level}{"colormap_high_color"};$ColorGradientArray[1]=$HashConfi_ref->{$Level}{"colormap_high_color"}; $ValueLabelsGradient[1]=$VV;
		$GradientSteps=1;
	}
	elsif ($ValueCount< $HashConfi_ref->{$Level}{"colormap_nlevels"})
	{
		my $Atmp=int($ValueCount/2);

		my $VV=$ValueArry[0];
		if (exists $ValueToCustomColor_ref->{$VV} ) {$HashConfi_ref->{$Level}{"colormap_low_color"}=$ValueToCustomColor_ref->{$VV};}
		$ValueToColor{$VV}=$HashConfi_ref->{$Level}{"colormap_low_color"};$ColorGradientArray[0]=$HashConfi_ref->{$Level}{"colormap_low_color"}; $ValueLabelsGradient[0]=$VV;
		$VV=$ValueArry[$Atmp];
		if (exists $ValueToCustomColor_ref->{$VV} ) {$HashConfi_ref->{$Level}{"colormap_mid_color"}=$ValueToCustomColor_ref->{$VV};}
		$ValueToColor{$VV}=$HashConfi_ref->{$Level}{"colormap_mid_color"};$ColorGradientArray[$Atmp]=$HashConfi_ref->{$Level}{"colormap_mid_color"}; $ValueLabelsGradient[$Atmp]=$VV;
		$VV=$ValueArry[$ValueCount];
		if (exists $ValueToCustomColor_ref->{$VV} ) {$HashConfi_ref->{$Level}{"colormap_high_color"}=$ValueToCustomColor_ref->{$VV};}
		$ValueToColor{$VV}=$HashConfi_ref->{$Level}{"colormap_high_color"};$ColorGradientArray[$ValueCount]=$HashConfi_ref->{$Level}{"colormap_high_color"}; $ValueLabelsGradient[$ValueCount]=$VV;

		my @StartRGB;
		($StartRGB[0],$StartRGB[1],$StartRGB[2] )=HTML2RGB($HashConfi_ref->{$Level}{"colormap_low_color"});
		my @EndRGB;
		($EndRGB[0],$EndRGB[1],$EndRGB[2])=HTML2RGB($HashConfi_ref->{$Level}{"colormap_high_color"});
		my @MidRGB;
		($MidRGB[0],$MidRGB[1],$MidRGB[2])=HTML2RGB($HashConfi_ref->{$Level}{"colormap_mid_color"});


		my $MidNumGradien=$Atmp; my $Btmp=$Atmp-1;
		foreach my $k (1..$Btmp)
		{
			my $RR=int($StartRGB[0]+($MidRGB[0]-$StartRGB[0])*$k*1.0/$MidNumGradien);
			my $GG=int($StartRGB[1]+($MidRGB[1]-$StartRGB[1])*$k*1.0/$MidNumGradien);
			my $BB=int($StartRGB[2]+($MidRGB[2]-$StartRGB[2])*$k*1.0/$MidNumGradien);
			$VV=$ValueArry[$k];   $ValueToColor{$VV}="rgb($RR,$GG,$BB)";
			$ColorGradientArray[$k]="rgb($RR,$GG,$BB)";  $ValueLabelsGradient[$k]=$VV;
			if (exists $ValueToCustomColor_ref->{$VV} )
			{
				$ValueToColor{$VV}=$ValueToCustomColor_ref->{$VV};
				$ColorGradientArray[$k]=$ValueToCustomColor_ref->{$VV};				
			}
		}
		$Btmp=$Atmp+1;  my $Ctmp=$ValueCount-1;

		foreach my $k ($Btmp..$Ctmp)
		{
			my $RR=int($MidRGB[0]+($EndRGB[0]-$MidRGB[0])*($k-$Atmp)*1.0/$MidNumGradien);
			my $GG=int($MidRGB[1]+($EndRGB[1]-$MidRGB[1])*($k-$Atmp)*1.0/$MidNumGradien);
			my $BB=int($MidRGB[2]+($EndRGB[2]-$MidRGB[2])*($k-$Atmp)*1.0/$MidNumGradien);
			$VV=$ValueArry[$k];   $ValueToColor{$VV}="rgb($RR,$GG,$BB)";
			$ColorGradientArray[$k]="rgb($RR,$GG,$BB)";  $ValueLabelsGradient[$k]=$VV;
			if (exists $ValueToCustomColor_ref->{$VV} )
			{
				$ValueToColor{$VV}=$ValueToCustomColor_ref->{$VV};
				$ColorGradientArray[$k]=$ValueToCustomColor_ref->{$VV};				
			}
		}
		$GradientSteps=$ValueCount;
	}
	else
	{
		my $NumGradien=$HashConfi_ref->{$Level}{"colormap_nlevels"};
		$GradientSteps=$NumGradien-1;
		my $MidNumGradien=int($GradientSteps/2);

		my $VV=$ValueArry[0];
		if (exists $ValueToCustomColor_ref->{$VV} ) {$HashConfi_ref->{$Level}{"colormap_low_color"}=$ValueToCustomColor_ref->{$VV};}
		$VV=$ValueArry[$MidNumGradien];
		if (exists $ValueToCustomColor_ref->{$VV} ) {$HashConfi_ref->{$Level}{"colormap_mid_color"}=$ValueToCustomColor_ref->{$VV};}
		$VV=$ValueArry[$GradientSteps];
		if (exists $ValueToCustomColor_ref->{$VV} ) {$HashConfi_ref->{$Level}{"colormap_high_color"}=$ValueToCustomColor_ref->{$VV};}

		my @StartRGB;
		($StartRGB[0],$StartRGB[1],$StartRGB[2] )=HTML2RGB($HashConfi_ref->{$Level}{"colormap_low_color"});
		my @EndRGB;
		($EndRGB[0],$EndRGB[1],$EndRGB[2])=HTML2RGB($HashConfi_ref->{$Level}{"colormap_high_color"});
		my @MidRGB;
		($MidRGB[0],$MidRGB[1],$MidRGB[2])=HTML2RGB($HashConfi_ref->{$Level}{"colormap_mid_color"});

		foreach my $k (0..$MidNumGradien)
		{
			my $RR=int($StartRGB[0]+($MidRGB[0]-$StartRGB[0])*$k*1.0/$MidNumGradien);
			my $GG=int($StartRGB[1]+($MidRGB[1]-$StartRGB[1])*$k*1.0/$MidNumGradien);
			my $BB=int($StartRGB[2]+($MidRGB[2]-$StartRGB[2])*$k*1.0/$MidNumGradien);
			$ColorGradientArray[$k]="rgb($RR,$GG,$BB)";
		}
		my $MidNumGradienBB=$MidNumGradien+1;
		$NumGradien--;
		foreach my $k ($MidNumGradienBB..$NumGradien)
		{
			my $RR=int($MidRGB[0]+($EndRGB[0]-$MidRGB[0])*($k-$MidNumGradien)*1.0/$MidNumGradienBB);
			my $GG=int($MidRGB[1]+($EndRGB[1]-$MidRGB[1])*($k-$MidNumGradien)*1.0/$MidNumGradienBB);
			my $BB=int($MidRGB[2]+($EndRGB[2]-$MidRGB[2])*($k-$MidNumGradien)*1.0/$MidNumGradienBB);
			$ColorGradientArray[$k]="rgb($RR,$GG,$BB)";
		}
		$ColorGradientArray[$NumGradien+1]=$HashConfi_ref->{$Level}{"colormap_high_color"};

		if ($HashConfi_ref->{$Level}{"IsNumber"}==1 )
		{
			my $ShiftTmpEnd=$NumGradien;
			if ($EndCountBin< $ValueCount)
			{
				my $VV=$ValueArry[$EndCountBin];
				$VV=sprintf ($Precision,$VV*1.0);
				$ValueLabelsGradient[$NumGradien]=">$VV";
				my $tttEnd=$EndCountBin+1;
				foreach my $k ($tttEnd..$ValueCount)
				{
					my $VV=$ValueArry[$k];   $ValueToColor{$VV}=$HashConfi_ref->{$Level}{"colormap_high_color"};
					if (exists $ValueToCustomColor_ref->{$VV} ) {$ValueToColor{$VV}=$ValueToCustomColor_ref->{$VV};}
				}
				$NumGradien--;
				$ShiftTmpEnd--;
			}

			my $ShiftTmpStart=0;
			if ($StartCountBin>0)
			{
				my $VV=$ValueArry[$StartCountBin];
				$VV=sprintf ($Precision,$VV*1.0);
				$ValueLabelsGradient[0]="<$VV";
				my $tttEnd=$StartCountBin-1;
				foreach my $k (0..$tttEnd)
				{
					my $VV=$ValueArry[$k];   $ValueToColor{$VV}=$HashConfi_ref->{$Level}{"colormap_low_color"};
					if (exists $ValueToCustomColor_ref->{$VV} ) {$ValueToColor{$VV}=$ValueToCustomColor_ref->{$VV};}
				}
				$NumGradien--;
				$ShiftTmpStart=1;
			}


			my $Diff=($MaxCutValue-$MinCutValue)/($NumGradien+1);
			if ($Diff==0) {$Diff=1;}
			LocalUtils::update_value_color_map(\%ValueToColor,\@ValueArry,\@ColorGradientArray,
			$StartCountBin,$EndCountBin,$MinCutValue,$Diff,$ShiftTmpStart,$ValueToCustomColor_ref);

			my $Shift=$ShiftTmpStart;	
			foreach my $k ($ShiftTmpStart..$ShiftTmpEnd)
			{
				my $MinAA=$MinCutValue+($k-$Shift)*$Diff;
				$MinAA=sprintf ($Precision,$MinAA*1.0);
				$ValueLabelsGradient[$k]="$MinAA";
			}
		}
		else
		{
			my $ShiftTmpEnd=$NumGradien;
			if ($EndCountBin< $ValueCount)
			{
				my $VV=$ValueArry[$EndCountBin];
				$ValueLabelsGradient[$NumGradien]=">$VV";
				my $tttEnd=$EndCountBin+1;
				foreach my $k ($tttEnd..$ValueCount)
				{
					my $VV=$ValueArry[$k];   $ValueToColor{$VV}=$HashConfi_ref->{$Level}{"colormap_high_color"};
					if (exists $ValueToCustomColor_ref->{$VV} ) {$ValueToColor{$VV}=$ValueToCustomColor_ref->{$VV};}
				}
				$NumGradien--;
				$ShiftTmpEnd--;
			}

			my $ShiftTmpStart=0;
			if ($StartCountBin>0)
			{
				my $VV=$ValueArry[$StartCountBin];
				$ValueLabelsGradient[0]="<$VV";
				my $tttEnd=$StartCountBin-1;
				foreach my $k (0..$tttEnd)
				{
					my $VV=$ValueArry[$k];   $ValueToColor{$VV}=$HashConfi_ref->{$Level}{"colormap_low_color"};
					if (exists $ValueToCustomColor_ref->{$VV} ) {$ValueToColor{$VV}=$ValueToCustomColor_ref->{$VV};}
				}
				$NumGradien--;
				$ShiftTmpStart=1;
			}

			my $Diff=($EndCountBin-$StartCountBin)/($NumGradien);
			if ($Diff==0) {$Diff=1;}
			LocalUtils::update_value_color_map2(\%ValueToColor,\@ValueLabelsGradient,\@ValueArry,\@ColorGradientArray,
			$StartCountBin,$EndCountBin,$Diff,$ShiftTmpStart,$ValueToCustomColor_ref);
		}
	}

	if ($ValueToCustomColor_ref)
	{
		my @TmpCol=keys  %{$ValueToCustomColor_ref};
		if ($#TmpCol >=$ValueCount)
		{
			foreach my $yy (0..$GradientSteps)
			{
				my $cc=$ValueLabelsGradient[$yy];
				if  (exists $ValueToCustomColor_ref->{$cc}) { $ColorGradientArray[$yy]=$ValueToCustomColor_ref->{$cc};}
			}
		}
	}





	my $ColorBarSize=$HashConfi_ref->{$Level}{"colormap_legend_sizeratio"}*$color_gradient_scale;
	my $NumPlotArry=$#$PlotInfo+1;
################ Dispatch to appropriate plotting function ######################
	#################### Start  Plot ########
	if (($HashConfi_ref->{$Level}{"plot_type"}  eq  "heatmap")   ||  ($HashConfi_ref->{$Level}{"plot_type"}  eq  "highlights"))	
	{
        LocalUtils::plot_heatmap($HashConfi_ref,\%ValueToColor, $Level, $svg, \%hashYY1, \%hashYY2, \%hashXX1,
			$ChrMax, $NumPlotArry, $PlotInfo, $FileData_ref, $FileRow_ref, $ValueToCustomColor_ref, \@ColorGradientArray,
			\@ValueLabelsGradient, $ColorBarSize, $Bodyheight,$LegendOffsetRatio ,$GradientSteps,$fontsize);
	}
	elsif (( $HashConfi_ref->{$Level}{"plot_type"}  eq  "LinkSelf" )   || ( $HashConfi_ref->{$Level}{"plot_type"}  eq  "LinkS" )   )  
	{
    	LocalUtils::plot_link_self($HashConfi_ref,\%ValueToColor, $Level, $svg, \%hashYY1, \%hashYY2, \%hashXX1, 
            $ChrMax,$NumPlotArry, $PlotInfo, $FileData_ref, $FileRow_ref, $ValueToCustomColor_ref,\@ColorGradientArray,
 	        \@ValueLabelsGradient,$ColorBarSize,$Bodyheight, $LegendOffsetRatio,$GradientSteps,$fontsize);
	}
	elsif (( $HashConfi_ref->{$Level}{"plot_type"}  eq  "pairwiselinkV2" )  || ( $HashConfi_ref->{$Level}{"plot_type"}  eq  "PairWiseLinkV2" ))
	{

    	LocalUtils::plot_pairwiselinkV2($HashConfi_ref,\%ValueToColor, $Level, $svg, \%hashYY1, \%hashYY2, \%hashXX1, 
            $ChrMax,$NumPlotArry, $PlotInfo, $FileData_ref, $FileRow_ref, $ValueToCustomColor_ref,\@ColorGradientArray,
 	        \@ValueLabelsGradient,$ColorBarSize,$Bodyheight, $LegendOffsetRatio,$GradientSteps,$fontsize);

	}


	elsif (( $HashConfi_ref->{$Level}{"plot_type"}  eq  "pairwiselink" )  || ( $HashConfi_ref->{$Level}{"plot_type"}  eq  "PairWiseLink" ))
	{
    	LocalUtils::plot_pairwiselink($HashConfi_ref,\%ValueToColor, $Level, $svg, \%hashYY1, \%hashYY2, \%hashXX1, 
            $ChrMax,$NumPlotArry, $PlotInfo, $FileData_ref, $FileRow_ref, $ValueToCustomColor_ref,\@ColorGradientArray,
 	        \@ValueLabelsGradient,$ColorBarSize,$Bodyheight, $LegendOffsetRatio,$GradientSteps,$fontsize);

	}
	elsif (( $HashConfi_ref->{$Level}{"plot_type"}  eq  "histogram" )  || ( $HashConfi_ref->{$Level}{"plot_type"}  eq  "hist" ))
	{
    	LocalUtils::plot_histogram($HashConfi_ref,\%ValueToColor, $Level, $svg, \%hashYY1, \%hashYY2, \%hashXX1, 
            $ChrMax,$NumPlotArry, $PlotInfo, $FileData_ref, $FileRow_ref, $ValueToCustomColor_ref,\@ColorGradientArray,
 	        \@ValueLabelsGradient,$ColorBarSize,$Bodyheight, $LegendOffsetRatio,$GradientSteps,$fontsize,$ChrArry_ref,$hashChr_ref);

	}
	elsif (($HashConfi_ref->{$Level}{"plot_type"}  eq  "scatter" )  || ( $HashConfi_ref->{$Level}{"plot_type"}  eq  "point" ) || ( $HashConfi_ref->{$Level}{"plot_type"}  eq  "points" ))
	{
		LocalUtils::plot_point($HashConfi_ref,\%ValueToColor, $Level, $svg, \%hashYY1, \%hashYY2, \%hashXX1, 
            $ChrMax,$NumPlotArry, $PlotInfo, $FileData_ref, $FileRow_ref, $ValueToCustomColor_ref,\@ColorGradientArray,
 	        \@ValueLabelsGradient,$ColorBarSize,$Bodyheight, $LegendOffsetRatio,$GradientSteps,
			$fontsize,$ChrArry_ref,$hashChr_ref,$Precision);

	}
	elsif (($HashConfi_ref->{$Level}{"plot_type"}  eq  "shape" )  || ( $HashConfi_ref->{$Level}{"plot_type"}  eq  "shapes" ) || ( $HashConfi_ref->{$Level}{"plot_type"}  eq  "Shape" ))
	{
		LocalUtils::plot_shape($HashConfi_ref,\%ValueToColor, $Level, $svg, \%hashYY1, \%hashYY2, \%hashXX1, 
            $ChrMax,$NumPlotArry, $PlotInfo, $FileData_ref, $FileRow_ref, $ValueToCustomColor_ref,\@ColorGradientArray,
 	        \@ValueLabelsGradient,$ColorBarSize,$Bodyheight, $LegendOffsetRatio,$GradientSteps,
			$fontsize,$ChrArry_ref,$hashChr_ref,$Precision);
	}
	elsif (	($HashConfi_ref->{$Level}{"plot_type"}  eq  "text" )	  )
	{
		LocalUtils::plot_text($HashConfi_ref,\%ValueToColor, $Level, $svg, \%hashYY1, \%hashYY2, \%hashXX1, 
            $ChrMax,$NumPlotArry, $PlotInfo, $FileData_ref, $FileRow_ref, $ValueToCustomColor_ref,\@ColorGradientArray,
 	        \@ValueLabelsGradient,$ColorBarSize,$Bodyheight, $LegendOffsetRatio,$GradientSteps,
			$fontsize,$ChrArry_ref,$hashChr_ref);

	
	}
	elsif (( $HashConfi_ref->{$Level}{"plot_type"}  eq  "ridgeline" ) )
	{
		LocalUtils::plot_ridgeline($HashConfi_ref,\%ValueToColor, $Level, $svg, \%hashYY1, \%hashYY2, \%hashXX1, 
            $ChrMax,$NumPlotArry, $PlotInfo, $FileData_ref, $FileRow_ref, $ValueToCustomColor_ref,\@ColorGradientArray,
 	        \@ValueLabelsGradient,$ColorBarSize,$Bodyheight, $LegendOffsetRatio,$GradientSteps,
			$fontsize,$ChrArry_ref,$hashChr_ref,$Precision);
	}

	elsif (( $HashConfi_ref->{$Level}{"plot_type"}  eq  "lines" )  || ( $HashConfi_ref->{$Level}{"plot_type"}  eq  "line" ))
	{
		LocalUtils::plot_line($HashConfi_ref,\%ValueToColor, $Level, $svg, \%hashYY1, \%hashYY2, \%hashXX1, 
            $ChrMax,$NumPlotArry, $PlotInfo, $FileData_ref, $FileRow_ref, $ValueToCustomColor_ref,\@ColorGradientArray,
 	        \@ValueLabelsGradient,$ColorBarSize,$Bodyheight, $LegendOffsetRatio,$GradientSteps,
			$fontsize,$ChrArry_ref,$hashChr_ref,$Precision);

	}
	elsif (($HashConfi_ref->{$Level}{"plot_type"}  eq  "heatmapAnimated")   ||  ($HashConfi_ref->{$Level}{"plot_type"}  eq  "highlightsAnimated"))
	{
		LocalUtils::plot_heatmap_animated($HashConfi_ref,\%ValueToColor, $Level, $svg, \%hashYY1, \%hashYY2, \%hashXX1, 
            $ChrMax,$NumPlotArry, $PlotInfo, $FileData_ref, $FileRow_ref, $ValueToCustomColor_ref,\@ColorGradientArray,
 	        \@ValueLabelsGradient,$ColorBarSize,$Bodyheight, $LegendOffsetRatio,$GradientSteps,
			$fontsize,$ChrArry_ref,$hashChr_ref,$Precision);
	}
	elsif (( $HashConfi_ref->{$Level}{"plot_type"}  eq  "histogramAnimated" )  || ( $HashConfi_ref->{$Level}{"plot_type"}  eq  "histAnimated" ))
	{
			LocalUtils::plot_histogram_animated($HashConfi_ref,\%ValueToColor, $Level, $svg, \%hashYY1, \%hashYY2, \%hashXX1, 
            $ChrMax,$NumPlotArry, $PlotInfo, $FileData_ref, $FileRow_ref, $ValueToCustomColor_ref,\@ColorGradientArray,
 	        \@ValueLabelsGradient,$ColorBarSize,$Bodyheight, $LegendOffsetRatio,$GradientSteps,
			$fontsize,$ChrArry_ref,$hashChr_ref,$Precision);	
	}

}


return $svg;


}

######################swimming in the sky and flying in the sea ###########################


