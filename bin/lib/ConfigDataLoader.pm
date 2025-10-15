package ConfigDataLoader;

use strict;
use warnings;
use Exporter 'import';
use ColorPaletteManager qw(%MAX_COLOR_COUNT  %QualColNum RGB2HTML HTML2RGB GetColGradien SVGgetShape);

# Export Deal_Para function to be used by external modules
our @EXPORT_OK = qw(Deal_Para);
our @EXPORT    = qw(Deal_Para);


# Function declarations for internal use
sub init_global_defaults;               # Initialize global default parameters
sub init_parameter_flags;               # Get list of available parameters from ALL section
sub parse_config_file;                  # Parse configuration file and extract settings
sub process_data_file;                  # Read input data files (e.g., chromosome positions)
sub apply_zoom_region;                  # Apply zoom region if specified in config
sub set_default_parameters;             # Set missing default values based on data
sub sort_chromosomes;                   # Sort chromosomes alphabetically or numerically
sub validate_chromosome_data;           # Ensure all listed chromosomes exist in data
sub calculate_dimensions;               # Calculate image dimensions based on data
sub load_custom_colors;                 # Load custom color mapping from file
sub validate_and_fix_parameters;        # Validate and fix level-specific parameters
sub check_show_column_format;           # Validate column selection format
sub check_colorbrewer_usage;            # Validate usage of ColorBrewer palettes
sub warn_if_all_level_conflict;         # Warn if ALL-level params conflict with Level-specific ones
sub adjust_value_x_based_on_max_level;  # Adjust ValueX based on detected max level


# Log messages with severity: info, warn, error
sub log_message {
	my ($type, $msg) = @_;
	if ($type eq 'error') {
		print STDERR "[ERROR] $msg\n";
		exit 1;
	} elsif ($type eq 'warn') {
		print STDERR "[WARNING] $msg\n";
	} else {
		print "[INFO] $msg\n";
	}
}



sub process_legend_layout {
    my ($HashConfi, $Level) = @_;
	my %allowed_types = map { $_ => 1 } qw(
    LinkS
    LinkSelf
    PairWiseLink
    PairWiseLinkV2
    Shape
    heatmap
    heatmapAnimated
    highlights
    highlightsAnimated
    hist
    histAnimated
    histogram
    histogramAnimated
    line
    lines
    pairwiselink
    pairwiselinkV2
    plot_type
    point
    points
    ridgeline
    scatter
    shape
    shapes
    text
   );
   return  if (!exists $allowed_types{$HashConfi->{$Level}{"plot_type"}});
   my $legend_layout = $HashConfi->{$Level}{"colormap_legend_layout"};
    if ($HashConfi->{$Level}{colormap_legend_show} != 0 && $HashConfi->{$Level}{colormap_legend_sizeratio} > 0 && $legend_layout != 0) {
        if ($legend_layout == 1 || $legend_layout ==6) {
            $HashConfi->{global}{legend_HHCount}++;
        }
        elsif ($legend_layout == 2  || $legend_layout ==7) {
            $HashConfi->{global}{legend_HRCount}++;
			$HashConfi->{global}{Legend_OffsetRatio} = 0.01;
        }
        elsif ($legend_layout == 3 || $legend_layout ==8) {
            $HashConfi->{global}{legend_VVCount}++;
        }
		elsif ($legend_layout == 4|| $legend_layout ==9) {
            $HashConfi->{global}{legend_VRCount}++;
        }
        elsif ($legend_layout == 5|| $legend_layout ==10) {
            $HashConfi->{global}{legend_HVCount}++;
            $HashConfi->{global}{Legend_OffsetRatio} = 0.01;
        }
		elsif($legend_layout ==11  ||  $legend_layout ==12|| $legend_layout ==13)
		{
			$HashConfi->{global}{canvas_margin_bottom}+=70;
		}
    }

    return $HashConfi;
}

sub get_max_of_five {
    my ($num1, $num2, $num3, $num4,$num5) = @_;
    my $max = $num1;
    if ($num2 > $max) {
        $max = $num2;
    }
    if ($num3 > $max) {
        $max = $num3;
    }
    if ($num4 > $max) {
        $max = $num4;
    }
    if ($num5 > $max) {
        $max = $num5;
    }
 
	return $max;
}


