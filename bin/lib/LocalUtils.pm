package LocalUtils;
use strict;
use warnings;

our @EXPORT_OK = qw(CheckValueNow svg2PNGfunction );
my $log10=log(10);


####### Applies value constraints (min/max) and optional log transformation######
sub CheckValueNow {
	my ($HashConfi_ref, $Level, $Value) = @_;
	
	if (exists $HashConfi_ref->{$Level}{"cap_max_value"}) {
		if ($Value > $HashConfi_ref->{$Level}{"cap_max_value"}) {
			$Value = $HashConfi_ref->{$Level}{"cap_max_value"};
		}
	}

	if (exists $HashConfi_ref->{$Level}{"cap_min_value"}) {
		if ($Value < $HashConfi_ref->{$Level}{"cap_min_value"}) {
			$Value = $HashConfi_ref->{$Level}{"cap_min_value"};
		}
	}

	if ($HashConfi_ref->{$Level}{"log_p"} != 0) {
		$Value = 0 - log($Value) / $log10;
	}

	return $Value;
}

###### Converts SVG object to PNG using external tools#####
sub svg2PNGfunction
{
	my $HashConfi_ref=shift;
	my $svg=shift;
	my $OutPutHere=shift;
	my $Bin=$HashConfi_ref->{"global"}{Bin};
	my $RealBin=$HashConfi_ref->{"global"}{RealBin};
	if (!($OutPutHere=~s/.svg$/.svg/))
	{
		$OutPutHere=$OutPutHere.".svg";
	}
	open (OUT,">$OutPutHere") || die "input file can't open $!";
	print OUT $svg->xmlify();
	close OUT ;

	print "convert   SVG ---> PNG ...\n";

	my $convert="/usr/bin/convert";
	if  ( !(-e $convert) )
	{
		$convert=`which convert  2> /dev/null `;chomp $convert;
	}

	my $SVG2XXX="$Bin/svg_kit/svg2xxx.pl";
	if  ( !(-e $SVG2XXX ))
	{
		$SVG2XXX="$RealBin/svg_kit/svg2xxx.pl";
	}

	my $bbb = $OutPutHere;
	if ($bbb=~ s/\.svg$/.png/i) 
	{
	}
	else
	{
		($bbb .= ".png");
	}

	my @arryStat=stat($OutPutHere);
	my $convertPara="";
	if  ($HashConfi_ref->{"global"}{"canvas_angle"}!=0)
	{
		$convertPara="-rotate " . $HashConfi_ref->{"global"}{"canvas_angle"} ;
	}
	if (  ( $arryStat[7]   <  500000000 )    &&   (-e $convert)  )
	{
		system (" $convert   $convertPara  $OutPutHere    $bbb   ");
		exit(1);
	}

	if  ( -e $SVG2XXX )
	{
		system ("  perl   $SVG2XXX    $OutPutHere   " );
		exit(1);
	}

	if  ( !(-e $convert) )
	{
		print "Can't find the [ convert ] bin in your \$PATH, You shoud install the [convert] First,then:\t\t";
		print " convert  $OutPutHere    $bbb  \n";
		exit(1);
	}
	else
	{
		system (" $convert $convertPara  $OutPutHere   $bbb ");
	}

}

#### Maps values to colors based on a gradient array#######
sub update_value_color_map {
	my ($hash_value2col_ref, $values_ref, $array_col_ref, $start_bin, $end_bin, $min_cut_value, $diff, $shift_start, $value2self_col_ref) = @_;

	for my $k ($start_bin .. $end_bin) {
		my $vv = $values_ref->[$k];
		my $key = int(($vv - $min_cut_value) / $diff) + $shift_start;
		$hash_value2col_ref->{$vv} = $array_col_ref->[$key];
		if (exists $value2self_col_ref->{$vv}) {
			$hash_value2col_ref->{$vv} = $value2self_col_ref->{$vv};
		}
	}
	return $hash_value2col_ref; 
}


#### Maps values to colors based on a gradient array v2#######
sub update_value_color_map2 {

	my ($hash_value2col_ref, $arry_value_ref,$values_ref, $array_col_ref, $start_bin, $end_bin,$diff, $shift_start, $value2self_col_ref) = @_;
	for my $k ($start_bin .. $end_bin) {
		my $vv = $values_ref->[$k];
		my $k_key = int(($k - $start_bin) / $diff) + $shift_start;

		$hash_value2col_ref->{$vv} = $array_col_ref->[$k_key];
		if (exists $value2self_col_ref->{$vv}) {
			$hash_value2col_ref->{$vv} = $value2self_col_ref->{$vv};
		}

		$arry_value_ref->[$k_key] ||= "$vv";
	}

}

##### Generates an RGB color gradient between start, mid, and end colors######
sub generate_gradient_colors {
	my ($start_rgb, $mid_rgb, $end_rgb, $num_steps, $output_array_ref) = @_;
	@$output_array_ref = ();

	my $mid_steps = int($num_steps / 2);

	for my $i (0 .. $mid_steps) {
		my $r = int($start_rgb->[0] + ($mid_rgb->[0] - $start_rgb->[0]) * $i / $mid_steps);
		my $g = int($start_rgb->[1] + ($mid_rgb->[1] - $start_rgb->[1]) * $i / $mid_steps);
		my $b = int($start_rgb->[2] + ($mid_rgb->[2] - $start_rgb->[2]) * $i / $mid_steps);
		push @$output_array_ref, "rgb($r,$g,$b)";
	}

	for my $i (1 .. ($num_steps - $mid_steps)) {
		my $r = int($mid_rgb->[0] + ($end_rgb->[0] - $mid_rgb->[0]) * $i / ($num_steps - $mid_steps));
		my $g = int($mid_rgb->[1] + ($end_rgb->[1] - $mid_rgb->[1]) * $i / ($num_steps - $mid_steps));
		my $b = int($mid_rgb->[2] + ($end_rgb->[2] - $mid_rgb->[2]) * $i / ($num_steps - $mid_steps));
		push @$output_array_ref, "rgb($r,$g,$b)";
	}

}

####### Computes boundaries for data visualization (e.g., min/max values)###### 
sub compute_data_boundaries {
	my ($value_array, $flag_value_ref, $total_value, $lower_outlier_ratio, $upper_outlier_ratio) = @_;

	my $min_cut_num = $lower_outlier_ratio * $total_value;
	my $max_cut_num = $upper_outlier_ratio * $total_value;
	my ($min_cut_count, $max_cut_count) = (0, 0);
	my $countTemp= $#{$value_array};
	my ($start_idx, $end_idx) = (0,$countTemp);
	if ($countTemp>2)
	{
		foreach my $key (0 .. $countTemp) 
		{
			my $val = $value_array->[$key];
			$min_cut_count += $flag_value_ref->{$val};
			$max_cut_count += $flag_value_ref->{$val};
			$start_idx = $key if $min_cut_count <= $min_cut_num;
			$end_idx = $key if $max_cut_count <= $max_cut_num;
		}
		if ($start_idx == $end_idx)
		{
			$start_idx=0;
			$end_idx=$countTemp;
		}
	}

	my $MinCutValue=$value_array->[$start_idx];	
	my $MaxCutValue=$value_array->[$end_idx];
	return ($start_idx,$end_idx,$MinCutValue, $MaxCutValue);

}

