#!/usr/bin/perl
use strict;
use warnings;

die  "Version 1.0\t2025-06-12;\nUsage: $0 <InPut><Out>\n" unless (@ARGV ==2);

#############Befor  Start  , open the files ####################

my %parameter_mapping = (
	"CanvasHeightRitao" => "canvas_height_ratio",
	"CanvasWidthRitao" => "canvas_width_ratio",
	"RotatePng" => "canvas_angle",
	"body" => "canvas_body",
	"down" => "canvas_margin_bottom",
	"left" => "canvas_margin_left",
	"right" => "canvas_margin_right",
	"up" => "canvas_margin_top",
	"ChrArrayDirection" => "chr_orientation",
	"ChrSpacingRatio" => "chr_spacing_ratio",
	"Chromosomes_order" => "chr_order",
	"ZoomRegion" => "chr_zoom_region",
	"RotateChrName" => "chr_label_rotation",
	"ChrLenUnitRatio" => "chr_scale_ratio",
	"ChrNameRatio" => "chr_label_size_ratio",
	"ShiftChrNameX" => "chr_label_shift_x",
	"ShiftChrNameY" => "chr_label_shift_y",
	"ReverseChr" => "chr_order_reverse",
	"LabelUnit" => "axis_tick_unit",
	"RotateAxisText" => "axis_text_angle",
	"ShowYaxis" => "xaxis_tick_show",
	"ScaleNum" => "axis_tick_num",
	"ScaleUnit" => "axis_tick_interval",
	"ShiftXaxisY" => "xaxis_shift_y",
	"Precision" => "axis_tick_precision",
	"ShowYaxis" => "yaxis_tick_show",
	"MainCol" => "title_color",
	"MainRatioFontSize" => "title_size",
	"Main" => "title",
	"ShiftMainX" => "title_shift_x",
	"ShiftMainY" => "title_shift_y",
	"PType" => "plot_type",
	"ShowColumn" => "show_columns",
	"LogP" => "log_p",
	"asFlag" => "as_flag",
	"LimitYMax" => "cap_max_value",
	"LimitYMin" => "cap_min_value",
	"YMin" => "Ymin",
	"YMax" => "Ymax",
	"TopVHigh" => "upper_outlier_ratio",
	"TopVLow" => "lower_outlier_ratio",
	"ValueX" => "track_num",
	"crBG" => "background_color",
	"NoShowBackGroup" => "background_show",
	"BGChrEndCurve" => "bg_end_arc",
	"EndCurveOUT" => "bg_end_offset",
	"EndCurveRadian" => "bg_end_arc_division",
	"BGWidthRatio" => "track_bg_height_ratio",
	"ValueSpacingRatio" => "padding_ratio",
	"ChrWidth" => "track_height",
	"LevelName" => "label",
	"NameCol" => "label_color",
	"NameRatioFontSize" => "label_size",
	"NameRotate" => "label_angle",
	"ShiftNameX" => "label_shift_x",
	"ShiftNameY" => "label_shift_y",
	"ColorBrewer" => "colormap_brewer_name",
	"Gradien" => "colormap_nlevels",
	"ReverseColor" => "colormap_reverse",
	"ColorsConf" => "colormap_conf",
	"crBegin" => "colormap_low_color",
	"crMid" => "colormap_mid_color",
	"crEnd" => "colormap_high_color",
	"NoShowGradien" => "colormap_legend_show",
	"ShiftGradienX" => "colormap_legend_shift_x",
	"ShiftGradienY" => "colormap_legend_shift_y",
	"SizeGradienRatio" => "colormap_legend_size",
	"ShapeType" => "track_geom_shape",
	"ShapesizeRatio" => "track_geom_shape_size",
	"TextFontRatio" => "track_text_size",
	"CirsizeRatio" => "track_point_size",
	"Rotate" => "track_text_angle",
	"TextAnchor" => "track_text_anchor",
	"LinesColBB" => "line_colors_conf",
	"StyleUpDown" => "link_direction",
	"SameHigh" => "link_uniform_height",
	"lineType" => "link_linestyle",
	"CorCutline" => "cutoff_color",
	"CorCutline1" => "cutoff1_color",
	"CorCutline2" => "cutoff2_color",
	"Cutline" => "cutoff_value",
	"Cutline1" => "cutoff1_value",
	"Cutline2" => "cutoff2_value",
	"stroke-width" => "stroke-width",
	"fill-opacity" => "fill-opacity",
	"font-family" => "font-family",
	"crStrokeBG" => "bg_stroke_color",
	"stroke-opacity" => "stroke-opacity",
	"font-family" => "font-family",
	"font-size" => "font-size",
	"fill" => "fill",
	"strokewidth" => "stroke-width",
	"text-font-size" => "text-font-size",
	"strokeWidthBG" => "bg_stroke_width",
	"track_shift_y" => "track_shift_y",
	"track_shift_x" => "track_shift_x"
);

my %ccc=();
foreach my $k (keys %parameter_mapping)
{
	my $vv=$parameter_mapping{$k};
	$vv=~s/ //g;
	$ccc{$vv}++;
}

my %Ano2=();
open (IB,"cc") || die "input file can't open $!";
#open (OA,">$ARGV[1]") || die "output file can't open $!" ;
################ Do what you want to do #######################
while(<IB>)
{
	chomp ;
	next if (length($_)<5);
	##chr_order =                     ## 指定染色体顺序或筛选显示的染色体列表（未指定则按名称自动排序）
	$_=~s/^#//;
	my @inf=split /\s+/;
	my @AA=split /\=/,$inf[0];
	$AA[0]=~s/ //g;
	$Ano2{$AA[0]}=$inf[-1];
	$ccc{$AA[0]}=1
}
close IB;

my %Ano=();
open (IA,"In-CN.cofi") || die "input file can't open $!";
#open (OA,">$ARGV[1]") || die "output file can't open $!" ;
################ Do what you want to do #######################
while(<IA>)
{
	chomp ;
	next if (length($_)<5);
	##chr_order =                     ## 指定染色体顺序或筛选显示的染色体列表（未指定则按名称自动排序）
	$_=~s/^#//;
	my @inf=split /\#/;
	my @AA=split /\=/,$inf[0];
	$AA[0]=~s/ //g;
	$Ano{$AA[0]}=$inf[-1];
	$ccc{$AA[0]}=1
}


close IA;






foreach my $key (sort keys %ccc)
{
	my $aaa=$Ano{$key};
	my $bbb=$Ano2{$key};
	$aaa||="NANA";
	$bbb||="NANA";
	print $key,"\t\t##$aaa\t\t##$bbb\n";
}
######################swimming in the sky and flying in the sea ###########################