# ================== Main Entry Point: Deal_Para ==================
# Deals with parsing configuration and preparing plotting data
sub Deal_Para {
	my $InConfi = shift;
	my $Bin=shift;
	my $RealBin=shift;

	my %HashConfi = init_global_defaults();

	my @ParaFlag = init_parameter_flags(\%HashConfi);
	my $NumParaFlag = scalar(@ParaFlag) - 1;

	my @FilePath=();
	my $MaxLevel =parse_config_file($InConfi, \%HashConfi,\@FilePath);

	$HashConfi{"global"}{Bin}=$Bin;
	$HashConfi{"global"}{RealBin}=$RealBin;
	my @FileColumn=();
	my @FileRow=();
	my %hashChr=();
	my @FileData=();
	my %hashChr2File=();
	if  (  (exists $HashConfi{global}{zoom_region})  &&  (!$HashConfi{global}{chr_zoom_region}) )
	{
		$HashConfi{global}{chr_zoom_region}=$HashConfi{global}{zoom_region};
	}

	foreach my $i (0 .. $#FilePath) {
		process_data_file($i, $FilePath[$i], \%hashChr, \%hashChr2File,\@FileData,\@FileColumn,\@FileRow);
	}

	apply_zoom_region(\%HashConfi, \%hashChr, \%hashChr2File, \@FileData, \@FileRow)
	if (exists $HashConfi{global}{chr_zoom_region} && defined $HashConfi{global}{chr_zoom_region} && $HashConfi{global}{chr_zoom_region} ne '');

	warn_if_all_level_conflict(\%HashConfi);
	set_default_parameters(\%HashConfi, \@FileColumn);

	my $NumberLevel = adjust_value_x_based_on_max_level(\%HashConfi,$MaxLevel);

	my $PTypeLink = 0;
	my $MaxGradien = $HashConfi{ALL}{colormap_nlevels};
	my @ShowColumn;

	for my $Level (1 .. $NumberLevel) {
		validate_and_fix_parameters(\%HashConfi, $Level);
		check_show_column_format(\%HashConfi, $Level, \@FileColumn,\@ShowColumn);
		check_colorbrewer_usage(\%HashConfi, $Level);
		adjust_layout_based_on_level_config(\%HashConfi, $Level, \@ShowColumn);
		inherit_all_parameters(\%HashConfi, $Level);

		if ($HashConfi{$Level}{colormap_nlevels} < $MaxGradien){
			$MaxGradien = $HashConfi{$Level}{colormap_nlevels};
		}

		if ($HashConfi{$Level}{plot_type} =~ /^link$/i) {
			$PTypeLink = 1;
		}
		process_legend_layout(\%HashConfi, $Level);
	}

	my @ChrArry = sort_chromosomes(\%HashConfi, \%hashChr);
	validate_chromosome_data(\%hashChr, \%HashConfi, \@ChrArry);

	my (
		$ChrMax, $total_chr_length, $RegionStart,
		$bin, $axis_label, $ChrCount, $chr_spacing, $widthForPerChr,
		$Bodyheight, $color_gradient_scale, $fontsize, $height, $width
	) = calculate_dimensions(\%HashConfi, \@ChrArry, $NumberLevel,$MaxGradien,\%hashChr);

	my %Value2SelfCol = load_custom_colors($HashConfi{"global"}{"colormap_conf"});

	$HashConfi{"global"}{"MaxGradien"}=$MaxGradien;
	return (\%HashConfi, \%Value2SelfCol, \%hashChr, \%hashChr2File,
		\@ShowColumn, \@FileData, \@FileRow, \@FileColumn, \@ChrArry, \@ParaFlag,
		$widthForPerChr, $PTypeLink, $ChrMax,
		$total_chr_length, $RegionStart, $bin,
		$axis_label, $ChrCount, $color_gradient_scale, $chr_spacing, $Bodyheight,
		$fontsize, $height, $width, $NumberLevel, $NumParaFlag
	);
}


#### Initialize global and default configuration structure#####
sub init_global_defaults {
	return (
		global => {
			canvas_body          => 1200,
			canvas_margin_top    => 55,
			canvas_margin_bottom => 30,
			canvas_margin_left   => 100,
			canvas_margin_right  => 80,
			strokewidth          => 1,
			'stroke-width'       => 1,
			canvas_angle         => 0,
			legend_Count         => 0,
			legend_HHCount       => 0,
			legend_HRCount       => 0,
			legend_HVCount       => 0,
			legend_VVCount       => 0,
			legend_VRCount       => 0,
			chr_label_rotation   => 0,
			'font-family'        => 'Arial',
			fill                 => 'green',
			xaxis_shift_y        => 0,
			chr_spacing_ratio    => 0.2,
			axis_tick_num        => 10,
			chr_orientation      => 'vertical',
			chr_label_size_ratio => 0.3,
			xaxis_tick_show     => 1,
		},
		ALL => {
			plot_type           => 'heatmap',
			background_color    => '#B8B8B8',
			upper_outlier_ratio => 0.95,
			lower_outlier_ratio => 0,
			colormap_nlevels    => 8,
			track_height        => 20,
			bg_stroke_width     => 0,
			track_bg_height_ratio => 1,
			log_p               => 0,
			yaxis_tick_show     => 0,
			track_text_angle    => 0,
			'font-family'       => 'Arial',
			'stroke-width'      => 1,
			strokewidth         => 1,
			padding_ratio       => 0,
			colormap_legend_sizeratio=> 1.0,
			'stroke-opacity'    => 1,
			'fill-opacity'      => 1,
			chr_label_shift_x   => 0,
			chr_label_shift_y   => 0,
			colormap_legend_layout   => 1,
			colormap_legend_shift_x  => 0,
			colormap_legend_shift_y  => 0,
			track_shift_x  => 0,
			track_shift_y  => 0,
			bg_end_arc          => 1,
			colormap_legend_show   => 1,
		},
		1 => { chr_label_shift_x => 0, chr_label_shift_y => 0 },
		2 => { chr_label_shift_x => 0, chr_label_shift_y => 0 },
	);
}