######### Draws a color legend on the SVG canvas ##############
sub draw_color_legend {
	my ($svg, $LegendOffsetRatio, $Bodyheight, $ColorBarSize, $ColorGradientArray_ref, $ValueLabelsGradient_ref, $HashConfi_ref, $Level, $legend_type,$legend_title,$shapeType_ref) = @_;
	my $layout=$HashConfi_ref->{$Level}{"colormap_legend_layout"};
	if ($HashConfi_ref->{$Level}{"colormap_legend_show"} == 0 || $HashConfi_ref->{$Level}{"colormap_legend_sizeratio"} <= 0    || $layout==0) {
		return;
	}
	
	my $stroke_width = $HashConfi_ref->{"global"}{"stroke-width"};
	my $stroke_opacity = $HashConfi_ref->{$Level}{"stroke-opacity"};
	my $fill_opacity = $HashConfi_ref->{$Level}{"fill-opacity"};
	my $max_index_legend=0;
	$ColorBarSize=$ColorBarSize*$HashConfi_ref->{$Level}{"colormap_legend_sizeratio"};
	for (my $k = $#{$ColorGradientArray_ref}; $k >= 0; $k-- )
	{
		if (defined($ValueLabelsGradient_ref->[$k]) && $ValueLabelsGradient_ref->[$k] ne "") 
		{
			$max_index_legend = $k;
			last;
		}
	}

	my $gap=$HashConfi_ref->{global}{colormap_legend_gap};
    my $Legend_Count=$HashConfi_ref->{global}{legend_Count};
	$HashConfi_ref->{global}{legend_Count}++;
	my $gradient_gap = $HashConfi_ref->{$Level}{colormap_gradient_gap} // 0;
	if ($legend_type eq 'shape') 
	{
		$gradient_gap+=2;
	}
	my $ColorBarSize2=$ColorBarSize+$gradient_gap;


	if  ($layout ==1  || $layout ==3 ||  $layout ==5 ||  $layout ==11)
	{
		my $YY1 = $HashConfi_ref->{"global"}{"canvas_margin_top"} + $LegendOffsetRatio * $Bodyheight + $HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
		my $XX1 = $HashConfi_ref->{"global"}{"canvas_margin_left"} + $HashConfi_ref->{"global"}{"canvas_body"} + $Legend_Count * $ColorBarSize * $gap + $HashConfi_ref->{$Level}{"colormap_legend_shift_x"} + ($ColorBarSize*0.68)+1;
		if ($layout ==3)
		{
		  $YY1 = $HashConfi_ref->{"global"}{"canvas_margin_Height"}-$HashConfi_ref->{"global"}{"canvas_margin_bottom"}+$ColorBarSize2*0.68+$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};

		  $XX1 = $HashConfi_ref->{"global"}{"canvas_margin_left"} +$Legend_Count* $ColorBarSize * ($gap+1)+1.5+$HashConfi_ref->{$Level}{"colormap_legend_shift_x"};
		}
		elsif ($layout ==5)
		{
		   my $MaxGradien=$HashConfi_ref->{"global"}{"MaxGradien"}+1;
		   $YY1 = $HashConfi_ref->{"global"}{"canvas_margin_top"} + $HashConfi_ref->{$Level}{"colormap_legend_shift_y"}+$Legend_Count*$MaxGradien*$ColorBarSize2;
		   $XX1 = $HashConfi_ref->{"global"}{"canvas_margin_left"} + $HashConfi_ref->{"global"}{"canvas_body"}  + $HashConfi_ref->{$Level}{"colormap_legend_shift_x"} + ($ColorBarSize*0.68)+1;
		}
		elsif ($layout ==11)
		{
		   my $MaxGradien=$HashConfi_ref->{"global"}{"MaxGradien"}+1;
		   $YY1 = $HashConfi_ref->{"global"}{"canvas_margin_Height"}-$HashConfi_ref->{"global"}{"canvas_margin_bottom"}+$ColorBarSize2*0.68+$HashConfi_ref->{$Level}{"colormap_legend_shift_y"}+$Legend_Count *$MaxGradien*$ColorBarSize2;
		  $XX1 = $HashConfi_ref->{"global"}{"canvas_margin_left"} +1.688+$HashConfi_ref->{$Level}{"colormap_legend_shift_x"};

		}

		my $XX2=$XX1+$ColorBarSize;

		if ($legend_type eq 'rectangle')
		{
			my $YY2=$YY1+$ColorBarSize2*($max_index_legend+1);
			my $path = $svg->get_path(
				x => [$XX1, $XX1, $XX2,$XX2],
				y => [$YY1, $YY2, $YY2,$YY1],
				-type => 'polygon');

			$svg->polygon(
				%$path,
				style => {
					'fill' =>'none',
					'stroke'         => 'black',
					'stroke-width'   =>  $HashConfi_ref->{"global"}{"stroke-width"},
					'stroke-opacity' =>  $HashConfi_ref->{$Level}{"stroke-opacity"},
					'fill-opacity'   =>  $HashConfi_ref->{$Level}{"fill-opacity"},
				},
			);
		}

		if ($legend_title=~s/#//g)
		{
			my $TY=$YY1-1.68;
			my $fontsize=$ColorBarSize*0.95;
				$svg->text(
					'text-anchor', 'start',
					'x', $XX1,
					'y', $TY,
					'-cdata',$legend_title,
					'font-family', 'Arial',
					'font-size', $fontsize
				);
		}



		foreach my $k (0 ..$max_index_legend) {
			next if (!defined($ValueLabelsGradient_ref->[$k]));
			my $current_yy1 = $YY1 + $ColorBarSize2 * $k;
			my $current_yy2 = $current_yy1 + $ColorBarSize;
			if ($legend_type eq 'rectangle') {
				my $path = $svg->get_path(
					x => [$XX1, $XX1, $XX2, $XX2],
					y => [$current_yy1, $current_yy2, $current_yy2, $current_yy1],
					-type => 'polygon'
				);
				$svg->polygon(%$path, style => {
						'fill' => "$ColorGradientArray_ref->[$k]",
						'stroke' => 'black',
						'stroke-width' => 0,
						'stroke-opacity' => $stroke_opacity,
						'fill-opacity' => $fill_opacity,
					});
			}
			elsif ($legend_type eq 'shape') {
				ColorPaletteManager::SVGgetShape($XX1+$ColorBarSize * 0.5, $current_yy1 + $ColorBarSize2 * 0.5, $ColorBarSize * 0.5, $shapeType_ref->[$k], $ColorGradientArray_ref->[$k], $svg);
			}
			elsif ($legend_type eq 'lines') {
				$svg->line('x1',$XX1,'y1',$current_yy1,'x2',$XX2,'y2',$current_yy2,'stroke',$ColorGradientArray_ref->[$k],'stroke-width',$stroke_width);
			}
			elsif ($legend_type eq 'circle') {
				$svg->circle(
					cx => $XX1 + $ColorBarSize / 2,
					cy => $current_yy1+$ColorBarSize2 / 2,
					r  => $ColorBarSize * 0.45,
					fill => "$ColorGradientArray_ref->[$k]"
				);
			}
			elsif ($legend_type eq 'text-only') {
				$svg->text(
					'text-anchor', 'start',
					'x', $XX1 +1.5, 
					'y', $current_yy2,
					'-cdata', "$ValueLabelsGradient_ref->[$k]",
					'font-family', 'Arial',
					'font-size', $ColorBarSize,
					'font-weight',"bold",
					'fill', $ColorGradientArray_ref->[$k]
					#'stroke', $ColorGradientArray_ref->[$k]
				);
			}

			# 绘制文本标签（如果需要）
			unless ($legend_type eq 'text-only') {
				$svg->text(
					'text-anchor', 'start',
					'x', $XX2  + 1.5,
					'y', $current_yy2,
					'-cdata', "$ValueLabelsGradient_ref->[$k]",
					'font-family', 'Arial',
					'font-size', $ColorBarSize
				);
			}
		}
	}
	elsif ($layout ==2 || $layout ==4  || $layout ==12 )
	{
		my $YY2 = $HashConfi_ref->{"global"}{"canvas_margin_Height"}-$ColorBarSize*1.5+$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
		my $MaxGradien=$HashConfi_ref->{"global"}{"MaxGradien"}+1;

		my $XX1 = $HashConfi_ref->{"global"}{"canvas_margin_left"} +$Legend_Count* $ColorBarSize2 * $MaxGradien+1.5+$HashConfi_ref->{$Level}{"colormap_legend_shift_x"};

		if ($layout==2)
		{
		  $YY2 = $HashConfi_ref->{"global"}{"canvas_margin_top"}+($Legend_Count+1)*$ColorBarSize * $gap + $LegendOffsetRatio * $Bodyheight + $HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
		  $XX1 = $HashConfi_ref->{"global"}{"canvas_margin_left"} + $HashConfi_ref->{"global"}{"canvas_body"} + $HashConfi_ref->{$Level}{"colormap_legend_shift_x"} + ($ColorBarSize2*0.68)+1;
		}
		elsif ($layout==12)
		{
		  $YY2 = $HashConfi_ref->{"global"}{"canvas_margin_Height"}-$HashConfi_ref->{"global"}{"canvas_margin_bottom"}+($Legend_Count+1)*$ColorBarSize * $gap+$ColorBarSize*1.5+$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
		  $XX1 = $HashConfi_ref->{"global"}{"canvas_margin_left"} +1.688+$HashConfi_ref->{$Level}{"colormap_legend_shift_x"};
		}

		 my $YY1=$YY2-$ColorBarSize;

		if ($legend_type eq 'rectangle')
		{
			my $XX2=$XX1+$ColorBarSize*($max_index_legend+1);
			my $path = $svg->get_path(
				x => [$XX1, $XX2, $XX2,$XX1],
				y => [$YY1, $YY1, $YY2,$YY2],
				-type => 'polygon');
			
			$svg->polygon(
				%$path,
				style => {
					'fill' =>'none',
					'stroke'         => 'black',
					'stroke-width'   =>  $HashConfi_ref->{"global"}{"stroke-width"},
					'stroke-opacity' =>  $HashConfi_ref->{$Level}{"stroke-opacity"},
					'fill-opacity'   =>  $HashConfi_ref->{$Level}{"fill-opacity"},
				},
			);
		}
		if ($legend_title=~s/#//g)
		{
			my $TY=$YY2;
			my $TX=$XX1-1.68;
			my $fontsize=$ColorBarSize*0.95;
				$svg->text(
					'text-anchor', 'start',
					'x', $TX,
					'y', $TY,
					'-cdata',$legend_title,
					'font-family', 'Arial',
					'font-size', $fontsize,
					'transform', "rotate(-90,$TX,$TY)"
				);
		}






		foreach my $k (0 ..$max_index_legend) {
			next if (!defined($ValueLabelsGradient_ref->[$k]));
			my $current_XX1 = $XX1 + $ColorBarSize2 * $k;
			my $current_XX2 = $current_XX1 + $ColorBarSize;
			if ($legend_type eq 'rectangle') {
				my $path = $svg->get_path(
					x => [$current_XX1, $current_XX2, $current_XX2, $current_XX1],
					y => [$YY1, $YY1, $YY2, $YY2],
					-type => 'polygon'
				);
				$svg->polygon(%$path, style => {
						'fill' => "$ColorGradientArray_ref->[$k]",
						'stroke' => 'black',
						'stroke-width' => 0,
						'stroke-opacity' => $stroke_opacity,
						'fill-opacity' => $fill_opacity,
					});
			}
			elsif ($legend_type eq 'shape') {
				ColorPaletteManager::SVGgetShape($current_XX1+$ColorBarSize2 * 0.5, $YY2 + $ColorBarSize * 0.5, $ColorBarSize * 0.5, $shapeType_ref->[$k], $ColorGradientArray_ref->[$k], $svg);
			}
			elsif ($legend_type eq 'lines') {
				$svg->line('x1',$current_XX1,'y1',$YY2,'x2',$current_XX2,'y2',$YY1,'stroke',$ColorGradientArray_ref->[$k],'stroke-width',$stroke_width);
			}
			elsif ($legend_type eq 'circle') {
				$svg->circle(
					cx => $YY1 + $ColorBarSize2 / 2,
					cy => $current_XX1+$ColorBarSize / 2,
					r  => $ColorBarSize * 0.45,
					fill => "$ColorGradientArray_ref->[$k]"
				);
			}
			elsif ($legend_type eq 'text-only') {
				my $XXNow=$current_XX2;
				my $YYNow=$YY2;
				$svg->text(
					'text-anchor', 'start',
					'x', $XXNow, 
					'y', $YYNow,
					'-cdata', "$ValueLabelsGradient_ref->[$k]",
					'font-family', 'Arial',
					'font-size', $ColorBarSize,
					'font-weight',"bold",
					'fill', $ColorGradientArray_ref->[$k],
					'transform', "rotate(-90,$XXNow,$YYNow)"
				);
			}

			unless ($legend_type eq 'text-only') {
				my $XXNow=$current_XX2;
				my $YYNow=$YY1-1.5;
				$svg->text(
					'text-anchor', 'start',
					'x', $XXNow,
					'y', $YYNow,
					'-cdata', "$ValueLabelsGradient_ref->[$k]",
					'font-family', 'Arial',
					'font-size', $ColorBarSize,
					'transform', "rotate(-90,$XXNow,$YYNow)"
				);
			}
		}
	}
	elsif  ($layout ==6  || $layout ==8 ||  $layout ==10 )
	{
		my $YY1 = $HashConfi_ref->{"global"}{"canvas_margin_top"} + $LegendOffsetRatio * $Bodyheight + $HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
		my $XX1 = $HashConfi_ref->{"global"}{"canvas_margin_left"} + $HashConfi_ref->{"global"}{"canvas_body"} + $Legend_Count * $ColorBarSize * $gap + $HashConfi_ref->{$Level}{"colormap_legend_shift_x"} + ($ColorBarSize*0.68)+1;
		if ($layout ==8)
		{
		  $YY1 = $HashConfi_ref->{"global"}{"canvas_margin_Height"}-$HashConfi_ref->{"global"}{"canvas_margin_bottom"}+$ColorBarSize2*0.68+$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};

		  $XX1 = $HashConfi_ref->{"global"}{"canvas_margin_left"} +$Legend_Count* $ColorBarSize * ($gap+1)+1.5+$HashConfi_ref->{$Level}{"colormap_legend_shift_x"};
		}
		elsif ($layout ==10)
		{
		   my $MaxGradien=$HashConfi_ref->{"global"}{"MaxGradien"}+1;
		   $YY1 = $HashConfi_ref->{"global"}{"canvas_margin_top"} + $HashConfi_ref->{$Level}{"colormap_legend_shift_y"}+$Legend_Count*$MaxGradien*$ColorBarSize2;
		   $XX1 = $HashConfi_ref->{"global"}{"canvas_margin_left"} + $HashConfi_ref->{"global"}{"canvas_body"}  + $HashConfi_ref->{$Level}{"colormap_legend_shift_x"} + ($ColorBarSize*0.68)+1;

		}

		$XX1+=$ColorBarSize *($gap-1);
		my $XX2=$XX1+$ColorBarSize;

		if ($legend_type eq 'rectangle')
		{
			my $YY2=$YY1+$ColorBarSize2*($max_index_legend+1);
			my $path = $svg->get_path(
				x => [$XX1, $XX1, $XX2,$XX2],
				y => [$YY1, $YY2, $YY2,$YY1],
				-type => 'polygon');

			$svg->polygon(
				%$path,
				style => {
					'fill' =>'none',
					'stroke'         => 'black',
					'stroke-width'   =>  $HashConfi_ref->{"global"}{"stroke-width"},
					'stroke-opacity' =>  $HashConfi_ref->{$Level}{"stroke-opacity"},
					'fill-opacity'   =>  $HashConfi_ref->{$Level}{"fill-opacity"},
				},
			);
		}


		if ($legend_title=~s/#//g)
		{
			my $TY=$YY1-1.68;
			my $fontsize=$ColorBarSize*0.95;
				$svg->text(
					'text-anchor', 'end',
					'x', $XX2,
					'y', $TY,
					'-cdata',$legend_title,
					'font-family', 'Arial',
					'font-size', $fontsize
				);
		}


		foreach my $k (0 ..$max_index_legend) {
			next if (!defined($ValueLabelsGradient_ref->[$k]));
			my $current_yy1 = $YY1 + $ColorBarSize2 * $k;
			my $current_yy2 = $current_yy1 + $ColorBarSize;
			if ($legend_type eq 'rectangle') {
				my $path = $svg->get_path(
					x => [$XX1, $XX1, $XX2, $XX2],
					y => [$current_yy1, $current_yy2, $current_yy2, $current_yy1],
					-type => 'polygon'
				);
				$svg->polygon(%$path, style => {
						'fill' => "$ColorGradientArray_ref->[$k]",
						'stroke' => 'black',
						'stroke-width' => 0,
						'stroke-opacity' => $stroke_opacity,
						'fill-opacity' => $fill_opacity,
					});
			}
			elsif ($legend_type eq 'shape') {
				ColorPaletteManager::SVGgetShape($XX1+$ColorBarSize * 0.5, $current_yy1 + $ColorBarSize2 * 0.5, $ColorBarSize * 0.5, $shapeType_ref->[$k], $ColorGradientArray_ref->[$k], $svg);
			}
			elsif ($legend_type eq 'lines') {
				$svg->line('x1',$XX1,'y1',$current_yy1,'x2',$XX2,'y2',$current_yy2,'stroke',$ColorGradientArray_ref->[$k],'stroke-width',$stroke_width);
			}
			elsif ($legend_type eq 'circle') {
				$svg->circle(
					cx => $XX1 + $ColorBarSize / 2,
					cy => $current_yy1+$ColorBarSize2 / 2,
					r  => $ColorBarSize * 0.45,
					fill => "$ColorGradientArray_ref->[$k]"
				);
			}
			elsif ($legend_type eq 'text-only') {
				$svg->text(
					'text-anchor', 'end',
					'x', $XX2 -1.5, 
					'y', $current_yy2,
					'-cdata', "$ValueLabelsGradient_ref->[$k]",
					'font-family', 'Arial',
					'font-size', $ColorBarSize,
					'font-weight',"bold",
					'fill', $ColorGradientArray_ref->[$k]
				);
			}

			unless ($legend_type eq 'text-only') {
				$svg->text(
					'text-anchor', 'end',
					'x', $XX1  - 1.5,
					'y', $current_yy2,
					'-cdata', "$ValueLabelsGradient_ref->[$k]",
					'font-family', 'Arial',
					'font-size', $ColorBarSize
				);
			}
		}
	}
	elsif ($layout ==7 || $layout ==9  ||   $layout ==13 )
	{
		my $YY2 = $HashConfi_ref->{"global"}{"canvas_margin_Height"}-$ColorBarSize*1.5+$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
		my $MaxGradien=$HashConfi_ref->{"global"}{"MaxGradien"}+1;

		my $XX1 = $HashConfi_ref->{"global"}{"canvas_margin_left"} +$Legend_Count* $ColorBarSize2 * $MaxGradien+1.5+$HashConfi_ref->{$Level}{"colormap_legend_shift_x"};

		if ($layout==7)
		{
		  $YY2 = $HashConfi_ref->{"global"}{"canvas_margin_top"}+($Legend_Count+1)*$ColorBarSize * $gap + $LegendOffsetRatio * $Bodyheight + $HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
		  $XX1 = $HashConfi_ref->{"global"}{"canvas_margin_left"} + $HashConfi_ref->{"global"}{"canvas_body"} + $HashConfi_ref->{$Level}{"colormap_legend_shift_x"} + ($ColorBarSize2*0.68)+1;
		}
		elsif ($layout==13)
		{
		   $YY2 = $HashConfi_ref->{"global"}{"canvas_margin_Height"}-$HashConfi_ref->{"global"}{"canvas_margin_bottom"}+($Legend_Count+1.2)*$ColorBarSize * $gap+$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
		   $XX1 = $HashConfi_ref->{"global"}{"canvas_margin_left"} +1.688+$HashConfi_ref->{$Level}{"colormap_legend_shift_x"};
		}

		    $YY2=$YY2-$ColorBarSize *($gap-1);
		 my $YY1=$YY2-$ColorBarSize;

		if ($legend_type eq 'rectangle')
		{
			my $XX2=$XX1+$ColorBarSize2*($max_index_legend+1);
			my $path = $svg->get_path(
				x => [$XX1, $XX2, $XX2,$XX1],
				y => [$YY1, $YY1, $YY2,$YY2],
				-type => 'polygon');
			
			$svg->polygon(
				%$path,
				style => {
					'fill' =>'none',
					'stroke'         => 'black',
					'stroke-width'   =>  $HashConfi_ref->{"global"}{"stroke-width"},
					'stroke-opacity' =>  $HashConfi_ref->{$Level}{"stroke-opacity"},
					'fill-opacity'   =>  $HashConfi_ref->{$Level}{"fill-opacity"},
				},
			);
		}
		if ($legend_title=~s/#//g)
		{
			my $TY=$YY2;
			my $TX=$XX1-1.68;
			my $fontsize=$ColorBarSize*0.95;
				$svg->text(
					'text-anchor', 'end',
					'x', $TX,
					'y', $TY,
					'-cdata',$legend_title,
					'font-family', 'Arial',
					'font-size', $fontsize,
					'transform', "rotate(-90,$TX,$TY)"
				);
		}


		foreach my $k (0 ..$max_index_legend) {
			next if (!defined($ValueLabelsGradient_ref->[$k]));
			my $current_XX1 = $XX1 + $ColorBarSize2 * $k;
			my $current_XX2 = $current_XX1 + $ColorBarSize;
			if ($legend_type eq 'rectangle') {
				my $path = $svg->get_path(
					x => [$current_XX1, $current_XX2, $current_XX2, $current_XX1],
					y => [$YY1, $YY1, $YY2, $YY2],
					-type => 'polygon'
				);
				$svg->polygon(%$path, style => {
						'fill' => "$ColorGradientArray_ref->[$k]",
						'stroke' => 'black',
						'stroke-width' => 0,
						'stroke-opacity' => $stroke_opacity,
						'fill-opacity' => $fill_opacity,
					});
			}
			elsif ($legend_type eq 'shape') {
				ColorPaletteManager::SVGgetShape($current_XX1+$ColorBarSize2 * 0.5, $YY2 + $ColorBarSize2 * 0.5, $ColorBarSize * 0.5, $shapeType_ref->[$k], $ColorGradientArray_ref->[$k], $svg);
			}
			elsif ($legend_type eq 'lines') {
				$svg->line('x1',$current_XX1,'y1',$YY2,'x2',$current_XX2,'y2',$YY1,'stroke',$ColorGradientArray_ref->[$k],'stroke-width',$stroke_width);
			}
			elsif ($legend_type eq 'circle') {
				$svg->circle(
					cx => $YY1 + $ColorBarSize2 / 2,
					cy => $current_XX1+$ColorBarSize / 2,
					r  => $ColorBarSize * 0.45,
					fill => "$ColorGradientArray_ref->[$k]"
				);
			}
			elsif ($legend_type eq 'text-only') {
				my $XXNow=$current_XX2;
				my $YYNow=$YY1;
				$svg->text(
					'text-anchor', 'end',
					'x', $XXNow, 
					'y', $YYNow,
					'-cdata', "$ValueLabelsGradient_ref->[$k]",
					'font-family', 'Arial',
					'font-size', $ColorBarSize,
					'font-weight',"bold",
					'fill', $ColorGradientArray_ref->[$k],
					'transform', "rotate(-90,$XXNow,$YYNow)"
				);
			}

			unless ($legend_type eq 'text-only') {
				my $XXNow=$current_XX2;
				my $YYNow=$YY2+1.5;
				$svg->text(
					'text-anchor', 'end',
					'x', $XXNow,
					'y', $YYNow,
					'-cdata', "$ValueLabelsGradient_ref->[$k]",
					'font-family', 'Arial',
					'font-size', $ColorBarSize,
					'transform', "rotate(-90,$XXNow,$YYNow)"
				);
			}
		}
	}



}



#####################   yaxis_tick_show  ###################
sub draw_yaxis_ticks {
	my ($HashConfi_ref, $Level, $ChrArry_ref, $hashYY1_ref, $hashYY2_ref, $svg, $fontsize) = @_;
	my $YMax=$HashConfi_ref->{$Level}{"Ymax"};
	my $YMin=$HashConfi_ref->{$Level}{"Ymin"};
	my $StartYLevel = $YMin * 1.0;
	my $EndYLevel   = $YMax * 1.0;
	my $countTmpChr = $#$ChrArry_ref;
	if ($HashConfi_ref->{"global"}{"chr_orientation"} ne "vertical") {
		$countTmpChr = 0;
	}
	my $tick_precision =0;
	if (($YMax=~ /^-?\d+$/)   &&  ($YMin=~ /^-?\d+$/) )
	{			
	}
	else
	{
		my @tmp=split /\./,$YMax;
		if (length($tmp[-1])>4)
		{
			$tick_precision=2;
		}
		else
		{
			$tick_precision=1;
		}
	}
	if  (exists   $HashConfi_ref->{$Level}{"yaxis_tick_precision"} )
	{
		$tick_precision = $HashConfi_ref->{$Level}{"yaxis_tick_precision"} ;
	}
	my $strokewidth = $HashConfi_ref->{$Level}{"yaxis_tick_strokewidth"} || 1;

	foreach my $thisChr (0 .. $countTmpChr) 
	{
		my $ThisChrName = $ChrArry_ref->[$thisChr];
		my $XX2 = $HashConfi_ref->{"global"}{"canvas_margin_left"} - $fontsize * 0.5;
		my $YY1 = $hashYY1_ref->{$ThisChrName}{$Level} ;#+ $fontsize * 0.1;
		my $YY2 = $hashYY2_ref->{$ThisChrName}{$Level} ;#- $fontsize * 0.1;
		my $height = $YY2 - $YY1;
		my $tick_num = 5;
		if (exists $HashConfi_ref->{$Level}{"yaxis_tick_num"})
		{
			$tick_num = $HashConfi_ref->{$Level}{"yaxis_tick_num"};
		}
		elsif($height<=20)
		{
			$tick_num=2;
		}
		elsif($height<90)
		{
			$tick_num=int($height/20)+1;
		}
		my $tick_unit = $HashConfi_ref->{$Level}{"yaxis_tick_unit"} || (($EndYLevel - $StartYLevel) / ($tick_num - 1));
		$svg->line(
			'x1', $XX2,
			'y1', $YY1,
			'x2', $XX2,
			'y2', $YY2,
			'stroke', 'black',  # 刻度线颜色
			'stroke-width', $strokewidth   # 刻度线宽度
		);

		my $tick_length = $fontsize * 0.2;  # 刻度线长度
		if  (exists $HashConfi_ref->{$Level}{"yaxis_tick_direction"} )
		{
			$XX2=$XX2 - $tick_length;
		}

		for (my $i = 0; $i < $tick_num; $i++)
		{
			my $tick_value = $StartYLevel + $i * $tick_unit;
			my $formatted_value = sprintf("%.${tick_precision}f", $tick_value);
			my $y_pos = $YY2 - ($i * ($height / ($tick_num - 1)));

			# 绘制刻度线
			my $tick_start_x = $XX2 + $tick_length;
			my $tick_end_x = $XX2;
			$svg->line(
				'x1', $tick_start_x,
				'y1', $y_pos,
				'x2', $tick_end_x,
				'y2', $y_pos,
				'stroke', 'black',  # 刻度线颜色
				'stroke-width', $strokewidth   # 刻度线宽度
			);

			# 绘制刻度文本
			$svg->text(
				'text-anchor', 'end',
				'x', $XX2-$fontsize * 0.1,
				'y', $y_pos+$fontsize * 0.1,
				'-cdata', $formatted_value,
				'font-family', $HashConfi_ref->{"global"}{"font-family"},
				'font-size', $fontsize * 0.32
			);
		}
	}

}






###### Plots heatmap based on data values across chromosomes###
sub plot_heatmap {
	my ($HashConfi_ref,$ValueToColor_ref, $Level, $svg, $hashYY1_ref, $hashYY2_ref, $hashXX1_ref, $ChrMax, $NumPlotArry, $PlotInfo_ref, $FileData_ref, $FileRow_ref, $ValueToCustomColor_ref, $ColorGradientArray_ref, $ValueLabelsGradient_ref, $ColorBarSize, $Bodyheight,$LegendOffsetRatio ,$GradientSteps,$fontsize) = @_;

	my $path;

	my $YY1 = $HashConfi_ref->{"global"}{"canvas_margin_top"} + $LegendOffsetRatio * $Bodyheight + $HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
	my $YY2 = $YY1 + $ColorBarSize * ($GradientSteps + 1);
	my $XX1 = $HashConfi_ref->{"global"}{"canvas_margin_left"} + $HashConfi_ref->{"global"}{"canvas_body"} + ($Level - 1) * $ColorBarSize * 4.5 + $HashConfi_ref->{$Level}{"colormap_legend_shift_x"} ;
	my $XX2 = $XX1 + $ColorBarSize;
	my $headLT="heatmap";
	if  ($NumPlotArry>1)
	{
		@$ColorGradientArray_ref = @$ColorGradientArray_ref[0..($NumPlotArry - 1)];
	}
	else
	{
	   my $NowPlotLT = $PlotInfo_ref->[0];
	   my $FileNowLT = $NowPlotLT->[0];
	   my $CoumnNowLT = $NowPlotLT->[1];
	   $headLT=$FileData_ref->[$FileNowLT][0][$CoumnNowLT];
	}

	draw_color_legend($svg,$LegendOffsetRatio, $Bodyheight, $ColorBarSize, $ColorGradientArray_ref, $ValueLabelsGradient_ref, $HashConfi_ref, $Level, 'rectangle',$headLT);

	my $HeatMapstrokewidth = $HashConfi_ref->{$Level}{"stroke-width"};

	foreach my $tmpkk (1..$NumPlotArry) {
		my $ThisBoxbin = $tmpkk - 1;
		my $NowPlot = $PlotInfo_ref->[$ThisBoxbin];
		my $FileNow = $NowPlot->[0];
		my $CoumnNow = $NowPlot->[1];
		my $StartCount = 0;

		if ($FileData_ref->[$FileNow][0][0] =~ s/#/#/) {
			$StartCount = 1;
		}

		for (; $StartCount < $FileRow_ref->[$FileNow]; $StartCount++) {
			my $Value = $FileData_ref->[$FileNow][$StartCount][$CoumnNow];
			next if ($Value eq "NA");
			$Value = CheckValueNow($HashConfi_ref, $Level, $Value);

			my $ThisChrName = $FileData_ref->[$FileNow][$StartCount][0];
			next unless exists $hashYY1_ref->{$ThisChrName};

			my $StartSite = $FileData_ref->[$FileNow][$StartCount][1];
			my $EndSite   = $FileData_ref->[$FileNow][$StartCount][2];

			my $YY1 = $hashYY1_ref->{$ThisChrName}{$Level};
			my $YY2 = $hashYY2_ref->{$ThisChrName}{$Level};
			my $binYYHeat = ($YY2 - $YY1) / $NumPlotArry;
			$YY1 += $ThisBoxbin * $binYYHeat;
			$YY2 = $YY1 + $binYYHeat;

			if (exists $ValueToCustomColor_ref->{$Value}){
				$ValueToColor_ref->{$Value} = $ValueToCustomColor_ref->{$Value};
			}

			my $XX1 = sprintf("%.1f", ($StartSite / $ChrMax) * $HashConfi_ref->{"global"}{"canvas_bodyOO"} + $hashXX1_ref->{$ThisChrName}{$Level});
			my $XX2 = sprintf("%.1f", ($EndSite / $ChrMax) * $HashConfi_ref->{"global"}{"canvas_bodyOO"} + $hashXX1_ref->{$ThisChrName}{$Level});
			$path = $svg->get_path(x => [$XX1, $XX1, $XX2, $XX2], y => [$YY1, $YY2, $YY2, $YY1], -type => 'polygon');
			$svg->polygon(%$path, style => {
					'fill' => $ValueToColor_ref->{$Value},
					'stroke' => $ValueToColor_ref->{$Value},
					'stroke-width' => $HeatMapstrokewidth,
					'stroke-opacity' => $HashConfi_ref->{$Level}{"stroke-opacity"},
					'fill-opacity' => $HashConfi_ref->{$Level}{"fill-opacity"},
				});
		}
	}
}



#####Plots linkage map based on data values across chromosomes######
sub plot_link_self {
	my ($HashConfi_ref,$ValueToColor_ref, $Level, $svg, $hashYY1_ref, $hashYY2_ref, $hashXX1_ref,$ChrMax,$NumPlotArry, 
		$PlotInfo, $FileData_ref, $FileRow_ref, $ValueToCustomColor_ref,$ColorGradientArray_ref, $ValueLabelsGradient_ref,$ColorBarSize, 
		$Bodyheight, $LegendOffsetRatio, $GradientSteps,$fontsize)=@_;

	my $HHstrokewidth = $HashConfi_ref->{$Level}{"stroke-width"};

	if ( $HashConfi_ref->{$Level}{"track_height"} < 25 ) {
		print "Bad at Track(Level) $Level  For  [-PType]  is  [LinkS] , For LinkS the input  [ChrWidth] is Suggest to be biger, like ChrWidth=100 \n";
	}

	if ( ($HashConfi_ref->{$Level}{"background_color"}  eq  "#FFFFFF" ) ||  
		( exists $HashConfi_ref->{$Level}{"background_show"}  && $HashConfi_ref->{$Level}{"background_show"} == 0 ) ) {
		# Background is white or not shown
	} else {
		print "Wartning at Track(Level) $Level  For  [-PType]  is  [LinkS] , For LinkS the input  [background_show] is Suggest to be 0, like background_show=0 \n";
	}

	my $LineType = 1;
	if ((exists $HashConfi_ref->{$Level}{"link_linestyle"}) && ($HashConfi_ref->{$Level}{"link_linestyle"} eq "line")) {
		$LineType = 0;
	}

	my $YY1 = $HashConfi_ref->{"global"}{"canvas_margin_top"} + $LegendOffsetRatio * $Bodyheight + 
	$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
	my $YY2 = $YY1 + $ColorBarSize * ($GradientSteps + 1);
	my $XX1 = $HashConfi_ref->{"global"}{"canvas_margin_left"} + $HashConfi_ref->{"global"}{"canvas_body"} + 
	($Level - 1) * $ColorBarSize * 4.5 + $HashConfi_ref->{$Level}{"colormap_legend_shift_x"};
	my $XX2 = $XX1 + $ColorBarSize;



	my $HeatMapstrokewidth = $HashConfi_ref->{$Level}{"stroke-width"};

	my $NowPlot = $PlotInfo->[0];
	my $FileNow = $NowPlot->[0];
	my $CoumnNow = $NowPlot->[1];
	my $B1 = $CoumnNow + 1; 
	my $B2 = $CoumnNow + 2; 
	my $B3 = $CoumnNow + 3; 
	
	draw_color_legend($svg,$LegendOffsetRatio, $Bodyheight, $ColorBarSize, $ColorGradientArray_ref, $ValueLabelsGradient_ref, $HashConfi_ref, $Level, 'rectangle',"#LinkS");

	if ($NumPlotArry != 4) {
		print "Bad at Track(Level) $Level  For  [-PType]  is  [LinkS] , For LinkS the input  CoumnNow  must be 4 (Value chrB StartB EndB)\n";
		print " so you can set the  [  show_columns=File$FileNow:$CoumnNow  File$FileNow:$B1   File$FileNow:$B2   File$FileNow:$B3   ]\n";
		return;
	} else {
		my ($NowPlot1, $NowPlot2, $NowPlot3) = ($PlotInfo->[1], $PlotInfo->[2], $PlotInfo->[3]);
		my ($FileNow1, $FileNow2, $FileNow3) = ($NowPlot1->[0], $NowPlot2->[0], $NowPlot3->[0]);

		if ($FileNow != $FileNow1 || $FileNow != $FileNow2 || $FileNow != $FileNow3) {
			print "Bad at Track(Level) $Level  For  [-PType]  is  [LinkS] , For LinkS the input  CoumnNow  must be 4 (Value chrB StartB EndB),and the File must be the same\n";
			print " so you can set the para like as   [  show_columns=File$FileNow:$CoumnNow,$B1,$B2,$B3 ]\n";
			return;
		}

		($B1, $B2, $B3) = ($NowPlot1->[1], $NowPlot2->[1], $NowPlot3->[1]);
	}

	my $StartCount = defined($FileData_ref->[$FileNow][0][0]) && $FileData_ref->[$FileNow][0][0] =~ s/#/#/ ? 1 : 0;

	if ($LineType == 0) {
		for (; $StartCount < $FileRow_ref->[$FileNow]; $StartCount++) {
			my $Value = $FileData_ref->[$FileNow][$StartCount][$CoumnNow];
			next if $Value eq "NA";
			$Value =CheckValueNow($HashConfi_ref, $Level, $Value);

			my $ThisChrName = $FileData_ref->[$FileNow][$StartCount][0];
			next unless exists $hashYY1_ref->{$ThisChrName};

			my $StartA = $FileData_ref->[$FileNow][$StartCount][1];
			my $EndA   = $FileData_ref->[$FileNow][$StartCount][2];

			my $chrB = $FileData_ref->[$FileNow][$StartCount][$B1];
			my $StartB = $FileData_ref->[$FileNow][$StartCount][$B2];
			my $EndB   = $FileData_ref->[$FileNow][$StartCount][$B3];
			next unless exists $hashYY1_ref->{$chrB};

			my $ZRTF = 1;
			if (exists $HashConfi_ref->{"global"}{"chr_zoom_region"}) {
				my $regionArry = $HashConfi_ref->{"global"}{"chr_zoom_region"};

				$ZRTF = 0;
				next if $chrB ne $$regionArry[0];
				next if ($StartB < $$regionArry[1] && $EndB < $$regionArry[1]);
				next if ($StartB > $$regionArry[2] && $EndB > $$regionArry[2]);
				$ZRTF = 1;

				# Handle zoom region adjustments
				if ($StartB >= $$regionArry[1] && $StartB <= $$regionArry[2]) {
					$StartB = $StartB - $$regionArry[1] + 1;
				} elsif ($StartB < $$regionArry[1]) {
					$StartB = 1;
				} else {
					$StartB = $$regionArry[2] - $$regionArry[1] + 1;
				}

				if ($EndB >= $$regionArry[1] && $EndB <= $$regionArry[2]) {
					$EndB = $EndB - $$regionArry[1] + 1;
				} elsif ($EndB < $$regionArry[1]) {
					$EndB = 1;
				} else {
					$EndB = $$regionArry[2] - $$regionArry[1] + 1;
				}
			}

			next if $ZRTF != 1;

			my $YY1 = $hashYY1_ref->{$ThisChrName}{$Level};
			my $YY2 = $hashYY2_ref->{$ThisChrName}{$Level};
			my $YY1_AA = $YY1;
			my $YY2_AA = $YY1;
			my $XStart_AA = sprintf("%.1f", ($StartA / $ChrMax) * 
				$HashConfi_ref->{"global"}{"canvas_bodyOO"} + 
				$hashXX1_ref->{$ThisChrName}{$Level});
			my $XEnd_AA = sprintf("%.1f", ($EndA / $ChrMax) * 
				$HashConfi_ref->{"global"}{"canvas_bodyOO"} + 
				$hashXX1_ref->{$ThisChrName}{$Level});

			my $YY1_BB = $YY2;
			my $YY2_BB = $YY2;
			my $XStart_BB = sprintf("%.1f", ($StartB / $ChrMax) * 
				$HashConfi_ref->{"global"}{"canvas_bodyOO"} + 
				$hashXX1_ref->{$chrB}{$Level});
			my $XEnd_BB = sprintf("%.1f", ($EndB / $ChrMax) * 
				$HashConfi_ref->{"global"}{"canvas_bodyOO"} + 
				$hashXX1_ref->{$chrB}{$Level});

			if (exists $ValueToCustomColor_ref->{$Value}) {
				$ValueToColor_ref->{$Value} = $ValueToCustomColor_ref->{$Value};
			}

			my $path = $svg->get_path(
				x => [$XStart_AA, $XEnd_AA, $XEnd_BB, $XStart_BB],
				y => [$YY2_AA, $YY2_AA, $YY1_BB, $YY1_BB],
				-type => 'polygon'
			);

			$svg->polygon(
				%$path,
				style => {
					'opacity' => $HashConfi_ref->{$Level}{"stroke-opacity"},
					'fill' => $ValueToColor_ref->{$Value},
					'fill-opacity' => $HashConfi_ref->{$Level}{"fill-opacity"},
					'stroke' => $ValueToColor_ref->{$Value},
					'stroke-width' => $HHstrokewidth,
					'stroke-opacity' => $HashConfi_ref->{$Level}{"stroke-opacity"}
				}
			);
		}
	}      
	else
	{

		for ( ; $StartCount<$FileRow_ref->[$FileNow]; $StartCount++)
		{
			my $Value=$FileData_ref->[$FileNow][$StartCount][$CoumnNow];
			next if  ($Value eq "NA");

			$Value=CheckValueNow($HashConfi_ref,$Level,$Value);

			my $ThisChrName=$FileData_ref->[$FileNow][$StartCount][0];
			next if (!exists $hashYY1_ref->{$ThisChrName}) ;
			my $StartA=$FileData_ref->[$FileNow][$StartCount][1];
			my $EndA  =$FileData_ref->[$FileNow][$StartCount][2];

			my $chrB=$FileData_ref->[$FileNow][$StartCount][$B1];
			my $StartB=$FileData_ref->[$FileNow][$StartCount][$B2];
			my $EndB=$FileData_ref->[$FileNow][$StartCount][$B3];
			next if (!exists $hashYY1_ref->{$chrB}) ;



			my  $ZRTF=1;
			if ( exists $HashConfi_ref->{"global"}{"chr_zoom_region"})
			{
				my $regionArry=$HashConfi_ref->{"global"}{"chr_zoom_region"};

				$ZRTF=0;
				next if  ( $chrB  ne $$regionArry[0] );
				next if ( ( $StartB< $$regionArry[1])  && ($EndB < $$regionArry[1] ));
				next if ( ( $StartB> $$regionArry[2])  && ($EndB > $$regionArry[2] ));
				$ZRTF=1;

				if ( ($StartB>=$$regionArry[1])  &&     ($StartB<=$$regionArry[2]))
				{
					$StartB=$StartB-$$regionArry[1]+1;
				}
				elsif ($StartB<$$regionArry[1])
				{
					$StartB=1;
				}
				else
				{
					$StartB=$$regionArry[2]-$$regionArry[1]+1;
				}


				if ( ($EndB>=$$regionArry[1])  &&  ($EndB<=$$regionArry[2]))
				{
					$EndB=$EndB-$$regionArry[1]+1;
				}
				elsif ($EndB<$$regionArry[1])
				{
					$EndB=1;
				}
				else
				{
					$EndB=$$regionArry[2]-$$regionArry[1]+1;
				}


			}
			next if  ($ZRTF!=1);






			my $YY1=$hashYY1_ref->{$ThisChrName}{$Level};
			my $YY2=$hashYY2_ref->{$ThisChrName}{$Level};
			my $YY1_AA=$YY1;
			my $YY2_AA=$YY1;
			my $XStart_AA=sprintf ("%.1f",($StartA/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_bodyOO"}+$hashXX1_ref->{$ThisChrName}{$Level});
			my $XEnd_AA=sprintf ("%.1f",($EndA/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_bodyOO"}+$hashXX1_ref->{$ThisChrName}{$Level});

			my $YY1_BB=$YY2;
			my $YY2_BB=$YY2;
			my $XStart_BB=sprintf ("%.1f",($StartB/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_bodyOO"}+$hashXX1_ref->{$chrB}{$Level});
			my $XEnd_BB=sprintf ("%.1f",($EndB/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_bodyOO"}+$hashXX1_ref->{$chrB}{$Level});

			my $MidHH=($YY1+$YY2)*0.5;

			if (exists $ValueToCustomColor_ref->{$Value} ) {$ValueToColor_ref->{$Value}=$ValueToCustomColor_ref->{$Value};}
			my $MidXX_Start=($XStart_AA+$XStart_BB)*0.5;
			my $MidYY=($YY2_AA+$YY1_BB)*0.5;
			my $MidXX_End=($XEnd_AA+$XEnd_BB)*0.5;

			my $kk=($XEnd_AA-$MidXX_End)*0.4/$MidHH;
			my $QQBB_XX=($XEnd_AA + $MidXX_End)*0.5+$MidHH*$kk;
			my $QQBB_YY=($YY2_AA+ $MidYY)*0.5;

			$kk=($XStart_BB-$MidXX_Start)*0.4/$MidHH;
			my $QQAA_XX=($XStart_BB+$MidXX_Start)*0.5+$MidHH*$kk;
			my $QQAA_YY=($MidYY+$YY1_BB)*0.5;

			$svg->path(
				'd'=>"M$XStart_AA $YY2_AA L $XEnd_AA $YY2_AA  Q $QQBB_XX $QQBB_YY , $MidXX_End $MidYY T $XEnd_BB $YY1_BB  L $XStart_BB $YY1_BB Q $QQAA_XX $QQAA_YY , $MidXX_Start $MidYY T $XStart_AA $YY2_AA  Z",
				style => {
					'opacity' => $HashConfi_ref->{$Level}{"stroke-opacity"},
					'fill'           => $ValueToColor_ref->{$Value},
					'fill-opacity'   => $HashConfi_ref->{$Level}{"fill-opacity"},
					'stroke'         => $ValueToColor_ref->{$Value},
					'stroke-width'   => $HHstrokewidth,
					'stroke-opacity' => $HashConfi_ref->{$Level}{"stroke-opacity"},
				},
			);
		}
	}


}



##### Plots pairwise links between different genomic regions,for diff Chr###
sub plot_pairwiselinkV2 {
	my (
		$HashConfi_ref,     # 全局配置引用
		$ValueToColor_ref, # 值到颜色映射
		$Level,             # 当前绘图层级
		$svg,               # SVG 对象
		$hashYY1_ref,           # 染色体起始 Y 坐标
		$hashYY2_ref,           # 染色体结束 Y 坐标
		$hashXX1_ref,           # 染色体起始 X 坐标
		$ChrMax,            # 染色体最大长度
		$NumPlotArry,       # 数据列数量
		$PlotInfo,          # 绘图信息数组
		$FileData_ref,      # 文件数据引用
		$FileRow_ref,       # 每个文件行数
		$ValueToCustomColor_ref, # 自定义值-颜色映射
		$ColorGradientArray_ref,       # 颜色数组
		$ValueLabelsGradient_ref,     # 数值数组
		$ColorBarSize,       # 图例大小比例
		$Bodyheight,        # 主体高度
		$LegendOffsetRatio,  # 渐变起始位置比
		$GradientSteps,            # 最大颜色级别
		$fontsize           # 字号
	) = @_;


	my $path;

	my $YY1 = $HashConfi_ref->{"global"}{"canvas_margin_top"} +
	$LegendOffsetRatio * $Bodyheight +
	$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
	my $YY2 = $YY1 + $ColorBarSize * ($GradientSteps + 1);
	my $XX1 = $HashConfi_ref->{"global"}{"canvas_margin_left"} +
	$HashConfi_ref->{"global"}{"canvas_body"} +
	($Level - 1) * $ColorBarSize * 4.5 +
	$HashConfi_ref->{$Level}{"colormap_legend_shift_x"}; 
	my $XX2 = $XX1 + $ColorBarSize;

	my %hashHHC;
	my $HH = $HashConfi_ref->{$Level}{"track_height"};
	my $HHbinS = $HH / ($GradientSteps + 1);
	$hashHHC{$HashConfi_ref->{$Level}{"colormap_high_color"}} = $GradientSteps;
	$hashHHC{$HashConfi_ref->{$Level}{"colormap_low_color"}}  = 0;

	foreach my $k (0 .. $GradientSteps) {
		$hashHHC{$$ColorGradientArray_ref[$k]} = ($k + 1) * $HHbinS;
		my $HTML = ColorPaletteManager::RGB2HTML($$ColorGradientArray_ref[$k]);
		$hashHHC{$HTML} = ($k + 1) * $HHbinS;
		if (exists $HashConfi_ref->{$Level}{"link_uniform_height"} &&
			$HashConfi_ref->{$Level}{"link_uniform_height"} != 0)
		{
			$hashHHC{$$ColorGradientArray_ref[$k]} = $HH;
			$hashHHC{$HTML} = $HH;
		}
	}

	draw_color_legend($svg, $LegendOffsetRatio, $Bodyheight, $ColorBarSize, $ColorGradientArray_ref, $ValueLabelsGradient_ref, $HashConfi_ref, $Level, 'rectangle',"#Link");	


	# ————————————————————————————————
	# 获取绘图参数
	# ————————————————————————————————

	my $HeatMapstrokewidth = $HashConfi_ref->{$Level}{"stroke-width"};

	my $NowPlot = $$PlotInfo[0];
	my $FileNow = $$NowPlot[0];
	my $FileNow1 = $FileNow;
	my $FileNow2 = $FileNow;
	my $CoumnNow = $$NowPlot[1];
	my $B1 = $CoumnNow + 1;
	my $B2 = $CoumnNow + 2;

	if ($NumPlotArry != 3) {
		print "Bad at Level $Level For [-PType] is [PairWiseLinkV2], Input must be 3 columns (Value chrB SiteB)\n";
		print "Please set: ShowColumn=File$FileNow:$CoumnNow File$FileNow:$B1 File$FileNow:$B2\n";
		return;
	}

	my $NowPlot1 = $$PlotInfo[1];
	$FileNow1 = $$NowPlot1[0];
	my $NowPlot2 = $$PlotInfo[2];
	$FileNow2 = $$NowPlot2[0];

	if ($FileNow ne $FileNow1 || $FileNow ne $FileNow2) {
		print "Error in PairWiseLinkV2: All files must be the same.\n";
		print "Please set like: ShowColumn=File$FileNow:$CoumnNow,$B1,$B2\n";
		return;
	}

	$B1 = $$NowPlot1[1];
	$B2 = $$NowPlot2[1];

	# ————————————————————————————————
	# 数据开始绘制
	# ————————————————————————————————

	my $StartCount = 0;
	if (defined($$FileData_ref[$FileNow][0][0]) && $$FileData_ref[$FileNow][0][0] =~ s/#/#/) {
		$StartCount = 1;
	}

	# 根据 link_direction 判断绘制方式

	if ( (exists ($HashConfi_ref->{$Level}{"link_linestyle"}))   &&  ( $HashConfi_ref->{$Level}{"link_linestyle"} eq "line") )
	{
		if ((exists ($HashConfi_ref->{$Level}{"link_direction"}))   &&  ($HashConfi_ref->{$Level}{"link_direction"} eq "DownUp" ))
		{
			for ( ; $StartCount<$FileRow_ref->[$FileNow]; $StartCount++ )
			{
				my $Value=$FileData_ref->[$FileNow][$StartCount][$CoumnNow];
				next if  ($Value eq "NA");
				my $ThisChrName=$FileData_ref->[$FileNow][$StartCount][0];
				next if (!exists $$hashYY1_ref{$ThisChrName} );				
				my $ThisChrNameBB=$FileData_ref->[$FileNow][$StartCount][$B1];
				next if (!exists $$hashYY2_ref{$ThisChrNameBB});
				my $StartSite=$FileData_ref->[$FileNow][$StartCount][1];
				my $YY1=$$hashYY1_ref{$ThisChrName}{$Level};
				my $YY2=$$hashYY2_ref{$ThisChrNameBB}{$Level};
				my $EndSite=$FileData_ref->[$FileNow][$StartCount][$B2];
				my $XX1=sprintf ("%.1f",($StartSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_bodyOO"}+$$hashXX1_ref{$ThisChrName}{$Level});
				my $XX2=sprintf ("%.1f",($EndSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_bodyOO"}+$$hashXX1_ref{$ThisChrNameBB}{$Level});
				if (exists $ValueToCustomColor_ref->{$Value} ) {$ValueToColor_ref->{$Value}=$ValueToCustomColor_ref->{$Value};}
				$svg->line('x1',$XX1,'y1',$YY2,'x2',$XX2,'y2', $YY1 , 'stroke',$ValueToColor_ref->{$Value},'stroke-width',$HeatMapstrokewidth,'fill',$ValueToColor_ref->{$Value}); 
			}
		}
		else
		{
			for ( ; $StartCount<$FileRow_ref->[$FileNow]; $StartCount++ )
			{
				my $Value=$FileData_ref->[$FileNow][$StartCount][$CoumnNow];
				next if  ($Value eq "NA");
				my $ThisChrName=$FileData_ref->[$FileNow][$StartCount][0];
				next if (!exists $$hashYY1_ref{$ThisChrName} ) ;	
				my $ThisChrNameBB=$FileData_ref->[$FileNow][$StartCount][$B1];
				next if (!exists $$hashYY2_ref{$ThisChrNameBB} ) ;	
				my $StartSite=$FileData_ref->[$FileNow][$StartCount][1];
				my $YY1=$$hashYY1_ref{$ThisChrName}{$Level};
				my $YY2=$$hashYY2_ref{$ThisChrNameBB}{$Level};
				my $EndSite=$FileData_ref->[$FileNow][$StartCount][$B2];
				my $XX1=sprintf ("%.1f",($StartSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_bodyOO"}+$$hashXX1_ref{$ThisChrName}{$Level});
				my $XX2=sprintf ("%.1f",($EndSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_bodyOO"}+$$hashXX1_ref{$ThisChrNameBB}{$Level});
				if (exists $ValueToCustomColor_ref->{$Value} ) {$ValueToColor_ref->{$Value}=$ValueToCustomColor_ref->{$Value};}
				$svg->line('x1',$XX1,'y1',$YY1,'x2',$XX2,'y2', $YY2 , 'stroke',$ValueToColor_ref->{$Value},'stroke-width',$HeatMapstrokewidth,'fill',$ValueToColor_ref->{$Value}); 
			}
		}
	}
	elsif ((exists ($HashConfi_ref->{$Level}{"link_direction"}))   &&  ($HashConfi_ref->{$Level}{"link_direction"} eq "DownDown" ))
	{
		#cx = (x - (Math.pow(1 - t, 2) * x1) - Math.pow(t, 2) * x2) / (2 * t * (1 - t))
		#cy = (y - (Math.pow(1 - t, 2) * y1) - Math.pow(t, 2) * y2) / (2 * t * (1 - t))
		#t[0-1]
		for ( ; $StartCount<$FileRow_ref->[$FileNow]; $StartCount++ )
		{
			my $Value=$FileData_ref->[$FileNow][$StartCount][$CoumnNow];
			next if  ($Value eq "NA");
			my $ThisChrName=$FileData_ref->[$FileNow][$StartCount][0];
			next if (!exists $$hashYY1_ref{$ThisChrName} ) ;
			my $ThisChrNameBB=$FileData_ref->[$FileNow][$StartCount][$B1];
			next if (!exists $$hashYY2_ref{$ThisChrNameBB} ) ;
			my $StartSite=$FileData_ref->[$FileNow][$StartCount][1];
			my $YY1=$$hashYY1_ref{$ThisChrName}{$Level};
			my $YY2=$$hashYY2_ref{$ThisChrNameBB}{$Level};
			my $EndSite=$FileData_ref->[$FileNow][$StartCount][$B2];
			my $XX1=sprintf ("%.1f",($StartSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_bodyOO"}+$$hashXX1_ref{$ThisChrName}{$Level});
			my $XX2=sprintf ("%.1f",($EndSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_bodyOO"}+$$hashXX1_ref{$ThisChrNameBB}{$Level});
			my $Q1_X=($XX1+$XX2)*0.5;
			my $Q1_Y=$YY2-(2*$hashHHC{$ValueToColor_ref->{$Value}});
			if (exists $ValueToCustomColor_ref->{$Value} ) {$ValueToColor_ref->{$Value}=$ValueToCustomColor_ref->{$Value};}
			if ( $XX1 ==  $XX2 )
			{
				$svg->line('x1',$XX1,'y1',$YY2,'x2',$XX2,'y2', $YY2-$hashHHC{$ValueToColor_ref->{$Value}} , 'stroke',$ValueToColor_ref->{$Value},'stroke-width',$HeatMapstrokewidth,'fill',$ValueToColor_ref->{$Value}); 
				next ;
			}
			$svg->path(
				'd'=>"M$XX1 $YY2 Q $Q1_X $Q1_Y ,  $XX2 $YY2 ",
				style => {
					'fill'           =>  'none',
					'stroke'         =>  $ValueToColor_ref->{$Value},
					'stroke-width'   =>  $HeatMapstrokewidth,
					'stroke-opacity' =>  $HashConfi_ref->{$Level}{"stroke-opacity"},
					'fill-opacity'   =>  $HashConfi_ref->{$Level}{"fill-opacity"},
				},
			);
		}


	}
	elsif ((exists ($HashConfi_ref->{$Level}{"link_direction"}))   &&  ($HashConfi_ref->{$Level}{"link_direction"} eq "UpDownV2" ))
	{
		my $MidHH=$HashConfi_ref->{$Level}{"track_height"};
		for ( ; $StartCount<$FileRow_ref->[$FileNow]; $StartCount++ )
		{
			my $Value=$FileData_ref->[$FileNow][$StartCount][$CoumnNow];
			next if  ($Value eq "NA");
			my $ThisChrName=$FileData_ref->[$FileNow][$StartCount][0];
			next if (!exists $$hashYY1_ref{$ThisChrName} );
			my $ThisChrNameBB=$FileData_ref->[$FileNow][$StartCount][$B1];
			next if (!exists $$hashYY2_ref{$ThisChrNameBB} );
			my $StartSite=$FileData_ref->[$FileNow][$StartCount][1];
			my $EndSite=$FileData_ref->[$FileNow][$StartCount][$B2];
			my $YY1=$$hashYY1_ref{$ThisChrName}{$Level};
			my $YY2=$$hashYY2_ref{$ThisChrNameBB}{$Level};
			my $XX1=sprintf ("%.1f",($StartSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_bodyOO"}+$$hashXX1_ref{$ThisChrName}{$Level});
			my $XX2=sprintf ("%.1f",($EndSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_bodyOO"}+$$hashXX1_ref{$ThisChrNameBB}{$Level});

			if (exists $ValueToCustomColor_ref->{$Value} ) {$ValueToColor_ref->{$Value}=$ValueToCustomColor_ref->{$Value};}

			if ( $XX1 ==  $XX2 )
			{
				$svg->line('x1',$XX1,'y1',$YY1,'x2',$XX2,'y2', $YY2 , 'stroke',$ValueToColor_ref->{$Value},'stroke-width',$HeatMapstrokewidth,'fill',$ValueToColor_ref->{$Value}); 
				next ;
			}

			my $M1_X=($XX1+$XX2)*0.5;
			my $M1_Y=($YY1+$YY2)*0.5;

			my $kk=($XX2-$M1_X)*0.4/$MidHH;
			my $Q1_X=($XX1+$M1_X)*0.5+$MidHH*$kk;
			my $Q1_Y=($YY1+$M1_Y)*0.5;
			$svg->path(
				'd'=>"M$XX1 $YY1 Q $Q1_X $Q1_Y ,$M1_X , $M1_Y  T $XX2 $YY2  ",
				style => {
					'fill'           =>  'none',
					'stroke'         =>  $ValueToColor_ref->{$Value},
					'stroke-width'   =>  $HeatMapstrokewidth,
					'stroke-opacity' =>  $HashConfi_ref->{$Level}{"stroke-opacity"},
					'fill-opacity'   =>  $HashConfi_ref->{$Level}{"fill-opacity"},
				},
			);
		}


	}
	elsif ((exists ($HashConfi_ref->{$Level}{"link_direction"}))   &&  ($HashConfi_ref->{$Level}{"link_direction"} eq "UpDown") )
	{
		my $MidHH=$HashConfi_ref->{$Level}{"track_height"};
		for ( ; $StartCount<$FileRow_ref->[$FileNow]; $StartCount++ )
		{
			my $Value=$FileData_ref->[$FileNow][$StartCount][$CoumnNow];
			next if  ($Value eq "NA");
			my $ThisChrName=$FileData_ref->[$FileNow][$StartCount][0];
			next if (!exists $$hashYY1_ref{$ThisChrName}) ;
			my $ThisChrNameBB=$FileData_ref->[$FileNow][$StartCount][$B1];
			next if (!exists $$hashYY2_ref{$ThisChrNameBB}) ;
			my $StartSite=$FileData_ref->[$FileNow][$StartCount][1];
			my $EndSite=$FileData_ref->[$FileNow][$StartCount][$B2];
			my $YY1=$$hashYY1_ref{$ThisChrName}{$Level};
			my $YY2=$$hashYY2_ref{$ThisChrNameBB}{$Level};
			my $XX1=sprintf ("%.1f",($StartSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_bodyOO"}+$$hashXX1_ref{$ThisChrName}{$Level});
			my $XX2=sprintf ("%.1f",($EndSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_bodyOO"}+$$hashXX1_ref{$ThisChrNameBB}{$Level});

			if (exists $ValueToCustomColor_ref->{$Value} ) {$ValueToColor_ref->{$Value}=$ValueToCustomColor_ref->{$Value};}

			if ( $XX1 ==  $XX2 )
			{
				$svg->line('x1',$XX1,'y1',$YY1,'x2',$XX2,'y2', $YY2 , 'stroke',$ValueToColor_ref->{$Value},'stroke-width',$HeatMapstrokewidth,'fill',$ValueToColor_ref->{$Value}); 
				next ;
			}

			my $M1_X=($XX1+$XX2)*0.5;
			my $M1_Y=($YY1+$YY2)*0.5;

			my $kk=($XX1-$M1_X)*0.4/$MidHH;
			my $Q1_X=($XX1+$M1_X)*0.5+$MidHH*$kk;
			my $Q1_Y=($YY1+$M1_Y)*0.5;
			$svg->path(
				'd'=>"M$XX1 $YY1 Q $Q1_X $Q1_Y ,$M1_X , $M1_Y  T $XX2 $YY2  ",
				style => {
					'fill'           =>  'none',
					'stroke'         =>  $ValueToColor_ref->{$Value},
					'stroke-width'   =>  $HeatMapstrokewidth,
					'stroke-opacity' =>  $HashConfi_ref->{$Level}{"stroke-opacity"},
					'fill-opacity'   =>  $HashConfi_ref->{$Level}{"fill-opacity"},
				},
			);
		}
	}

	elsif ((exists ($HashConfi_ref->{$Level}{"link_direction"}))   &&  ($HashConfi_ref->{$Level}{"link_direction"} eq "DownUpV2" ))
	{
		my $MidHH=$HashConfi_ref->{$Level}{"track_height"};
		for ( ; $StartCount<$FileRow_ref->[$FileNow]; $StartCount++ )
		{
			my $Value=$FileData_ref->[$FileNow][$StartCount][$CoumnNow];
			next if  ($Value eq "NA");
			my $ThisChrName=$FileData_ref->[$FileNow][$StartCount][0];
			next if (!exists $$hashYY1_ref{$ThisChrName} ) ;
			my $ThisChrNameBB=$FileData_ref->[$FileNow][$StartCount][$B1];
			next if (!exists $$hashYY2_ref{$ThisChrNameBB} ) ;
			my $StartSite=$FileData_ref->[$FileNow][$StartCount][1];
			my $EndSite=$FileData_ref->[$FileNow][$StartCount][$B2];
			my $YY1=$$hashYY1_ref{$ThisChrName}{$Level};
			my $YY2=$$hashYY2_ref{$ThisChrNameBB}{$Level};
			my $XX1=sprintf ("%.1f",($StartSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_bodyOO"}+$$hashXX1_ref{$ThisChrName}{$Level});
			my $XX2=sprintf ("%.1f",($EndSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_bodyOO"}+$$hashXX1_ref{$ThisChrNameBB}{$Level});

			if (exists $ValueToCustomColor_ref->{$Value} ) {$ValueToColor_ref->{$Value}=$ValueToCustomColor_ref->{$Value};}

			if ( $XX1 ==  $XX2 )
			{
				$svg->line('x1',$XX1,'y1',$YY2,'x2',$XX2,'y2', $YY1 , 'stroke',$ValueToColor_ref->{$Value},'stroke-width',$HeatMapstrokewidth,'fill',$ValueToColor_ref->{$Value}); 
				next ;
			}

			my $M1_X=($XX1+$XX2)*0.5;
			my $M1_Y=($YY1+$YY2)*0.5;

			my $kk=($XX2-$M1_X)*0.4/$MidHH;
			my $Q1_X=($XX1+$M1_X)*0.5+$MidHH*$kk;
			my $Q1_Y=($YY2+$M1_Y)*0.5;
			$svg->path(
				'd'=>"M$XX1 $YY2 Q $Q1_X $Q1_Y ,$M1_X , $M1_Y  T $XX2 $YY1  ",
				style => {
					'fill'           =>  'none',
					'stroke'         =>  $ValueToColor_ref->{$Value},
					'stroke-width'   =>  $HeatMapstrokewidth,
					'stroke-opacity' =>  $HashConfi_ref->{$Level}{"stroke-opacity"},
					'fill-opacity'   =>  $HashConfi_ref->{$Level}{"fill-opacity"},
				},
			);
		}


	}
	elsif ((exists ($HashConfi_ref->{$Level}{"link_direction"}))   &&  ($HashConfi_ref->{$Level}{"link_direction"} eq "DownUp") )
	{
		my $MidHH=$HashConfi_ref->{$Level}{"track_height"};
		for ( ; $StartCount<$FileRow_ref->[$FileNow]; $StartCount++ )
		{
			my $Value=$FileData_ref->[$FileNow][$StartCount][$CoumnNow];
			next if  ($Value eq "NA");
			my $ThisChrName=$FileData_ref->[$FileNow][$StartCount][0];
			next if (!exists $$hashYY1_ref{$ThisChrName} ) ;
			my $ThisChrNameBB=$FileData_ref->[$FileNow][$StartCount][$B1];
			next if (!exists $$hashYY2_ref{$ThisChrNameBB} ) ;
			my $StartSite=$FileData_ref->[$FileNow][$StartCount][1];
			my $EndSite=$FileData_ref->[$FileNow][$StartCount][$B2];
			my $YY1=$$hashYY1_ref{$ThisChrName}{$Level};
			my $YY2=$$hashYY2_ref{$ThisChrNameBB}{$Level};
			my $XX1=sprintf ("%.1f",($StartSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_bodyOO"}+$$hashXX1_ref{$ThisChrName}{$Level});
			my $XX2=sprintf ("%.1f",($EndSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_bodyOO"}+$$hashXX1_ref{$ThisChrNameBB}{$Level});

			if (exists $ValueToCustomColor_ref->{$Value} ) {$ValueToColor_ref->{$Value}=$ValueToCustomColor_ref->{$Value};}

			if ( $XX1 ==  $XX2 )
			{
				$svg->line('x1',$XX1,'y1',$YY2,'x2',$XX2,'y2', $YY1 , 'stroke',$ValueToColor_ref->{$Value},'stroke-width',$HeatMapstrokewidth,'fill',$ValueToColor_ref->{$Value}); 
				next ;
			}

			my $M1_X=($XX1+$XX2)*0.5;
			my $M1_Y=($YY1+$YY2)*0.5;


			my $kk=($XX2-$M1_X)*0.4/$MidHH;
			my $Q1_X=($XX1+$M1_X)*0.5-$MidHH*$kk;
			my $Q1_Y=($YY2+$M1_Y)*0.5;
			$svg->path(
				'd'=>"M$XX1 $YY2 Q $Q1_X $Q1_Y ,$M1_X , $M1_Y  T $XX2 $YY1  ",
				style => {
					'fill'           =>  'none',
					'stroke'         =>  $ValueToColor_ref->{$Value},
					'stroke-width'   =>  $HeatMapstrokewidth,
					'stroke-opacity' =>  $HashConfi_ref->{$Level}{"stroke-opacity"},
					'fill-opacity'   =>  $HashConfi_ref->{$Level}{"fill-opacity"},
				},
			);


		}
	}

	else
	{

		for (; $StartCount<$FileRow_ref->[$FileNow]; $StartCount++)
		{
			my $Value=$FileData_ref->[$FileNow][$StartCount][$CoumnNow];
			next if  ($Value eq "NA");
			my $ThisChrName=$FileData_ref->[$FileNow][$StartCount][0];
			next if (!exists $$hashYY1_ref{$ThisChrName} ) ;				
			my $ThisChrNameBB=$FileData_ref->[$FileNow][$StartCount][$B1];
			next if (!exists $$hashYY2_ref{$ThisChrNameBB} ) ;				
			my $StartSite=$FileData_ref->[$FileNow][$StartCount][1];
			my $EndSite=$FileData_ref->[$FileNow][$StartCount][$B2];
			my $YY1=$$hashYY1_ref{$ThisChrName}{$Level};
			my $YY2=$$hashYY2_ref{$ThisChrNameBB}{$Level};
			my $XX1=sprintf ("%.1f",($StartSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_bodyOO"}+$$hashXX1_ref{$ThisChrName}{$Level});
			my $XX2=sprintf ("%.1f",($EndSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_bodyOO"}+$$hashXX1_ref{$ThisChrNameBB}{$Level});
			my $Q1_X=($XX1+$XX2)*0.5;
			my $Q1_Y=$YY1+2*$hashHHC{$ValueToColor_ref->{$Value}};
			if (exists $ValueToCustomColor_ref->{$Value} ) {$ValueToColor_ref->{$Value}=$ValueToCustomColor_ref->{$Value};}
			if ($XX1 ==  $XX2 )
			{
				$svg->line('x1',$XX1,'y1',$YY1,'x2',$XX1,'y2', $YY1+$hashHHC{$ValueToColor_ref->{$Value}} , 'stroke',$ValueToColor_ref->{$Value},'stroke-width',$HeatMapstrokewidth,'fill',$ValueToColor_ref->{$Value}); 
				next ;
			}
			$svg->path(
				'd'=>"M$XX1 $YY1 Q $Q1_X $Q1_Y ,  $XX2 $YY1 ",
				style => {
					'fill'           =>  'none',
					'stroke'         =>  $ValueToColor_ref->{$Value},
					'stroke-width'   =>  $HeatMapstrokewidth,
					'stroke-opacity' =>  $HashConfi_ref->{$Level}{"stroke-opacity"},
					'fill-opacity'   =>  $HashConfi_ref->{$Level}{"fill-opacity"},
				},
			);
		}



	}


	return;
}




##### Plots pairwise links between different genomic regions ####
sub plot_pairwiselink {
	my ($HashConfi_ref, $ValueToColor_ref, $Level, $svg, $hashYY1_ref, $hashYY2_ref, $hashXX1_ref,
		$ChrMax, $NumPlotArry, $PlotInfo_ref, $FileData_ref, $FileRow_ref, $ValueToCustomColor_ref, $ColorGradientArray_ref,
		$ValueLabelsGradient_ref, $ColorBarSize,  $Bodyheight, $LegendOffsetRatio, $GradientSteps, $fontsize) = @_;

	# 定义坐标轴相关的变量
	my $YY1 = $HashConfi_ref->{"global"}{"canvas_margin_top"} + $LegendOffsetRatio * $Bodyheight + $HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
	my $YY2 = $YY1 + $ColorBarSize * ($GradientSteps + 1);
	my $XX1 = $HashConfi_ref->{"global"}{"canvas_margin_left"} + $HashConfi_ref->{"global"}{"canvas_body"} + ($Level - 1) * $ColorBarSize * 4.5 + $HashConfi_ref->{$Level}{"colormap_legend_shift_x"} ;
	my $XX2 = $XX1 + $ColorBarSize;

	# 颜色高度映射表
	my %hashHHC;
	my $HH = $HashConfi_ref->{$Level}{"track_height"};
	my $HHbinS = $HH / ($GradientSteps + 1);

	$hashHHC{$HashConfi_ref->{$Level}{"colormap_high_color"}} = $GradientSteps;
	$hashHHC{$HashConfi_ref->{$Level}{"colormap_low_color"}} = 0;

	foreach my $k (0 .. $GradientSteps) {
		$hashHHC{$ColorGradientArray_ref->[$k]} = ($k + 1) * $HHbinS;
		my $HTML = ColorPaletteManager::RGB2HTML($ColorGradientArray_ref->[$k]);
		$hashHHC{$HTML} = ($k + 1) * $HHbinS;

		if ((exists $HashConfi_ref->{$Level}{"link_uniform_height"}) && $HashConfi_ref->{$Level}{"link_uniform_height"} != 0) {
			$hashHHC{$ColorGradientArray_ref->[$k]} = $HH;
			$hashHHC{$HTML} = $HH;
		}
	}

	my $headLT="Plink";
	if  ($NumPlotArry==1)
	{
	   my $NowPlotLT = $PlotInfo_ref->[0];
	   my $FileNowLT = $NowPlotLT->[0];
	   my $CoumnNowLT = $NowPlotLT->[1];
	   $headLT=$FileData_ref->[$FileNowLT][0][$CoumnNowLT];
	}

	draw_color_legend($svg,$LegendOffsetRatio, $Bodyheight, $ColorBarSize, $ColorGradientArray_ref, $ValueLabelsGradient_ref, $HashConfi_ref, $Level, 'rectangle',$headLT);



	my $HeatMapstrokewidth = $HashConfi_ref->{$Level}{"stroke-width"};

	# 遍历每个 Plot 层次的数据
	foreach my $tmpkk (1 .. $NumPlotArry) {
		my $ThisBoxbin = $tmpkk - 1;
		my $NowPlot    = $PlotInfo_ref->[$ThisBoxbin];
		my $FileNow    = $NowPlot->[0];
		my $CoumnNow   = $NowPlot->[1];

		my $StartCount = 0;
		if (defined($FileData_ref->[$FileNow][0][0]) && $FileData_ref->[$FileNow][0][0] =~ s/#/#/) {
			$StartCount = 1;
		}

		# 判断线型和方向
		if (exists $HashConfi_ref->{$Level}{"link_linestyle"} && $HashConfi_ref->{$Level}{"link_linestyle"} eq "line") {
			if (exists $HashConfi_ref->{$Level}{"link_direction"} && $HashConfi_ref->{$Level}{"link_direction"} eq "DownUp") {
				# DownUp 方向绘制直线

				for (; $StartCount < $FileRow_ref->[$FileNow]; $StartCount++) {
					my $Value = $FileData_ref->[$FileNow][$StartCount][$CoumnNow];
					next if $Value eq "NA";
					$Value = CheckValueNow($HashConfi_ref, $Level, $Value);

					my $ThisChrName = $FileData_ref->[$FileNow][$StartCount][0];
					next unless exists $$hashYY1_ref{$ThisChrName};

					my $StartSite = $FileData_ref->[$FileNow][$StartCount][1];
					my $EndSite   = $FileData_ref->[$FileNow][$StartCount][2];
					my $YY1       = $$hashYY1_ref{$ThisChrName}{$Level};
					my $YY2       = $$hashYY2_ref{$ThisChrName}{$Level};
					my $XX1       = sprintf("%.1f", ($StartSite / $ChrMax) * $HashConfi_ref->{"global"}{"canvas_bodyOO"} + $$hashXX1_ref{$ThisChrName}{$Level});
					my $XX2       = sprintf("%.1f", ($EndSite / $ChrMax) * $HashConfi_ref->{"global"}{"canvas_bodyOO"} + $$hashXX1_ref{$ThisChrName}{$Level});

					if (exists $ValueToCustomColor_ref->{$Value}) {
						$ValueToColor_ref->{$Value} = $ValueToCustomColor_ref->{$Value};
					}

					$svg->line(
						'x1', $XX1, 'y1', $YY2,
						'x2', $XX2, 'y2', $YY1,
						'stroke', $ValueToColor_ref->{$Value},
						'stroke-width', $HeatMapstrokewidth,
						'fill', $ValueToColor_ref->{$Value}
					);
				}
			} else {

				# 默认方向绘制直线
				for (; $StartCount < $FileRow_ref->[$FileNow]; $StartCount++) {
					my $Value = $FileData_ref->[$FileNow][$StartCount][$CoumnNow];
					next if $Value eq "NA";
					$Value = CheckValueNow($HashConfi_ref, $Level, $Value);

					my $ThisChrName = $FileData_ref->[$FileNow][$StartCount][0];
					next unless exists $$hashYY1_ref{$ThisChrName};

					my $StartSite = $FileData_ref->[$FileNow][$StartCount][1];
					my $EndSite   = $FileData_ref->[$FileNow][$StartCount][2];
					my $YY1       = $$hashYY1_ref{$ThisChrName}{$Level};
					my $YY2       = $$hashYY2_ref{$ThisChrName}{$Level};
					my $XX1       = sprintf("%.1f", ($StartSite / $ChrMax) * $HashConfi_ref->{"global"}{"canvas_bodyOO"} + $$hashXX1_ref{$ThisChrName}{$Level});
					my $XX2       = sprintf("%.1f", ($EndSite / $ChrMax) * $HashConfi_ref->{"global"}{"canvas_bodyOO"} + $$hashXX1_ref{$ThisChrName}{$Level});

					if (exists $ValueToCustomColor_ref->{$Value}) {
						$ValueToColor_ref->{$Value} = $ValueToCustomColor_ref->{$Value};
					}

					$svg->line(
						'x1', $XX1, 'y1', $YY1,
						'x2', $XX2, 'y2', $YY2,
						'stroke', $ValueToColor_ref->{$Value},
						'stroke-width', $HeatMapstrokewidth,
						'fill', $ValueToColor_ref->{$Value}
					);

				}
			}
		} elsif (exists $HashConfi_ref->{$Level}{"link_direction"} && $HashConfi_ref->{$Level}{"link_direction"} eq "DownDown") {
			# DownDown 贝塞尔曲线绘制
			for (; $StartCount < $FileRow_ref->[$FileNow]; $StartCount++) {
				my $Value = $FileData_ref->[$FileNow][$StartCount][$CoumnNow];
				next if $Value eq "NA";
				$Value = CheckValueNow($HashConfi_ref, $Level, $Value);

				my $ThisChrName = $FileData_ref->[$FileNow][$StartCount][0];
				next unless exists $$hashYY1_ref{$ThisChrName};

				my $StartSite = $FileData_ref->[$FileNow][$StartCount][1];
				my $EndSite   = $FileData_ref->[$FileNow][$StartCount][2];
				my $YY1       = $$hashYY1_ref{$ThisChrName}{$Level};
				my $YY2       = $$hashYY2_ref{$ThisChrName}{$Level};
				my $XX1       = sprintf("%.1f", ($StartSite / $ChrMax) * $HashConfi_ref->{"global"}{"canvas_bodyOO"} + $$hashXX1_ref{$ThisChrName}{$Level});
				my $XX2       = sprintf("%.1f", ($EndSite / $ChrMax) * $HashConfi_ref->{"global"}{"canvas_bodyOO"} + $$hashXX1_ref{$ThisChrName}{$Level});
				my $Q1_X      = ($XX1 + $XX2) * 0.5;
				my $Q1_Y      = $YY2 - 2 * $hashHHC{$ValueToColor_ref->{$Value}};

				if (exists $ValueToCustomColor_ref->{$Value}) {
					$ValueToColor_ref->{$Value} = $ValueToCustomColor_ref->{$Value};
				}

				if ($XX1 == $XX2) {
					$svg->line(
						'x1', $XX1, 'y1', $YY2,
						'x2', $XX2, 'y2', $YY2 - $hashHHC{$ValueToColor_ref->{$Value}},
						'stroke', $ValueToColor_ref->{$Value},
						'stroke-width', $HeatMapstrokewidth,
						'fill', $ValueToColor_ref->{$Value}
					);
				} else {
					$svg->path(
						d => "M$XX1 $YY2 Q $Q1_X $Q1_Y , $XX2 $YY2",
						style => {
							fill             => 'none',
							stroke           => $ValueToColor_ref->{$Value},
							'stroke-width'   => $HeatMapstrokewidth,
							'stroke-opacity' => $HashConfi_ref->{$Level}{"stroke-opacity"},
							'fill-opacity'   => $HashConfi_ref->{$Level}{"fill-opacity"}
						}
					);
				}
			}
		} elsif ( (exists $HashConfi_ref->{$Level}{"link_direction"} && $HashConfi_ref->{$Level}{"link_direction"} eq "UpDown" ) || (exists $HashConfi_ref->{$Level}{"link_direction"} && $HashConfi_ref->{$Level}{"link_direction"} eq "UpDownV2" ))  {
			my $MidHH = $HashConfi_ref->{$Level}{"track_height"};
			for (; $StartCount < $FileRow_ref->[$FileNow]; $StartCount++) {
				my $Value = $FileData_ref->[$FileNow][$StartCount][$CoumnNow];
				next if $Value eq "NA";
				$Value = CheckValueNow($HashConfi_ref, $Level, $Value);

				my $ThisChrName = $FileData_ref->[$FileNow][$StartCount][0];
				next unless exists $$hashYY1_ref{$ThisChrName};

				my $StartSite = $FileData_ref->[$FileNow][$StartCount][1];
				my $EndSite   = $FileData_ref->[$FileNow][$StartCount][2];
				my $YY1       = $$hashYY1_ref{$ThisChrName}{$Level};
				my $YY2       = $$hashYY2_ref{$ThisChrName}{$Level};
				my $XX1       = sprintf("%.1f", ($StartSite / $ChrMax) * $HashConfi_ref->{"global"}{"canvas_bodyOO"} + $$hashXX1_ref{$ThisChrName}{$Level});
				my $XX2       = sprintf("%.1f", ($EndSite / $ChrMax) * $HashConfi_ref->{"global"}{"canvas_bodyOO"} + $$hashXX1_ref{$ThisChrName}{$Level});

				if (exists $ValueToCustomColor_ref->{$Value}) {
					$ValueToColor_ref->{$Value} = $ValueToCustomColor_ref->{$Value};
				}

				if ($XX1 == $XX2) {
					$svg->line(
						'x1', $XX1, 'y1', $YY1,
						'x2', $XX2, 'y2', $YY2,
						'stroke', $ValueToColor_ref->{$Value},
						'stroke-width', $HeatMapstrokewidth,
						'fill', $ValueToColor_ref->{$Value}
					);
				} else {
					my $M1_X = ($XX1 + $XX2) * 0.5;
					my $M1_Y = ($YY1 + $YY2) * 0.5;
					my $kk     = ($XX1 - $M1_X) * 0.4 / $MidHH;
					if (exists $HashConfi_ref->{$Level}{"link_direction"} && $HashConfi_ref->{$Level}{"link_direction"} eq "UpDownV2" )
					{
						$kk=($XX2-$M1_X)*0.4/$MidHH;
					}
					my $Q1_X   = ($XX1 + $M1_X) * 0.5 + $MidHH * $kk;
					my $Q1_Y   = ($YY1 + $M1_Y) * 0.5;

					$svg->path(
						d => "M$XX1 $YY1 Q $Q1_X $Q1_Y , $M1_X $M1_Y T $XX2 $YY2",
						style => {
							fill             => 'none',
							stroke           => $ValueToColor_ref->{$Value},
							'stroke-width'   => $HeatMapstrokewidth,
							'stroke-opacity' => $HashConfi_ref->{$Level}{"stroke-opacity"},
							'fill-opacity'   => $HashConfi_ref->{$Level}{"fill-opacity"}
						}
					);
				}
			}		
		}

		elsif ((exists ($HashConfi_ref->{$Level}{"link_direction"}))   &&  ($HashConfi_ref->{$Level}{"link_direction"} eq "DownUpV2" ))
		{
			my $MidHH=$HashConfi_ref->{$Level}{"track_height"};
			for ( ; $StartCount<$FileRow_ref->[$FileNow]; $StartCount++ )
			{
				my $Value=$FileData_ref->[$FileNow][$StartCount][$CoumnNow];
				next if  ($Value eq "NA");
				my $ThisChrName=$FileData_ref->[$FileNow][$StartCount][0];
				next if (!exists $$hashYY1_ref{$ThisChrName} ) ;				
				my $StartSite=$FileData_ref->[$FileNow][$StartCount][1];
				my $EndSite=$FileData_ref->[$FileNow][$StartCount][2];
				my $YY1=$$hashYY1_ref{$ThisChrName}{$Level};
				my $YY2=$$hashYY2_ref{$ThisChrName}{$Level};
				my $XX1=sprintf ("%.1f",($StartSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_bodyOO"}+$$hashXX1_ref{$ThisChrName}{$Level});
				my $XX2=sprintf ("%.1f",($EndSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_bodyOO"}+$$hashXX1_ref{$ThisChrName}{$Level});

				if (exists $ValueToCustomColor_ref->{$Value} ) {$ValueToColor_ref->{$Value}=$ValueToCustomColor_ref->{$Value};}

				if ( $XX1 ==  $XX2 )
				{
					$svg->line('x1',$XX1,'y1',$YY2,'x2',$XX2,'y2', $YY1 , 'stroke',$ValueToColor_ref->{$Value},'stroke-width',$HeatMapstrokewidth,'fill',$ValueToColor_ref->{$Value}); 
					next ;
				}

				my $M1_X=($XX1+$XX2)*0.5;
				my $M1_Y=($YY1+$YY2)*0.5;

				my $kk=($XX2-$M1_X)*0.4/$MidHH;
				my $Q1_X=($XX1+$M1_X)*0.5+$MidHH*$kk;
				my $Q1_Y=($YY2+$M1_Y)*0.5;
				$svg->path(
					'd'=>"M$XX1 $YY2 Q $Q1_X $Q1_Y ,$M1_X , $M1_Y  T $XX2 $YY1  ",
					style => {
						'fill'           =>  'none',
						'stroke'         =>  $ValueToColor_ref->{$Value},
						'stroke-width'   =>  $HeatMapstrokewidth,
						'stroke-opacity' =>  $HashConfi_ref->{$Level}{"stroke-opacity"},
						'fill-opacity'   =>  $HashConfi_ref->{$Level}{"fill-opacity"},
					},
				);
			}


		}
		elsif ((exists ($HashConfi_ref->{$Level}{"link_direction"}))   &&  ($HashConfi_ref->{$Level}{"link_direction"} eq "DownUp") )
		{
			my $MidHH=$HashConfi_ref->{$Level}{"track_height"};
			for ( ; $StartCount<$FileRow_ref->[$FileNow]; $StartCount++ )
			{
				my $Value=$FileData_ref->[$FileNow][$StartCount][$CoumnNow];
				next if  ($Value eq "NA");
				my $ThisChrName=$FileData_ref->[$FileNow][$StartCount][0];
				next if (!exists $$hashYY1_ref{$ThisChrName} ) ;				
				my $StartSite=$FileData_ref->[$FileNow][$StartCount][1];
				my $EndSite=$FileData_ref->[$FileNow][$StartCount][2];
				my $YY1=$$hashYY1_ref{$ThisChrName}{$Level};
				my $YY2=$$hashYY2_ref{$ThisChrName}{$Level};
				my $XX1=sprintf ("%.1f",($StartSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_bodyOO"}+$$hashXX1_ref{$ThisChrName}{$Level});
				my $XX2=sprintf ("%.1f",($EndSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_bodyOO"}+$$hashXX1_ref{$ThisChrName}{$Level});

				if (exists $ValueToCustomColor_ref->{$Value} ) {$ValueToColor_ref->{$Value}=$ValueToCustomColor_ref->{$Value};}

				if ( $XX1 ==  $XX2 )
				{
					$svg->line('x1',$XX1,'y1',$YY2,'x2',$XX2,'y2', $YY1 , 'stroke',$ValueToColor_ref->{$Value},'stroke-width',$HeatMapstrokewidth,'fill',$ValueToColor_ref->{$Value}); 
					next ;
				}

				my $M1_X=($XX1+$XX2)*0.5;
				my $M1_Y=($YY1+$YY2)*0.5;


				my $kk=($XX2-$M1_X)*0.4/$MidHH;
				my $Q1_X=($XX1+$M1_X)*0.5-$MidHH*$kk;
				my $Q1_Y=($YY2+$M1_Y)*0.5;
				$svg->path(
					'd'=>"M$XX1 $YY2 Q $Q1_X $Q1_Y ,$M1_X , $M1_Y  T $XX2 $YY1  ",
					style => {
						'fill'           =>  'none',
						'stroke'         =>  $ValueToColor_ref->{$Value},
						'stroke-width'   =>  $HeatMapstrokewidth,
						'stroke-opacity' =>  $HashConfi_ref->{$Level}{"stroke-opacity"},
						'fill-opacity'   =>  $HashConfi_ref->{$Level}{"fill-opacity"},
					},
				);


			}
		}



		else {
			# 默认样式：二次贝塞尔曲线
			for (; $StartCount < $FileRow_ref->[$FileNow]; $StartCount++) {
				my $Value = $FileData_ref->[$FileNow][$StartCount][$CoumnNow];
				next if $Value eq "NA";
				$Value = CheckValueNow($HashConfi_ref, $Level, $Value);

				my $ThisChrName = $FileData_ref->[$FileNow][$StartCount][0];
				next unless exists $$hashYY1_ref{$ThisChrName};

				my $StartSite = $FileData_ref->[$FileNow][$StartCount][1];
				my $EndSite   = $FileData_ref->[$FileNow][$StartCount][2];
				my $YY1       = $$hashYY1_ref{$ThisChrName}{$Level};
				my $YY2       = $$hashYY2_ref{$ThisChrName}{$Level};
				my $XX1       = sprintf("%.1f", ($StartSite / $ChrMax) * $HashConfi_ref->{"global"}{"canvas_bodyOO"} + $$hashXX1_ref{$ThisChrName}{$Level});
				my $XX2       = sprintf("%.1f", ($EndSite / $ChrMax) * $HashConfi_ref->{"global"}{"canvas_bodyOO"} + $$hashXX1_ref{$ThisChrName}{$Level});
				my $Q1_X     = ($XX1 + $XX2) * 0.5;
				my $Q1_Y     = $YY1 + 2 * $hashHHC{$ValueToColor_ref->{$Value}};

				if (exists $ValueToCustomColor_ref->{$Value}) {
					$ValueToColor_ref->{$Value} = $ValueToCustomColor_ref->{$Value};
				}

				if ($XX1 == $XX2) {
					$svg->line(
						'x1', $XX1, 'y1', $YY1,
						'x2', $XX2, 'y2', $YY1 + $hashHHC{$ValueToColor_ref->{$Value}},
						'stroke', $ValueToColor_ref->{$Value},
						'stroke-width', $HeatMapstrokewidth,
						'fill', $ValueToColor_ref->{$Value}
					);
				} else {
					$svg->path(
						d => "M$XX1 $YY1 Q $Q1_X $Q1_Y , $XX2 $YY1",
						style => {
							fill             => 'none',
							stroke           => $ValueToColor_ref->{$Value},
							'stroke-width'   => $HeatMapstrokewidth,
							'stroke-opacity' => $HashConfi_ref->{$Level}{"stroke-opacity"},
							'fill-opacity'   => $HashConfi_ref->{$Level}{"fill-opacity"}
						}
					);
				}
			}
		}
	}
}


##### Plots histogram-style bars on the genome map ####
sub plot_histogram {
	my ($HashConfi_ref, $ValueToColor_ref, $Level, $svg, $hashYY1_ref, $hashYY2_ref, $hashXX1_ref,
		$ChrMax, $NumPlotArry, $PlotInfo_ref, $FileData_ref, $FileRow_ref, $ValueToCustomColor_ref, 
		$ColorGradientArray_ref, $ValueLabelsGradient_ref, $ColorBarSize,  $Bodyheight, 
		$LegendOffsetRatio, $GradientSteps, $fontsize,$ChrArry_ref,$hashChr_ref) = @_;

	if ($NumPlotArry > 2) {
		print "Error:\tFor -PType histogram on Level [$Level] only One/two Plot, you can modify to add the Level for it or change the -PType\n";
		for (my $i = 0; $i < $NumPlotArry; $i++) {
			my $NowPlot = $PlotInfo_ref->[$i];
			print "\t\tFile$NowPlot->[0]\tCoumn$NowPlot->[1]\n";
		}
		print "\t:you can change the [-PType] as [histAnimated] have a try\n";
		exit;
	}


	if ($NumPlotArry == 2) {
		$ColorGradientArray_ref->[1] = $ColorGradientArray_ref->[$GradientSteps];
		@$ColorGradientArray_ref = @$ColorGradientArray_ref[0, 1];
		$GradientSteps = 1;
		my $NowPlot = $PlotInfo_ref->[0];
		my $FileNow = $NowPlot->[0];
		my $CoumnNow = $NowPlot->[1];
		$ValueLabelsGradient_ref->[0] = "U:" . $FileData_ref->[$FileNow][0][$CoumnNow];

		$NowPlot = $PlotInfo_ref->[1];
		$FileNow = $NowPlot->[0];
		$CoumnNow = $NowPlot->[1];
		$ValueLabelsGradient_ref->[1] = "D:" . $FileData_ref->[$FileNow][0][$CoumnNow];
	}

	my $YY1 = $HashConfi_ref->{"global"}{"canvas_margin_top"} + $LegendOffsetRatio * $Bodyheight + $HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
	my $YY2 = $YY1 + $ColorBarSize * ($GradientSteps + 1);
	my $XX1 = $HashConfi_ref->{"global"}{"canvas_margin_left"} + $HashConfi_ref->{"global"}{"canvas_body"} + ($Level - 1) * $ColorBarSize * 4.5 + $HashConfi_ref->{$Level}{"colormap_legend_shift_x"} ;
	my $XX2 = $XX1 + $ColorBarSize;

	my $headLT="hist";
	if  ($NumPlotArry==1)
	{
	   my $NowPlotLT = $PlotInfo_ref->[0];
	   my $FileNowLT = $NowPlotLT->[0];
	   my $CoumnNowLT = $NowPlotLT->[1];
	   $headLT=$FileData_ref->[$FileNowLT][0][$CoumnNowLT];
	}

	draw_color_legend($svg,$LegendOffsetRatio, $Bodyheight, $ColorBarSize, $ColorGradientArray_ref, $ValueLabelsGradient_ref, $HashConfi_ref, $Level, 'rectangle',$headLT);


	my $MaxDiffValue = $HashConfi_ref->{$Level}{"Ymax"} - $HashConfi_ref->{$Level}{"Ymin"};
	my $HHstrokewidth = $HashConfi_ref->{$Level}{"stroke-width"};
	if ($NumPlotArry == 1) {  #单列数据处理逻辑略
		if ((exists $HashConfi_ref->{$Level}{"yaxis_tick_show"}) && ($HashConfi_ref->{$Level}{"yaxis_tick_show"} > 0)) 
		{
			draw_yaxis_ticks($HashConfi_ref,$Level,$ChrArry_ref, $hashYY1_ref, $hashYY2_ref, $svg, $fontsize);
		}
		my $NowPlot = $PlotInfo_ref->[0];
		my $FileNow = $NowPlot->[0];
		my $CoumnNow = $NowPlot->[1];
		my $StartCount = 0;

		if ($FileData_ref->[$FileNow][0][0] =~ s/#/#/) {
			$StartCount = 1;
		}

		for (; $StartCount < $FileRow_ref->[$FileNow]; $StartCount++) {
			my $Value = $FileData_ref->[$FileNow][$StartCount][$CoumnNow];
			next if $Value eq "NA";
			$Value = CheckValueNow($HashConfi_ref, $Level, $Value);

			my $ThisChrName = $FileData_ref->[$FileNow][$StartCount][0];
			next unless exists $hashYY1_ref->{$ThisChrName};

			my $StartSite = $FileData_ref->[$FileNow][$StartCount][1];
			my $EndSite   = $FileData_ref->[$FileNow][$StartCount][2];
			my $YY1       = $hashYY1_ref->{$ThisChrName}{$Level};
			my $YY2       = $hashYY2_ref->{$ThisChrName}{$Level};

			$YY1 = $YY2 - ($YY2 - $YY1) * ($Value - $HashConfi_ref->{$Level}{"Ymin"}) / $MaxDiffValue;
			my $XX1 = sprintf("%.1f", ($StartSite / $ChrMax) * $HashConfi_ref->{"global"}{"canvas_bodyOO"} + $hashXX1_ref->{$ThisChrName}{$Level});
			my $XX2 = sprintf("%.1f", ($EndSite / $ChrMax) * $HashConfi_ref->{"global"}{"canvas_bodyOO"} + $hashXX1_ref->{$ThisChrName}{$Level});

			if (exists $ValueToCustomColor_ref->{$Value}) {
				$ValueToColor_ref->{$Value} = $ValueToCustomColor_ref->{$Value};
			}

			my $path = $svg->get_path(
				x => [$XX1, $XX1, $XX2, $XX2],
				y => [$YY1, $YY2, $YY2, $YY1],
				-type => 'polygon'
			);

			$svg->polygon(
				%$path,
				style => {
					'fill'           => $ValueToColor_ref->{$Value},
					'stroke'         => $ValueToColor_ref->{$Value},
					'stroke-width'   => $HHstrokewidth,
					'stroke-opacity' => $HashConfi_ref->{$Level}{"stroke-opacity"},
					'fill-opacity'   => $HashConfi_ref->{$Level}{"fill-opacity"},
				},
			);
		}
	} else {
		if ((exists $HashConfi_ref->{$Level}{"yaxis_tick_show"}) && ($HashConfi_ref->{$Level}{"yaxis_tick_show"} > 0)) {
			my $StartYLevel = sprintf("%.1f", $HashConfi_ref->{$Level}{"Ymin"} * 1.0);
			my $EndYLevel   = sprintf("%.1f", $HashConfi_ref->{$Level}{"Ymax"} * 1.0);
			my $countTmpChr = $#$ChrArry_ref;
			if ($HashConfi_ref->{"global"}{"chr_orientation"} ne "vertical") {
				$countTmpChr = 0;
			}

			foreach my $thisChr (0 .. $countTmpChr) {
				my $ThisChrName = $ChrArry_ref->[$thisChr];
				my $XX2 = $HashConfi_ref->{"global"}{"canvas_margin_left"} - $fontsize * 0.5;
				my $YY1 = $hashYY1_ref->{$ThisChrName}{$Level} + $fontsize * 0.1;
				my $YY2 = $hashYY2_ref->{$ThisChrName}{$Level} - $fontsize * 0.1;

				$svg->text(
					'text-anchor', 'middle',
					'x', $XX2,
					'y', $YY1,
					'-cdata', $EndYLevel,
					'font-family', $HashConfi_ref->{"global"}{"font-family"},
					'font-size', $fontsize * 0.32
				);

				$svg->text(
					'text-anchor', 'middle',
					'x', $XX2,
					'y', $YY2,
					'-cdata', $EndYLevel,
					'font-family', $HashConfi_ref->{"global"}{"font-family"},
					'font-size', $fontsize * 0.32
				);

				$svg->text(
					'text-anchor', 'middle',
					'x', $XX2,
					'y', ($YY2 + $YY1) / 2,
					'-cdata', $StartYLevel,
					'font-family', $HashConfi_ref->{"global"}{"font-family"},
					'font-size', $fontsize * 0.32
				);
			}
		}

		my $NowPlot = $PlotInfo_ref->[0];
		my $FileNow = $NowPlot->[0];
		my $CoumnNow = $NowPlot->[1];
		my $StartCount = 0;

		if ($FileData_ref->[$FileNow][0][0] =~ s/#/#/) {
			$StartCount = 1;
		}

		for (; $StartCount < $FileRow_ref->[$FileNow]; $StartCount++) {
			my $Value = $FileData_ref->[$FileNow][$StartCount][$CoumnNow];
			next if $Value eq "NA";
			$Value = CheckValueNow($HashConfi_ref, $Level, $Value);

			my $ThisChrName = $FileData_ref->[$FileNow][$StartCount][0];
			next unless exists $hashYY1_ref->{$ThisChrName};

			my $StartSite = $FileData_ref->[$FileNow][$StartCount][1];
			my $EndSite   = $FileData_ref->[$FileNow][$StartCount][2];
			my $YY1       = $hashYY1_ref->{$ThisChrName}{$Level};
			my $YY2       = $hashYY2_ref->{$ThisChrName}{$Level};

			$YY2 = ($YY1 + $YY2) / 2;
			$YY1 = $YY2 - ($YY2 - $YY1) * ($Value - $HashConfi_ref->{$Level}{"Ymin"}) / $MaxDiffValue;
			my $XX1 = sprintf("%.1f", ($StartSite / $ChrMax) * $HashConfi_ref->{"global"}{"canvas_bodyOO"} + $hashXX1_ref->{$ThisChrName}{$Level});
			my $XX2 = sprintf("%.1f", ($EndSite / $ChrMax) * $HashConfi_ref->{"global"}{"canvas_bodyOO"} + $hashXX1_ref->{$ThisChrName}{$Level});

			my $path = $svg->get_path(
				x => [$XX1, $XX1, $XX2, $XX2],
				y => [$YY1, $YY2, $YY2, $YY1],
				-type => 'polygon'
			);

			$svg->polygon(
				%$path,
				style => {
					'fill'           => $ColorGradientArray_ref->[0],
					'stroke'         => $ColorGradientArray_ref->[0],
					'stroke-width'   => $HHstrokewidth,
					'stroke-opacity' => $HashConfi_ref->{$Level}{"stroke-opacity"},
					'fill-opacity'   => $HashConfi_ref->{$Level}{"fill-opacity"},
				},
			);
		}

		$NowPlot = $PlotInfo_ref->[1];
		$FileNow = $NowPlot->[0];
		$CoumnNow = $NowPlot->[1];
		$StartCount = 0;

		if ($FileData_ref->[$FileNow][0][0] =~ s/#/#/) {
			$StartCount = 1;
		}

		for (; $StartCount < $FileRow_ref->[$FileNow]; $StartCount++) {
			my $Value = $FileData_ref->[$FileNow][$StartCount][$CoumnNow];
			next if $Value eq "NA";
			$Value = CheckValueNow($HashConfi_ref, $Level, $Value);

			my $ThisChrName = $FileData_ref->[$FileNow][$StartCount][0];
			next unless exists $hashYY1_ref->{$ThisChrName};

			my $StartSite = $FileData_ref->[$FileNow][$StartCount][1];
			my $EndSite   = $FileData_ref->[$FileNow][$StartCount][2];
			my $YY1       = $hashYY1_ref->{$ThisChrName}{$Level};
			my $YY2       = $hashYY2_ref->{$ThisChrName}{$Level};

			$YY1 = ($YY1 + $YY2) / 2;
			$YY2 = $YY1 + ($YY2 - $YY1) * ($Value - $HashConfi_ref->{$Level}{"Ymin"}) / $MaxDiffValue;
			my $XX1 = sprintf("%.1f", ($StartSite / $ChrMax) * $HashConfi_ref->{"global"}{"canvas_bodyOO"} + $hashXX1_ref->{$ThisChrName}{$Level});
			my $XX2 = sprintf("%.1f", ($EndSite / $ChrMax) * $HashConfi_ref->{"global"}{"canvas_bodyOO"} + $hashXX1_ref->{$ThisChrName}{$Level});

			my $path = $svg->get_path(
				x => [$XX1, $XX1, $XX2, $XX2],
				y => [$YY1, $YY2, $YY2, $YY1],
				-type => 'polygon'
			);

			$svg->polygon(
				%$path,
				style => {
					'fill'           => $ColorGradientArray_ref->[1],
					'stroke'         => $ColorGradientArray_ref->[1],
					'stroke-width'   => $HHstrokewidth,
					'stroke-opacity' => $HashConfi_ref->{$Level}{"stroke-opacity"},
					'fill-opacity'   => $HashConfi_ref->{$Level}{"fill-opacity"},
				},
			);
		}
	}

	if (exists $HashConfi_ref->{$Level}{"cutoff_y"}) {
		draw_cutoff_line($HashConfi_ref, $Level, $svg, $ChrArry_ref, $hashChr_ref, $hashXX1_ref, $hashYY1_ref, $hashYY2_ref, $ChrMax, $MaxDiffValue, "cutoff_y");
	}
	if (exists $HashConfi_ref->{$Level}{"cutoff1_y"}) {
		draw_cutoff_line($HashConfi_ref, $Level, $svg, $ChrArry_ref, $hashChr_ref, $hashXX1_ref, $hashYY1_ref, $hashYY2_ref, $ChrMax, $MaxDiffValue, "cutoff1_y");
	}
	if (exists $HashConfi_ref->{$Level}{"cutoff2_y"}) {
		draw_cutoff_line($HashConfi_ref, $Level, $svg, $ChrArry_ref, $hashChr_ref, $hashXX1_ref, $hashYY1_ref, $hashYY2_ref, $ChrMax, $MaxDiffValue, "cutoff2_y");
	}





}

#####  # Plots points on the genome map  ######
sub plot_point {
	my ($HashConfi_ref, $ValueToColor_ref, $Level, $svg, $hashYY1_ref, $hashYY2_ref, $hashXX1_ref,
		$ChrMax, $NumPlotArry, $PlotInfo_ref, $FileData_ref, $FileRow_ref, $ValueToCustomColor_ref,
		$ColorGradientArray_ref, $ValueLabelsGradient_ref, $ColorBarSize,$Bodyheight, 
		$LegendOffsetRatio, $GradientSteps, $fontsize,$ChrArry_ref,$hashChr_ref,$Precision) = @_;


	my $cirsize = $ColorBarSize / 12;
	if (exists $HashConfi_ref->{$Level}{"track_point_size"} && $HashConfi_ref->{$Level}{"track_point_size"} > 0) {
		$cirsize *= $HashConfi_ref->{$Level}{"track_point_size"};
	}

	my $MaxDiffValue = $HashConfi_ref->{$Level}{"Ymax"} - $HashConfi_ref->{$Level}{"Ymin"};

	if ((exists $HashConfi_ref->{$Level}{"yaxis_tick_show"}) && ($HashConfi_ref->{$Level}{"yaxis_tick_show"} > 0)) 
	{
		draw_yaxis_ticks($HashConfi_ref,$Level,$ChrArry_ref, $hashYY1_ref, $hashYY2_ref, $svg, $fontsize);
	}

	if ($NumPlotArry == 1) {
		my $YY1 = $HashConfi_ref->{"global"}{"canvas_margin_top"} + $LegendOffsetRatio * $Bodyheight + $HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
		my $YY2 = $YY1 + $ColorBarSize * ($GradientSteps + 1);
		my $XX1 = $HashConfi_ref->{"global"}{"canvas_margin_left"} + $HashConfi_ref->{"global"}{"canvas_body"} + ($Level - 1) * $ColorBarSize * 4.8 + $HashConfi_ref->{$Level}{"colormap_legend_shift_x"} ;
		my $XX2 = $XX1 + $ColorBarSize;

		my $NowPlot = $PlotInfo_ref->[0];
		my $FileNow = $NowPlot->[0];
		my $CoumnNow = $NowPlot->[1];
		my $StartCount = 0;
		my $headLT=$FileData_ref->[$FileNow][0][$CoumnNow];

		draw_color_legend($svg,$LegendOffsetRatio, $Bodyheight, $ColorBarSize, $ColorGradientArray_ref, $ValueLabelsGradient_ref, $HashConfi_ref, $Level, 'circle',$headLT);



		if (defined($FileData_ref->[$FileNow][0][0]) && $FileData_ref->[$FileNow][0][0] =~ s/#/#/) {
			$StartCount = 1;
		}

		my %Uniq;
		for (; $StartCount < $FileRow_ref->[$FileNow]; $StartCount++) {
			my $Value = $FileData_ref->[$FileNow][$StartCount][$CoumnNow];
			next if $Value eq "NA";
			$Value = CheckValueNow($HashConfi_ref, $Level, $Value);

			my $ThisChrName = $FileData_ref->[$FileNow][$StartCount][0];
			next unless exists $hashYY1_ref->{$ThisChrName};

			my $StartSite = $FileData_ref->[$FileNow][$StartCount][1];
			my $EndSite   = $FileData_ref->[$FileNow][$StartCount][2];

			my $YY1 = $hashYY1_ref->{$ThisChrName}{$Level};
			my $YY2 = $hashYY2_ref->{$ThisChrName}{$Level};
			$YY1 = sprintf("%.1f", $YY2 - ($YY2 - $YY1) * ($Value - $HashConfi_ref->{$Level}{"Ymin"}) / $MaxDiffValue);
			my $XX1 = sprintf("%.1f", ($StartSite / $ChrMax) * $HashConfi_ref->{"global"}{"canvas_bodyOO"} + $hashXX1_ref->{$ThisChrName}{$Level});
			my $key = "$XX1\_$YY1";
			next if exists $Uniq{$key};

			if (exists $ValueToCustomColor_ref->{$Value}) {
				$ValueToColor_ref->{$Value} = $ValueToCustomColor_ref->{$Value};
			}

			$svg->circle(
				cx => $XX1,
				cy => $YY1,
				r  => $cirsize,
				fill => $ValueToColor_ref->{$Value}
			);
			$Uniq{$key} = 1;
		}
	} else {
		my $NumGradien = $NumPlotArry;

		if (!exists $HashConfi_ref->{$Level}{"colormap_brewer_name"}) {
			my @StartRGB = ColorPaletteManager::HTML2RGB($HashConfi_ref->{$Level}{"colormap_low_color"});
			my @EndRGB   = ColorPaletteManager::HTML2RGB($HashConfi_ref->{$Level}{"colormap_high_color"});
			my @MidRGB   = ColorPaletteManager::HTML2RGB($HashConfi_ref->{$Level}{"colormap_mid_color"});

			@{$ColorGradientArray_ref} = ();
			ColorPaletteManager::generate_gradient_colors(\@StartRGB, \@MidRGB, \@EndRGB, $NumGradien, $ColorGradientArray_ref);
			$ColorGradientArray_ref->[$NumPlotArry] = $HashConfi_ref->{$Level}{"colormap_high_color"};
			if ($NumPlotArry == 2) {
				$ColorGradientArray_ref->[1] = $HashConfi_ref->{$Level}{"colormap_high_color"};
			}
		} else {
			@{$ColorGradientArray_ref} = ();
			my $ColFlag = $HashConfi_ref->{$Level}{"colormap_brewer_name"};
			ColorPaletteManager::GetColGradien($ColFlag, $NumGradien, $ColorGradientArray_ref,$HashConfi_ref);
			if (exists $HashConfi_ref->{$Level}{"colormap_reverse"}) {
				@{$ColorGradientArray_ref} = reverse @{$ColorGradientArray_ref};
			}
		}

		foreach my $k (1..$NumPlotArry) {
			my $NowPlot = $PlotInfo_ref->[$k - 1];
			my $FileNow = $NowPlot->[0];
			my $CoumnNow = $NowPlot->[1];
			my $StartCount = 0;
			$ValueLabelsGradient_ref->[$k - 1] = $FileData_ref->[$FileNow][0][$CoumnNow];

			my $XX1 = $HashConfi_ref->{"global"}{"canvas_margin_left"} + $HashConfi_ref->{"global"}{"canvas_body"} + ($Level - 1) * $ColorBarSize * 4.5 + $HashConfi_ref->{$Level}{"colormap_legend_shift_x"} ;
			my $XX2 = $XX1 + $ColorBarSize;
			my $YY1 = $HashConfi_ref->{"global"}{"canvas_margin_top"} + $LegendOffsetRatio * $Bodyheight + $ColorBarSize * ($k - 1) + $HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
			my $YY2 = $YY1 + $ColorBarSize;



			if ($FileData_ref->[$FileNow][0][0] =~ s/#/#/) {
				$StartCount = 1;
			}

			my %Uniq;
			for (; $StartCount < $FileRow_ref->[$FileNow]; $StartCount++) {
				my $Value = $FileData_ref->[$FileNow][$StartCount][$CoumnNow];
				next if $Value eq "NA";
				$Value = CheckValueNow($HashConfi_ref, $Level, $Value);

				my $ThisChrName = $FileData_ref->[$FileNow][$StartCount][0];
				next unless exists $hashYY1_ref->{$ThisChrName};

				my $StartSite = $FileData_ref->[$FileNow][$StartCount][1];
				my $EndSite   = $FileData_ref->[$FileNow][$StartCount][2];

				my $YY1 = $hashYY1_ref->{$ThisChrName}{$Level};
				my $YY2 = $hashYY2_ref->{$ThisChrName}{$Level};
				$YY1 = sprintf("%.1f", $YY2 - ($YY2 - $YY1) * ($Value - $HashConfi_ref->{$Level}{"Ymin"}) / $MaxDiffValue);
				my $XX1 = sprintf("%.1f", ($StartSite / $ChrMax) * $HashConfi_ref->{"global"}{"canvas_bodyOO"} + $hashXX1_ref->{$ThisChrName}{$Level});
				my $key = "$XX1\_$YY1";
				next if exists $Uniq{$key};

				$svg->circle(
					cx => $XX1,
					cy => $YY1,
					r  => $cirsize,
					fill => $ColorGradientArray_ref->[$k - 1]
				);
				$Uniq{$key} = 1;
			}
		}

		@$ColorGradientArray_ref = @$ColorGradientArray_ref[0..($NumPlotArry - 1)];
		draw_color_legend($svg, $LegendOffsetRatio, $Bodyheight, $ColorBarSize, $ColorGradientArray_ref, $ValueLabelsGradient_ref, $HashConfi_ref, $Level, 'circle',"circle");
	}

	if (exists $HashConfi_ref->{$Level}{"cutoff_y"}) {
		draw_cutoff_line($HashConfi_ref, $Level, $svg, $ChrArry_ref, $hashChr_ref, $hashXX1_ref, $hashYY1_ref, $hashYY2_ref, $ChrMax, $MaxDiffValue, "cutoff_y");
	}
	if (exists $HashConfi_ref->{$Level}{"cutoff1_y"}) {
		draw_cutoff_line($HashConfi_ref, $Level, $svg, $ChrArry_ref, $hashChr_ref, $hashXX1_ref, $hashYY1_ref, $hashYY2_ref, $ChrMax, $MaxDiffValue, "cutoff1_y");
	}
	if (exists $HashConfi_ref->{$Level}{"cutoff2_y"}) {
		draw_cutoff_line($HashConfi_ref, $Level, $svg, $ChrArry_ref, $hashChr_ref, $hashXX1_ref, $hashYY1_ref, $hashYY2_ref, $ChrMax, $MaxDiffValue, "cutoff2_y");
	}


}


##### # Plots shapes (e.g., circles, triangles) at specified genomic locations ####
sub plot_shape {
	my ($HashConfi_ref, $ValueToColor_ref, $Level, $svg, $hashYY1_ref, $hashYY2_ref, $hashXX1_ref,
		$ChrMax, $NumPlotArry, $PlotInfo, $FileData_ref, $FileRow_ref, $ValueToCustomColor_ref, $ColorGradientArray_ref,
		$ValueLabelsGradient_ref, $ColorBarSize, $Bodyheight, $LegendOffsetRatio, $GradientSteps,
		$fontsize, $ChrArry_ref, $hashChr_ref, $Precision) = @_;

	my $cirsize = $ColorBarSize / 12;
	if ((exists $HashConfi_ref->{$Level}{"track_point_size"}) && ($HashConfi_ref->{$Level}{"track_point_size"} > 0)) {
		$cirsize *= $HashConfi_ref->{$Level}{"track_point_size"};
	}
	if ((exists $HashConfi_ref->{$Level}{"track_geom_shape_size"}) && ($HashConfi_ref->{$Level}{"track_geom_shape_size"} > 0)) {
		$cirsize *= $HashConfi_ref->{$Level}{"track_geom_shape_size"};
	}

	my $MaxDiffValue = 1;
	if ($HashConfi_ref->{$Level}{"IsNumber"} == 1) 
	{
		$MaxDiffValue = $HashConfi_ref->{$Level}{"Ymax"} - $HashConfi_ref->{$Level}{"Ymin"};
		if ((exists $HashConfi_ref->{$Level}{"yaxis_tick_show"}) && ($HashConfi_ref->{$Level}{"yaxis_tick_show"} > 0))
		{
			draw_yaxis_ticks($HashConfi_ref,$Level,$ChrArry_ref, $hashYY1_ref, $hashYY2_ref, $svg, $fontsize);
		}
	}

	if ($NumPlotArry == 1) {
		#my $YY1 = $HashConfi_ref->{"global"}{"canvas_margin_top"} + $LegendOffsetRatio * $Bodyheight + $HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
		#my $YY2 = $YY1 + $ColorBarSize * ($GradientSteps + 1);
		#my $XX1 = $HashConfi_ref->{"global"}{"canvas_margin_left"} + $HashConfi_ref->{"global"}{"canvas_body"} + ($Level - 1) * $ColorBarSize * 4.8 + $HashConfi_ref->{$Level}{"colormap_legend_shift_x"} +$ColorBarSize;
		#my $XX2 = $XX1 + $ColorBarSize;

		my @shapeType = map { $_ % 20 } 0 .. $GradientSteps;
		if (exists $HashConfi_ref->{$Level}{"track_geom_shape"}) {
			my @ccc = split(/,/, $HashConfi_ref->{$Level}{"track_geom_shape"});
			foreach my $k (0 .. $#ccc) {
				if ($ccc[$k] < 20) {
					$shapeType[$k] = $ccc[$k];
				}
			}
		}

		my %Col2Shape;

		foreach my $k (0 .. $GradientSteps) {
				$Col2Shape{$ColorGradientArray_ref->[$k]} = $shapeType[$k];
			}

		
		my $NowPlot = $PlotInfo->[0];
		my $FileNow = $NowPlot->[0];
		my $CoumnNow = $NowPlot->[1];
		my $StartCount = $FileData_ref->[$FileNow][0][0] =~ s/#/#/ ? 1 : 0;
		my %Uniq;
		my $headLT=$FileData_ref->[$FileNow][0][$CoumnNow];

		draw_color_legend($svg,$LegendOffsetRatio, $Bodyheight, $ColorBarSize, $ColorGradientArray_ref, $ValueLabelsGradient_ref, $HashConfi_ref, $Level, 'shape',$headLT,\@shapeType);

		for (; $StartCount < $FileRow_ref->[$FileNow]; $StartCount++) {
			my $Value = $FileData_ref->[$FileNow][$StartCount][$CoumnNow];
			next if $Value eq "NA";
			$Value = CheckValueNow($HashConfi_ref, $Level, $Value);

			my $ThisChrName = $FileData_ref->[$FileNow][$StartCount][0];
			next unless exists $hashYY1_ref->{$ThisChrName};

			my $StartSite = $FileData_ref->[$FileNow][$StartCount][1];
			my $EndSite   = $FileData_ref->[$FileNow][$StartCount][2];

			my $YY1 = $hashYY1_ref->{$ThisChrName}{$Level};
			my $YY2 = $hashYY2_ref->{$ThisChrName}{$Level};

			if ($HashConfi_ref->{$Level}{"IsNumber"} == 1) {
				$YY1 = sprintf("%.1f", $YY2 - ($YY2 - $YY1) * ($Value - $HashConfi_ref->{$Level}{"Ymin"}) / $MaxDiffValue);
			} else {
				$YY1 = ($YY1 + $YY2) * 0.5;
			}

			my $XX1 = sprintf("%.1f", ($StartSite / $ChrMax) * $HashConfi_ref->{"global"}{"canvas_bodyOO"} + $hashXX1_ref->{$ThisChrName}{$Level});
			my $shapeT = $Col2Shape{$ValueToColor_ref->{$Value}};
			my $key = "$XX1\_$YY1\_$shapeT";
			next if exists $Uniq{$key};

			if (exists $ValueToCustomColor_ref->{$Value}) {
				$ValueToColor_ref->{$Value} = $ValueToCustomColor_ref->{$Value};
			}
			ColorPaletteManager::SVGgetShape($XX1, $YY1, $cirsize, $shapeT, $ValueToColor_ref->{$Value}, $svg);
			$Uniq{$key} = 1;
		}
	} else {
		my $NumGradien = $NumPlotArry;

		if (!exists $HashConfi_ref->{$Level}{"colormap_brewer_name"}) {
			my @StartRGB = ColorPaletteManager::HTML2RGB($HashConfi_ref->{$Level}{"colormap_low_color"});
			my @MidRGB   = ColorPaletteManager::HTML2RGB($HashConfi_ref->{$Level}{"colormap_mid_color"});
			my @EndRGB   = ColorPaletteManager::HTML2RGB($HashConfi_ref->{$Level}{"colormap_high_color"});
			@{$ColorGradientArray_ref} = ();
			ColorPaletteManager::generate_gradient_colors(\@StartRGB, \@MidRGB, \@EndRGB, $NumGradien, $ColorGradientArray_ref);
			$ColorGradientArray_ref->[$NumPlotArry] = $HashConfi_ref->{$Level}{"colormap_high_color"};
			$ColorGradientArray_ref->[1] = $HashConfi_ref->{$Level}{"colormap_high_color"} if $NumPlotArry == 2;
		} else {
			@{$ColorGradientArray_ref} = ();
			my $ColFlag = $HashConfi_ref->{$Level}{"colormap_brewer_name"};
			ColorPaletteManager::GetColGradien($ColFlag, $NumGradien, $ColorGradientArray_ref,$HashConfi_ref);
			if (exists $HashConfi_ref->{$Level}{"colormap_reverse"}) {
				my @cccTmpCor;
				foreach my $k (0 .. $#$ColorGradientArray_ref) {
					$cccTmpCor[$#{$ColorGradientArray_ref} - $k] = $ColorGradientArray_ref->[$k];
				}
				@$ColorGradientArray_ref = @cccTmpCor;
			}
		}

		my @shapeType = map { $_ % 20 } 0 .. $NumPlotArry - 1;
		if (exists $HashConfi_ref->{$Level}{"track_geom_shape"}) {
			my @ccc = split(/,/, $HashConfi_ref->{$Level}{"track_geom_shape"});
			foreach my $k (0 .. $#ccc) {
				if ($ccc[$k] < 20) {
					$shapeType[$k] = $ccc[$k];
				}
			}
		}

		foreach my $k (1 .. $NumPlotArry) {
			my $ThisBoxbin = $k - 1;
			my $NowPlot   = $PlotInfo->[$ThisBoxbin];
			my $FileNow   = $NowPlot->[0];
			my $CoumnNow  = $NowPlot->[1];
			my $shapeT    = $shapeType[$ThisBoxbin];
			$ValueLabelsGradient_ref->[$ThisBoxbin] = $FileData_ref->[$FileNow][0][$CoumnNow];

			#my $XX1 = $HashConfi_ref->{"global"}{"canvas_margin_left"} + $HashConfi_ref->{"global"}{"canvas_body"} +($Level - 1) * $ColorBarSize * 4.5 + $HashConfi_ref->{$Level}{"colormap_legend_shift_x"} ;
			#my $XX2 = $XX1 + $ColorBarSize;
			#			my $YY1 = $HashConfi_ref->{"global"}{"canvas_margin_top"} + $LegendOffsetRatio * $Bodyheight +	$ColorBarSize * ($k - 1) + $HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
			#my $YY2 = $YY1 + $ColorBarSize;

			my $StartCount = $FileData_ref->[$FileNow][0][0] =~ s/#/#/ ? 1 : 0;
			my %Uniq;
			for (; $StartCount < $FileRow_ref->[$FileNow]; $StartCount++) {
				my $Value = $FileData_ref->[$FileNow][$StartCount][$CoumnNow];
				next if $Value eq "NA";
				$Value = CheckValueNow($HashConfi_ref, $Level, $Value);

				my $ThisChrName = $FileData_ref->[$FileNow][$StartCount][0];
				next unless exists $hashYY1_ref->{$ThisChrName};

				my $StartSite = $FileData_ref->[$FileNow][$StartCount][1];
				my $EndSite   = $FileData_ref->[$FileNow][$StartCount][2];

				my $YY1 = $hashYY1_ref->{$ThisChrName}{$Level};
				my $YY2 = $hashYY2_ref->{$ThisChrName}{$Level};

				if ($HashConfi_ref->{$Level}{"IsNumber"} == 1) {
					$YY1 = sprintf("%.1f", $YY2 - ($YY2 - $YY1) * ($Value - $HashConfi_ref->{$Level}{"Ymin"}) / $MaxDiffValue);
				} else {
					$YY1 = ($YY1 + $YY2) * 0.5;
				}

				my $XX1 = sprintf("%.1f", ($StartSite / $ChrMax) * $HashConfi_ref->{"global"}{"canvas_bodyOO"} + $hashXX1_ref->{$ThisChrName}{$Level});
				my $key = "$XX1\_$YY1\_$shapeType[$ThisBoxbin]";
				next if exists $Uniq{$key};

				ColorPaletteManager::SVGgetShape($XX1, $YY1, $cirsize, $shapeT, $ColorGradientArray_ref->[$ThisBoxbin], $svg);
				$Uniq{$key} = 1;
			}
		}

		my $max_index=$#{$ValueLabelsGradient_ref};	
		if ($max_index >= $NumPlotArry)
		{
    		for (my $i = $NumPlotArry; $i <= $max_index; $i++) 
			{
        		$ValueLabelsGradient_ref->[$i] = undef;
    		}
		}

	
		draw_color_legend($svg,$LegendOffsetRatio, $Bodyheight, $ColorBarSize, $ColorGradientArray_ref, $ValueLabelsGradient_ref, $HashConfi_ref, $Level, 'shape',"shape"  ,\@shapeType);


	}


	if (exists $HashConfi_ref->{$Level}{"cutoff_y"}) {
		draw_cutoff_line($HashConfi_ref, $Level, $svg, $ChrArry_ref, $hashChr_ref, $hashXX1_ref, $hashYY1_ref, $hashYY2_ref, $ChrMax, $MaxDiffValue, "cutoff_y");
	}
	if (exists $HashConfi_ref->{$Level}{"cutoff1_y"}) {
		draw_cutoff_line($HashConfi_ref, $Level, $svg, $ChrArry_ref, $hashChr_ref, $hashXX1_ref, $hashYY1_ref, $hashYY2_ref, $ChrMax, $MaxDiffValue, "cutoff1_y");
	}
	if (exists $HashConfi_ref->{$Level}{"cutoff2_y"}) {
		draw_cutoff_line($HashConfi_ref, $Level, $svg, $ChrArry_ref, $hashChr_ref, $hashXX1_ref, $hashYY1_ref, $hashYY2_ref, $ChrMax, $MaxDiffValue, "cutoff2_y");
	}




}





##### Adds text labels at specified genomic positions #####
sub plot_text {
	my ($HashConfi_ref, $ValueToColor_ref, $Level, $svg, $hashYY1_ref, $hashYY2_ref, $hashXX1_ref,
		$ChrMax, $NumPlotArry, $PlotInfo, $FileData_ref, $FileRow_ref, $ValueToCustomColor_ref, $ColorGradientArray_ref,
		$ValueLabelsGradient_ref, $ColorBarSize, $Bodyheight, $LegendOffsetRatio, $GradientSteps,
		$fontsize) = @_;

	if ($NumPlotArry > 1) {
		print "Error:\tFor -PType txt one Level [$Level] only One Plot,you can modify to add the Level for it or change the -PType\n";
		foreach my $i (0 .. $NumPlotArry - 1) {
			my $NowPlot = $PlotInfo->[$i];
			print "\t\tFile$NowPlot->[0]\tCoumn$NowPlot->[1]\n";
		}
		exit;
	}

	my $YY1 = $HashConfi_ref->{"global"}{"canvas_margin_top"} + $LegendOffsetRatio * $Bodyheight +
	$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
	my $YY2 = $YY1 + $ColorBarSize * ($GradientSteps + 1);
	my $XX1 = $HashConfi_ref->{"global"}{"canvas_margin_left"} + $HashConfi_ref->{"global"}{"canvas_body"} +
	($Level - 1) * $ColorBarSize * 4.5 + $HashConfi_ref->{$Level}{"colormap_legend_shift_x"};
	my $XX2 = $XX1 + $ColorBarSize;



	my $NowPlot = $PlotInfo->[0];
	my $FileNow = $NowPlot->[0];
	my $CoumnNow = $NowPlot->[1];
	my $StartCount = $FileData_ref->[$FileNow][0][0] =~ s/#/#/ ? 1 : 0;
	my $headLT=$FileData_ref->[$FileNow][0][$CoumnNow];

	draw_color_legend($svg,$LegendOffsetRatio, $Bodyheight, $ColorBarSize, $ColorGradientArray_ref, $ValueLabelsGradient_ref, $HashConfi_ref, $Level, 'text-only',$headLT);


	my $text_font_size = $fontsize * 0.5;
	if (exists $HashConfi_ref->{$Level}{"text-font-size"}) {
		$text_font_size = $HashConfi_ref->{$Level}{"text-font-size"};
	}
	if (exists $HashConfi_ref->{$Level}{"track_text_size"}) {
		$text_font_size *= $HashConfi_ref->{$Level}{"track_text_size"};
	}

	my $TextAnchor = "start";
	#my $TextAnchor = "middle";
	if (exists $HashConfi_ref->{$Level}{"track_text_anchor"}) {
		$TextAnchor = $HashConfi_ref->{$Level}{"track_text_anchor"};
	}


	my $LastXX=-100;
	my $LastYY=-100;
	my $track_height=$HashConfi_ref->{$Level}{"track_height"};
	my $HHY_Line=$track_height*0.1;
	my $HHY_LineAA=$HHY_Line*0.2;
	my $HHY_LineMM=$HHY_Line*0.6;
	my $FlagOver=0;

	my %sorted_data;
	for (; $StartCount < $FileRow_ref->[$FileNow]; $StartCount++)
	{
		my $Value = $FileData_ref->[$FileNow][$StartCount][$CoumnNow];
		next if $Value eq "NA";
		my $ThisChrName = $FileData_ref->[$FileNow][$StartCount][0];
		next unless exists $hashYY1_ref->{$ThisChrName};
		my $StartSite = $FileData_ref->[$FileNow][$StartCount][1];
		$sorted_data{$ThisChrName}{$StartSite}=$Value;
	}

	foreach  my $ThisChrName  (sort keys %sorted_data)
	{
		my $Tmp=$sorted_data{$ThisChrName};
		foreach my $StartSite  (sort {$a<=>$b} keys %$Tmp)
		{
			my $Value = $sorted_data{$ThisChrName}{$StartSite};
			$Value = CheckValueNow($HashConfi_ref, $Level, $Value);

			$YY1 = $hashYY1_ref->{$ThisChrName}{$Level};
			$YY2 = $hashYY2_ref->{$ThisChrName}{$Level};
			$XX1 = sprintf("%.1f", ($StartSite / $ChrMax) * $HashConfi_ref->{"global"}{"canvas_bodyOO"} + $hashXX1_ref->{$ThisChrName}{$Level});

			if (exists $ValueToCustomColor_ref->{$Value}) {
				$ValueToColor_ref->{$Value} = $ValueToCustomColor_ref->{$Value};
			}

			my $NowTrack_text_angle=$HashConfi_ref->{$Level}{"track_text_angle"}-90;
			my $track_text_overlap=5;
			if  (exists $HashConfi_ref->{$Level}{"track_text_overlap"})
			{
				$track_text_overlap=$HashConfi_ref->{$Level}{"track_text_overlap"} ;
			}

			if ( ($NowTrack_text_angle==-90  || $NowTrack_text_angle==270 ) && ($track_text_overlap>0))
			{

				my $XXNow=$XX1+$text_font_size*0.50;
				my $YYNowA=$YY2-$HHY_Line;

				#if ((abs($XXNow-$LastXX)<$text_font_size) && ($YYNowA == $LastYY))
				if ((($XXNow-$LastXX)<$text_font_size) && ($YYNowA == $LastYY))
				{
					$XXNow=$LastXX+$text_font_size;
					$FlagOver++;
				}
				else
				{
					$FlagOver=0;
				}

				if  ($FlagOver<$track_text_overlap)
				{
					$svg->text(
						'text-anchor', $TextAnchor,
						'x', $XXNow,
						'y', $YYNowA,
						'-cdata', "$Value",
						'fill', $ValueToColor_ref->{$Value},
						'font-family', $HashConfi_ref->{$Level}{"font-family"},
						'font-size', $text_font_size,
						'transform', "rotate(-90,$XXNow,$YYNowA)"
					);
					$LastXX=$XXNow;$LastYY=$YYNowA;
					$XXNow-=$text_font_size*0.50;
					$svg->line('x1', $XX1,'y1', $YY2,'x2', $XXNow,'y2', $YYNowA,'stroke', 'black','stroke-width', $HashConfi_ref->{"ALL"}{"stroke-width"});
				}

			}
			elsif ($NowTrack_text_angle != 0) {
				my $XXNow=$XX1+$text_font_size*0.54;
				#	$YY1 += ($YY2 - $YY1) * 3 / 5;
				$svg->text(
					'text-anchor', $TextAnchor,
					'x', $XXNow,
					'y', $YY2,
					'-cdata', "$Value",
					'fill', $ValueToColor_ref->{$Value},
					'font-family', $HashConfi_ref->{$Level}{"font-family"},
					'font-size', $text_font_size,
					'transform', "rotate($NowTrack_text_angle,$XXNow,$YY2)"
				);
			} else {
				$svg->text(
					'text-anchor', $TextAnchor,
					'x', $XX1,
					'y', $YY2,
					'-cdata', "$Value",
					'fill', $ValueToColor_ref->{$Value},
					'font-family', $HashConfi_ref->{$Level}{"font-family"},
					'font-size', $text_font_size
				);
			}
		}
	}
}



######## Plots ridgeline charts to show distribution across genomic regions #####
sub plot_ridgeline {
	my ($HashConfi_ref, $ValueToColor_ref, $Level, $svg, $hashYY1_ref, $hashYY2_ref, $hashXX1_ref,
		$ChrMax, $NumPlotArry, $PlotInfo, $FileData_ref, $FileRow_ref, $ValueToCustomColor_ref, $ColorGradientArray_ref,
		$ValueLabelsGradient_ref, $ColorBarSize, $Bodyheight, $LegendOffsetRatio, $GradientSteps,
		$fontsize, $ChrArry_ref, $hashChr_ref, $Precision) = @_;


	if ((exists $HashConfi_ref->{$Level}{"yaxis_tick_show"}) && ($HashConfi_ref->{$Level}{"yaxis_tick_show"} > 0)) 
	{
		draw_yaxis_ticks($HashConfi_ref,$Level,$ChrArry_ref, $hashYY1_ref, $hashYY2_ref, $svg, $fontsize);
	}

	if (!exists $HashConfi_ref->{$Level}{"colormap_brewer_name"}) {
		my @StartRGB = ColorPaletteManager::HTML2RGB($HashConfi_ref->{$Level}{"colormap_low_color"});
		my @EndRGB   = ColorPaletteManager::HTML2RGB($HashConfi_ref->{$Level}{"colormap_high_color"});
		my @MidRGB   = ColorPaletteManager::HTML2RGB($HashConfi_ref->{$Level}{"colormap_mid_color"});

		if ($NumPlotArry != 1) {
			@$ColorGradientArray_ref = ();
			LocalUtils::generate_gradient_colors(\@StartRGB, \@MidRGB, \@EndRGB, $NumPlotArry, $ColorGradientArray_ref);
		} else {
			$ColorGradientArray_ref->[0] = $HashConfi_ref->{$Level}{"colormap_low_color"};
		}
		$ColorGradientArray_ref->[$NumPlotArry] = $HashConfi_ref->{$Level}{"colormap_high_color"};
		if ($NumPlotArry == 2) {
			$ColorGradientArray_ref->[1] = $HashConfi_ref->{$Level}{"colormap_high_color"};
		}
	} else {
		my $ColFlag = $HashConfi_ref->{$Level}{"colormap_brewer_name"};
		ColorPaletteManager::GetColGradien($ColFlag, $NumPlotArry, $ColorGradientArray_ref,$HashConfi_ref);
		if (exists $HashConfi_ref->{$Level}{"colormap_reverse"}) {
			my @cccTmpCor = reverse @$ColorGradientArray_ref;
			@$ColorGradientArray_ref = @cccTmpCor;
		}
	}

	my $MaxDiffValue = $HashConfi_ref->{$Level}{"Ymax"} - $HashConfi_ref->{$Level}{"Ymin"};
	my $strokewidthV2 = $HashConfi_ref->{"ALL"}{"stroke-width"} * 0.88;
	if (exists $HashConfi_ref->{$Level}{"stroke-width"}) {
		$strokewidthV2 = $HashConfi_ref->{$Level}{"stroke-width"};
	}

	foreach my $tmpkk (1 .. $NumPlotArry) {
		my $ThisBoxbin = $tmpkk - 1;
		my $NowPlot    = $PlotInfo->[$ThisBoxbin];
		my $FileNow    = $NowPlot->[0];
		my $CoumnNow   = $NowPlot->[1];

		$ValueLabelsGradient_ref->[$ThisBoxbin] = "$FileData_ref->[$FileNow][0][$CoumnNow]";

		my $XX1 = $HashConfi_ref->{"global"}{"canvas_margin_left"} +
		$HashConfi_ref->{"global"}{"canvas_body"} +
		($Level - 1) * $ColorBarSize * 4.5 +
		$HashConfi_ref->{$Level}{"colormap_legend_shift_x"} ;
		my $XX2 = $XX1 + $ColorBarSize;
		my $YY1 = $HashConfi_ref->{"global"}{"canvas_margin_top"} +	$LegendOffsetRatio * $Bodyheight +	$ColorBarSize * $tmpkk +$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};

		my $YY2 = $YY1 + $ColorBarSize;

		my $StartCount = 0;
		if ($FileData_ref->[$FileNow][0][0] =~ s/#/#/) {
			$StartCount = 1;
		}

		my ($FirstPoint, $pointAX, $pointAY, $ChrThisNow) = (1, undef, undef, "NA");

		for (; $StartCount < $FileRow_ref->[$FileNow]; $StartCount++) {
			my $Value = $FileData_ref->[$FileNow][$StartCount][$CoumnNow];
			next if $Value eq "NA";
			$Value = CheckValueNow($HashConfi_ref, $Level, $Value);

			my $ThisChrName = $FileData_ref->[$FileNow][$StartCount][0];
			next unless exists $hashYY1_ref->{$ThisChrName};

			my $StartSite = $FileData_ref->[$FileNow][$StartCount][1];
			my $EndSite   = $FileData_ref->[$FileNow][$StartCount][2];
			$YY1 = $hashYY1_ref->{$ThisChrName}{$Level};
			$YY2 = $hashYY2_ref->{$ThisChrName}{$Level};
			$YY1 = $YY2 - ($YY2 - $YY1) * ($Value - $HashConfi_ref->{$Level}{"Ymin"}) / $MaxDiffValue;
			$XX1 = sprintf("%.1f", ($StartSite / $ChrMax) * $HashConfi_ref->{"global"}{"canvas_bodyOO"} + $hashXX1_ref->{$ThisChrName}{$Level});

			if ($FirstPoint || $ChrThisNow ne $ThisChrName) {
				($pointAX, $pointAY, $ChrThisNow, $FirstPoint) = ($XX1, $YY1, $ThisChrName, 0);
				next;
			}

			$svg->line(
				'x1', $pointAX,
				'y1', $pointAY,
				'x2', $XX1,
				'y2', $YY1,
				'stroke', $ColorGradientArray_ref->[$ThisBoxbin],
				'stroke-width', $strokewidthV2
			);

			my $path = $svg->get_path(
				x => [$pointAX, $XX1, $XX1, $pointAX],
				y => [$pointAY, $YY1, $YY2, $YY2],
				-type => 'polygon'
			);

			$svg->polygon(
				%$path,
				style => {
					'fill'           => $ColorGradientArray_ref->[$ThisBoxbin],
					'stroke'         => $ColorGradientArray_ref->[$ThisBoxbin],
					'stroke-width'   => $strokewidthV2,
					'stroke-opacity' => $HashConfi_ref->{$Level}{"stroke-opacity"},
					'fill-opacity'   => $HashConfi_ref->{$Level}{"fill-opacity"},
				},
			);

			($pointAX, $pointAY) = ($XX1, $YY1);
		}
	}

	my $max_index=$#{$ValueLabelsGradient_ref};	
	if ($max_index >= $NumPlotArry)
	{
    	for (my $i = $NumPlotArry; $i <= $max_index; $i++) 
		{
        	$ValueLabelsGradient_ref->[$i] = undef;
    	}
	}
	my $headLT="RT";
	if  ($NumPlotArry==1)
	{
		my $NowPlotLT    = $PlotInfo->[0];
		my $FileNowLT    = $NowPlotLT->[0];
		my $CoumnNowLT   = $NowPlotLT->[1];
		$headLT=$FileData_ref->[$FileNowLT][0][$CoumnNowLT];
	}

	draw_color_legend($svg,$LegendOffsetRatio, $Bodyheight, $ColorBarSize, $ColorGradientArray_ref, $ValueLabelsGradient_ref, $HashConfi_ref, $Level, 'rectangle',$headLT);
	if (exists $HashConfi_ref->{$Level}{"cutoff_y"}) {
		draw_cutoff_line($HashConfi_ref, $Level, $svg, $ChrArry_ref, $hashChr_ref, $hashXX1_ref, $hashYY1_ref, $hashYY2_ref, $ChrMax, $MaxDiffValue, "cutoff_y");
	}
	if (exists $HashConfi_ref->{$Level}{"cutoff1_y"}) {
		draw_cutoff_line($HashConfi_ref, $Level, $svg, $ChrArry_ref, $hashChr_ref, $hashXX1_ref, $hashYY1_ref, $hashYY2_ref, $ChrMax, $MaxDiffValue, "cutoff1_y");
	}
	if (exists $HashConfi_ref->{$Level}{"cutoff2_y"}) {
		draw_cutoff_line($HashConfi_ref, $Level, $svg, $ChrArry_ref, $hashChr_ref, $hashXX1_ref, $hashYY1_ref, $hashYY2_ref, $ChrMax, $MaxDiffValue, "cutoff2_y");
	}
}

###### # Helper: Draws cutoff lines for thresholds (Y-axis) ####
# 私有辅助函数：绘制截断线
sub draw_cutoff_line {
	my ($HashConfi_ref, $Level, $svg, $ChrArry_ref, $hashChr_ref, $hashXX1_ref, $hashYY1_ref, $hashYY2_ref, $ChrMax, $MaxDiffValue, $cutoff_key) = @_;
	my $Value = $HashConfi_ref->{$Level}{$cutoff_key};
	return if $Value >= $HashConfi_ref->{$Level}{"Ymax"} || $Value <= $HashConfi_ref->{$Level}{"Ymin"};

	my $HHstrokewidth = $HashConfi_ref->{$Level}{"stroke-width"} || 1;
	my ($AA, $BB) = ($HHstrokewidth * 3, $HHstrokewidth * 2);
	my $colrAA=${cutoff_key}; $colrAA=~s/_y/_color/g;
	my $corCutline = exists $HashConfi_ref->{$Level}{$colrAA} ? $HashConfi_ref->{$Level}{$colrAA} : "red";

	foreach my $thisChr (0 .. $#$ChrArry_ref) {
		my $ThisChrName = $ChrArry_ref->[$thisChr];
		next unless exists $hashYY1_ref->{$ThisChrName}{$Level};

		my $XX1 = sprintf("%.1f", $hashXX1_ref->{$ThisChrName}{$Level});
		my $XX2 = sprintf("%.1f", ($hashChr_ref->{$ThisChrName} / $ChrMax) * $HashConfi_ref->{"global"}{"canvas_bodyOO"} + $hashXX1_ref->{$ThisChrName}{$Level});
		my $YY1 = $hashYY1_ref->{$ThisChrName}{$Level};
		my $YY2 = $hashYY2_ref->{$ThisChrName}{$Level};
		my $labYY = $YY2 - ($YY2 - $YY1) * ($Value - $HashConfi_ref->{$Level}{"Ymin"}) / $MaxDiffValue;

		$svg->line(
			'x1', $XX1,
			'y1', $labYY,
			'x2', $XX2,
			'y2', $labYY,
			'stroke', $corCutline,
			'stroke-width', $HHstrokewidth,
			'stroke-dasharray', "$AA $BB"
		);
	}
}




#### # Plots connected lines between genomic features ####
sub plot_line {
	my ($HashConfi_ref, $ValueToColor_ref, $Level, $svg, $hashYY1_ref, $hashYY2_ref, $hashXX1_ref,
		$ChrMax, $NumPlotArry, $PlotInfo, $FileData_ref, $FileRow_ref, $ValueToCustomColor_ref, $ColorGradientArray_ref,
		$ValueLabelsGradient_ref, $ColorBarSize, $Bodyheight, $LegendOffsetRatio, $GradientSteps,
		$fontsize, $ChrArry_ref, $hashChr_ref, $Precision) = @_;

	# 绘制 Y 轴刻度标签（如果启用）
	if ((exists $HashConfi_ref->{$Level}{"yaxis_tick_show"}) && ($HashConfi_ref->{$Level}{"yaxis_tick_show"} > 0)) 
	{
		draw_yaxis_ticks($HashConfi_ref,$Level,$ChrArry_ref, $hashYY1_ref, $hashYY2_ref, $svg, $fontsize);
	}

	# 设置颜色映射
	my $NumGradien = $NumPlotArry;

	if (!exists $HashConfi_ref->{$Level}{"colormap_brewer_name"}) {
		my @StartRGB = ColorPaletteManager::HTML2RGB($HashConfi_ref->{$Level}{"colormap_low_color"});
		my @EndRGB   = ColorPaletteManager::HTML2RGB($HashConfi_ref->{$Level}{"colormap_high_color"});
		my @MidRGB   = ColorPaletteManager::HTML2RGB($HashConfi_ref->{$Level}{"colormap_mid_color"});

		if ($NumGradien != 1) {
			@$ColorGradientArray_ref = ();
			LocalUtils::generate_gradient_colors(\@StartRGB, \@MidRGB, \@EndRGB, $NumGradien, $ColorGradientArray_ref);
		} else {
			$ColorGradientArray_ref->[0] = $HashConfi_ref->{$Level}{"colormap_low_color"};
		}
		$ColorGradientArray_ref->[$NumPlotArry] = $HashConfi_ref->{$Level}{"colormap_high_color"};
		if ($NumPlotArry == 2) {
			$ColorGradientArray_ref->[1] = $HashConfi_ref->{$Level}{"colormap_high_color"};
		}
	} else {
		my $ColFlag = $HashConfi_ref->{$Level}{"colormap_brewer_name"};
		ColorPaletteManager::GetColGradien($ColFlag, $NumGradien, $ColorGradientArray_ref,$HashConfi_ref);

		if (exists $HashConfi_ref->{$Level}{"colormap_reverse"}) {
			my @cccTmpCor = reverse @$ColorGradientArray_ref;
			@$ColorGradientArray_ref = @cccTmpCor;
		}
	}

	# 自定义线条颜色配置
	if (exists $HashConfi_ref->{$Level}{"line_colors_conf"}) {
		my $bbb = $HashConfi_ref->{$Level}{"line_colors_conf"};
		open(my $fh, '<', $bbb) or die "can't open the line_colors_conf file $bbb  $!";
		while (<$fh>) {
			chomp;
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
			my ($NumberLines,$NewCor) = split(/\s*=\s*/,$_);
			$NumberLines++;
			$ColorGradientArray_ref->[$NumberLines] = $NewCor;
		}
		close $fh;
	}

	my $MaxDiffValue = $HashConfi_ref->{$Level}{"Ymax"} - $HashConfi_ref->{$Level}{"Ymin"};
	my $strokewidthV2 = $HashConfi_ref->{"ALL"}{"stroke-width"} * 0.88;
	$strokewidthV2 = $HashConfi_ref->{$Level}{"stroke-width"} if exists $HashConfi_ref->{$Level}{"stroke-width"};

	# 绘制每条线
	foreach my $tmpkk (1 .. $NumPlotArry) {
		my $ThisBoxbin = $tmpkk - 1;
		my $NowPlot    = $PlotInfo->[$ThisBoxbin];
		my $FileNow    = $NowPlot->[0];
		my $CoumnNow   = $NowPlot->[1];

		$ValueLabelsGradient_ref->[$ThisBoxbin] = "$FileData_ref->[$FileNow][0][$CoumnNow]";

		my $XX1 = $HashConfi_ref->{"global"}{"canvas_margin_left"} +
		$HashConfi_ref->{"global"}{"canvas_body"} +
		($Level - 1) * $ColorBarSize * 4.5 +
		$HashConfi_ref->{$Level}{"colormap_legend_shift_x"} ;
		my $XX2 = $XX1 + $ColorBarSize;
		my $YY1 = $HashConfi_ref->{"global"}{"canvas_margin_top"} +
		$LegendOffsetRatio * $Bodyheight +
		$ColorBarSize * $tmpkk +
		$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
		my $YY2 = $YY1 + $ColorBarSize;



		my $StartCount = 0;
		if ($FileData_ref->[$FileNow][0][0] =~ /^#/) {
			$StartCount = 1;
		}

		my ($FirstPoint, $pointAX, $pointAY, $ChrThisNow) = (1, undef, undef, "NA");

		for (; $StartCount < $FileRow_ref->[$FileNow]; $StartCount++) {
			my $Value = $FileData_ref->[$FileNow][$StartCount][$CoumnNow];
			if ($Value eq "NA")
			{
				$FirstPoint=1;
				next;
			}
			$Value = CheckValueNow($HashConfi_ref, $Level, $Value);

			my $ThisChrName = $FileData_ref->[$FileNow][$StartCount][0];
			next unless exists $hashYY1_ref->{$ThisChrName};

			my $StartSite = $FileData_ref->[$FileNow][$StartCount][1];
			my $EndSite   = $FileData_ref->[$FileNow][$StartCount][2];
			$YY1 = $hashYY1_ref->{$ThisChrName}{$Level};
			$YY2 = $hashYY2_ref->{$ThisChrName}{$Level};
			$YY1 = $YY2 - ($YY2 - $YY1) * ($Value - $HashConfi_ref->{$Level}{"Ymin"}) / $MaxDiffValue;
			$XX1 = sprintf("%.1f", ($StartSite / $ChrMax) * $HashConfi_ref->{"global"}{"canvas_bodyOO"} + $hashXX1_ref->{$ThisChrName}{$Level});

			if ($FirstPoint || $ChrThisNow ne $ThisChrName) {
				($pointAX, $pointAY, $ChrThisNow, $FirstPoint) = ($XX1, $YY1, $ThisChrName, 0);
				next;
			}

			$svg->line(
				'x1', $pointAX,
				'y1', $pointAY,
				'x2', $XX1,
				'y2', $YY1,
				'stroke', $ColorGradientArray_ref->[$ThisBoxbin],
				'stroke-width', $strokewidthV2
			);

			($pointAX, $pointAY) = ($XX1, $YY1);
		}
	}

	@$ColorGradientArray_ref = @$ColorGradientArray_ref[0..($NumPlotArry- 1)];
	my $headLT="lines";
	if  ($NumPlotArry==1)
	{
		my $NowPlotLT    = $PlotInfo->[0];
		my $FileNowLT    = $NowPlotLT->[0];
		my $CoumnNowLT   = $NowPlotLT->[1];
		$headLT=$FileData_ref->[$FileNowLT][0][$CoumnNowLT];
	}

	draw_color_legend($svg,$LegendOffsetRatio, $Bodyheight, $ColorBarSize, $ColorGradientArray_ref, $ValueLabelsGradient_ref, $HashConfi_ref, $Level, 'lines',$headLT);

	if (exists $HashConfi_ref->{$Level}{"cutoff_y"}) {
		draw_cutoff_line($HashConfi_ref, $Level, $svg, $ChrArry_ref, $hashChr_ref, $hashXX1_ref, $hashYY1_ref, $hashYY2_ref, $ChrMax, $MaxDiffValue, "cutoff_y");
	}
	if (exists $HashConfi_ref->{$Level}{"cutoff1_y"}) {
		draw_cutoff_line($HashConfi_ref, $Level, $svg, $ChrArry_ref, $hashChr_ref, $hashXX1_ref, $hashYY1_ref, $hashYY2_ref, $ChrMax, $MaxDiffValue, "cutoff1_y");
	}
	if (exists $HashConfi_ref->{$Level}{"cutoff2_y"}) {
		draw_cutoff_line($HashConfi_ref, $Level, $svg, $ChrArry_ref, $hashChr_ref, $hashXX1_ref, $hashYY1_ref, $hashYY2_ref, $ChrMax, $MaxDiffValue, "cutoff2_y");
	}


}




##### Animated version of heatmap with transitions over time ####
sub plot_heatmap_animated {
	my ($HashConfi_ref, $ValueToColor_ref, $Level, $svg, $hashYY1_ref, $hashYY2_ref, $hashXX1_ref,
		$ChrMax, $NumPlotArry, $PlotInfo, $FileData_ref, $FileRow_ref, $ValueToCustomColor_ref, $ColorGradientArray_ref,
		$ValueLabelsGradient_ref, $ColorBarSize, $Bodyheight, $LegendOffsetRatio, $GradientSteps,
		$fontsize, $ChrArry_ref, $hashChr_ref, $Precision) = @_;

	my $YY1 = $HashConfi_ref->{"global"}{"canvas_margin_top"} + $LegendOffsetRatio * $Bodyheight +
	$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
	my $YY2 = $YY1 + $ColorBarSize * ($GradientSteps + 1);
	my $XX1 = $HashConfi_ref->{"global"}{"canvas_margin_left"} + $HashConfi_ref->{"global"}{"canvas_body"} +
	($Level - 1) * $ColorBarSize * 4.5 + $HashConfi_ref->{$Level}{"colormap_legend_shift_x"} ;
	my $XX2 = $XX1 + $ColorBarSize;



	draw_color_legend($svg,$LegendOffsetRatio, $Bodyheight, $ColorBarSize, $ColorGradientArray_ref, $ValueLabelsGradient_ref, $HashConfi_ref, $Level, 'rectangle',"ATime");


	my $HeatMapstrokewidth = $HashConfi_ref->{$Level}{"stroke-width"};

	# 动态文本动画部分
	my ($ThisBoxbin, $NowPlot, $CoumnNow, $FileNow, $StartCount) = (undef, undef, undef, undef, 0);
	my @NowPLotCoumn;
	my ($animationLabelText, $textData) = ("", "");

	foreach my $tmpkk (1 .. 1) {
		$ThisBoxbin = $tmpkk - 1;
		$NowPlot    = $PlotInfo->[$ThisBoxbin];
		$FileNow    = $NowPlot->[0];
		$CoumnNow   = $NowPlot->[1];
		$NowPLotCoumn[$ThisBoxbin] = $CoumnNow;
		$animationLabelText = $FileData_ref->[$FileNow][0][$CoumnNow];
	}

	foreach my $tmpkk (2 .. $NumPlotArry) {
		$ThisBoxbin = $tmpkk - 1;
		$NowPlot    = $PlotInfo->[$ThisBoxbin];
		$FileNow    = $NowPlot->[0];
		$CoumnNow   = $NowPlot->[1];
		$NowPLotCoumn[$ThisBoxbin] = $CoumnNow;
		$textData    = $FileData_ref->[$FileNow][0][$CoumnNow];
		$animationLabelText .= ";$textData";
	}

	if ($FileData_ref->[$FileNow][0][0] =~ s/#/#/) {
		$StartCount = 1;
	}

	$YY2 = $HashConfi_ref->{"global"}{"canvas_margin_top"} + $LegendOffsetRatio * $Bodyheight +
	$HashConfi_ref->{$Level}{"colormap_legend_shift_y"} - $ColorBarSize * 2;

	my $textLength = $ColorBarSize * $NumPlotArry;

	$svg->text(
		'text-anchor', 'start',
		'x', $XX1,
		'y', $YY2,
		'textlength', $textLength,
		'-cdata', $animationLabelText,
		'font-family', 'Arial',
		'font-size', $ColorBarSize
	);

	$svg->rect(
		'x', $XX1,
		'y', $YY2,
		'width', $textLength,
		'height', $ColorBarSize,
		'fill', "grey"
	);

	my $animateTxt = $svg->text(
		'text-anchor', 'start',
		'x', $XX1,
		'y', $YY2 + $ColorBarSize,
		'-cdata', "Time",
		'font-family', 'Arial',
		'font-size', $ColorBarSize
	);

	my $XX2_anim = $XX1 + $textLength;

	$animateTxt->animate(
		attributeName => "x",
		from          => $XX1,
		to            => $XX2_anim,
		begin         => "0s",
		dur           => "3s",
		repeatDur     => 'indefinite',
		"-method"     => "animate"
	);

	$ValueToColor_ref->{"NA"} = "white";

	# 主要热图矩形绘制循环
	for (; $StartCount < $FileRow_ref->[$FileNow]; $StartCount++) {
		my $Value = $FileData_ref->[$FileNow][$StartCount][$CoumnNow];
		$Value = CheckValueNow($HashConfi_ref, $Level, $Value);

		my $ThisChrName = $FileData_ref->[$FileNow][$StartCount][0];
		next unless exists $hashYY1_ref->{$ThisChrName};

		my $StartSite = $FileData_ref->[$FileNow][$StartCount][1];
		my $EndSite   = $FileData_ref->[$FileNow][$StartCount][2];

		my $YY1A = $hashYY1_ref->{$ThisChrName}{$Level};
		my $YY2A = $hashYY2_ref->{$ThisChrName}{$Level};
		if (exists $ValueToCustomColor_ref->{$Value} ) {$ValueToColor_ref->{$Value}=$ValueToCustomColor_ref->{$Value};}

		my $XX1 = sprintf("%.1f", ($StartSite / $ChrMax) * $HashConfi_ref->{"global"}{"canvas_bodyOO"} + $hashXX1_ref->{$ThisChrName}{$Level});
		my $XX2 = sprintf("%.1f", ($EndSite / $ChrMax) * $HashConfi_ref->{"global"}{"canvas_bodyOO"} + $hashXX1_ref->{$ThisChrName}{$Level});

		my $path = $svg->get_path(
			x => [$XX1, $XX1, $XX2, $XX2],
			y => [$YY1A, $YY2A, $YY2A, $YY1A],
			-type => 'polygon'
		);

		my $AnimatedElement = $svg->polygon(
			%$path,
			style => {
				'fill'           => $ValueToColor_ref->{$Value},
				'stroke'         => $ValueToColor_ref->{$Value},
				'stroke-width'   => $HeatMapstrokewidth,
				'stroke-opacity' => $HashConfi_ref->{$Level}{"stroke-opacity"},
				'fill-opacity'   => $HashConfi_ref->{$Level}{"fill-opacity"},
			},
		);

		my $animationColorSequence = $ValueToColor_ref->{$Value};

		for (my $NowAA = $NumPlotArry - 2; $NowAA >= 0; $NowAA--) {
			$Value = $FileData_ref->[$FileNow][$StartCount][$NowPLotCoumn[$NowAA]];
			if (exists $ValueToCustomColor_ref->{$Value}) {
				$ValueToColor_ref->{$Value} = $ValueToCustomColor_ref->{$Value};
			}
			$animationColorSequence = $ValueToColor_ref->{$Value} . ";" . $animationColorSequence;
		}

		$AnimatedElement->animate(
			attributeName => "fill",
			values        => "$animationColorSequence",
			dur           => "3s",
			repeatDur     => 'indefinite',
			"-method"     => "animate"
		);

		$AnimatedElement->animate(
			attributeName => "stroke",
			values        => "$animationColorSequence",
			dur           => "3s",
			repeatDur     => 'indefinite',
			"-method"     => "animate"
		);
	}
}


####  # Animated histogram that can transition between states ####
sub plot_histogram_animated {
	my ($HashConfi_ref, $ValueToColor_ref, $Level, $svg, $hashYY1_ref, $hashYY2_ref, $hashXX1_ref,
		$ChrMax, $NumPlotArry, $PlotInfo, $FileData_ref, $FileRow_ref, $ValueToCustomColor_ref, $ColorGradientArray_ref,
		$ValueLabelsGradient_ref, $ColorBarSize, $Bodyheight, $LegendOffsetRatio, $GradientSteps,
		$fontsize, $ChrArry_ref, $hashChr_ref, $Precision) = @_;

	my $XX1 = $HashConfi_ref->{"global"}{"canvas_margin_left"} +
	$HashConfi_ref->{"global"}{"canvas_body"} +
	($Level - 1) * $ColorBarSize * 4.5 +
	$HashConfi_ref->{$Level}{"colormap_legend_shift_x"} ;

	my ($ThisBoxbin, $NowPlot, $CoumnNow, $FileNow, $StartCount) = (undef, undef, undef, undef, 0);
	my @NowPLotCoumn;
	my ($animationLabelText, $textData) = ("", "");

	foreach my $tmpkk (1 .. 1) {
		$ThisBoxbin = $tmpkk - 1;
		$NowPlot    = $PlotInfo->[$ThisBoxbin];
		$FileNow    = $NowPlot->[0];
		$CoumnNow   = $NowPlot->[1];
		$NowPLotCoumn[$ThisBoxbin] = $CoumnNow;
		$animationLabelText = $FileData_ref->[$FileNow][0][$CoumnNow];
	}

	foreach my $tmpkk (2 .. $NumPlotArry) {
		$ThisBoxbin = $tmpkk - 1;
		$NowPlot    = $PlotInfo->[$ThisBoxbin];
		$FileNow    = $NowPlot->[0];
		$CoumnNow   = $NowPlot->[1];
		$NowPLotCoumn[$ThisBoxbin] = $CoumnNow;
		$textData    = $FileData_ref->[$FileNow][0][$CoumnNow];
		$animationLabelText .= ";$textData";
	}

	if ($FileData_ref->[$FileNow][0][0] =~ s/#/#/) {
		$StartCount = 1;
	}

	my $YY2 = $HashConfi_ref->{"global"}{"canvas_margin_top"} +
	$LegendOffsetRatio * $Bodyheight +
	$HashConfi_ref->{$Level}{"colormap_legend_shift_y"} -
	$ColorBarSize * 2;

	my $textLength = $ColorBarSize * $NumPlotArry;

	$svg->text(
		'text-anchor', 'start',
		'x', $XX1,
		'y', $YY2,
		'textlength', $textLength,
		'-cdata', $animationLabelText,
		'font-family', 'Arial',
		'font-size', $ColorBarSize
	);

	$svg->rect(
		'x', $XX1,
		'y', $YY2,
		'width', $textLength,
		'height', $ColorBarSize,
		'fill', "grey"
	);

	my $animateTxt = $svg->text(
		'text-anchor', 'start',
		'x', $XX1,
		'y', $YY2 + $ColorBarSize,
		'-cdata', "Time",
		'font-family', 'Arial',
		'font-size', $ColorBarSize
	);

	my $XX2 = $XX1 + $textLength;

	$animateTxt->animate(
		attributeName => "x",
		from          => $XX1,
		to            => $XX2,
		begin         => "0s",
		dur           => "3s",
		repeatDur     => 'indefinite',
		"-method"     => "animate"
	);

	$ValueToColor_ref->{"NA"} = "white";


	# 绘制颜色图例部分
	my $YY1 = $HashConfi_ref->{"global"}{"canvas_margin_top"} +
	$LegendOffsetRatio * $Bodyheight +
	$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
	$YY2 = $YY1 + $ColorBarSize * ($GradientSteps + 1);

	$XX1=$HashConfi_ref->{"global"}{"canvas_margin_left"}+$HashConfi_ref->{"global"}{"canvas_body"}+($Level-1)*$ColorBarSize*4.5+$HashConfi_ref->{$Level}{"colormap_legend_shift_x"};
	$XX2=$XX1+$ColorBarSize;

	if ($HashConfi_ref->{$Level}{"colormap_legend_show"} == 0 ||
		$HashConfi_ref->{$Level}{"colormap_legend_sizeratio"} <= 0)
	{
		# 不绘制图例
	}
	else {
		my $path = $svg->get_path(
			x => [$XX1, $XX1, $XX2, $XX2],
			y => [$YY1, $YY2, $YY2, $YY1],
			-type => 'polygon'
		);

		$svg->polygon(
			%$path,
			style => {
				'fill'           => 'none',
				'stroke'         => 'black',
				'stroke-width'   => $HashConfi_ref->{"global"}{"stroke-width"},
				'stroke-opacity' => $HashConfi_ref->{$Level}{"stroke-opacity"},
				'fill-opacity'   => $HashConfi_ref->{$Level}{"fill-opacity"},
			},
		);

		foreach my $k (0 .. $GradientSteps) {
			$YY1 = $HashConfi_ref->{"global"}{"canvas_margin_top"} +
			$LegendOffsetRatio * $Bodyheight +
			$ColorBarSize * $k +
			$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
			$YY2 = $YY1 + $ColorBarSize;

			my $path = $svg->get_path(
				x => [$XX1, $XX1, $XX2, $XX2],
				y => [$YY1, $YY2, $YY2, $YY1],
				-type => 'polygon'
			);

			$svg->polygon(
				%$path,
				style => {
					'fill'           => $$ColorGradientArray_ref[$k],
					'stroke'         => 'black',
					'stroke-width'   => 0,
					'stroke-opacity' => $HashConfi_ref->{$Level}{"stroke-opacity"},
					'fill-opacity'   => $HashConfi_ref->{$Level}{"fill-opacity"},
				},
			);

			$svg->text(
				'text-anchor', 'middle',
				'x', $XX2 + length($$ValueLabelsGradient_ref[$k]) + $ColorBarSize * 1.88,
				'y', $YY2,
				'-cdata', "$$ValueLabelsGradient_ref[$k]",
				'font-family', 'Arial',
				'font-size', $ColorBarSize
			);
		}
	}

	my $MaxDiffValue = $HashConfi_ref->{$Level}{"Ymax"} - $HashConfi_ref->{$Level}{"Ymin"};
	my $HHstrokewidth = $HashConfi_ref->{$Level}{"stroke-width"};

	# Y轴刻度标签（可选）
	if ((exists $HashConfi_ref->{$Level}{"yaxis_tick_show"}) && ($HashConfi_ref->{$Level}{"yaxis_tick_show"} > 0)) 
	{
		draw_yaxis_ticks($HashConfi_ref,$Level,$ChrArry_ref, $hashYY1_ref, $hashYY2_ref, $svg, $fontsize);
	}


	# 主要绘图循环
	for (; $StartCount < $FileRow_ref->[$FileNow]; $StartCount++) {
		my $Value = $FileData_ref->[$FileNow][$StartCount][$CoumnNow];
		$Value = CheckValueNow($HashConfi_ref, $Level, $Value);

		my $ThisChrName = $FileData_ref->[$FileNow][$StartCount][0];
		next unless exists $hashYY1_ref->{$ThisChrName};

		my $StartSite = $FileData_ref->[$FileNow][$StartCount][1];
		my $EndSite   = $FileData_ref->[$FileNow][$StartCount][2];

		my $YY1A = $hashYY1_ref->{$ThisChrName}{$Level};
		my $YY2A = $hashYY2_ref->{$ThisChrName}{$Level};

		my $heightLL = 0;
		if ($Value ne "NA") {
			$heightLL = ($YY2A - $YY1A) * ($Value - $HashConfi_ref->{$Level}{"Ymin"}) / $MaxDiffValue;
		}

		my $YY1 = $YY2A - $heightLL;
		my $XX1 = sprintf("%.1f", ($StartSite / $ChrMax) * $HashConfi_ref->{"global"}{"canvas_bodyOO"} + $hashXX1_ref->{$ThisChrName}{$Level});
		my $XX2 = sprintf("%.1f", ($EndSite / $ChrMax) * $HashConfi_ref->{"global"}{"canvas_bodyOO"} + $hashXX1_ref->{$ThisChrName}{$Level});
		my $widthLL = $XX2 - $XX1;

		my $AnimatedElement = $svg->rect(
			'x', $XX1,
			'y', $YY2A,
			'width', $widthLL,
			'height', $heightLL,
			'fill', $ValueToColor_ref->{$Value},
			'stroke', $ValueToColor_ref->{$Value},
			'stroke-width', $HHstrokewidth,
			'stroke-opacity', $HashConfi_ref->{$Level}{"stroke-opacity"},
			'fill-opacity', $HashConfi_ref->{$Level}{"fill-opacity"}
		);

		my $animationColorSequence = $ValueToColor_ref->{$Value};
		my $YY1line   = $YY1;
		my $heightLLline = $heightLL;

		for (my $NowAA = $NumPlotArry - 2; $NowAA >= 0; $NowAA--) {
			$Value = $FileData_ref->[$FileNow][$StartCount][$NowPLotCoumn[$NowAA]];
			if (exists $ValueToCustomColor_ref->{$Value}) {
				$ValueToColor_ref->{$Value} = $ValueToCustomColor_ref->{$Value};
			}

			$animationColorSequence = $ValueToColor_ref->{$Value} . ";" . $animationColorSequence;

			if ($Value eq "NA") {
				$heightLL = 0;
			} else {
				$heightLL = ($YY2A - $YY1A) * ($Value - $HashConfi_ref->{$Level}{"Ymin"}) / $MaxDiffValue;
			}

			$YY1 = $YY2A - $heightLL;
			$YY1line   = $YY1 . ";" . $YY1line;
			$heightLLline = $heightLL . ";" . $heightLLline;
		}

		$AnimatedElement->animate(
			attributeName => "fill",
			values        => "$animationColorSequence",
			dur           => "3s",
			repeatDur     => 'indefinite',
			"-method"     => "animate"
		);

		$AnimatedElement->animate(
			attributeName => "stroke",
			values        => "$animationColorSequence",
			dur           => "3s",
			repeatDur     => 'indefinite',
			"-method"     => "animate"
		);

		$AnimatedElement->animate(
			attributeName => "y",
			values        => "$YY1line",
			dur           => "3s",
			repeatDur     => 'indefinite',
			"-method"     => "animate"
		);

		$AnimatedElement->animate(
			attributeName => "height",
			values        => "$heightLLline",
			dur           => "3s",
			repeatDur     => 'indefinite',
			"-method"     => "animate"
		);
	}
}




1;


######################swimming in the sky and flying in the sea ###########################