# Return list of parameter names from ALL section
sub init_parameter_flags {
	my ($HashConfi) = @_;
	my $all_params = $HashConfi->{ALL};
	return keys %$all_params;
}

########### Parse configuration file and populate HashConfi structure#############
sub parse_config_file {
	my ($InConfi, $HashConfi,$FilePath) = @_;
	my $fh;
	if (-e $InConfi && $InConfi =~ /\.gz$/) {
		open $fh, '-|', 'gzip', '-cd', $InConfi or die "Can't open gzipped config file: $!";
	} elsif (-e $InConfi) {
		open  $fh, '<', $InConfi or die "Can't open config file: $!";
	} else {
		log_message('error', "Input config file not found: $InConfi");
	}




	my (%hashChr, %hashChr2File);
	my ($SetParaFor);

	my $MaxLevel=0;

	while(<$fh>) {
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
		my ($Para,$InfoPara) = split(/\s*=\s*/,$_);

		$Para =~ s/^\s+|\s+$//g;
		$InfoPara =~ s/^\s+|\s+$//g;
		$InfoPara=~s/^ +// ;  $InfoPara=~s/ +$//;
		$InfoPara=~s/^\t+// ;  $InfoPara=~s/\t+$//;
		$InfoPara=~s/^ +// ;  $InfoPara=~s/ +$//;

		next if  ( $Para eq "");


		if ($Para eq 'SetParaFor') {
			$InfoPara =~ s/Level//g;
			$InfoPara =~ s/Track//g;
			$InfoPara =~ s/track//g;
			$SetParaFor = $InfoPara;
			if ( $InfoPara =~ /^\d+$/)
			{
				$MaxLevel = $InfoPara if $InfoPara > $MaxLevel;
			}
		} elsif ($Para =~ s/File//) {
			if ($Para < 1) {
				log_message('error', "Para FileN; The N number should start from 1,but File$Para found $InfoPara");
			}

			my $FileIndex = $Para - 1;
			$FilePath->[$FileIndex] = $InfoPara;
		} else {
			$HashConfi->{$SetParaFor}{$Para} = $InfoPara;
		}
	}

	close $fh;
	return $MaxLevel ;
	#	return ($SetParaFor,$MaxLevel);
}


########### Adjust ValueX based on detected max level################
sub adjust_value_x_based_on_max_level {
	my ($HashConfi,$MaxLevel) = @_;

	my $NumberLevel = $HashConfi->{"global"}{"track_num"};
	return $NumberLevel unless defined $NumberLevel;

	my $TF = 0;
	if (exists $HashConfi->{"ALL"}{"plot_type"} && $HashConfi->{"ALL"}{"plot_type"} =~ /^link$/i) {
		$TF = 1;
	}
	for my $checkLevel (1..2) {
		if (exists $HashConfi->{$checkLevel}{"plot_type"} && $HashConfi->{$checkLevel}{"plot_type"} =~ /^link$/i) {
			$TF = 1;
		}
	}

	if ($MaxLevel > $NumberLevel && !$TF) {
		log_message('warn', "The max track(Level) found is $MaxLevel, but global.track_num = $NumberLevel. Auto updated.");
		$HashConfi->{"global"}{"track_num"} = $NumberLevel = $MaxLevel;
	}

	return $NumberLevel;
}

sub process_data_file {
	my ($index, $filename, $hashChr, $hashChr2File, $FileData, $FileColumn,$FileRow) = @_;
	my $fh;
	if (-e $filename && $filename =~ /\.gz$/) {
		open $fh, '-|', 'gzip', '-cd', $filename or die "Can't open gzipped file: $!";
	} elsif (-e $filename) {
		open  $fh, '<', $filename or die "Can't open file: $!";
	} else {
		log_message('error', "Input file not found File:$index+1: $filename");
	}

	my $FirstAA=<$fh>; chomp $FirstAA;
	my @headers = split(/\s+/, $FirstAA);
	my $col_num = $#headers;
	$FileColumn->[$index] = $col_num;

	for my $i (0 .. $col_num) 
	{
		$FileData->[$index][0][$i] = $headers[$i];	
	}

	if (!($FirstAA=~s/#/#/g))
	{
		$hashChr->{$headers[0]} //= $headers[2];
	}


	my $row = 1;
	while($_=<$fh>) {
		chomp;
		my @cols = split;
		next if @cols < 3;
		for my $i (0 .. $col_num) {
			$FileData->[$index][$row][$i] = $cols[$i];
		}
		next if  ($_=~/#/);

		my $chr_name = $cols[0];
		$hashChr->{$chr_name} //= $cols[2];
		$hashChr->{$chr_name} = $cols[2] if $cols[2] > $hashChr->{$chr_name};
		$hashChr2File->{$chr_name} = $index;
		$row++;
	}

	$FileRow->[$index] = $row;
	close $fh;
}

sub apply_zoom_region {
	my ($HashConfi, $hashChr, $hashChr2File, $FileData, $FileRow) = @_;

	if (exists $HashConfi->{global}{chr_zoom_region} && defined $HashConfi->{global}{chr_zoom_region} && $HashConfi->{global}{chr_zoom_region} ne '') {
		#	if (exists $HashConfi->{global}{chr_zoom_region}) {
		my @Region = split /:/, $HashConfi->{global}{chr_zoom_region};
		if ($#Region != 2) {
			log_message('error', "global Para ZoomRegion Format wrong: should be like as [chr1:1000:5000]. Please check it.");
		}

		if (!exists $hashChr->{$Region[0]}) {
			log_message('error', "global Para ZoomRegion Chr Name wrong: Can't find the $Region[0] chr Name at the FileX file. Please check it.");
		}

		if ($Region[1] > $Region[2]) {
			log_message('warn', "global Para ZoomRegion : $Region[1] and $Region[2] maybe wrong, we change them.");
			@Region[1,2] = @Region[2,1];
		}

		$HashConfi->{global}{"chr_zoom_region"} = \@Region;

		my (@new_FileData, @new_FileRow);
		my %hashChr2FileRegion;

		foreach my $file_idx (0 .. $#$FileData) {
			my $ColumnNum = scalar(@{$FileData->[$file_idx][0]}) - 1;
			my $Row = $FileRow->[$file_idx];
			my $newRowRegion = 0;

			for (my $thisRow = 0; $thisRow < $Row; $thisRow++) {
				my @data = @{$FileData->[$file_idx][$thisRow]};

				if ($data[0] =~ /^#/) {
					$new_FileData[$file_idx][$newRowRegion] = [ @data ];
					$newRowRegion++;
					next;
				}

				next if $data[0] ne $Region[0];
				next if $data[1] < $Region[1] && $data[2] < $Region[1];
				next if $data[1] > $Region[2] && $data[2] > $Region[2];

				if ($data[1] >= $Region[1] && $data[1] <= $Region[2]) {
					$data[1] = $data[1] - $Region[1] + 1;
				} elsif ($data[1] < $Region[1]) {
					$data[1] = 1;
				} else {
					$data[1] = $Region[2] - $Region[1] + 1;
				}

				if ($data[2] >= $Region[1] && $data[2] <= $Region[2]) {
					$data[2] = $data[2] - $Region[1] + 1;
				} elsif ($data[2] < $Region[1]) {
					$data[2] = 1;
				} else {
					$data[2] = $Region[2] - $Region[1] + 1;
				}

				$new_FileData[$file_idx][$newRowRegion] = [ @data ];

				if (!exists $hashChr2FileRegion{$data[0]}) {
					$hashChr2FileRegion{$data[0]} = $file_idx;
				}

				$newRowRegion++;
			}
			$new_FileRow[$file_idx] = $newRowRegion;
		}

		my %hashChrRegion;
		foreach my $chrname (keys %$hashChr) {
			next if $chrname ne $Region[0];
			$hashChrRegion{$chrname} = $Region[2] - $Region[1] + 1;
		}
		%$hashChr = %hashChrRegion;

		%$hashChr2File = %hashChr2FileRegion;

		@$FileData = @new_FileData;
		@$FileRow = @new_FileRow;

	}
}

sub set_default_parameters {
	my ($HashConfi, $FileColumn) = @_;

	unless (exists $HashConfi->{global}{track_num}) {
		my $default_col = $FileColumn->[0] // -1;
		if ($default_col < 3)
		{
			log_message('error', "Can't find Input File1 or format wrong");
			exit(1);
		}
		$HashConfi->{global}{track_num} = $default_col - 2;
	}

	$HashConfi->{ALL}{colormap_low_color} ||= "#006400";
	$HashConfi->{ALL}{colormap_mid_color}   ||= "#FFFF00";
	$HashConfi->{ALL}{colormap_high_color}   ||= "#FF0000";

	if (!exists $HashConfi->{"ALL"}{"bg_stroke_color"})
	{
		$HashConfi->{"ALL"}{"bg_stroke_color"}=$HashConfi->{"ALL"}{"background_color"};
	}

}

sub warn_if_all_level_conflict {
	my ($HashConfi) = @_;

	if (exists $HashConfi->{ALL}{colormap_low_color} ||
		exists $HashConfi->{ALL}{colormap_mid_color} ||
		exists $HashConfi->{ALL}{colormap_high_color} ||
		exists $HashConfi->{ALL}{colormap_brewer_name}) {
		log_message('warn', "Warning:\tSetParaFor= [ALL], Para (crBegin/crMid/crEnd/ColorBrewer) should be seted in each track(Level),move it to  SetParaFor=trackX");
	}


}

sub inherit_all_parameters {
	my ($HashConfi, $Level) = @_;
	my @ParaFlag = init_parameter_flags($HashConfi);
	foreach my $kk (0 .. $#ParaFlag) {
		my $thisPara = $ParaFlag[$kk];
		if (exists $HashConfi->{ALL}{$thisPara} && !exists $HashConfi->{$Level}{$thisPara}) {
			$HashConfi->{$Level}{$thisPara} = $HashConfi->{ALL}{$thisPara};
		}
	}
}

sub validate_and_fix_parameters {
	my ($HashConfi, $Level) = @_;
	my $para_ref = $HashConfi->{$Level};

	if (exists $para_ref->{colormap_reverse}) {
		my $cccctm = $para_ref->{colormap_low_color};
		$para_ref->{colormap_low_color} = $para_ref->{colormap_high_color};
		$para_ref->{colormap_high_color} = $cccctm;
	}



	if ( (!exists  $para_ref->{"bg_stroke_color"})  &&  (exists $para_ref->{"background_color"}) )
	{
		$para_ref->{"bg_stroke_color"}=$para_ref->{"background_color"};
	}
	if ( (!exists $para_ref->{"stroke-opacity"}) && (exists $para_ref->{"fill-opacity"}))
	{
		$para_ref->{"stroke-opacity"}=$para_ref->{"fill-opacity"};
	}





	if (!exists $para_ref->{upper_outlier_ratio}) {
		if  (!defined($para_ref->{plot_type}))
		{
			$para_ref->{plot_type}=$HashConfi->{"ALL"}{plot_type};
		}

		if ( $para_ref->{plot_type} ne 'heatmap' && $para_ref->{plot_type} ne 'highlights' && ($HashConfi->{"ALL"}{"upper_outlier_ratio"}==0.95)) {
			$para_ref->{upper_outlier_ratio} = 1.01; 
		}
		else
		{
			$para_ref->{"upper_outlier_ratio"}=$HashConfi->{"ALL"}{"upper_outlier_ratio"};
		}
	}


	if (exists $para_ref->{padding_ratio}) {
		if ($para_ref->{padding_ratio} < 0 || $para_ref->{padding_ratio} > 1) {
			log_message('warn', "Level:$Level Para [ValueSpacingRatio] should be in [0,1], modified to 0.3");
			$para_ref->{padding_ratio} = 0.3;
		}
	}

	foreach my $p (qw(stroke-opacity fill-opacity)) {
		if (exists $para_ref->{$p} && ($para_ref->{$p} < 0 || $para_ref->{$p} > 1)) {
			log_message('warn', "Level:$Level Para [$p] should be in [0,1], modified to 1.0");
			$para_ref->{$p} = 1.0;
		}
	}

	if (exists $para_ref->{track_height} && $para_ref->{track_height} < 5) {
		log_message('warn', "track(Level):$Level Para [track_height] too small, modified to 5");
		$para_ref->{track_height} = 5;
	}



	if (defined $para_ref->{upper_outlier_ratio} && defined $para_ref->{lower_outlier_ratio} &&
		$para_ref->{upper_outlier_ratio} < $para_ref->{lower_outlier_ratio}) {
		($para_ref->{upper_outlier_ratio}, $para_ref->{lower_outlier_ratio}) = ($para_ref->{lower_outlier_ratio}, $para_ref->{upper_outlier_ratio});
	}

	if (exists $para_ref->{colormap_brewer_name} && exists $QualColNum{$para_ref->{colormap_brewer_name}}) {
		my $max_color_count = $QualColNum{$para_ref->{colormap_brewer_name}};
		if (!defined $para_ref->{colormap_nlevels})
		{
			$para_ref->{colormap_nlevels}=$max_color_count;
		}
		elsif ($para_ref->{colormap_nlevels} > $max_color_count) {
			log_message('warn', "Level $Level Para [-Gradien] exceeds max color count for ColorBrewer '$para_ref->{colormap_brewer_name}'. Modified from $para_ref->{colormap_nlevels} to $max_color_count.");
			$para_ref->{colormap_nlevels} = $max_color_count;
		}
	}

	if ( !exists $para_ref->{colormap_nlevels}) {
		$para_ref->{colormap_nlevels} = $HashConfi->{ALL}{colormap_nlevels};
	}


	if ($para_ref->{colormap_nlevels} > 255) {
		log_message('warn', "track(Level):$Level Para [colormap_nlevels] is Max Gradien must < 255; we modify $para_ref->{colormap_nlevels} ---> 255");
		$para_ref->{colormap_nlevels} = 255;
	} elsif ($para_ref->{colormap_nlevels} < 3) {
		log_message('warn', "track(Level):$Level Para [colormap_nlevels] is seted to be $para_ref->{colormap_nlevels}, but too small, we modify it to be 3");
		$para_ref->{colormap_nlevels} = 3;
	}



	return;
}

sub check_show_column_format {
	my ($HashConfi, $Level, $FileColumn,$ShowColumn_ref) = @_;
	my @ShowColumnArry;

	my $file_index = $Level - 1;
	if (!exists $HashConfi->{$Level}{"show_columns"}) {
		my $column_count = $FileColumn->[$file_index] // -1;

		if ($column_count > 2) {
			push @ShowColumnArry, [$file_index, 3];
		} else {
			my $VVV = $FileColumn->[0] // -1;
			if ($VVV < 3 || ($file_index + 3) > $VVV) {
				log_message('error', "Can't find the File$file_index or File1 for setting the default parameter [ShowColumn] for Level $Level: details as follows");
				log_message('error', "File$file_index Column only $column_count+1 (>2) and File1 Column only $VVV+1 (>2)");
				log_message('error', "Please set the parameter [ShowColumn] for Level:$Level manually");
			} else {
				push @ShowColumnArry, [0, $file_index + 3];
			}
		}
	} else {
		my @temAA = split /\s+/, $HashConfi->{$Level}{"show_columns"};
		foreach my $tmpA (@temAA) {
			my @temBB = split /:/, $tmpA;
			if ($temBB[0] =~ s/File//g) {
				$temBB[0]--;

				my $VV = $FileColumn->[$temBB[0]] // -1;
				if ($VV < 0) {
					log_message('error', "Can't find the File " . ($temBB[0] + 1));
				}
				my @temCC = split /,/, $temBB[-1];
				foreach my $coumn (@temCC) {
					$coumn--;
					if ($coumn < 3 || $coumn > $VV) {
						log_message('error', "File " . ($temBB[0] + 1) . " Column only $VV+1, but you give the show_columns is $coumn");
					} else {
						push @ShowColumnArry, [$temBB[0], $coumn];
					}
				}
			} else {
				log_message('error', "Para [show_columns] For track$Level Format wrong");
			}
		}
	}
	$ShowColumn_ref->[$file_index]=[@ShowColumnArry];

}


#### Sort chromosomes alphabetically or numerically#####

sub sort_chromosomes {
	my ($HashConfi, $hashChr) = @_;
	my @ChrArry;

	if (exists $HashConfi->{global}{chr_order}) {
		@ChrArry = split /,/, $HashConfi->{global}{chr_order};
		return @ChrArry ;
	} else {
		@ChrArry = sort keys %$hashChr;
	}

	my %tmpChrSort;
	my $sedSort = 1;

	foreach my $k (@ChrArry) {
		my $chr = lc $k;
		$chr =~ s/^chr(?:omosome)?|lg//gi;
		$chr = 23 if $chr eq 'x';
		$chr = 24 if $chr eq 'y';
		if ($chr =~ /^\d+$/) {
			$tmpChrSort{$k} = $chr;
		} else {
			$sedSort = 0;
			last;
		}
	}
	if ($sedSort==1)
	{
		@ChrArry =();
		@ChrArry =  sort { $tmpChrSort{$a} <=> $tmpChrSort{$b} } keys %tmpChrSort ;
	}

	if ($HashConfi->{"global"}{"canvas_angle"}==90)
	{
		my @newArray=@ChrArry;
		@ChrArry =();
		@ChrArry = reverse @newArray;
	}
	return @ChrArry;
}

###################Ensure all listed chromosomes exist in data#########################
sub validate_chromosome_data {
	my ($hashChr, $HashConfi, $ChrArry) = @_;

	foreach my $thisChr (@$ChrArry) {
		unless (exists $hashChr->{$thisChr}) {
			log_message('error', "Chr '$thisChr' not found in data. Please check Chromosomes_order.");
		}
	}
}

#################Calculate dimensions############################
sub calculate_dimensions {
	my ($HashConfi, $ChrArry, $NumberLevel,$MaxGradien,$hashChr) = @_;
	my ($ChrMax, $total_chr_length)=(0,0);

	foreach my $chr (@$ChrArry) {
		my $len = $hashChr->{$chr};
		$total_chr_length += $len;
		$ChrMax = $len if $len > $ChrMax;
	}

	my $ShiftChrLenth = $ChrMax;
	my $RegionStart = 0;

	if (exists $HashConfi->{global}{chr_zoom_region}) {
		my $region = $HashConfi->{global}{chr_zoom_region};
		$RegionStart = $$region[1];
		$ShiftChrLenth += $$region[1];
	}

	my ($bin, $axis_label) = (1000000, "Mb");
	if ($ShiftChrLenth / $bin < 10)
	{
		$bin = 1000, $axis_label = "kb" ;
		if ($ShiftChrLenth / $bin < 10)
		{
			$bin = 1, $axis_label = "bp";
		}
	}
	$axis_label = $HashConfi->{global}{axis_tick_unit} if exists $HashConfi->{global}{axis_tick_unit};

	my $ChrCount = scalar @$ChrArry;
	my $widthForPerChr = 0;

	for my $Level (1 .. $NumberLevel) {
		$widthForPerChr += $HashConfi->{$Level}{track_height} // 0;
		if  ($Level!=$NumberLevel)
		{
			$widthForPerChr+=$HashConfi->{$Level}{"track_height"}*$HashConfi->{$Level}{"padding_ratio"};
		}
	}

	if ($widthForPerChr =~ s/\././) {
		$widthForPerChr = sprintf("%.1f", $widthForPerChr + 0);
	}

	my $chr_spacing = $HashConfi->{global}{chr_spacing_ratio} * $HashConfi->{ALL}{track_height};
	my $Bodyheight = $ChrCount * ($widthForPerChr + $chr_spacing);
	if ($HashConfi->{global}{chr_orientation} ne "vertical") {
	   $Bodyheight =  ($widthForPerChr + $chr_spacing)+30;
	}

	my $color_gradient_scale = $Bodyheight * 0.5 / $MaxGradien;
	my $Midl = 20 + ($HashConfi->{ALL}{track_height} - 20) * 0.125 ;

	if ($color_gradient_scale < $Midl * 0.85) {
		$color_gradient_scale = $Midl * 0.85;
	} elsif ($color_gradient_scale > $Midl * 1.2) {
		$color_gradient_scale = $Midl * 1.2;
	}

	my $fontsize = $color_gradient_scale;

	if ($fontsize > ($HashConfi->{global}{canvas_body} * 0.029)) {
		$fontsize = int($HashConfi->{global}{canvas_body} * 0.029);
	}

	if (!exists $HashConfi->{global}{"font-size"}) {
		$HashConfi->{global}{"font-size"} = $fontsize;
	} else {
		$fontsize = $HashConfi->{global}{"font-size"};
	}

	if ($HashConfi->{global}{canvas_margin_top} < $fontsize * 1.1) {
		$HashConfi->{global}{canvas_margin_top} = $fontsize * 1.1;
	}

	if (exists $HashConfi->{global}{title}) {
		$HashConfi->{global}{canvas_margin_top} += $HashConfi->{global}{"font-size"} * 1.6;
	}


	my $all_chromosomes_spacing=0;
  	if ($HashConfi->{"global"}{"chr_orientation"} ne "vertical")
   	{
       $all_chromosomes_spacing=$ChrCount*$chr_spacing;
    }

	if (!exists $HashConfi->{global}{colormap_legend_gap})
	{
		$HashConfi->{global}{colormap_legend_gap}=4.5;
	}

	   $HashConfi->{global}{canvas_bodyOO}=$HashConfi->{global}{canvas_body};
	   $HashConfi->{global}{canvas_body}+=$all_chromosomes_spacing;
	my $BodyWide=$HashConfi->{"global"}{"canvas_body"};
		#		$HashConfi->{global}{all_chromosomes_spacing}=$all_chromosomes_spacing;

	my $Legen_HH=$MaxGradien * $color_gradient_scale;
	my $Legen_WW=($HashConfi->{global}{colormap_legend_gap}) * $color_gradient_scale;
	my $Legen_HH2=$Legen_HH+$color_gradient_scale;
	my $Legen_WW2=$Legen_WW+$color_gradient_scale;


    my $HH_H=0;
	my $HH_W=($HashConfi->{global}{legend_HHCount})*$Legen_WW;

	my $HR_W=$Legen_HH;
	my $HR_H=($HashConfi->{global}{legend_HRCount})*$Legen_WW2-$Bodyheight;
	if (($HashConfi->{global}{legend_HRCount})==0){$HR_W=0;}

	my $HV_W=$Legen_WW;
	my $HV_H=($HashConfi->{global}{legend_HVCount})*$Legen_HH2-$Bodyheight;
	if ($HashConfi->{global}{legend_HVCount}==0)
	{
		$HV_W=0;
	}



	my $VV_H=$Legen_HH2;
	my $VV_W=($HashConfi->{global}{legend_VVCount})*$Legen_WW2-$BodyWide;
	if ($HashConfi->{global}{legend_VVCount}==0)
	{
		$VV_H=0;
	}

	my $VR_H=$Legen_WW2;
	my $VR_W=($HashConfi->{global}{legend_VRCount})*$Legen_HH2-$BodyWide;
	if ($HashConfi->{global}{legend_VRCount}==0)
	{
		$VR_H=0;
	}

	my $Add_H=get_max_of_five($HH_H,$HR_H,$HV_H,$VR_H,$VV_H);
	my $Add_W=get_max_of_five($HH_W,$HR_W,$HV_W,$VR_W,$VV_W);

	$HashConfi->{global}{canvas_margin_bottom}+=$Add_H;
	$HashConfi->{global}{canvas_margin_right}+=$Add_W;

	my $height = $HashConfi->{global}{canvas_margin_top} + $HashConfi->{global}{canvas_margin_bottom} + $Bodyheight;
	my $width = $HashConfi->{global}{canvas_margin_left} + $HashConfi->{global}{canvas_margin_right} + $HashConfi->{global}{canvas_body};

	return (
		$ChrMax, $total_chr_length, $RegionStart,
		$bin, $axis_label, $ChrCount, $chr_spacing, $widthForPerChr,
		$Bodyheight, $color_gradient_scale, $fontsize, $height, $width
	);



}

##### Load custom color mappings from a file if provided#####
sub load_custom_colors {
	my ($color_file) = @_;
	my %Value2SelfCol;
	return %Value2SelfCol unless defined $color_file && -e $color_file;
	open my $fh, '<', $color_file or die "Cannot open color file: $!";
	while(<$fh>) {
		chomp;
		$_=~s/^ +//;    $_=~s/ +$//;    next if(/^#/);  next if(/^$/);
		my @bbb=split /\#\#/,$_;    $_=$bbb[0];
		$_=~s/^ +//;    $_=~s/ +$//;    next if(/^#/);  next if(/^$/);
		$_=~s/\"#/UUUU/g;
		@bbb=();    @bbb=split /\#/,$_; $_=$bbb[0];
		$_=~s/UUUU/\"#/g;
		$_=~s/\"//g;
		$_=~s/^ +//;    $_=~s/ +$//;
		next unless /=/;
		my ($key,$val) = split(/\s*=\s*/,$_);
		$Value2SelfCol{$key} = $val;

	}
	close $fh;
	return %Value2SelfCol;
}


### Adjust layout based on level-specific settings (e.g., animated SVG)###
sub adjust_layout_based_on_level_config {
	my ($HashConfi, $Level, $ShowColumn) = @_;

	if ((exists $HashConfi->{$Level}{yaxis_tick_show} ) && ($HashConfi->{$Level}{yaxis_tick_show} > 0)) {
		$HashConfi->{global}{ShiftChrNameRatio} = 0.5;
	}

	if (exists $HashConfi->{$Level}{plot_type} && $HashConfi->{$Level}{plot_type} =~ s/Animated/Animated/i) {
		my $PlotInfo = $ShowColumn->[$Level - 1];
		my $PlotArryNum = scalar @$PlotInfo;

		if ($PlotArryNum < 2) {
			log_message('error', "Level $Level [-PType] is set to Animated SVG but requires multiple columns via [-ShowColumn]. Only $PlotArryNum column(s) found.");
		}
		my %tmpFile;
		foreach my $entry (@$PlotInfo) {
			$tmpFile{$entry->[0]}++;
		}

		if (keys %tmpFile > 1) {
			log_message('error', "Animated SVG requires all columns from the same file.\nTrack(Level) $Level [plot_type] is Animated SVG but [-ShowColumn] spans multiple files.");
		}
		else {
			log_message('info', "SVG will be animated. Open in a modern browser for animation preview.");
		}
	}
}

## Validate and warn about ColorBrewer usage (e.g., valid palette names and levels)##
sub check_colorbrewer_usage {
	my ($HashConfi, $Level) = @_;
	my $para_ref = $HashConfi->{$Level};

	if ( exists $para_ref->{colormap_brewer_name})
	{
		my $color_name = $para_ref->{colormap_brewer_name};
		if (!exists $MAX_COLOR_COUNT{$color_name}) 
		{
			my $RealBin=$HashConfi->{"global"}{RealBin};
			my $file="$RealBin/../ColorsBrewer/$color_name";
			if (-e $file)
			{
				my $count=` wc  -l  $file | awk '{print \$1}' `; 
				chomp $count ;
				
				if (! exists $para_ref->{colormap_nlevels}) 
				{
					$para_ref->{colormap_nlevels}=$count;
				}
				if ($para_ref->{colormap_nlevels} > $count )
				{
					log_message('warn',"track $Level Color Brewer $color_name at $file only nlevels = $count, but input colormap_nlevels $para_ref->{colormap_nlevels} > $count,  Changed  to $count \n");
					$para_ref->{colormap_nlevels}=$count;
				}
			}
			else
			{
			log_message('warn', "RColor Brewer must be in specified name like BrBG/PiYG/PRGn... or color FileName at the Dir ColorsBrewer, but $color_name is not valid\n Changed $color_name  --->  'GnYlRd'\n See: https://www.r-graph-gallery.com/38-rcolorbrewers-palettes.html\n");
			$color_name = $para_ref->{colormap_brewer_name} = 'GnYlRd';
			}
		}

		unless (exists $para_ref->{colormap_nlevels}) {
			$para_ref->{colormap_nlevels} = $MAX_COLOR_COUNT{$color_name};
		}

		if (exists $QualColNum{$color_name}) {
			my $max_color_count = $QualColNum{$color_name};

			if ($para_ref->{colormap_nlevels} > $max_color_count) {
				log_message('warn', "Level $Level: [-colormap_nlevels] exceeds max color count for ColorBrewer '$color_name'. Modified from $para_ref->{colormap_nlevels} to $max_color_count.");
				$para_ref->{colormap_nlevels} = $max_color_count;
			}
		}
	}
	elsif ( (!exists $para_ref->{"colormap_low_color"})  && (!exists $para_ref->{"colormap_mid_color"})   &&   (!exists $para_ref->{"colormap_high_color"})  )
	{
		$para_ref->{"colormap_brewer_name"}="NA";
		if (!exists   $para_ref->{"colormap_nlevels"}){$para_ref->{"colormap_brewer_name"}="NANA";}
	}

}

1;
######################swimming in the sky and flying in the sea ###########################

