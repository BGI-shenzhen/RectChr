package GenomicLinkPlot;


use ColorPaletteManager qw ( RGB2HTML HTML2RGB  GetColGradien SVGgetShape); 
use LocalUtils ;
#qw (LocalUtils::CheckValueNow svg2PNGfuntion update_value_color_map update_value_color_map2); 

our @EXPORT_OK = qw(PTypeLinkPlot );


sub PTypeLinkPlot
{

	my  ($HashConfi_ref, $ValueToCustomColor_ref,$hashChr_ref,$hashChr2File_ref,$ShowColumn_ref, $FileData_ref, $FileRow_ref,$FileColumn_ref,$ChrArry_ref,$ParaFlag_ref,$widthForPerChr,$ChrMax,$total_chr_length,$RegionStart,$bin,$axis_label,$ChrCount,$color_gradient_scale,$chr_spacing,$Bodyheight,$fontsize, $height,$width,$NumberLevel,$NumParaFlag)=@_;


	my $precision_format="%.0f";
	my $log10=log(10);
	my $chr_name_ratio=$HashConfi_ref->{global}{chr_label_size_ratio};
	my $MaxGradien=$HashConfi_ref->{"global"}{"MaxGradien"};



	if ( exists $HashConfi_ref->{"global"}{"chr_zoom_region"})
	{
		print "Error:\tFor Type [Link] no not  accept global Para : [ZoomRegion];  please remove it  or use the new soft [https://github.com/hewm2008/NGenomeSyn] to re-plot the fig\n";
		exit ;
	}

	if (($NumberLevel>2))
	{
		print "Error:\tFor Type [Link] only accept Level:1 / 2;  please set [ ValueX = 1 ]  or [ ValueX = 2 ]\n";
		print "Error:\t[ValueX = 1] is for two Genomes; [ ValueX = 2 ] is for Three Genomes ;\n";
		print "Error:\tBut you also can use the [SetParaFor=Level3] : ShowColumn  to additional information for Background bar infomation\n";
		exit;
	}


	if ( $FileColumn_ref->[0] != 6 )
	{
		print "Error:\tFor Type [Link] InPut File1 Format must be [chr1 start1 end1 Flag chr2 start2 end2]\n";
		exit;
	}
	if ($#$FileColumn_ref>3 )
	{
		print "Error:\tFor Type [link] InPut only File1 or File2  can be accept and File1/File2 format must be [chr1 start1 end1 Flag chr2 start2 end2]\n";
		print "Error:\twe found the max File$#$FileColumn_ref+1 here, But Only Max File4 can be accept  For Type [Link] here\n ";
		exit;
	}
	elsif ($#$FileColumn_ref==1)
	{
		if ( ( $FileColumn_ref->[1] != 6 )  &&  ($NumberLevel==2) )
		{
			print "Error:\tFor Type [Link] InPut File2 ( ValueX = 2 ) Format must be [chr1 start1 end1 Flag chr2 start2 end2]\n";
			exit ;
		}
	}


	if  ( (  $HashConfi_ref->{1}{"padding_ratio"}  < 2  )  &&  ($NumberLevel==1))
	{
		print "Error:\tFor Type [link] InPut Para [ValueSpacingRatio]  for Level:1  must be >= 2 \n";
		exit;
	}
	elsif ( ($NumberLevel==2) &&  ( $HashConfi_ref->{2}{"padding_ratio"}  < 2  )  )
	{
		print "Error:\tFor Type [link] InPut Para [ValueSpacingRatio]  for Level:2  must be >= 2 \n";
		exit;
	}
	else
	{

	}

	$widthForPerChr+=$HashConfi_ref->{$NumberLevel}{"track_height"}*$HashConfi_ref->{$NumberLevel}{"padding_ratio"};	



	if (!exists $HashConfi_ref->{"global"}{"chr_order"})
	{
		my $bbb=0;if ( $NumberLevel==2 ) {$bbb=1;}
		my %temphcc=();
		foreach my $chrname( keys  %hashChr)
		{
			next if ($hashChr2File->{$chrname} >$bbb);
			$temphcc{$chrname}=1;
		}
		@ChrArry=sort  keys  %temphcc;
		$ChrCount=$#$ChrArry_ref+1;
		%temphcc=();
	}



	my %ChrGenomeA=();
	my %ChrGenomeB=();
	my %ChrGenomeC=();
	my %ReverseChr=();
	foreach my $thisChr (0..$#$ChrArry_ref)
	{
		my $ThisChrName=$ChrArry_ref->[$thisChr];
		$ChrGenomeA{$ThisChrName}=$hashChr_ref->{$ThisChrName};
	}

	my $CoumnNow=3;
	my $StartCount=0;
	$HashConfi_ref->{1}{"IsNumber"}=1;
	$HashConfi_ref->{2}{"IsNumber"}=1;

	my %ChrA2ChrB=();
	my %ChrA2ChrC=();
	my %FlagValue=();

	if ($FileData_ref->[0][0][0] =~s/#/#/)
	{
		$StartCount=1;
	}


	my $FileNow=0;
	my $Level=1;
	for ( ; $StartCount<$FileRow_ref->[0]; $StartCount++)
	{
		my $Value=$FileData_ref->[$FileNow][$StartCount][$CoumnNow];
		next if  ($Value eq "NA" );
		$Value=LocalUtils::CheckValueNow($HashConfi_ref,$Level,$Value);

		my $ThisChrName=$FileData_ref->[$FileNow][$StartCount][0];
		next if (!exists $ChrGenomeA{$ThisChrName});


		my $StartA=$FileData_ref->[$FileNow][$StartCount][1];
		my $EndA  =$FileData_ref->[$FileNow][$StartCount][2];
		my $chrB=$FileData_ref->[$FileNow][$StartCount][4];
		my $StartB=$FileData_ref->[$FileNow][$StartCount][5];
		my $EndB=$FileData_ref->[$FileNow][$StartCount][6];
		if (!exists $ChrGenomeB{$chrB})
		{
			$ChrGenomeB{$chrB}=$EndB;
		}
		elsif ( $ChrGenomeB{$chrB} < $EndB)
		{
			$ChrGenomeB{$chrB}=$EndB;
		}
		if ( $ChrGenomeB{$chrB} < $StartB)
		{
			$ChrGenomeB{$chrB}=$StartB;
		}




		$ChrA2ChrB{$ThisChrName}{$chrB}+=($EndA-$StartA+1) ;

		if ($HashConfi_ref->{$Level}{"log_p"}!=0){$Value=0-log($Value)/$log10;}
		$FlagValue{$Level}{$Value}++;
		$HashConfi_ref->{$Level}{"TotalValue"}++;
		if ($Value=~s/\./\./)
		{
			$precision_format="%.2f";
		}
		if ( $Value =~ /^-?(0|([1-9][0-9]*))(\.[0-9]+)?([eE][-+]?[0-9]+)?$/)
		{
		}
		elsif (!( $Value  =~ /^[+-]?\d+(\.\d+)?$/ ))
		{
			$HashConfi_ref->{1}{"IsNumber"}=0;
		}
	}

	if (exists $HashConfi_ref->{1}{"as_flag"} ) { $HashConfi_ref->{1}{"IsNumber"}=0;}

	my $One2OneAB=1;
	my $One2OneAC=1;
	my @ChrArryBB=();
	my @ChrArryCC=();
	my %BB2AA=();
	my %CC2AA=();

	foreach my $thisChr (0..$#$ChrArry_ref)
	{
		my $ThisChrName=$ChrArry_ref->[$thisChr];
		my $TemBB=$ChrA2ChrB{$ThisChrName};
		my @bbbbbb = keys %$TemBB;
		my $TYU="NA";
		for (my $uu=0 ; $uu<=$#bbbbbb ; $uu++)
		{
			if (!exists $BB2AA{$bbbbbb[$uu]} )
			{
				$BB2AA{$bbbbbb[$uu]}=$thisChr;
				if ($TYU eq "NA")
				{
					$TYU=$bbbbbb[$uu];
				}
				else
				{
					$TYU=$TYU.",$bbbbbb[$uu]";
				}
			}
			else
			{
				$One2OneAB=0;
				my $FirstNum=$BB2AA{$bbbbbb[$uu]};
				my $lengthSed=$ChrA2ChrB{$ThisChrName}{$bbbbbb[$uu]};
				my $ChrAAtmp=$ChrArry_ref->[$FirstNum];
				my $LengthFirst=$ChrA2ChrB{$ChrAAtmp}{$bbbbbb[$uu]};
				if ( ($LengthFirst*1.1) < $lengthSed )
				{
					$BB2AA{$bbbbbb[$uu]}=$thisChr;
					if ($TYU eq "NA")
					{
						$TYU=$bbbbbb[$uu];
					}
					else
					{
						$TYU=$TYU.",$bbbbbb[$uu]";
					}

					my @ccT=split(/\,/,$ChrArryBB[$FirstNum]);
					my $TYU_First="NA";
					foreach my $tmpww (0..$#ccT)
					{
						next if ( $ccT[$tmpww] eq  $bbbbbb[$uu]);
						if ($TYU_First eq "NA")
						{
							$TYU_First=$ccT[$tmpww];
						}
						else
						{
							$TYU_First=$TYU_First.",$ccT[$tmpww]";
						}
					}
					$ChrArryBB[$FirstNum]=$TYU_First;
				}
			}
		}
		$ChrArryBB[$thisChr]=$TYU;
		$ChrArryCC[$thisChr]="NA";
	}


	if ( ($#$FileColumn_ref>0)  &&  ($NumberLevel==2)  )
	{
		$StartCount=0;
		$FileNow=1;
		$Level=2;
		if  ($FileData_ref->[1][0][0] =~s/#/#/)
		{
			$StartCount=1;
		}


		for ( ; $StartCount<$FileRow_ref->[1]; $StartCount++)
		{
			my $Value=$FileData_ref->[$FileNow][$StartCount][$CoumnNow];
			next if  ($Value eq "NA");
			$Value=LocalUtils::CheckValueNow($HashConfi_ref,$Level,$Value);

			my $ThisChrName=$FileData_ref->[$FileNow][$StartCount][0];
			next if (!exists $ChrGenomeA{$ThisChrName});

			my $StartA=$FileData_ref->[$FileNow][$StartCount][1];
			my $EndA  =$FileData_ref->[$FileNow][$StartCount][2];
			my $chrB=$FileData_ref->[$FileNow][$StartCount][4];
			my $StartB=$FileData_ref->[$FileNow][$StartCount][5];
			my $EndB=$FileData_ref->[$FileNow][$StartCount][6];
			if (!exists $ChrGenomeC{$chrB})
			{
				$ChrGenomeC{$chrB}=$EndB;
			}
			elsif ( $ChrGenomeC{$chrB} < $EndB)
			{
				$ChrGenomeC{$chrB}=$EndB;
			}
			if ( $ChrGenomeC{$chrB} < $StartB)
			{
				$ChrGenomeC{$chrB}=$StartB;
			}


			if ($HashConfi_ref->{$Level}{"log_p"}!=0)
			{
				$Value=0-log($Value)/$log10;
			}
			$FlagValue{$Level}{$Value}++;
			$HashConfi_ref->{$Level}{"TotalValue"}++;
			if ($Value=~s/\./\./)
			{
				$precision_format="%.2f";
			}

			$ChrA2ChrC{$ThisChrName}{$chrB}+=($EndA-$StartA+1) ;

			if ( $Value =~ /^-?(0|([1-9][0-9]*))(\.[0-9]+)?([eE][-+]?[0-9]+)?$/)
			{

			}
			elsif (!( $Value  =~ /^[+-]?\d+(\.\d+)?$/ ))
			{
				$HashConfi_ref->{2}{"IsNumber"}=0;
			}
		}

		if (exists $HashConfi_ref->{2}{"as_flag"} ) { $HashConfi_ref->{2}{"IsNumber"}=0;}

		foreach my $thisChr (0..$#$ChrArry_ref)
		{
			my $ThisChrName=$ChrArry_ref->[$thisChr];
			my $TemCC=$ChrA2ChrC{$ThisChrName};
			my @bbbbbb = keys %$TemCC;
			my $TYU="NA";
			for (my $uu=0 ; $uu<=$#bbbbbb ; $uu++)
			{
				if (!exists $CC2AA{$bbbbbb[$uu]} )
				{
					$CC2AA{$bbbbbb[$uu]}=$thisChr;
					if ($TYU eq "NA")
					{
						$TYU=$bbbbbb[$uu];
					}
					else
					{
						$TYU=$TYU.",$bbbbbb[$uu]";
					}
				}
				else
				{
					$One2OneAC=0;
					my $FirstNumCC=$CC2AA{$bbbbbb[$uu]};
					my $lengthSed=$ChrA2ChrC{$ThisChrName}{$bbbbbb[$uu]};
					my $ChrAAtmp=$ChrArry_ref->[$FirstNumCC];
					my $LengthFirst=$ChrA2ChrC{$ChrAAtmp}{$bbbbbb[$uu]};
					if ($LengthFirst*1.1 < $lengthSed )
					{
						$BB2AA{$bbbbbb[$uu]}=$thisChr;
						if ($TYU eq "NA")
						{
							$TYU=$bbbbbb[$uu];
						}
						else
						{
							$TYU=$TYU.",$bbbbbb[$uu]";
						}
						my @ccT=split /\,/ , $ChrArryCC[$FirstNumCC];
						my $TYU_FirstCC="NA";
						foreach my $tmpww (0..$#ccT)
						{
							next if ($ccT[$tmpww] eq  $bbbbbb[$uu]);
							if ($TYU_FirstCC eq "NA")
							{
								$TYU_FirstCC=$ccT[$tmpww];
							}
							else
							{
								$TYU_FirstCC=$TYU_FirstCC.",$ccT[$tmpww]";
							}
						}
						$ChrArryCC[$FirstNumCC]=$TYU_FirstCC;
					}
				}
			}
			$ChrArryCC[$thisChr]=$TYU;
		}


	}


	my $One2One=$ChrCount;

	my $ChrMaxUnit=$ChrMax/$HashConfi_ref->{"global"}{"canvas_body"};
	my $ChrMaxUnitV2=$ChrMaxUnit;
	my $ChrMaxUnitV3=$ChrMaxUnit;
	my $XBetweenChr=$HashConfi_ref->{"global"}{"canvas_margin_left"}*$HashConfi_ref->{"global"}{"chr_spacing_ratio"};
	my $all_chromosomes_spacing=0;
	if ( ( $One2OneAB== 1 )  &&  ( $One2OneAC==1)  &&  (  $HashConfi_ref->{"global"}{"chr_orientation"} eq  "vertical")    &&  ($One2One!=1)  )
	{
		my $MaxCunt=0;
		foreach my $thisChr (0..$#$ChrArry_ref)
		{
			next if  ($ChrArryCC[$thisChr] eq "NA");
			my @ccT=split /\,/ , $ChrArryCC[$thisChr];
			my $Cunt=$#ccT;
			my $length=0;
			foreach my $tmpww (0..$Cunt)
			{
				$length+=$ChrGenomeC{$ccT[$tmpww]};
			}
			my $UnitC=$length/$HashConfi_ref->{"global"}{"canvas_body"};
			if ($MaxCunt> $Cunt) {$MaxCunt=$Cunt ;}
			if ($UnitC > $ChrMaxUnit) {$ChrMaxUnit=$UnitC;}
		}

		foreach my $thisChr (0..$#$ChrArry_ref)
		{
			next if ($ChrArryBB[$thisChr] eq "NA");
			my @ccT=split /\,/ , $ChrArryBB[$thisChr];
			my $Cunt=$#ccT;
			my $length=0;
			foreach my $tmpww (0..$Cunt)
			{
				$length+=$ChrGenomeB{$ccT[$tmpww]};
			}
			my $UnitC=$length/$HashConfi_ref->{"global"}{"canvas_body"};
			if ($MaxCunt> $Cunt) {$MaxCunt=$Cunt ;}
			if ($UnitC > $ChrMaxUnit) {$ChrMaxUnit=$UnitC;}
		}
		$all_chromosomes_spacing=($MaxCunt*$XBetweenChr);
		$width+=$all_chromosomes_spacing;
		$HashConfi_ref->{"global"}{"canvas_body"}+=$all_chromosomes_spacing;
	}
	else
	{
		$One2One=1;

		my $length=0;
		my $CuntAA=-1;

		my $ALLONE_CC="NA";
		my %FlagTmpAA=();
		foreach my $thisChr (0..$#$ChrArry_ref)
		{
			next if  ($ChrArryCC[$thisChr] eq "NA");
			my @ccT=split /\,/ , $ChrArryCC[$thisChr];
			foreach my $tmpww (0..$#ccT)
			{
				next if (exists $FlagTmpAA{$ccT[$tmpww]});
				$FlagTmpAA{$ccT[$tmpww]}=1;
				$length+=$ChrGenomeC{$ccT[$tmpww]};
				$CuntAA++;
				if ($ALLONE_CC eq "NA")
				{
					$ALLONE_CC =$ccT[$tmpww];
				}
				else
				{
					$ALLONE_CC =$ALLONE_CC.",$ccT[$tmpww]";
				}
			}
		}
		my $UnitC=$length/($HashConfi_ref->{"global"}{"canvas_body"});
		if ($UnitC > $ChrMaxUnit) {$ChrMaxUnit=$UnitC;}
		if (exists $HashConfi_ref->{"2"}{"chr_order"}){$ALLONE_CC=$HashConfi_ref->{"2"}{"chr_order"};}

		$length=0;
		my $CuntBB=-1;
		my $ALLONE_BB="NA";

		%FlagTmpAA=();
		foreach my $thisChr (0..$#$ChrArry_ref)
		{
			next if ($ChrArryBB[$thisChr] eq "NA");
			my @ccT=split /\,/ , $ChrArryBB[$thisChr];
			foreach my $tmpww (0..$#ccT)			
			{
				next if (exists $FlagTmpAA{$ccT[$tmpww]});
				$FlagTmpAA{$ccT[$tmpww]}=1;
				$length+=$ChrGenomeB{$ccT[$tmpww]};
				$CuntBB++;
				if ($ALLONE_BB eq "NA")
				{
					$ALLONE_BB =$ccT[$tmpww];
				}
				else
				{
					$ALLONE_BB =$ALLONE_BB.",$ccT[$tmpww]";
				}

			}
		}

		$UnitC=$length/($HashConfi_ref->{"global"}{"canvas_body"});
		if ($UnitC > $ChrMaxUnit) {$ChrMaxUnit=$UnitC;}
		if (exists $HashConfi_ref->{"1"}{"chr_order"}){$ALLONE_BB=$HashConfi_ref->{"1"}{"chr_order"};}

		$length=0;
		my $CuntCC=-1;
		my $ALLONE_AA="NA";
		%FlagTmpAA=();
		foreach my $thisChr (0..$#$ChrArry_ref)
		{
			my $ThisChrName=$ChrArry_ref->[$thisChr];
			next if (exists $FlagTmpAA{$ThisChrName});
			$FlagTmpAA{$ThisChrName}=1;
			$length+=$ChrGenomeA{$ThisChrName};
			$CuntCC++;
			if ($ALLONE_AA eq "NA")
			{
				$ALLONE_AA = $ThisChrName;
			}
			else
			{
				$ALLONE_AA =$ALLONE_AA.",$ThisChrName";
			}
		}
		$UnitC=$length/($HashConfi_ref->{"global"}{"canvas_body"});
		if ($UnitC > $ChrMaxUnit) {$ChrMaxUnit=$UnitC;}

		$ChrArry_ref->[0]=$ALLONE_AA;
		$ChrArryBB[0]=$ALLONE_BB;
		$ChrArryCC[0]=$ALLONE_CC;
		my $Cunt=0; 
		if ($CuntAA>$Cunt){$Cunt=$CuntAA;}
		if ($CuntBB>$Cunt){$Cunt=$CuntBB;}
		if ($CuntCC>$Cunt){$Cunt=$CuntCC;}
		$all_chromosomes_spacing=(($Cunt+1)*$XBetweenChr);
		$width+=$all_chromosomes_spacing;
		$HashConfi_ref->{"global"}{"canvas_body"}+=$all_chromosomes_spacing;
	}


	$ChrMaxUnitV2=$ChrMaxUnit;
	$ChrMaxUnitV3=$ChrMaxUnit;


	$widthForPerChr+=$HashConfi_ref->{ALL}{"track_height"};
	if ($widthForPerChr=~s/\././) { $widthForPerChr=sprintf ("%.1f",$widthForPerChr+0);}
	$Bodyheight=($One2One+0.5)*($widthForPerChr+$chr_spacing);
	$height=$HashConfi_ref->{"global"}{"canvas_margin_top"}+$HashConfi_ref->{"global"}{"canvas_margin_bottom"}+$Bodyheight;

	print STDERR "Start draw... SVG info: ChrNumber :$ChrCount Track(Level) Number is $NumberLevel, SVG (width,height) = ($width,$height)\n";

	$ChrCount--;
	my  $LegendOffsetRatio=0.5;
	my  $Y2=$HashConfi_ref->{"global"}{"canvas_margin_top"}+$LegendOffsetRatio*$Bodyheight+$HashConfi_ref->{"ALL"}{"colormap_legend_sizeratio"}*$color_gradient_scale*($MaxGradien+1);
	if ($Y2 > $height )
	{
		$height=$Y2*1.10;
		$LegendOffsetRatio=0.3;
	}

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

	my $svg = SVG->new('width',$CanvasWidth,'height',$CanvasHeight);

	$ChrMax=$HashConfi_ref->{"global"}{"canvas_body"}*$ChrMaxUnit;
	my $XX2=$HashConfi_ref->{"global"}{"canvas_margin_left"}+$HashConfi_ref->{"global"}{"canvas_body"}+$HashConfi_ref->{"global"}{"stroke-width"};
	my $YY3=$HashConfi_ref->{"global"}{"canvas_margin_top"}+$HashConfi_ref->{"global"}{"xaxis_shift_y"};
	my $YY1=$YY3-$fontsize*0.75;
	my $YY2=$YY1+$fontsize*0.25;
	my $XX1;
	my $ScaleNum=$HashConfi_ref->{"global"}{"axis_tick_num"};
	my $ScaleNumChrMax=$ScaleNum;
	my $BinXX=$HashConfi_ref->{"global"}{"canvas_body"}/$ScaleNum;

	if  (exists $HashConfi_ref->{"global"}{"axis_tick_interval"} )
	{
		$ScaleNumChrMax=$ChrMax*1.0/$HashConfi_ref->{"global"}{"axis_tick_interval"};
		if ($ScaleNumChrMax  < 2   ||  $ScaleNumChrMax >100 )
		{
			print "Pare [ScaleUnit] set is too small or too big, we use ScaleNum= $ScaleNum \n";
			$ScaleNumChrMax=$ScaleNum;
		}
		$BinXX=($HashConfi_ref->{"global"}{"canvas_body"}+$all_chromosomes_spacing)/$ScaleNumChrMax;
		$ScaleNum=int($ScaleNumChrMax);
	}

	foreach my $k (0..$ScaleNum)
	{
		$XX1=$HashConfi_ref->{"global"}{"canvas_margin_left"}+$k*$BinXX;

		my $VV=int($RegionStart/$bin+$ChrMax*$k/($bin*$ScaleNumChrMax));
		if ($axis_label eq "kb")		{			$VV= sprintf ("%.1f",($RegionStart/$bin+$ChrMax*$k/($bin*$ScaleNumChrMax))*1.0);}
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
		$svg->line('x1',$XX1,'y1',$YY1,'x2',$XX1,'y2',$YY3,'stroke','black','stroke-width',$HashConfi_ref->{"global"}{"stroke-width"},'fill',$HashConfi_ref->{"global"}{"fill"}); #X
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
		$svg->text('text-anchor','middle','x',$MainXX1,'y',$MainYY1,'-cdata',$HashConfi_ref->{"global"}{"title"},'font-family',$HashConfi_ref->{"global"}{"font-family"},'font-size',$Mainfortsize,'stroke',$colr,'fill',$colr);

	}

	$XX1=$HashConfi_ref->{"global"}{"canvas_margin_left"}-$HashConfi_ref->{"global"}{"stroke-width"};
	my $path = $svg->get_path(
		x => [$XX1, $XX1, $XX2,$XX2],
		y => [$YY1, $YY2, $YY2,$YY1],
		-type => 'polygon');

	if  ( $ScaleNum   > 0)
	{
		$svg->polygon(
			%$path,
			style => {
				'fill'           => $HashConfi_ref->{"global"}{"fill"},
				'stroke'         => 'black',
				'stroke-width'   =>  0,
				'stroke-opacity' =>  $HashConfi_ref->{"ALL"}{"stroke-opacity"},
				'fill-opacity'   =>  $HashConfi_ref->{"ALL"}{"fill-opacity"},
			},
		);
	}

	my $TwoChrHH=$HashConfi_ref->{1}{"track_height"}*$HashConfi_ref->{1}{"padding_ratio"};
	my $TwoChrHHV2=$TwoChrHH;
	my %hashYY1=();	my %hashYY2=();	my %hashXX1=();

	if ($NumberLevel==1)
	{
		for ( my $thisChr=0 ; $thisChr < $One2One ; $thisChr++ )
		{
			my $ThisChrName=$ChrArry_ref->[$thisChr];
			my $Level=1;
			next  if ($ThisChrName eq "NA");
			my $Y1=$HashConfi_ref->{"global"}{"canvas_margin_top"}+$thisChr*($widthForPerChr+$chr_spacing)+$chr_spacing;
			$YY1=$Y1;
			$YY2=$YY1+$HashConfi_ref->{ALL}{"track_height"};
			my $Mid=($YY1+$YY2)/2;
			my $AA=$HashConfi_ref->{ALL}{"track_bg_height_ratio"}*$HashConfi_ref->{ALL}{"track_height"}/2;
			$YY1=$Mid-$AA;
			$YY2=$Mid+$AA;
			my $YY3=$YY2+$TwoChrHH;
			my $YY4=$YY3+$HashConfi_ref->{$Level}{"track_height"};
			$Mid=($YY3+$YY4)/2;
			$AA=$HashConfi_ref->{$Level}{"track_bg_height_ratio"}*$HashConfi_ref->{$Level}{"track_height"}/2;
			$YY3=$Mid-$AA;
			$YY4=$Mid+$AA;
			my @ChrNameAA=split /\,/,$ThisChrName;
			$XX1=$HashConfi_ref->{"global"}{"canvas_margin_left"};
			for (my $YYUU=0 ; $YYUU<=$#ChrNameAA  ; $YYUU++)
			{
				my $AAAChrName=$ChrNameAA[$YYUU];
				$XX2= ($ChrGenomeA{$AAAChrName})/($ChrMaxUnit)+$XX1;
				$hashYY1{$AAAChrName}{0}=$YY1;
				$hashYY2{$AAAChrName}{0}=$YY2;
				$hashXX1{$AAAChrName}{0}=$XX1;
				my $BGCorThisChr=$HashConfi_ref->{ALL}{"background_color"} ;
				if (exists 	$ValueToCustomColor_ref->{$AAAChrName}) {$BGCorThisChr=$ValueToCustomColor_ref->{$AAAChrName};}
				if ($HashConfi_ref->{ALL}{"bg_end_arc"}==0)
				{
					$path = $svg->get_path(
						x => [$XX1, $XX1, $XX2,$XX2],
						y => [$YY1, $YY2, $YY2,$YY1],
						-type => 'polygon');

					$svg->polygon(
						%$path,
						style => {
							'fill'           => $BGCorThisChr,
							'stroke'         => $HashConfi_ref->{ALL}{"bg_stroke_color"},
							'stroke-width'   => $HashConfi_ref->{ALL}{"bg_stroke_width"},
							'stroke-opacity' => $HashConfi_ref->{ALL}{"stroke-opacity"},
							'fill-opacity'   => $HashConfi_ref->{ALL}{"fill-opacity"},
						},
					);
				}
				else
				{
					my $EndCurveRadian=3;
					if (exists $HashConfi_ref->{ALL}{"bg_end_arc_division"})
					{
						if ($HashConfi_ref->{ALL}{"bg_end_arc_division"}>=2)
						{
							$EndCurveRadian=$HashConfi_ref->{ALL}{"bg_end_arc_division"};
						}
						else
						{
							print "Leve ALL Para EndCurveRadian must >=2 ,so we chang it to be 2\n";
							$EndCurveRadian=2;$HashConfi_ref->{ALL}{"bg_end_arc_division"}=2;
						}
					}

					my $HH=($YY2-$YY1)/$EndCurveRadian;
					if (($HH*2)>abs($XX2-$XX1)) {$HH=abs($XX2-$XX1)*0.5;}
					my $HM=($YY2-$YY1)-$HH-$HH;
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
							'stroke'         =>  $HashConfi_ref->{ALL}{"bg_stroke_color"},
							'stroke-width'   =>  $HashConfi_ref->{ALL}{"bg_stroke_width"},
							'stroke-opacity' =>  $HashConfi_ref->{ALL}{"stroke-opacity"},
							'fill-opacity'   =>  $HashConfi_ref->{ALL}{"fill-opacity"},
						},
					);
				}
				my $ChrNameRatio=$HashConfi_ref->{"ALL"}{"chr_label_size_ratio"}; $ChrNameRatio||=1;
				my $AAAfontsize=$fontsize*$ChrNameRatio;
				my $XX3=$XX1-length($AAAChrName)*$AAAfontsize*$chr_name_ratio+$HashConfi_ref->{"ALL"}{"chr_label_shift_x"};
				my $TextYY=($YY1+$YY2)*0.5+$HashConfi_ref->{"ALL"}{"chr_label_shift_y"}+($AAAfontsize*0.5);
				if ($XX3<0) {$XX3=0;}
				if ($HashConfi_ref->{"global"}{"chr_label_rotation"}==0)
				{
					$svg->text('text-anchor','middle','x',$XX3,'y',$TextYY,'-cdata',$AAAChrName,'font-family',$HashConfi_ref->{"global"}{"font-family"},'font-size',$AAAfontsize);
				}
				else
				{
					my $XX3=$XX1-$AAAfontsize*1.1+$HashConfi_ref->{"ALL"}{"chr_label_shift_x"};
					my $rotate=$HashConfi_ref->{"global"}{"chr_label_rotation"};					
					$svg->text('text-anchor','middle','x',$XX3,'y',$TextYY,'-cdata',$AAAChrName,'font-family',$HashConfi_ref->{"global"}{"font-family"},'font-size',$AAAfontsize,'transform',"rotate($rotate,$XX3,$TextYY)");
				}
				$XX1=$XX2+$XBetweenChr;
			}


			my @ChrNameBB=split /\,/,$ChrArryBB[$thisChr];
			$XX1=$HashConfi_ref->{"global"}{"canvas_margin_left"};
			if  (exists $HashConfi_ref->{$Level}{"chr_scale_ratio"}) {$ChrMaxUnitV2=$ChrMaxUnit/$HashConfi_ref->{$Level}{"chr_scale_ratio"};}
			for (my $YYUU=0 ; $YYUU<=$#ChrNameBB  ; $YYUU++)
			{
				my $BBBChrName=$ChrNameBB[$YYUU];
				next if ($BBBChrName eq "NA");
				$XX2=($ChrGenomeB{$BBBChrName})/($ChrMaxUnitV2)+$XX1;
				$hashYY1{$BBBChrName}{$Level}=$YY3;
				$hashYY2{$BBBChrName}{$Level}=$YY4;
				$hashXX1{$BBBChrName}{$Level}=$XX1;
				my $BGCorThisChr=$HashConfi_ref->{$Level}{"background_color"} ;
				if (exists 	$ValueToCustomColor_ref->{$BBBChrName}) {$BGCorThisChr=$ValueToCustomColor_ref->{$BBBChrName};}


				if ($HashConfi_ref->{$Level}{"bg_end_arc"}==0)
				{

					$path = $svg->get_path(
						x => [$XX1, $XX1, $XX2,$XX2],
						y => [$YY3, $YY4, $YY4,$YY3],
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
					my $EndCurveRadian=3;
					if (exists $HashConfi_ref->{$Level}{"bg_end_arc_division"})
					{
						if ($HashConfi_ref->{$Level}{"bg_end_arc_division"}>=2)
						{
							$EndCurveRadian=$HashConfi_ref->{$Level}{"bg_end_arc_division"};
						}
						else
						{
							print "Leve $Level Para EndCurveRadian must >=2 ,so we chang it to be 2\n";
							$EndCurveRadian=2;$HashConfi_ref->{$Level}{"bg_end_arc_division"}=2;
						}

					}
					my $HH=($YY4-$YY3)/$EndCurveRadian;
					if (($HH*2)>abs($XX2-$XX1)) {$HH=abs($XX2-$XX1)*0.5;}
					my $HM=($YY4-$YY3)-$HH-$HH;
					my $P1_X=$XX1+$HH;  my $P1_Y=$YY3;
					my $P1Q_X=$XX1;  my $P1Q_Y=$YY3;
					my $P2_X=$XX1;  my $P2_Y=$YY3+$HH;
					my $P3_X=$XX1;  my $P3_Y=$P2_Y+$HM;
					my $P2Q_X=$XX1;  my $P2Q_Y=$YY4;
					my $P4_X=$XX1+$HH;  my $P4_Y=$YY4;
					my $P3Q_X=$XX2;  my $P3Q_Y=$YY4;
					my $P6_X=$XX2-$HH;  my $P6_Y=$YY4;
					my $P7_X=$XX2;  my $P7_Y=$YY4-$HH;
					my $P8_X=$XX2;  my $P8_Y=$P7_Y-$HM;
					my $P4Q_X=$XX2;  my $P4Q_Y=$YY3;
					my $P9_X=$XX2-$HH;  my $P9_Y=$YY3;
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


				}

				my $ChrNameRatio=$HashConfi_ref->{$Level}{"chr_label_size_ratio"}; $ChrNameRatio||=1;
				my $BBBfontsize=$fontsize*$ChrNameRatio;

				my $XX3=$XX1-length($BBBChrName)*$BBBfontsize*$chr_name_ratio+$HashConfi_ref->{$Level}{"chr_label_shift_x"};
				my $TextYY=($YY3+$YY4)*0.5+$HashConfi_ref->{$Level}{"chr_label_shift_y"}+($BBBfontsize*0.5);
				if ($XX3<0) {$XX3=0;}
				if ($HashConfi_ref->{"global"}{"chr_label_rotation"}==0)
				{
					$svg->text('text-anchor','middle','x',$XX3,'y',$TextYY,'-cdata',$BBBChrName,'font-family',$HashConfi_ref->{"global"}{"font-family"},'font-size',$BBBfontsize);
				}
				else
				{
					my $XX3=$XX1-$BBBfontsize*1.1+$HashConfi_ref->{$Level}{"chr_label_shift_x"};
					my $rotate=$HashConfi_ref->{"global"}{"chr_label_rotation"};
					$svg->text('text-anchor','middle','x',$XX3,'y',$TextYY,'-cdata',$BBBChrName,'font-family',$HashConfi_ref->{"global"}{"font-family"},'font-size',$BBBfontsize,'transform',"rotate($rotate,$XX3,$TextYY)");
				}
				$XX1=$XX2+$XBetweenChr;
			}
		}
	}
	else
	{
		$TwoChrHHV2=$HashConfi_ref->{2}{"track_height"}*$HashConfi_ref->{2}{"padding_ratio"};
		for ( my $thisChr=0 ;  $thisChr < $One2One ; $thisChr++ )
		{
			my $ThisChrName=$ChrArry_ref->[$thisChr];
			my $Level=1;
			my $LevelV2=2;
			next  if ($ThisChrName eq "NA");
			my $Y1=$HashConfi_ref->{"global"}{"canvas_margin_top"}+$thisChr*($widthForPerChr+$chr_spacing)+$chr_spacing;
			$YY1=$Y1;			
			$YY2=$YY1+$HashConfi_ref->{$Level}{"track_height"};

			my $Mid=($YY1+$YY2)/2;
			my $AA=$HashConfi_ref->{$Level}{"track_bg_height_ratio"}*$HashConfi_ref->{$Level}{"track_height"}/2;
			$YY1=$Mid-$AA;
			$YY2=$Mid+$AA;
			my $YY3=$YY2+$TwoChrHH;
			my $YY4=$YY3+$HashConfi_ref->{ALL}{"track_height"};
			$Mid=($YY3+$YY4)/2;
			$AA=$HashConfi_ref->{ALL}{"track_bg_height_ratio"}*$HashConfi_ref->{ALL}{"track_height"}/2;
			$YY3=$Mid-$AA;
			$YY4=$Mid+$AA;

			my $YY5=$YY4+$TwoChrHHV2;
			my $YY6=$YY5+$HashConfi_ref->{$LevelV2}{"track_height"};
			$AA=$HashConfi_ref->{$LevelV2}{"track_bg_height_ratio"}*$HashConfi_ref->{$LevelV2}{"track_height"}/2;
			$Mid=($YY5+$YY6)/2;
			$YY5=$Mid-$AA;
			$YY6=$Mid+$AA;


			my @ChrNameAA=split /\,/,$ThisChrName ;
			$XX1=$HashConfi_ref->{"global"}{"canvas_margin_left"};
			for (my $YYUU=0 ; $YYUU<=$#ChrNameAA  ; $YYUU++)
			{
				my $AAAChrName=$ChrNameAA[$YYUU];
				$XX2= ($ChrGenomeA{$AAAChrName})/($ChrMaxUnit)+$XX1;
				$hashYY1{$AAAChrName}{0}=$YY3;
				$hashYY2{$AAAChrName}{0}=$YY4;
				$hashXX1{$AAAChrName}{0}=$XX1;
				my $BGCorThisChr=$HashConfi_ref->{ALL}{"background_color"} ;
				if (exists 	$ValueToCustomColor_ref->{$AAAChrName}) {$BGCorThisChr=$ValueToCustomColor_ref->{$AAAChrName};}
				if ($HashConfi_ref->{"ALL"}{"bg_end_arc"}==0)
				{
					$path = $svg->get_path(
						x => [$XX1, $XX1, $XX2,$XX2],
						y => [$YY3, $YY4, $YY4,$YY3],
						-type => 'polygon');

					$svg->polygon(
						%$path,
						style => {
							'fill'           => $BGCorThisChr,
							'stroke'         => $HashConfi_ref->{ALL}{"bg_stroke_color"},
							'stroke-width'   => $HashConfi_ref->{ALL}{"bg_stroke_width"},
							'stroke-opacity' => $HashConfi_ref->{ALL}{"stroke-opacity"},
							'fill-opacity'   => $HashConfi_ref->{ALL}{"fill-opacity"},
						},
					);
				}
				else				
				{
					my $EndCurveRadian=3;
					if (exists $HashConfi_ref->{ALL}{"bg_end_arc_division"})
					{
						if ($HashConfi_ref->{ALL}{"bg_end_arc_division"}>=2)
						{
							$EndCurveRadian=$HashConfi_ref->{ALL}{"bg_end_arc_division"};
						}
						else
						{
							print "Leve ALL Para EndCurveRadian must >=2 ,so we chang it to be 2\n";
							$EndCurveRadian=2;$HashConfi_ref->{ALL}{"bg_end_arc_division"}=2;
						}

					}
					my $HH=($YY4-$YY3)/$EndCurveRadian;
					if (($HH*2)>abs($XX2-$XX1)) {$HH=abs($XX2-$XX1)*0.5;}
					my $HM=($YY4-$YY3)-$HH-$HH;
					my $P1_X=$XX1+$HH;  my $P1_Y=$YY3;
					my $P1Q_X=$XX1;  my $P1Q_Y=$YY3;
					my $P2_X=$XX1;  my $P2_Y=$YY3+$HH;
					my $P3_X=$XX1;  my $P3_Y=$P2_Y+$HM;
					my $P2Q_X=$XX1;  my $P2Q_Y=$YY4;
					my $P4_X=$XX1+$HH;  my $P4_Y=$YY4;
					my $P3Q_X=$XX2;  my $P3Q_Y=$YY4;
					my $P6_X=$XX2-$HH;  my $P6_Y=$YY4;
					my $P7_X=$XX2;  my $P7_Y=$YY4-$HH;
					my $P8_X=$XX2;  my $P8_Y=$P7_Y-$HM;
					my $P4Q_X=$XX2;  my $P4Q_Y=$YY3;
					my $P9_X=$XX2-$HH;  my $P9_Y=$YY3;
					$svg->path(
						'd'=>"M$P1_X $P1_Y Q $P1Q_X $P1Q_Y , $P2_X $P2_Y L  $P3_X $P3_Y  Q $P2Q_X $P2Q_Y , $P4_X $P4_Y   L $P6_X $P6_Y  Q $P3Q_X $P3Q_Y , $P7_X $P7_Y  L $P8_X $P8_Y Q $P4Q_X $P4Q_Y ,$P9_X $P9_Y  Z",
						style => {
							'fill'           =>  $BGCorThisChr,
							'stroke'         =>  $HashConfi_ref->{ALL}{"bg_stroke_color"},
							'stroke-width'   =>  $HashConfi_ref->{ALL}{"bg_stroke_width"},
							'stroke-opacity' =>  $HashConfi_ref->{ALL}{"stroke-opacity"},
							'fill-opacity'   =>  $HashConfi_ref->{ALL}{"fill-opacity"},
						},
					);



				}

				my $ChrNameRatio=$HashConfi_ref->{"ALL"}{"chr_label_size_ratio"}; $ChrNameRatio||=1;
				my $AAAfontsize=$fontsize*$ChrNameRatio;
				my $XX3=$XX1-length($AAAChrName)*$AAAfontsize*$chr_name_ratio+$HashConfi_ref->{"ALL"}{"chr_label_shift_x"};
				if ($XX3<0) {$XX3=0;}
				my $TextYY=($YY3+$YY4)*0.5+$HashConfi_ref->{"ALL"}{"chr_label_shift_y"}+($AAAfontsize*0.5);
				if ($HashConfi_ref->{"global"}{"chr_label_rotation"}==0)
				{
					$svg->text('text-anchor','middle','x',$XX3,'y',$TextYY,'-cdata',$AAAChrName,'font-family',$HashConfi_ref->{"global"}{"font-family"},'font-size',$AAAfontsize);
				}
				else
				{
					my $XX3=$XX1-$AAAfontsize*1.1+$HashConfi_ref->{"ALL"}{"chr_label_shift_x"};
					my $rotate=$HashConfi_ref->{"global"}{"chr_label_rotation"};
					$svg->text('text-anchor','middle','x',$XX3,'y',$TextYY,'-cdata',$AAAChrName,'font-family',$HashConfi_ref->{"global"}{"font-family"},'font-size',$AAAfontsize,'transform',"rotate($rotate,$XX3,$TextYY)");
				}

				$XX1=$XX2+$XBetweenChr;
			}


			my @ChrNameBB=split /\,/,$ChrArryBB[$thisChr];
			$XX1=$HashConfi_ref->{"global"}{"canvas_margin_left"};
			if  (exists $HashConfi_ref->{$Level}{"chr_scale_ratio"}) {$ChrMaxUnitV2=$ChrMaxUnitV2/$HashConfi_ref->{$Level}{"chr_scale_ratio"};}
			for (my $YYUU=0 ; $YYUU<=$#ChrNameBB  ; $YYUU++)
			{
				my $BBBChrName=$ChrNameBB[$YYUU];
				next if ($BBBChrName eq "NA");
				$XX2= ($ChrGenomeB{$BBBChrName})/($ChrMaxUnitV2)+$XX1;
				$hashYY1{$BBBChrName}{$Level}=$YY1;
				$hashYY2{$BBBChrName}{$Level}=$YY2;
				$hashXX1{$BBBChrName}{$Level}=$XX1;
				my $BGCorThisChr=$HashConfi_ref->{$Level}{"background_color"} ;
				if (exists 	$ValueToCustomColor_ref->{$BBBChrName}) {$BGCorThisChr=$ValueToCustomColor_ref->{$BBBChrName};}
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
					my $EndCurveRadian=3;
					if (exists $HashConfi_ref->{$Level}{"bg_end_arc_division"})
					{
						if ($HashConfi_ref->{$Level}{"bg_end_arc_division"}>=2)
						{
							$EndCurveRadian=$HashConfi_ref->{$Level}{"bg_end_arc_division"};
						}
						else
						{
							print "Leve $Level Para EndCurveRadian must >=2 ,so we chang it to be 2\n";
							$EndCurveRadian=2;$HashConfi_ref->{$Level}{"bg_end_arc_division"}=2;
						}

					}
					my $HH=($YY2-$YY1)/$EndCurveRadian;
					if (($HH*2)>abs($XX2-$XX1)) {$HH=abs($XX2-$XX1)*0.5;}
					my $HM=($YY2-$YY1)-$HH-$HH;
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


				}

				my $ChrNameRatio=$HashConfi_ref->{$Level}{"chr_label_size_ratio"}; $ChrNameRatio||=1;
				my $BBBfontsize=$fontsize*$ChrNameRatio;

				my $XX3=$XX1-length($BBBChrName)*$BBBfontsize*$chr_name_ratio+$HashConfi_ref->{$Level}{"chr_label_shift_x"};
				if ($XX3<0) {$XX3=0;}
				my $TextYY=($YY1+$YY2)*0.5+$HashConfi_ref->{$Level}{"chr_label_shift_y"}+($BBBfontsize*0.5);
				if ($HashConfi_ref->{"global"}{"chr_label_rotation"}==0)
				{
					$svg->text('text-anchor','middle','x',$XX3,'y',$TextYY,'-cdata',$BBBChrName,'font-family',$HashConfi_ref->{"global"}{"font-family"},'font-size',$BBBfontsize);
				}
				else
				{
					my $XX3=$XX1-$BBBfontsize*1.1+$HashConfi_ref->{$Level}{"chr_label_shift_x"};
					my $rotate=$HashConfi_ref->{"global"}{"chr_label_rotation"};
					$svg->text('text-anchor','middle','x',$XX3,'y',$TextYY,'-cdata',$BBBChrName,'font-family',$HashConfi_ref->{"global"}{"font-family"},'font-size',$BBBfontsize,'transform',"rotate($rotate,$XX3,$TextYY)");
				}
				$XX1=$XX2+$XBetweenChr;

			}




			my @ChrNameCC=split /\,/,$ChrArryCC[$thisChr];
			$XX1=$HashConfi_ref->{"global"}{"canvas_margin_left"};
			if  (exists $HashConfi_ref->{$Level}{"chr_scale_ratio"}) {$ChrMaxUnitV3=$ChrMaxUnit/$HashConfi_ref->{$Level}{"chr_scale_ratio"};}

			for (my $YYUU=0 ; $YYUU<=$#ChrNameCC  ; $YYUU++)
			{
				my $CCCChrName=$ChrNameCC[$YYUU];
				next if ($CCCChrName eq "NA");
				$XX2= ($ChrGenomeC{$CCCChrName})/($ChrMaxUnitV3)+$XX1;
				$hashYY1{$CCCChrName}{$LevelV2}=$YY5;
				$hashYY2{$CCCChrName}{$LevelV2}=$YY6;
				$hashXX1{$CCCChrName}{$LevelV2}=$XX1;
				my $BGCorThisChr=$HashConfi_ref->{$LevelV2}{"background_color"} ;
				if (exists 	$ValueToCustomColor_ref->{$CCCChrName}) {$BGCorThisChr=$ValueToCustomColor_ref->{$CCCChrName};}
				if ($HashConfi_ref->{$LevelV2}{"bg_end_arc"}==0)
				{

					$path = $svg->get_path(
						x => [$XX1, $XX1, $XX2,$XX2],
						y => [$YY5, $YY6, $YY6,$YY5],
						-type => 'polygon');

					$svg->polygon(
						%$path,
						style => {
							'fill'           => $BGCorThisChr,
							'stroke'         => $HashConfi_ref->{$LevelV2}{"bg_stroke_color"},
							'stroke-width'   => $HashConfi_ref->{$LevelV2}{"bg_stroke_width"},
							'stroke-opacity' => $HashConfi_ref->{$LevelV2}{"stroke-opacity"},
							'fill-opacity'   => $HashConfi_ref->{$LevelV2}{"fill-opacity"},
						},
					);
				}
				else
				{
					my $EndCurveRadian=3;
					if (exists $HashConfi_ref->{$LevelV2}{"bg_end_arc_division"})
					{
						if ($HashConfi_ref->{$LevelV2}{"bg_end_arc_division"}>=2)
						{
							$EndCurveRadian=$HashConfi_ref->{$LevelV2}{"bg_end_arc_division"};
						}
						else
						{
							print "Leve $LevelV2 Para EndCurveRadian must >=2 ,so we chang it to be 2\n";
							$EndCurveRadian=2;$HashConfi_ref->{$LevelV2}{"bg_end_arc_division"}=2;
						}

					}
					my $HH=($YY6-$YY5)/$EndCurveRadian;
					if (($HH*2)>abs($XX2-$XX1)) {$HH=abs($XX2-$XX1)*0.5;}
					my $HM=($YY6-$YY5)-$HH-$HH;
					my $P1_X=$XX1+$HH;  my $P1_Y=$YY5;
					my $P1Q_X=$XX1;  my $P1Q_Y=$YY5;
					my $P2_X=$XX1;  my $P2_Y=$YY5+$HH;
					my $P3_X=$XX1;  my $P3_Y=$P2_Y+$HM;
					my $P2Q_X=$XX1;  my $P2Q_Y=$YY6;
					my $P4_X=$XX1+$HH;  my $P4_Y=$YY6;
					my $P3Q_X=$XX2;  my $P3Q_Y=$YY6;
					my $P6_X=$XX2-$HH;  my $P6_Y=$YY6;
					my $P7_X=$XX2;  my $P7_Y=$YY6-$HH;
					my $P8_X=$XX2;  my $P8_Y=$P7_Y-$HM;
					my $P4Q_X=$XX2;  my $P4Q_Y=$YY5;
					my $P9_X=$XX2-$HH;  my $P9_Y=$YY5;
					$svg->path(
						'd'=>"M$P1_X $P1_Y Q $P1Q_X $P1Q_Y , $P2_X $P2_Y L  $P3_X $P3_Y  Q $P2Q_X $P2Q_Y , $P4_X $P4_Y   L $P6_X $P6_Y  Q $P3Q_X $P3Q_Y , $P7_X $P7_Y  L $P8_X $P8_Y Q $P4Q_X $P4Q_Y ,$P9_X $P9_Y  Z",
						style => {
							'fill'           =>  $BGCorThisChr,
							'stroke'         =>  $HashConfi_ref->{$LevelV2}{"bg_stroke_color"},
							'stroke-width'   =>  $HashConfi_ref->{$LevelV2}{"bg_stroke_width"},
							'stroke-opacity' =>  $HashConfi_ref->{$LevelV2}{"stroke-opacity"},
							'fill-opacity'   =>  $HashConfi_ref->{$LevelV2}{"fill-opacity"},
						},
					);





				}


				my $ChrNameRatio=$HashConfi_ref->{$LevelV2}{"chr_label_size_ratio"}; $ChrNameRatio||=1;
				my $CCCfontsize=$fontsize*$ChrNameRatio;
				my $XX3=$XX1-length($CCCChrName)*$CCCfontsize*$chr_name_ratio+$HashConfi_ref->{$LevelV2}{"chr_label_shift_x"};
				if ($XX3<0) {$XX3=0;}
				my $TextYY=($YY5+$YY6)/2.0+$HashConfi_ref->{$LevelV2}{"chr_label_shift_y"}+($CCCfontsize*0.5);
				if ($HashConfi_ref->{"global"}{"chr_label_rotation"}==0)
				{
					$svg->text('text-anchor','middle','x',$XX3,'y',$TextYY,'-cdata',$CCCChrName,'font-family',$HashConfi_ref->{"global"}{"font-family"},'font-size',$CCCfontsize);
				}
				else
				{
					my $XX3=$XX1-$CCCfontsize*1.1+$HashConfi_ref->{$LevelV2}{"chr_label_shift_x"};
					my $rotate=$HashConfi_ref->{"global"}{"chr_label_rotation"};
					$svg->text('text-anchor','middle','x',$XX3,'y',$TextYY,'-cdata',$CCCChrName,'font-family',$HashConfi_ref->{"global"}{"font-family"},'font-size',$CCCfontsize,'transform',"rotate($rotate,$XX3,$TextYY)");
				}
				$XX1=$XX2+$XBetweenChr;

			}





		}
	}






	######################swimming in the sky and flying in the sea ###########################


	for (my $Level=1; $Level<=$NumberLevel;  $Level++)
	{
		my $FlagValueThis=$FlagValue{$Level};
		my @ValueArry= sort  keys  %$FlagValueThis;
		if ($HashConfi_ref->{$Level}{"IsNumber"}==1)
		{
			@ValueArry= sort {$a<=>$b}   @ValueArry ;
		}

		my $ValueMin=$ValueArry[0];
		my $ValueCount=$#ValueArry;
		my $ValueMax=$ValueArry[$ValueCount];


		my ($StartCountBin,$EndCountBin,$MinCutValue,$MaxCutValue)=LocalUtils::compute_data_boundaries(
		\@ValueArry, 
		$FlagValue{$Level}, 
		$HashConfi_ref->{$Level}{"TotalValue"},
		$HashConfi_ref->{$Level}{"lower_outlier_ratio"},
		$HashConfi_ref->{$Level}{"upper_outlier_ratio"}
		); 


		if(exists $HashConfi_ref->{$Level}{"Ymax"})
		{
			if ($HashConfi_ref->{$Level}{"Ymax"}>$MaxCutValue)
			{
				$MaxCutValue=$HashConfi_ref->{$Level}{"Ymax"};
			}
			else
			{
				my $eeetmp=$HashConfi_ref->{$Level}{"Ymax"};
				print "InPut Para For [Level $Level] YMax  $eeetmp  must > $MaxCutValue \t since the data max Value is $MaxCutValue\n";
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
				print "InPut -YMin For [Level $Level] $eeetmp must < $ValueMin \t since the data min Value is $MinCutValue\n";
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

		if ($HashConfi_ref->{$Level}{"IsNumber"}==1)
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
				if ($VCount le  $MaxCutValue)
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
				}
				else
				{
					$HashConfi_ref->{$Level}{"colormap_brewer_name"}="Paired";
					$HashConfi_ref->{$Level}{"colormap_nlevels"}=8;
					$NumGradien=8;
				}
			}
			elsif ( $HashConfi_ref->{$Level}{"colormap_brewer_name"}  eq  "NA" )
			{
				if ($HashConfi_ref->{$Level}{"IsNumber"}==1 )
				{
					$HashConfi_ref->{$Level}{"colormap_brewer_name"}="GnYlRd";
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

				LocalUtils::update_value_color_map(\%ValueToColor,\@ValueArry,\@ColorGradientArray,
			       $StartCountBin,$EndCountBin,$MinCutValue,$Diff,$ShiftTmpStart,$ValueToCustomColor_ref);


				my $Shift=$ShiftTmpStart;
				foreach my $k ($ShiftTmpStart..$ShiftTmpEnd)
				{
					my $MinAA=$ValueArry[$StartCountBin]+($k-$Shift)*$Diff;
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

				LocalUtils::update_value_color_map2(\%ValueToColor,\@ValueLabelsGradient,\@ValueArry,\@ColorGradientArray,
				$StartCountBin,$EndCountBin,$Diff,$ShiftTmpStart,$ValueToCustomColor_ref);

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
					my $MinAA=$ValueArry[$StartCountBin]+($k-$Shift)*$Diff;
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
			my @TmpCol=keys %{$ValueToCustomColor_ref};
			if ($#TmpCol >=$ValueCount)
			{
				foreach my $yy (0..$GradientSteps)
				{
					my $cc=$ValueLabelsGradient[$yy];
					if  (exists $ValueToCustomColor_ref->{$cc}) { $ColorGradientArray[$yy]=$ValueToCustomColor_ref->{$cc};}
				}
			}
		}



		if ($HashConfi_ref->{$Level}{"fill-opacity"}==1   &&  $HashConfi_ref->{$Level}{"stroke-opacity"} ==1 )
		{
			$HashConfi_ref->{$Level}{"fill-opacity"}=0.95;
			$HashConfi_ref->{$Level}{"stroke-opacity"}=0.95;
		}

		if($HashConfi_ref->{$Level}{"fill-opacity"}<0.3)
		{
			$HashConfi_ref->{$Level}{"fill-opacity"}=0.3;
		}
		elsif ($HashConfi_ref->{$Level}{"fill-opacity"}>0.98)
		{
			$HashConfi_ref->{$Level}{"fill-opacity"}=1;
		}

		if($HashConfi_ref->{$Level}{"stroke-opacity"}<0.3)
		{
			$HashConfi_ref->{$Level}{"stroke-opacity"}=0.3;
		}
		elsif ($HashConfi_ref->{$Level}{"stroke-opacity"}>0.98)
		{
			$HashConfi_ref->{$Level}{"stroke-opacity"}=1;
		}

		my $LevelCorGra=$HashConfi_ref->{$Level}{"colormap_legend_sizeratio"}*$color_gradient_scale;
		$YY1=$HashConfi_ref->{"global"}{"canvas_margin_top"}+$LegendOffsetRatio*$Bodyheight+$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
		$YY2=$YY1+$LevelCorGra*($GradientSteps+1);
		$XX1=$HashConfi_ref->{"global"}{"canvas_margin_left"}+$HashConfi_ref->{"global"}{"canvas_body"}+($Level-1)*$LevelCorGra*4.5+$HashConfi_ref->{$Level}{"colormap_legend_shift_x"};
		$XX2=$XX1+$LevelCorGra;

		if ($HashConfi_ref->{$Level}{"colormap_legend_show"}==0   ||   $HashConfi_ref->{$Level}{"colormap_legend_sizeratio"}<=0 )
		{
		}
		else
		{
			$path = $svg->get_path(
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

			foreach my $k (0..$GradientSteps)
			{
				$YY1= $HashConfi_ref->{"global"}{"canvas_margin_top"}+$LegendOffsetRatio*$Bodyheight+$LevelCorGra*$k+$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
				$YY2=$YY1+$LevelCorGra;

				$path = $svg->get_path(
					x => [$XX1, $XX1, $XX2,$XX2],
					y => [$YY1, $YY2, $YY2,$YY1],
					-type => 'polygon');

				$svg->polygon(
					%$path,
					style => {
						'fill'           => "$ColorGradientArray[$k]",
						'stroke'         => 'black',
						'stroke-width'   =>  0,
						'stroke-opacity' =>  $HashConfi_ref->{$Level}{"stroke-opacity"},
						'fill-opacity'   =>  $HashConfi_ref->{$Level}{"fill-opacity"},
					},
				);  
				$svg->text('text-anchor','middle','x',$XX2+length($ValueLabelsGradient[$k])+$LevelCorGra*1.88,'y',$YY2,'-cdata',"$ValueLabelsGradient[$k]",'font-family','Arial','font-size',$LevelCorGra);
			}
		}













		my $MidHH=$TwoChrHH/2.5;
		my $MidHHV2=$TwoChrHHV2/2.5;


		my $HHstrokewidth=$HashConfi_ref->{$Level}{"stroke-width"};
		my $LineType=1;
		if ((exists $HashConfi_ref->{$Level}{"link_linestyle"})   && ($HashConfi_ref->{$Level}{"link_linestyle"} eq "line")  )
		{
			$LineType=0;
		}


		$FileNow=$Level-1;
		$StartCount=0;
		$CoumnNow=3;
		if  ($FileData_ref->[$FileNow][0][0] =~s/#/#/) 
		{
			$StartCount=1;
		}
		if  (exists $HashConfi_ref->{$Level}{"chr_order_reverse"} )
		{
			my @SplitChr=split/\,/,$HashConfi_ref->{$Level}{"chr_order_reverse"};
			my $ReStartCount=$StartCount;
			if   ($Level==1)
			{
				foreach my $k (0..$#SplitChr)
				{
					my $TmpChrBName=$SplitChr[$k];
					print "Reverse Link GenomeB Chr:\t$TmpChrBName\n";
					$ReverseChr{$TmpChrBName}=$ChrGenomeB{$TmpChrBName};
				}
			}
			else
			{
				foreach my $k (0..$#SplitChr)
				{
					my $TmpChrCName=$SplitChr[$k];
					print "Reverse Link GenomeC Chr:\t$TmpChrCName\n";
					$ReverseChr{$TmpChrCName}=$ChrGenomeC{$TmpChrCName};
				}
			}

			for ( ; $ReStartCount<$FileRow_ref->[$FileNow]; $ReStartCount++)
			{
				my $chrB=$FileData_ref->[$FileNow][$ReStartCount][4];
				next if (!exists $ReverseChr{$chrB});
				my $StartB=$ReverseChr{$chrB}-$FileData_ref->[$FileNow][$ReStartCount][6];
				my $EndB=$ReverseChr{$chrB}-$FileData_ref->[$FileNow][$ReStartCount][5];
				$FileData_ref->[$FileNow][$ReStartCount][5]=$StartB;
				$FileData_ref->[$FileNow][$ReStartCount][6]=$EndB;
			}
		}
		if ($LineType == 0 )
		{
			if ($NumberLevel==1)
			{
				for ( ; $StartCount<$FileRow_ref->[$FileNow]; $StartCount++)
				{
					my $Value=$FileData_ref->[$FileNow][$StartCount][$CoumnNow];
					next if  ($Value eq "NA");
					$Value=LocalUtils::CheckValueNow($HashConfi_ref,$Level,$Value);

					my $ThisChrName=$FileData_ref->[$FileNow][$StartCount][0];
					next if (!exists $ChrGenomeA{$ThisChrName} ) ;
					my $StartA=$FileData_ref->[$FileNow][$StartCount][1];
					my $EndA  =$FileData_ref->[$FileNow][$StartCount][2];
					my $chrB=$FileData_ref->[$FileNow][$StartCount][4];
					my $StartB=$FileData_ref->[$FileNow][$StartCount][5];
					my $EndB=$FileData_ref->[$FileNow][$StartCount][6];

					my $YY1_AA=$hashYY1{$ThisChrName}{0};
					my $YY2_AA=$hashYY2{$ThisChrName}{0};
					my $XStart_AA=$hashXX1{$ThisChrName}{0}+($StartA)/($ChrMaxUnit);
					my $XEnd_AA=$hashXX1{$ThisChrName}{0}+($EndA)/($ChrMaxUnit);
					next if (!exists $hashYY1{$chrB}{$Level});
					my $YY1_BB=$hashYY1{$chrB}{$Level};
					my $YY2_BB=$hashYY2{$chrB}{$Level};
					my $XStart_BB=$hashXX1{$chrB}{$Level}+($StartB)/($ChrMaxUnitV2);
					my $XEnd_BB=$hashXX1{$chrB}{$Level}+($EndB)/($ChrMaxUnitV2);

					if (exists $ValueToCustomColor_ref->{$Value} ) {$ValueToColor{$Value}=$ValueToCustomColor_ref->{$Value};}
					$path = $svg->get_path(
						x => [$XStart_AA, $XEnd_AA, $XEnd_BB,$XStart_BB],
						y => [$YY2_AA, $YY2_AA, $YY1_BB,$YY1_BB],
						-type => 'polygon');
					$svg->polygon(
						%$path,
						style => {
							'opacity' => $HashConfi_ref->{$Level}{"stroke-opacity"},
							'fill'           => $ValueToColor{$Value},
							'fill-opacity'   => $HashConfi_ref->{$Level}{"fill-opacity"},
							'stroke'         => $ValueToColor{$Value},
							'stroke-width'   => $HHstrokewidth,
							'stroke-opacity' => $HashConfi_ref->{$Level}{"stroke-opacity"},
						},
					);
				}
			}
			else
			{
				if ($Level==1)
				{
					for ( ; $StartCount<$FileRow_ref->[$FileNow]; $StartCount++)
					{
						my $Value=$FileData_ref->[$FileNow][$StartCount][$CoumnNow];
						next if  ($Value eq "NA");
						$Value=LocalUtils::CheckValueNow($HashConfi_ref,$Level,$Value);

						my $ThisChrName=$FileData_ref->[$FileNow][$StartCount][0];
						next if (!exists $ChrGenomeA{$ThisChrName} ) ;
						my $StartA=$FileData_ref->[$FileNow][$StartCount][1];
						my $EndA  =$FileData_ref->[$FileNow][$StartCount][2];
						my $chrB=$FileData_ref->[$FileNow][$StartCount][4];
						my $StartB=$FileData_ref->[$FileNow][$StartCount][5];
						my $EndB=$FileData_ref->[$FileNow][$StartCount][6];

						my $YY1_AA=$hashYY1{$ThisChrName}{0};
						my $YY2_AA=$hashYY2{$ThisChrName}{0};
						my $XStart_AA=$hashXX1{$ThisChrName}{0}+($StartA)/($ChrMaxUnit);
						my $XEnd_AA=$hashXX1{$ThisChrName}{0}+($EndA)/($ChrMaxUnit);
						next if (!exists $hashYY1{$chrB}{$Level});
						my $YY1_BB=$hashYY1{$chrB}{$Level};
						my $YY2_BB=$hashYY2{$chrB}{$Level};
						my $XStart_BB=$hashXX1{$chrB}{$Level}+($StartB)/($ChrMaxUnitV2);
						my $XEnd_BB=$hashXX1{$chrB}{$Level}+($EndB)/($ChrMaxUnitV2);

						if (exists $ValueToCustomColor_ref->{$Value} ) {$ValueToColor{$Value}=$ValueToCustomColor_ref->{$Value};}
						$path = $svg->get_path(
							x => [$XStart_BB,$XEnd_BB,$XEnd_AA,$XStart_AA],
							y => [$YY2_BB,$YY2_BB,$YY1_AA,$YY1_AA],
							-type => 'polygon');
						$svg->polygon(
							%$path,
							style => {
								'opacity' => $HashConfi_ref->{$Level}{"stroke-opacity"},
								'fill'           => $ValueToColor{$Value},
								'fill-opacity'   => $HashConfi_ref->{$Level}{"fill-opacity"},
								'stroke'         => $ValueToColor{$Value},
								'stroke-width'   => $HHstrokewidth,
								'stroke-opacity' => $HashConfi_ref->{$Level}{"stroke-opacity"},
							},
						);
					}


				}
				else
				{


					for ( ; $StartCount<$FileRow_ref->[$FileNow]; $StartCount++)
					{
						my $Value=$FileData_ref->[$FileNow][$StartCount][$CoumnNow];
						next if  ($Value eq "NA");
						$Value=LocalUtils::CheckValueNow($HashConfi_ref,$Level,$Value);

						my $ThisChrName=$FileData_ref->[$FileNow][$StartCount][0];
						next if (!exists $ChrGenomeA{$ThisChrName} ) ;
						my $StartA=$FileData_ref->[$FileNow][$StartCount][1];
						my $EndA  =$FileData_ref->[$FileNow][$StartCount][2];
						my $chrB=$FileData_ref->[$FileNow][$StartCount][4];
						my $StartB=$FileData_ref->[$FileNow][$StartCount][5];
						my $EndB=$FileData_ref->[$FileNow][$StartCount][6];

						my $YY1_AA=$hashYY1{$ThisChrName}{0};
						my $YY2_AA=$hashYY2{$ThisChrName}{0};
						my $XStart_AA=$hashXX1{$ThisChrName}{0}+($StartA)/($ChrMaxUnit);
						my $XEnd_AA=$hashXX1{$ThisChrName}{0}+($EndA)/($ChrMaxUnit);
						next if (!exists $hashYY1{$chrB}{$Level});
						my $YY1_BB=$hashYY1{$chrB}{$Level};
						my $YY2_BB=$hashYY2{$chrB}{$Level};
						my $XStart_BB=$hashXX1{$chrB}{$Level}+($StartB)/($ChrMaxUnitV3);
						my $XEnd_BB=$hashXX1{$chrB}{$Level}+($EndB)/($ChrMaxUnitV3);

						if (exists $ValueToCustomColor_ref->{$Value} ) {$ValueToColor{$Value}=$ValueToCustomColor_ref->{$Value};}
						$path = $svg->get_path(
							x => [$XStart_AA,$XEnd_AA,$XEnd_BB,$XStart_BB],
							y => [$YY2_AA,$YY2_AA,$YY1_BB,$YY1_BB],
							-type => 'polygon');
						$svg->polygon(
							%$path,
							style => {
								'opacity' => $HashConfi_ref->{$Level}{"stroke-opacity"},
								'fill'           => $ValueToColor{$Value},
								'fill-opacity'   => $HashConfi_ref->{$Level}{"fill-opacity"},
								'stroke'         => $ValueToColor{$Value},
								'stroke-width'   => $HHstrokewidth,
								'stroke-opacity' => $HashConfi_ref->{$Level}{"stroke-opacity"},
							},
						);
					}







				}
			}

		}


		else ## ���α���������  ����������
		{

			if ($NumberLevel==1)
			{
				for ( ; $StartCount<$FileRow_ref->[$FileNow]; $StartCount++)
				{
					my $Value=$FileData_ref->[$FileNow][$StartCount][$CoumnNow];
					next if  ($Value eq "NA");
					$Value=LocalUtils::CheckValueNow($HashConfi_ref,$Level,$Value);

					my $ThisChrName=$FileData_ref->[$FileNow][$StartCount][0];
					next if (!exists $ChrGenomeA{$ThisChrName} ) ;
					my $StartA=$FileData_ref->[$FileNow][$StartCount][1];
					my $EndA  =$FileData_ref->[$FileNow][$StartCount][2];
					my $chrB=$FileData_ref->[$FileNow][$StartCount][4];
					my $StartB=$FileData_ref->[$FileNow][$StartCount][5];
					my $EndB=$FileData_ref->[$FileNow][$StartCount][6];

					my $YY1_AA=$hashYY1{$ThisChrName}{0};
					my $YY2_AA=$hashYY2{$ThisChrName}{0};
					my $XStart_AA=$hashXX1{$ThisChrName}{0}+($StartA)/($ChrMaxUnit);
					my $XEnd_AA=$hashXX1{$ThisChrName}{0}+($EndA)/($ChrMaxUnit);
					next if (!exists $hashYY1{$chrB}{$Level});
					my $YY1_BB=$hashYY1{$chrB}{$Level};
					my $YY2_BB=$hashYY2{$chrB}{$Level};
					my $XStart_BB=$hashXX1{$chrB}{$Level}+($StartB)/($ChrMaxUnitV2);
					my $XEnd_BB=$hashXX1{$chrB}{$Level}+($EndB)/($ChrMaxUnitV2);

					if (exists $ValueToCustomColor_ref->{$Value} ) {$ValueToColor{$Value}=$ValueToCustomColor_ref->{$Value};}
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
							'fill'           => $ValueToColor{$Value},
							'fill-opacity'   => $HashConfi_ref->{$Level}{"fill-opacity"},
							'stroke'         => $ValueToColor{$Value},
							'stroke-width'   => $HHstrokewidth,
							'stroke-opacity' => $HashConfi_ref->{$Level}{"stroke-opacity"},
						},
					);
				}
			}
			else 
			{

				if ($Level==1)
				{
					for ( ; $StartCount<$FileRow_ref->[$FileNow]; $StartCount++)
					{
						my $Value=$FileData_ref->[$FileNow][$StartCount][$CoumnNow];
						next if  ($Value eq "NA");	
						$Value=LocalUtils::CheckValueNow($HashConfi_ref,$Level,$Value);


						my $ThisChrName=$FileData_ref->[$FileNow][$StartCount][0];
						next if (!exists $ChrGenomeA{$ThisChrName} ) ;
						my $StartA=$FileData_ref->[$FileNow][$StartCount][1];
						my $EndA  =$FileData_ref->[$FileNow][$StartCount][2];
						my $chrB=$FileData_ref->[$FileNow][$StartCount][4];
						my $StartB=$FileData_ref->[$FileNow][$StartCount][5];
						my $EndB=$FileData_ref->[$FileNow][$StartCount][6];

						my $YY1_AA=$hashYY1{$ThisChrName}{0};
						my $YY2_AA=$hashYY2{$ThisChrName}{0};
						my $XStart_AA=$hashXX1{$ThisChrName}{0}+($StartA)/($ChrMaxUnit);
						my $XEnd_AA=$hashXX1{$ThisChrName}{0}+($EndA)/($ChrMaxUnit);
						next if (!exists $hashYY1{$chrB}{$Level} ) ;
						my $YY1_BB=$hashYY1{$chrB}{$Level};
						my $YY2_BB=$hashYY2{$chrB}{$Level};
						my $XStart_BB=$hashXX1{$chrB}{$Level}+($StartB)/($ChrMaxUnitV2);
						my $XEnd_BB=$hashXX1{$chrB}{$Level}+($EndB)/($ChrMaxUnitV2);

						if (exists $ValueToCustomColor_ref->{$Value} ) {$ValueToColor{$Value}=$ValueToCustomColor_ref->{$Value};}

						my $MidXX_End=($XEnd_BB+$XEnd_AA)*0.5;
						my $MidYY=($YY2_BB+$YY1_AA)*0.5;
						my $MidXX_Start=($XStart_AA+$XStart_BB)*0.5;

						my $kk=($XEnd_BB-$MidXX_End)*0.4/$MidHH;
						my $QQBB_XX=($XEnd_BB+$MidXX_End)*0.5+$MidHH*$kk;
						my $QQBB_YY=($YY2_BB+ $MidYY)*0.5;

						$kk=($XStart_AA-$MidXX_Start)*0.4/$MidHH;
						my $QQAA_XX=($XStart_AA+$MidXX_Start)*0.5+$MidHH*$kk;
						my $QQAA_YY=($MidYY+$YY1_AA)*0.5;

						$svg->path(
							'd'=>"M$XStart_BB $YY2_BB L $XEnd_BB $YY2_BB  Q $QQBB_XX $QQBB_YY , $MidXX_End $MidYY T $XEnd_AA $YY1_AA  L $XStart_AA $YY1_AA Q $QQAA_XX $QQAA_YY , $MidXX_Start $MidYY T $XStart_BB $YY2_BB  Z",
							style => {
								'opacity' => $HashConfi_ref->{$Level}{"stroke-opacity"},
								'fill'           => $ValueToColor{$Value},
								'fill-opacity'   => $HashConfi_ref->{$Level}{"fill-opacity"},
								'stroke'         => $ValueToColor{$Value},
								'stroke-width'   => $HHstrokewidth,
								'stroke-opacity' => $HashConfi_ref->{$Level}{"stroke-opacity"},
							},
						);


					}


				}
				else
				{



					for ( ; $StartCount<$FileRow_ref->[$FileNow]; $StartCount++)
					{
						my $Value=$FileData_ref->[$FileNow][$StartCount][$CoumnNow];
						next if  ($Value eq "NA");
						$Value=LocalUtils::CheckValueNow($HashConfi_ref,$Level,$Value);

						my $ThisChrName=$FileData_ref->[$FileNow][$StartCount][0];
						next if (!exists $ChrGenomeA{$ThisChrName} ) ;
						my $StartA=$FileData_ref->[$FileNow][$StartCount][1];
						my $EndA  =$FileData_ref->[$FileNow][$StartCount][2];
						my $chrB=$FileData_ref->[$FileNow][$StartCount][4];
						my $StartB=$FileData_ref->[$FileNow][$StartCount][5];
						my $EndB=$FileData_ref->[$FileNow][$StartCount][6];

						my $YY1_AA=$hashYY1{$ThisChrName}{0};
						my $YY2_AA=$hashYY2{$ThisChrName}{0};
						my $XStart_AA=$hashXX1{$ThisChrName}{0}+($StartA)/($ChrMaxUnit);
						my $XEnd_AA=$hashXX1{$ThisChrName}{0}+($EndA)/($ChrMaxUnit);
						next if (!exists $hashYY1{$chrB}{$Level});
						my $YY1_BB=$hashYY1{$chrB}{$Level};
						my $YY2_BB=$hashYY2{$chrB}{$Level};
						my $XStart_BB=$hashXX1{$chrB}{$Level}+($StartB)/($ChrMaxUnitV3);
						my $XEnd_BB=$hashXX1{$chrB}{$Level}+($EndB)/($ChrMaxUnitV3);

						if (exists $ValueToCustomColor_ref->{$Value} ) {$ValueToColor{$Value}=$ValueToCustomColor_ref->{$Value};}


						my $MidXX_End=($XEnd_BB+$XEnd_AA)*0.5;
						my $MidYY=($YY2_AA+$YY1_BB)*0.5;
						my $MidXX_Start=($XStart_AA+$XStart_BB)*0.5;

						my $kk=($XEnd_AA-$MidXX_End)*0.4/$MidHH;
						my $QQBB_XX=($XEnd_AA+$MidXX_End)*0.5+$MidHH*$kk;
						my $QQBB_YY=($YY2_AA+ $MidYY)*0.5;

						$kk=($XStart_BB - $MidXX_Start)*0.4/$MidHH;
						my $QQAA_XX=($XStart_BB+$MidXX_Start)*0.5+$MidHH*$kk;
						my $QQAA_YY=($MidYY+$YY1_BB)*0.5;
						$svg->path(
							'd'=>"M$XStart_AA $YY2_AA L $XEnd_AA $YY2_AA  Q $QQBB_XX $QQBB_YY , $MidXX_End $MidYY T $XEnd_BB $YY1_BB  L $XStart_BB $YY1_BB Q $QQAA_XX $QQAA_YY , $MidXX_Start $MidYY T $XStart_AA $YY2_AA  Z",
							style => {
								'opacity' => $HashConfi_ref->{$Level}{"stroke-opacity"},
								'fill'           => $ValueToColor{$Value},
								'fill-opacity'   => $HashConfi_ref->{$Level}{"fill-opacity"},
								'stroke'         => $ValueToColor{$Value},
								'stroke-width'   => $HHstrokewidth,
								'stroke-opacity' => $HashConfi_ref->{$Level}{"stroke-opacity"},
							},
						);




					}
				}

			}


		}




	}



	################  Link ��  ������������Ϣ #######

	for (my $Level=$NumberLevel+1; $Level<4 ; $Level++)
	{
		if ( !( (exists $HashConfi_ref->{$Level}{"show_columns"} )    &&  ( $HashConfi_ref->{$Level}{"plot_type"}  ne  "link" )   &&  ( $HashConfi_ref->{$Level}{"plot_type"} ne "Link" ) ))
		{
			next ;
		}
		my @temAA=split /\s+/,$HashConfi_ref->{$Level}{"show_columns"};
		foreach my $tmpA (0..$#temAA)
		{
			my @temBB=split /\:/,$temAA[$tmpA];
			if ($temBB[0]=~s/File//g)
			{
				$temBB[0]--;
				my $VV=$FileColumn_ref->[$temBB[0]]; $VV||=-1;
				if ($VV<0) { print "Error:\tCan't find the File $temBB[0]+1 \n"; exit ;}
				my @temCC=split /\,/,$temBB[-1];
				foreach my $coumn (@temCC)
				{
					$coumn--;
					if  ($coumn <3 || $coumn>$VV)
					{
						print "File $temBB[0] Column only $VV+1, but you give the ShowColumn is $coumn; skip this Level info draw\n";
						next ;
					}
					else
					{
						my $AA=$Level-1;
						push @{$ShowColumn_ref->[$AA]},[$temBB[0],$coumn];
					}
				}
			}
			else
			{
				print "Error:\tPara  ShowColumn  For $Level Format wrong \n";
				exit;
			}			
		}


		foreach my $kk (0..$NumParaFlag)
		{
			my $thisPara=$ParaFlag_ref->[$kk];
			if ((exists $HashConfi_ref->{"ALL"}{$thisPara}) && (!exists $HashConfi_ref->{$Level}{$thisPara}))
			{
				$HashConfi_ref->{$Level}{$thisPara}=$HashConfi_ref->{"ALL"}{$thisPara};
			}
		}	





		my %ChrName2DiffGenome=();
		my %SameChrName=();
		my %GenomeFlag=(); 
		$GenomeFlag{"Ref0"}=0;$GenomeFlag{"Ref1"}=1; $GenomeFlag{"Ref2"}=2;
		foreach my $chr (keys %ChrGenomeA)
		{
			$ChrName2DiffGenome{$chr}=0;
		}
		foreach my $chr (keys %ChrGenomeB)
		{
			if  (!exists $ChrName2DiffGenome{$chr})
			{
				$ChrName2DiffGenome{$chr}=1;
			}
			else
			{
				$SameChrName{$chr}=$ChrName2DiffGenome{$chr}."/1";
			}
		}
		foreach my $chr (keys %ChrGenomeC)
		{
			if  (!exists $ChrName2DiffGenome{$chr})
			{
				$ChrName2DiffGenome{$chr}=2;
			}
			else
			{
				$SameChrName{$chr}=$ChrName2DiffGenome{$chr}."/2";
			}
		}



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
			my $StartCount=0;
			if  ($FileData_ref->[$FileNow][0][0] =~s/#/#/) 
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

				if ( $ValueNowAA =~ /^-?(0|([1-9][0-9]*))(\.[0-9]+)?([eE][-+]?[0-9]+)?$/)
				{

				}
				elsif (!( $ValueNowAA =~ /^[+-]?\d+(\.\d+)?$/ ))
				{
					$HashConfi_ref->{$Level}{"IsNumber"}=0;
				}
			}
		}

		if (exists $HashConfi_ref->{$Level}{"as_flag"} ) {	  $HashConfi_ref->{$Level}{"IsNumber"}=0; }
		my @ValueArry= sort  keys  %FlagValue ;
		if ($HashConfi_ref->{$Level}{"IsNumber"}==1)
		{
			@ValueArry= sort {$a<=>$b} @ValueArry;
		}
		my $ValueMin=$ValueArry[0];
		my $ValueCount=$#ValueArry;
		my $ValueMax=$ValueArry[$ValueCount];

		if (!exists   $HashConfi_ref->{$Level}{"upper_outlier_ratio"} )
		{
			if (($HashConfi_ref->{$Level}{"plot_type"} ne  "heatmap" )  &&  ( $HashConfi_ref->{$Level}{"plot_type"} ne  "highlights")  &&  ($HashConfi_ref->{"ALL"}{"upper_outlier_ratio"} ==0.95)  )
			{
				$HashConfi_ref->{$Level}{"upper_outlier_ratio"}=1.01;
			}
			else
			{
				$HashConfi_ref->{$Level}{"upper_outlier_ratio"}=$HashConfi_ref->{"ALL"}{"upper_outlier_ratio"};
			}
		}

		my ($StartCountBin,$EndCountBin,$MinCutValue,$MaxCutValue)=LocalUtils::compute_data_boundaries(
		\@ValueArry, 
		\%FlagValue, 
		$HashConfi_ref->{$Level}{"TotalValue"},
		$HashConfi_ref->{$Level}{"lower_outlier_ratio"},
		$HashConfi_ref->{$Level}{"upper_outlier_ratio"}
		); 



		if(exists $HashConfi_ref->{$Level}{"Ymax"})
		{
			if ($HashConfi_ref->{$Level}{"Ymax"}>$MaxCutValue)
			{
				$MaxCutValue=$HashConfi_ref->{$Level}{"Ymax"};
			}
			else
			{
				my $eeetmp=$HashConfi_ref->{$Level}{"Ymax"};
				print "InPut Para For [Level $Level] YMax  $eeetmp  must > $MaxCutValue \t since the data max Value is $MaxCutValue\n";
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
				print "InPut -YMin For [Level $Level] $eeetmp must < $ValueMin \t since the data min Value is $MinCutValue\n";
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

		if ($HashConfi_ref->{$Level}{"IsNumber"}==1)
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
				if ($VCount le  $MaxCutValue)
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
			elsif ( $HashConfi_ref->{$Level}{"colormap_brewer_name"}  eq  "NA" )
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
						if  ($PlotArryNum>1) { $HashConfi_ref->{$Level}{"colormap_brewer_name"}="Set1";}
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

				LocalUtils::update_value_color_map(\%ValueToColor,\@ValueArry,\@ColorGradientArray,
			       $StartCountBin,$EndCountBin,$MinCutValue,$Diff,$ShiftTmpStart,\%Value2SelfCol);


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

				LocalUtils::update_value_color_map2(\%ValueToColor,\@ValueLabelsGradient,\@ValueArry,\@ColorGradientArray,
				$StartCountBin,$EndCountBin,$Diff,$ShiftTmpStart,\%Value2SelfCol);
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
			if (exists $ValueToCustomColor_ref->{$VV}) {$HashConfi_ref->{$Level}{"colormap_low_color"}=$ValueToCustomColor_ref->{$VV};}
			$ValueToColor{$VV}=$HashConfi_ref->{$Level}{"colormap_low_color"};$ColorGradientArray[0]=$HashConfi_ref->{$Level}{"colormap_low_color"}; $ValueLabelsGradient[0]=$VV;
			$VV=$ValueArry[$Atmp];
			if (exists $ValueToCustomColor_ref->{$VV}) {$HashConfi_ref->{$Level}{"colormap_mid_color"}=$ValueToCustomColor_ref->{$VV};}
			$ValueToColor{$VV}=$HashConfi_ref->{$Level}{"colormap_mid_color"};$ColorGradientArray[$Atmp]=$HashConfi_ref->{$Level}{"colormap_mid_color"}; $ValueLabelsGradient[$Atmp]=$VV;
			$VV=$ValueArry[$ValueCount];
			if (exists $ValueToCustomColor_ref->{$VV}) {$HashConfi_ref->{$Level}{"colormap_high_color"}=$ValueToCustomColor_ref->{$VV};}
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


			if ($HashConfi_ref->{$Level}{"IsNumber"}==1)
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
			       $StartCountBin,$EndCountBin,$MinCutValue,$Diff,$ShiftTmpStart,\%Value2SelfCol);

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
				$StartCountBin,$EndCountBin,$Diff,$ShiftTmpStart,\%Value2SelfCol);
			}
		}









		if (%Value2SelfCol)
		{
			my @TmpCol=keys %Value2SelfCol;
			if ($#TmpCol >=$ValueCount)
			{
				foreach my $yy (0..$GradientSteps)
				{
					my $cc=$ValueLabelsGradient[$yy];
					if  (exists $ValueToCustomColor_ref->{$cc}) { $ColorGradientArray[$yy]=$ValueToCustomColor_ref->{$cc};}
				}
			}
		}






		my $LevelCorGra=$HashConfi_ref->{$Level}{"colormap_legend_sizeratio"}*$color_gradient_scale;
		my $NumPlotArry=$#$PlotInfo+1;





		#################### Start  Plot ########
		if (($HashConfi_ref->{$Level}{"plot_type"}  eq  "heatmap")   ||  ($HashConfi_ref->{$Level}{"plot_type"}  eq  "highlights"))
		{
			$YY1=$HashConfi_ref->{"global"}{"canvas_margin_top"}+$LegendOffsetRatio*$Bodyheight+$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
			$YY2=$YY1+$LevelCorGra*($GradientSteps+1);
			$XX1=$HashConfi_ref->{"global"}{"canvas_margin_left"}+$HashConfi_ref->{"global"}{"canvas_body"}+($Level-1)*$LevelCorGra*4.5+$HashConfi_ref->{$Level}{"colormap_legend_shift_x"};
			$XX2=$XX1+$LevelCorGra;

			if ($HashConfi_ref->{$Level}{"colormap_legend_show"}==0   ||   $HashConfi_ref->{$Level}{"colormap_legend_sizeratio"}<=0 )
			{

			}
			else
			{
				$path = $svg->get_path(
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
				foreach my $k (0..$GradientSteps)
				{
					$YY1= $HashConfi_ref->{"global"}{"canvas_margin_top"}+$LegendOffsetRatio*$Bodyheight+$LevelCorGra*$k+$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
					$YY2=$YY1+$LevelCorGra;

					$path = $svg->get_path(
						x => [$XX1, $XX1, $XX2,$XX2],
						y => [$YY1, $YY2, $YY2,$YY1],
						-type => 'polygon');

					$svg->polygon(
						%$path,
						style => {
							'fill'           => "$ColorGradientArray[$k]",
							'stroke'         => 'black',
							'stroke-width'   =>  0,
							'stroke-opacity' =>  $HashConfi_ref->{$Level}{"stroke-opacity"},
							'fill-opacity'   =>  $HashConfi_ref->{$Level}{"fill-opacity"},
						},
					);		
					$svg->text('text-anchor','middle','x',$XX2+length($ValueLabelsGradient[$k])+$LevelCorGra*1.88,'y',$YY2,'-cdata',"$ValueLabelsGradient[$k]",'font-family','Arial','font-size',$LevelCorGra);
				}
			}


			my $HeatMapstrokewidth=$HashConfi_ref->{$Level}{"stroke-width"};

			foreach my $tmpkk (1..$NumPlotArry) 
			{
				my $ThisBoxbin=$tmpkk-1;
				my $NowPlot=$PlotInfo->[$ThisBoxbin];
				my $FileNow=$NowPlot->[0];
				my $CoumnNow=$NowPlot->[1];
				my $StartCount=0;
				if  ($FileData_ref->[$FileNow][0][0] =~s/#/#/) 
				{
					$StartCount=1;
				}

				for ( ; $StartCount<$FileRow_ref->[$FileNow]; $StartCount++)
				{
					my $Value=$FileData_ref->[$FileNow][$StartCount][$CoumnNow];
					next if  ($Value eq "NA");
					$Value=LocalUtils::CheckValueNow($HashConfi_ref,$Level,$Value);

					my $ThisChrName="XXNAX";my $StartSite;my $EndSite;my $LevelV2;

					$LevelV2=$FileData_ref->[$FileNow][$StartCount][0];
					if (exists $GenomeFlag{$LevelV2})
					{
						$LevelV2=~s/Ref//g;
						$ThisChrName=$FileData_ref->[$FileNow][$StartCount][1];
						$StartSite=$FileData_ref->[$FileNow][$StartCount][2];
						$EndSite=$FileData_ref->[$FileNow][$StartCount][3];
					}
					else
					{
						if ( (!exists $SameChrName{$LevelV2})  &&  ( exists $ChrName2DiffGenome{$LevelV2}) )
						{
							$ThisChrName=$LevelV2;
							$LevelV2=$ChrName2DiffGenome{$ThisChrName} ;
							$StartSite=$FileData_ref->[$FileNow][$StartCount][1];
							$EndSite=$FileData_ref->[$FileNow][$StartCount][2];
						}
						elsif ( (exists $SameChrName{$LevelV2})  &&  ( exists $ChrName2DiffGenome{$LevelV2}) )
						{
							print "The chromosome name [$LevelV2] exists on both genomes Ref [$SameChrName{$LevelV2}], and it is impossible to distinguish which one, so skip this line\nYou can add Flag [RefX]  X=[$SameChrName{$LevelV2}] to the previous column of this row of data to distinguish\n";
						}
					}



					next if (!exists $hashYY1{$ThisChrName} ) ;

					if (exists $ReverseChr{$ThisChrName})
					{
						my $TS=$ReverseChr{$ThisChrName}-$EndSite;
						my $TE=$ReverseChr{$ThisChrName}-$StartSite;
						$StartSite=$TS;
						$EndSite=$TE;
					}
					my $YY1=$hashYY1{$ThisChrName}{$LevelV2};
					my $YY2=$hashYY2{$ThisChrName}{$LevelV2};
					my $binYYHeat=($YY2-$YY1)/$NumPlotArry;
					$YY1=$YY1+$ThisBoxbin*$binYYHeat;
					$YY2=$YY1+$binYYHeat;
					if (exists $ValueToCustomColor_ref->{$Value} ) {$ValueToColor{$Value}=$ValueToCustomColor_ref->{$Value};}
					my $XX1=sprintf ("%.1f",($StartSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$LevelV2});
					my $XX2=sprintf ("%.1f",($EndSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$LevelV2});
					$path = $svg->get_path(
						x => [$XX1, $XX1, $XX2,$XX2],
						y => [$YY1, $YY2, $YY2,$YY1],
						-type => 'polygon');
					$svg->polygon(
						%$path,
						style => {
							'fill'           => $ValueToColor{$Value},
							'stroke'         => $ValueToColor{$Value},
							'stroke-width'   => $HeatMapstrokewidth,
							'stroke-opacity' => $HashConfi_ref->{$Level}{"stroke-opacity"},
							'fill-opacity'   => $HashConfi_ref->{$Level}{"fill-opacity"},
						},
					);
				}
			}
		}
		elsif (( $HashConfi_ref->{$Level}{"plot_type"}  eq  "pairwiselink" )  || ( $HashConfi_ref->{$Level}{"plot_type"}  eq  "PairWiseLink" ))
		{
			$YY1=$HashConfi_ref->{"global"}{"canvas_margin_top"}+$LegendOffsetRatio*$Bodyheight+$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
			$YY2=$YY1+$LevelCorGra*($GradientSteps+1);
			$XX1=$HashConfi_ref->{"global"}{"canvas_margin_left"}+$HashConfi_ref->{"global"}{"canvas_body"}+($Level-1)*$LevelCorGra*4.5+$HashConfi_ref->{$Level}{"colormap_legend_shift_x"};
			$XX2=$XX1+$LevelCorGra;
			my %hashHHC=();
			my $HH=($HashConfi_ref->{$Level}{"track_height"});
			my $HHbinS=$HH/($GradientSteps+1);
			$hashHHC{$HashConfi_ref->{$Level}{"colormap_high_color"}}=$GradientSteps;
			$hashHHC{$HashConfi_ref->{$Level}{"colormap_low_color"}}=0;

			foreach my $k (0..$GradientSteps)
			{
				$hashHHC{$ColorGradientArray[$k]}=($k+1)*$HHbinS;
				my $HTML=RGB2HTML($ColorGradientArray[$k]);
				$hashHHC{$HTML}=($k+1)*$HHbinS;
				if ((exists ($HashConfi_ref->{$Level}{"link_uniform_height"}))   &&  ($HashConfi_ref->{$Level}{"link_uniform_height"}!=0) )
				{
					$hashHHC{$ColorGradientArray[$k]}=$HH;
					$hashHHC{$HTML}=$HH;
				}
			}





			if ($HashConfi_ref->{$Level}{"colormap_legend_show"}==0   ||   $HashConfi_ref->{$Level}{"colormap_legend_sizeratio"}<=0 )
			{

			}
			else
			{
				$path = $svg->get_path(
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

				foreach my $k (0..$GradientSteps)
				{
					$YY1= $HashConfi_ref->{"global"}{"canvas_margin_top"}+$LegendOffsetRatio*$Bodyheight+$LevelCorGra*$k+$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
					$YY2=$YY1+$LevelCorGra;

					$path = $svg->get_path(
						x => [$XX1, $XX1, $XX2,$XX2],
						y => [$YY1, $YY2, $YY2,$YY1],
						-type => 'polygon');

					$svg->polygon(
						%$path,
						style => {
							'fill'           => "$ColorGradientArray[$k]",
							'stroke'         => 'black',
							'stroke-width'   =>  0,
							'stroke-opacity' =>  $HashConfi_ref->{$Level}{"stroke-opacity"},
							'fill-opacity'   =>  $HashConfi_ref->{$Level}{"fill-opacity"},
						},
					);
					$svg->text('text-anchor','middle','x',$XX2+length($ValueLabelsGradient[$k])+$LevelCorGra*1.88,'y',$YY2,'-cdata',"$ValueLabelsGradient[$k]",'font-family','Arial','font-size',$LevelCorGra);
				}
			}

			my $HeatMapstrokewidth=$HashConfi_ref->{$Level}{"stroke-width"};

			foreach my $tmpkk (1..$NumPlotArry) 
			{
				my $ThisBoxbin=$tmpkk-1;
				my $NowPlot=$PlotInfo->[$ThisBoxbin];
				my $FileNow=$NowPlot->[0];
				my $CoumnNow=$NowPlot->[1];
				my $StartCount=0;
				if  ($FileData_ref->[$FileNow][0][0] =~s/#/#/) 
				{
					$StartCount=1;
				}


				if ( (exists ($HashConfi_ref->{$Level}{"link_linestyle"}))   &&  ( $HashConfi_ref->{$Level}{"link_linestyle"} eq "line") )
				{
					if ((exists ($HashConfi_ref->{$Level}{"link_direction"}))   &&  ($HashConfi_ref->{$Level}{"link_direction"} eq "DownUp" ))
					{
						for ( ; $StartCount<$FileRow_ref->[$FileNow]; $StartCount++ )
						{
							my $Value=$FileData_ref->[$FileNow][$StartCount][$CoumnNow];
							next if  ($Value eq "NA");
							$Value=LocalUtils::CheckValueNow($HashConfi_ref,$Level,$Value);

							my $ThisChrName="XXNAX";my $StartSite;my $EndSite;my $LevelV2;

							$LevelV2=$FileData_ref->[$FileNow][$StartCount][0];
							if (exists $GenomeFlag{$LevelV2})
							{
								$LevelV2=~s/Ref//g;
								$ThisChrName=$FileData_ref->[$FileNow][$StartCount][1];
								$StartSite=$FileData_ref->[$FileNow][$StartCount][2];
								$EndSite=$FileData_ref->[$FileNow][$StartCount][3];
							}
							else
							{
								if ( (!exists $SameChrName{$LevelV2})  &&  ( exists $ChrName2DiffGenome{$LevelV2}) )
								{
									$ThisChrName=$LevelV2;
									$LevelV2=$ChrName2DiffGenome{$ThisChrName} ;
									$StartSite=$FileData_ref->[$FileNow][$StartCount][1];
									$EndSite=$FileData_ref->[$FileNow][$StartCount][2];
								}
								elsif ( (exists $SameChrName{$LevelV2})  &&  ( exists $ChrName2DiffGenome{$LevelV2}) )
								{
									print "The chromosome name [$LevelV2] exists on both genomes Ref [$SameChrName{$LevelV2}], and it is impossible to distinguish which one, so skip this line\nYou can add Flag [RefX]  X=[$SameChrName{$LevelV2}] to the previous column of this row of data to distinguish\n";
								}
							}


							next if (!exists $hashYY1{$ThisChrName} ) ;
							if (exists $ReverseChr{$ThisChrName})
							{
								my $TS=$ReverseChr{$ThisChrName}-$EndSite;
								my $TE=$ReverseChr{$ThisChrName}-$StartSite;
								$StartSite=$TS;
								$EndSite=$TE;
							}

							my $YY1=$hashYY1{$ThisChrName}{$Level};
							my $YY2=$hashYY2{$ThisChrName}{$Level};
							my $XX1=sprintf ("%.1f",($StartSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$Level});
							my $XX2=sprintf ("%.1f",($EndSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$Level});
							if (exists $ValueToCustomColor_ref->{$Value} ) {$ValueToColor{$Value}=$ValueToCustomColor_ref->{$Value};}
							$svg->line('x1',$XX1,'y1',$YY2,'x2',$XX2,'y2', $YY1 , 'stroke',$ValueToColor{$Value},'stroke-width',$HeatMapstrokewidth,'fill',$ValueToColor{$Value}); 
						}
					}
					else
					{
						for ( ;$StartCount<$FileRow_ref->[$FileNow]; $StartCount++)
						{
							my $Value=$FileData_ref->[$FileNow][$StartCount][$CoumnNow];
							next if  ($Value eq "NA");
							$Value=LocalUtils::CheckValueNow($HashConfi_ref,$Level,$Value);


							my $ThisChrName="XXNAX";my $StartSite;my $EndSite;my $LevelV2;

							$LevelV2=$FileData_ref->[$FileNow][$StartCount][0];
							if (exists $GenomeFlag{$LevelV2})
							{
								$LevelV2=~s/Ref//g;
								$ThisChrName=$FileData_ref->[$FileNow][$StartCount][1];
								$StartSite=$FileData_ref->[$FileNow][$StartCount][2];
								$EndSite=$FileData_ref->[$FileNow][$StartCount][3];
							}
							else
							{
								if ( (!exists $SameChrName{$LevelV2})  &&  ( exists $ChrName2DiffGenome{$LevelV2}) )
								{
									$ThisChrName=$LevelV2;
									$LevelV2=$ChrName2DiffGenome{$ThisChrName} ;
									$StartSite=$FileData_ref->[$FileNow][$StartCount][1];
									$EndSite=$FileData_ref->[$FileNow][$StartCount][2];
								}
								elsif ( (exists $SameChrName{$LevelV2})  &&  ( exists $ChrName2DiffGenome{$LevelV2}) )
								{
									print "The chromosome name [$LevelV2] exists on both genomes Ref [$SameChrName{$LevelV2}], and it is impossible to distinguish which one, so skip this line\nYou can add Flag [RefX]  X=[$SameChrName{$LevelV2}] to the previous column of this row of data to distinguish\n";
								}
							}



							next if (!exists $hashYY1{$ThisChrName} ) ;
							if (exists $ReverseChr{$ThisChrName})
							{
								my $TS=$ReverseChr{$ThisChrName}-$EndSite;
								my $TE=$ReverseChr{$ThisChrName}-$StartSite;
								$StartSite=$TS;
								$EndSite=$TE;
							}

							my $YY1=$hashYY1{$ThisChrName}{$Level};
							my $YY2=$hashYY2{$ThisChrName}{$Level};
							my $XX1=sprintf ("%.1f",($StartSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$Level});
							my $XX2=sprintf ("%.1f",($EndSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$Level});
							if (exists $ValueToCustomColor_ref->{$Value} ) {$ValueToColor{$Value}=$ValueToCustomColor_ref->{$Value};}
							$svg->line('x1',$XX1,'y1',$YY1,'x2',$XX2,'y2', $YY2 , 'stroke',$ValueToColor{$Value},'stroke-width',$HeatMapstrokewidth,'fill',$ValueToColor{$Value});
						}
					}
				}


				elsif ((exists ($HashConfi_ref->{$Level}{"link_direction"}))   &&  ($HashConfi_ref->{$Level}{"link_direction"}  eq "DownDown" ) )
				{
					for ( ; $StartCount<$FileRow_ref->[$FileNow]; $StartCount++ )
					{
						my $Value=$FileData_ref->[$FileNow][$StartCount][$CoumnNow];
						next if  ($Value eq "NA");
						$Value=LocalUtils::CheckValueNow($HashConfi_ref,$Level,$Value);

						my $ThisChrName="XXNAX";my $StartSite;my $EndSite;my $LevelV2;

						$LevelV2=$FileData_ref->[$FileNow][$StartCount][0];
						if (exists $GenomeFlag{$LevelV2})
						{
							$LevelV2=~s/Ref//g;
							$ThisChrName=$FileData_ref->[$FileNow][$StartCount][1];
							$StartSite=$FileData_ref->[$FileNow][$StartCount][2];
							$EndSite=$FileData_ref->[$FileNow][$StartCount][3];
						}
						else
						{
							if ( (!exists $SameChrName{$LevelV2})  &&  ( exists $ChrName2DiffGenome{$LevelV2}) )
							{
								$ThisChrName=$LevelV2;
								$LevelV2=$ChrName2DiffGenome{$ThisChrName} ;
								$StartSite=$FileData_ref->[$FileNow][$StartCount][1];
								$EndSite=$FileData_ref->[$FileNow][$StartCount][2];
							}
							elsif ( (exists $SameChrName{$LevelV2})  &&  ( exists $ChrName2DiffGenome{$LevelV2}) )
							{
								print "The chromosome name [$LevelV2] exists on both genomes Ref [$SameChrName{$LevelV2}], and it is impossible to distinguish which one, so skip this line\nYou can add Flag [RefX]  X=[$SameChrName{$LevelV2}] to the previous column of this row of data to distinguish\n";
							}
						}




						next if (!exists $hashYY1{$ThisChrName} ) ;
						if (exists $ReverseChr{$ThisChrName})
						{
							my $TS=$ReverseChr{$ThisChrName}-$EndSite;
							my $TE=$ReverseChr{$ThisChrName}-$StartSite;
							$StartSite=$TS;
							$EndSite=$TE;
						}

						my $YY1=$hashYY1{$ThisChrName}{$LevelV2};
						my $YY2=$hashYY2{$ThisChrName}{$LevelV2};
						my $XX1=sprintf ("%.1f",($StartSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$LevelV2});
						my $XX2=sprintf ("%.1f",($EndSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$LevelV2});
						my $Q1_X=($XX1+$XX2)*0.5;
						my $Q1_Y=$YY2-2*$hashHHC{$ValueToColor{$Value}};
						if (exists $ValueToCustomColor_ref->{$Value} ) {$ValueToColor{$Value}=$ValueToCustomColor_ref->{$Value};}
						if ( $XX1 ==  $XX2 )
						{
							$svg->line('x1',$XX1,'y1',$YY2,'x2',$XX2,'y2', $YY2-$hashHHC{$ValueToColor{$Value}} , 'stroke',$ValueToColor{$Value},'stroke-width',$HeatMapstrokewidth,'fill',$ValueToColor{$Value}); 
							next ;
						}

						$svg->path(
							'd'=>"M$XX1 $YY2 Q $Q1_X $Q1_Y ,  $XX2 $YY2 ",
							style => {
								'fill'           =>  'none',
								'stroke'         =>  $ValueToColor{$Value},
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
						$Value=LocalUtils::CheckValueNow($HashConfi_ref,$Level,$Value);

						my $ThisChrName="XXNAX";my $StartSite;my $EndSite;my $LevelV2;

						$LevelV2=$FileData_ref->[$FileNow][$StartCount][0];
						if (exists $GenomeFlag{$LevelV2})
						{
							$LevelV2=~s/Ref//g;
							$ThisChrName=$FileData_ref->[$FileNow][$StartCount][1];
							$StartSite=$FileData_ref->[$FileNow][$StartCount][2];
							$EndSite=$FileData_ref->[$FileNow][$StartCount][3];
						}
						else
						{
							if ( (!exists $SameChrName{$LevelV2})  &&  ( exists $ChrName2DiffGenome{$LevelV2}) )
							{
								$ThisChrName=$LevelV2;
								$LevelV2=$ChrName2DiffGenome{$ThisChrName} ;
								$StartSite=$FileData_ref->[$FileNow][$StartCount][1];
								$EndSite=$FileData_ref->[$FileNow][$StartCount][2];
							}
							elsif ( (exists $SameChrName{$LevelV2})  &&  ( exists $ChrName2DiffGenome{$LevelV2}) )
							{
								print "The chromosome name [$LevelV2] exists on both genomes Ref [$SameChrName{$LevelV2}], and it is impossible to distinguish which one, so skip this line\nYou can add Flag [RefX]  X=[$SameChrName{$LevelV2}] to the previous column of this row of data to distinguish\n";
							}
						}








						next if (!exists $hashYY1{$ThisChrName} ) ;
						if (exists $ReverseChr{$ThisChrName})
						{
							my $TS=$ReverseChr{$ThisChrName}-$EndSite;
							my $TE=$ReverseChr{$ThisChrName}-$StartSite;
							$StartSite=$TS;
							$EndSite=$TE;
						}




						my $YY1=$hashYY1{$ThisChrName}{$Level};
						my $YY2=$hashYY2{$ThisChrName}{$Level};
						my $XX1=sprintf ("%.1f",($StartSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$Level});
						my $XX2=sprintf ("%.1f",($EndSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$Level});

						if (exists $ValueToCustomColor_ref->{$Value} ) {$ValueToColor{$Value}=$ValueToCustomColor_ref->{$Value};}

						if ( $XX1 ==  $XX2 )
						{
							$svg->line('x1',$XX1,'y1',$YY1,'x2',$XX2,'y2', $YY2 , 'stroke',$ValueToColor{$Value},'stroke-width',$HeatMapstrokewidth,'fill',$ValueToColor{$Value}); 
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
								'stroke'         =>  $ValueToColor{$Value},
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
						$Value=LocalUtils::CheckValueNow($HashConfi_ref,$Level,$Value);

						my $ThisChrName="XXNAX";my $StartSite;my $EndSite;my $LevelV2;

						$LevelV2=$FileData_ref->[$FileNow][$StartCount][0];
						if (exists $GenomeFlag{$LevelV2})
						{
							$LevelV2=~s/Ref//g;
							$ThisChrName=$FileData_ref->[$FileNow][$StartCount][1];
							$StartSite=$FileData_ref->[$FileNow][$StartCount][2];
							$EndSite=$FileData_ref->[$FileNow][$StartCount][3];
						}
						else
						{
							if ( (!exists $SameChrName{$LevelV2})  &&  ( exists $ChrName2DiffGenome{$LevelV2}) )
							{
								$ThisChrName=$LevelV2;
								$LevelV2=$ChrName2DiffGenome{$ThisChrName} ;
								$StartSite=$FileData_ref->[$FileNow][$StartCount][1];
								$EndSite=$FileData_ref->[$FileNow][$StartCount][2];
							}
							elsif ( (exists $SameChrName{$LevelV2})  &&  ( exists $ChrName2DiffGenome{$LevelV2}) )
							{
								print "The chromosome name [$LevelV2] exists on both genomes Ref [$SameChrName{$LevelV2}], and it is impossible to distinguish which one, so skip this line\nYou can add Flag [RefX]  X=[$SameChrName{$LevelV2}] to the previous column of this row of data to distinguish\n";
							}
						}









						next if (!exists $hashYY1{$ThisChrName} ) ;
						if (exists $ReverseChr{$ThisChrName})
						{
							my $TS=$ReverseChr{$ThisChrName}-$EndSite;
							my $TE=$ReverseChr{$ThisChrName}-$StartSite;
							$StartSite=$TS;
							$EndSite=$TE;
						}
						my $YY1=$hashYY1{$ThisChrName}{$Level};
						my $YY2=$hashYY2{$ThisChrName}{$Level};
						my $XX1=sprintf ("%.1f",($StartSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$Level});
						my $XX2=sprintf ("%.1f",($EndSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$Level});

						if (exists $ValueToCustomColor_ref->{$Value} ) {$ValueToColor{$Value}=$ValueToCustomColor_ref->{$Value};}

						if ( $XX1 ==  $XX2 )
						{
							$svg->line('x1',$XX1,'y1',$YY1,'x2',$XX2,'y2', $YY2 , 'stroke',$ValueToColor{$Value},'stroke-width',$HeatMapstrokewidth,'fill',$ValueToColor{$Value}); 
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
								'stroke'         =>  $ValueToColor{$Value},
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
						$Value=LocalUtils::CheckValueNow($HashConfi_ref,$Level,$Value);

						my $ThisChrName="XXNAX";my $StartSite;my $EndSite;my $LevelV2;

						$LevelV2=$FileData_ref->[$FileNow][$StartCount][0];
						if (exists $GenomeFlag{$LevelV2})
						{
							$LevelV2=~s/Ref//g;
							$ThisChrName=$FileData_ref->[$FileNow][$StartCount][1];
							$StartSite=$FileData_ref->[$FileNow][$StartCount][2];
							$EndSite=$FileData_ref->[$FileNow][$StartCount][3];
						}
						else
						{
							if ( (!exists $SameChrName{$LevelV2})  &&  ( exists $ChrName2DiffGenome{$LevelV2}) )
							{
								$ThisChrName=$LevelV2;
								$LevelV2=$ChrName2DiffGenome{$ThisChrName} ;
								$StartSite=$FileData_ref->[$FileNow][$StartCount][1];
								$EndSite=$FileData_ref->[$FileNow][$StartCount][2];
							}
							elsif ( (exists $SameChrName{$LevelV2})  &&  ( exists $ChrName2DiffGenome{$LevelV2}) )
							{
								print "The chromosome name [$LevelV2] exists on both genomes Ref [$SameChrName{$LevelV2}], and it is impossible to distinguish which one, so skip this line\nYou can add Flag [RefX]  X=[$SameChrName{$LevelV2}] to the previous column of this row of data to distinguish\n";
							}
						}





						next if (!exists $hashYY1{$ThisChrName} ) ;
						if (exists $ReverseChr{$ThisChrName})
						{
							my $TS=$ReverseChr{$ThisChrName}-$EndSite;
							my $TE=$ReverseChr{$ThisChrName}-$StartSite;
							$StartSite=$TS;
							$EndSite=$TE;
						}

						my $YY1=$hashYY1{$ThisChrName}{$Level};
						my $YY2=$hashYY2{$ThisChrName}{$Level};
						my $XX1=sprintf ("%.1f",($StartSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$Level});
						my $XX2=sprintf ("%.1f",($EndSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$Level});

						if (exists $ValueToCustomColor_ref->{$Value} ) {$ValueToColor{$Value}=$ValueToCustomColor_ref->{$Value};}

						if ( $XX1 ==  $XX2 )
						{
							$svg->line('x1',$XX1,'y1',$YY2,'x2',$XX2,'y2', $YY1 , 'stroke',$ValueToColor{$Value},'stroke-width',$HeatMapstrokewidth,'fill',$ValueToColor{$Value}); 
							next ;
						}

						my $M1_X=($XX1+$XX2)*0.5;
						my $M1_Y=($YY1+$YY2)*0.5;

						my $kk=($XX2-$M1_X)*0.4/$MidHH;
						my $Q1_X=($XX1+$M1_X)*0.5+$MidHH*$kk;
						my $Q1_Y=($YY1+$M1_Y)*0.5;
						$svg->path(
							'd'=>"M$XX1 $YY2 Q $Q1_X $Q1_Y ,$M1_X , $M1_Y  T $XX2 $YY1  ",
							style => {
								'fill'           =>  'none',
								'stroke'         =>  $ValueToColor{$Value},
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
						$Value=LocalUtils::CheckValueNow($HashConfi_ref,$Level,$Value);

						my $ThisChrName="XXNAX";my $StartSite;my $EndSite;my $LevelV2;

						$LevelV2=$FileData_ref->[$FileNow][$StartCount][0];
						if (exists $GenomeFlag{$LevelV2})
						{
							$LevelV2=~s/Ref//g;
							$ThisChrName=$FileData_ref->[$FileNow][$StartCount][1];
							$StartSite=$FileData_ref->[$FileNow][$StartCount][2];
							$EndSite=$FileData_ref->[$FileNow][$StartCount][3];
						}
						else
						{
							if ( (!exists $SameChrName{$LevelV2})  &&  ( exists $ChrName2DiffGenome{$LevelV2}) )
							{
								$ThisChrName=$LevelV2;
								$LevelV2=$ChrName2DiffGenome{$ThisChrName} ;
								$StartSite=$FileData_ref->[$FileNow][$StartCount][1];
								$EndSite=$FileData_ref->[$FileNow][$StartCount][2];
							}
							elsif ( (exists $SameChrName{$LevelV2})  &&  ( exists $ChrName2DiffGenome{$LevelV2}) )
							{
								print "The chromosome name [$LevelV2] exists on both genomes Ref [$SameChrName{$LevelV2}], and it is impossible to distinguish which one, so skip this line\nYou can add Flag [RefX]  X=[$SameChrName{$LevelV2}] to the previous column of this row of data to distinguish\n";
							}
						}




						next if (!exists $hashYY1{$ThisChrName} ) ;
						if (exists $ReverseChr{$ThisChrName})
						{
							my $TS=$ReverseChr{$ThisChrName}-$EndSite;
							my $TE=$ReverseChr{$ThisChrName}-$StartSite;
							$StartSite=$TS;
							$EndSite=$TE;
						}

						my $YY1=$hashYY1{$ThisChrName}{$Level};
						my $YY2=$hashYY2{$ThisChrName}{$Level};
						my $XX1=sprintf ("%.1f",($StartSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$Level});
						my $XX2=sprintf ("%.1f",($EndSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$Level});

						if (exists $ValueToCustomColor_ref->{$Value} ) {$ValueToColor{$Value}=$ValueToCustomColor_ref->{$Value};}

						if ( $XX1 ==  $XX2 )
						{
							$svg->line('x1',$XX1,'y1',$YY2,'x2',$XX2,'y2', $YY1 , 'stroke',$ValueToColor{$Value},'stroke-width',$HeatMapstrokewidth,'fill',$ValueToColor{$Value}); 
							next ;
						}

						my $M1_X=($XX1+$XX2)*0.5;
						my $M1_Y=($YY1+$YY2)*0.5;


						my $kk=($XX2-$M1_X)*0.4/$MidHH;
						my $Q1_X=($XX1+$M1_X)*0.5-$MidHH*$kk;
						my $Q1_Y=($YY1+$M1_Y)*0.5;
						$svg->path(
							'd'=>"M$XX1 $YY2 Q $Q1_X $Q1_Y ,$M1_X , $M1_Y  T $XX2 $YY1  ",
							style => {
								'fill'           =>  'none',
								'stroke'         =>  $ValueToColor{$Value},
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
						$Value=LocalUtils::CheckValueNow($HashConfi_ref,$Level,$Value);

						my $ThisChrName="XXNAX";my $StartSite;my $EndSite;my $LevelV2;

						$LevelV2=$FileData_ref->[$FileNow][$StartCount][0];
						if (exists $GenomeFlag{$LevelV2})
						{
							$LevelV2=~s/Ref//g;
							$ThisChrName=$FileData_ref->[$FileNow][$StartCount][1];
							$StartSite=$FileData_ref->[$FileNow][$StartCount][2];
							$EndSite=$FileData_ref->[$FileNow][$StartCount][3];
						}
						else
						{
							if ( (!exists $SameChrName{$LevelV2})  &&  ( exists $ChrName2DiffGenome{$LevelV2}) )
							{
								$ThisChrName=$LevelV2;
								$LevelV2=$ChrName2DiffGenome{$ThisChrName} ;
								$StartSite=$FileData_ref->[$FileNow][$StartCount][1];
								$EndSite=$FileData_ref->[$FileNow][$StartCount][2];
							}
							elsif ( (exists $SameChrName{$LevelV2})  &&  ( exists $ChrName2DiffGenome{$LevelV2}) )
							{
								print "The chromosome name [$LevelV2] exists on both genomes Ref [$SameChrName{$LevelV2}], and it is impossible to distinguish which one, so skip this line\nYou can add Flag [RefX]  X=[$SameChrName{$LevelV2}] to the previous column of this row of data to distinguish\n";
							}
						}





						next if (!exists $hashYY1{$ThisChrName} ) ;
						if (exists $ReverseChr{$ThisChrName})
						{
							my $TS=$ReverseChr{$ThisChrName}-$EndSite;
							my $TE=$ReverseChr{$ThisChrName}-$StartSite;
							$StartSite=$TS;
							$EndSite=$TE;
						}

						my $YY1=$hashYY1{$ThisChrName}{$LevelV2};
						my $YY2=$hashYY2{$ThisChrName}{$LevelV2};
						my $XX1=sprintf ("%.1f",($StartSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$LevelV2});
						my $XX2=sprintf ("%.1f",($EndSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$LevelV2});
						my $Q1_X=($XX1+$XX2)*0.5;
						my $Q1_Y=$YY1+2*$hashHHC{$ValueToColor{$Value}};
						if (exists $ValueToCustomColor_ref->{$Value} ) {$ValueToColor{$Value}=$ValueToCustomColor_ref->{$Value};}
						if ($XX1 ==  $XX2 )
						{
							$svg->line('x1',$XX1,'y1',$YY1,'x2',$XX2,'y2', $YY1+$hashHHC{$ValueToColor{$Value}} , 'stroke',$ValueToColor{$Value},'stroke-width',$HeatMapstrokewidth,'fill',$ValueToColor{$Value}); 
							next ;
						}

						$svg->path(
							'd'=>"M$XX1 $YY1 Q $Q1_X $Q1_Y ,  $XX2 $YY1 ",
							style => {
								'fill'           =>  'none',
								'stroke'         =>  $ValueToColor{$Value},
								'stroke-width'   =>  $HeatMapstrokewidth,
								'stroke-opacity' =>  $HashConfi_ref->{$Level}{"stroke-opacity"},
								'fill-opacity'   =>  $HashConfi_ref->{$Level}{"fill-opacity"},
							},
						);
					}



				}
			}








		}
		elsif (( $HashConfi_ref->{$Level}{"plot_type"}  eq  "histogram" )  || ( $HashConfi_ref->{$Level}{"plot_type"}  eq  "hist" ))
		{
			if ($NumPlotArry>2)
			{
				print "Error:\tFor -PType histogram  on Level [$Level] only One/two Plot,you can modify to add the Level for it or change the -PType\n";
				for (my $i=0; $i<$NumPlotArry; $i++)
				{
					my $NowPlot=$PlotInfo->[$i];
					print "\t\tFile$NowPlot->[0]\tCoumn$NowPlot->[1]\n";
				}
				exit;
			}

			if ($NumPlotArry==2)
			{
				$ColorGradientArray[1]=$ColorGradientArray[$GradientSteps];
				$GradientSteps=1;
				my $NowPlot=$PlotInfo->[0];
				my $FileNow=$NowPlot->[0];
				my $CoumnNow=$NowPlot->[1];
				$ValueLabelsGradient[0]="U:$FileData_ref->[$FileNow][0][$CoumnNow]";
				$NowPlot=$PlotInfo->[1];
				$FileNow=$NowPlot->[0];
				$CoumnNow=$NowPlot->[1];
				$ValueLabelsGradient[1]="D:$FileData_ref->[$FileNow][0][$CoumnNow]";
			}
			$YY1=$HashConfi_ref->{"global"}{"canvas_margin_top"}+$LegendOffsetRatio*$Bodyheight+$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
			$YY2=$YY1+$LevelCorGra*($GradientSteps+1);
			$XX1=$HashConfi_ref->{"global"}{"canvas_margin_left"}+$HashConfi_ref->{"global"}{"canvas_body"}+($Level-1)*$LevelCorGra*4.5+$HashConfi_ref->{$Level}{"colormap_legend_shift_x"};
			$XX2=$XX1+$LevelCorGra;

			if ($HashConfi_ref->{$Level}{"colormap_legend_show"}==0   ||   $HashConfi_ref->{$Level}{"colormap_legend_sizeratio"}<=0 )
			{

			}
			else
			{
				$path = $svg->get_path(
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
				foreach my $k (0..$GradientSteps)
				{
					$YY1= $HashConfi_ref->{"global"}{"canvas_margin_top"}+$LegendOffsetRatio*$Bodyheight+$LevelCorGra*$k+$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
					$YY2=$YY1+$LevelCorGra;

					$path = $svg->get_path(
						x => [$XX1, $XX1, $XX2,$XX2],
						y => [$YY1, $YY2, $YY2,$YY1],
						-type => 'polygon');

					$svg->polygon(
						%$path,
						style => {
							'fill'           => "$ColorGradientArray[$k]",
							'stroke'         => 'black',
							'stroke-width'   =>  0,
							'stroke-opacity' =>  $HashConfi_ref->{$Level}{"stroke-opacity"},
							'fill-opacity'   =>  $HashConfi_ref->{$Level}{"fill-opacity"},
						},
					);  
					$svg->text('text-anchor','middle','x',$XX2+length($ValueLabelsGradient[$k])+$LevelCorGra*1.88,'y',$YY2,'-cdata',"$ValueLabelsGradient[$k]",'font-family','Arial','font-size',$LevelCorGra);
				}
			}

			my $MaxDiffValue=$HashConfi_ref->{$Level}{"Ymax"}-$HashConfi_ref->{$Level}{"Ymin"};
			my $HHstrokewidth=$HashConfi_ref->{$Level}{"stroke-width"};
			if ($NumPlotArry==1)
			{
				if ( (exists $HashConfi_ref->{$Level}{"yaxis_tick_show"} )  && ( $HashConfi_ref->{$Level}{"yaxis_tick_show"} >0 ) )
				{
					my $StartYLevel=sprintf ($Precision,$HashConfi_ref->{$Level}{"Ymin"}*1.0);
					my $EndYLevel=sprintf ($Precision,$HashConfi_ref->{$Level}{"Ymax"}*1.0);
					my $countTmpChr=$#$ChrArry_ref;
					if ( $HashConfi_ref->{"global"}{"chr_orientation"} ne "vertical" )
					{
						$countTmpChr=0;
					}
					foreach my $thisChr (0..$countTmpChr)
					{
						my $ThisChrName=$ChrArry_ref->[$thisChr];
						my $XX2=$HashConfi_ref->{"global"}{"canvas_margin_left"}-$fontsize*0.5;
						my $YY1=$hashYY1{$ThisChrName}{$Level}+$fontsize*0.1;
						my $YY2=$hashYY2{$ThisChrName}{$Level}-$fontsize*0.1;
						$svg->text('text-anchor','middle','x',$XX2,'y',$YY2,'-cdata',$StartYLevel,'font-family',$HashConfi_ref->{"global"}{"font-family"},'font-size',$fontsize*0.32);
						$svg->text('text-anchor','middle','x',$XX2,'y',$YY1,'-cdata',$EndYLevel,'font-family',$HashConfi_ref->{"global"}{"font-family"},'font-size',$fontsize*0.32);

					}
				}


				my $NowPlot=$PlotInfo->[0];
				my $FileNow=$NowPlot->[0];
				my $CoumnNow=$NowPlot->[1];
				my $StartCount=0;
				if  ($FileData_ref->[$FileNow][0][0] =~s/#/#/) 
				{
					$StartCount=1;
				}

				for ( ; $StartCount<$FileRow_ref->[$FileNow]; $StartCount++)
				{
					my $Value=$FileData_ref->[$FileNow][$StartCount][$CoumnNow];
					next if  ($Value eq "NA");
					$Value=LocalUtils::CheckValueNow($HashConfi_ref,$Level,$Value);

					my $ThisChrName="XXNAX";my $StartSite;my $EndSite;my $LevelV2;

					$LevelV2=$FileData_ref->[$FileNow][$StartCount][0];
					if (exists $GenomeFlag{$LevelV2})
					{
						$LevelV2=~s/Ref//g;
						$ThisChrName=$FileData_ref->[$FileNow][$StartCount][1];
						$StartSite=$FileData_ref->[$FileNow][$StartCount][2];
						$EndSite=$FileData_ref->[$FileNow][$StartCount][3];
					}
					else
					{
						if ( (!exists $SameChrName{$LevelV2})  &&  ( exists $ChrName2DiffGenome{$LevelV2}) )
						{
							$ThisChrName=$LevelV2;
							$LevelV2=$ChrName2DiffGenome{$ThisChrName} ;
							$StartSite=$FileData_ref->[$FileNow][$StartCount][1];
							$EndSite=$FileData_ref->[$FileNow][$StartCount][2];
						}
						elsif ( (exists $SameChrName{$LevelV2})  &&  ( exists $ChrName2DiffGenome{$LevelV2}) )
						{
							print "The chromosome name [$LevelV2] exists on both genomes Ref [$SameChrName{$LevelV2}], and it is impossible to distinguish which one, so skip this line\nYou can add Flag [RefX]  X=[$SameChrName{$LevelV2}] to the previous column of this row of data to distinguish\n";
						}
					}




					next if (!exists $hashYY1{$ThisChrName} ) ;
					if (exists $ReverseChr{$ThisChrName})
					{
						my $TS=$ReverseChr{$ThisChrName}-$EndSite;
						my $TE=$ReverseChr{$ThisChrName}-$StartSite;
						$StartSite=$TS;
						$EndSite=$TE;
					}

					my $YY1=$hashYY1{$ThisChrName}{$LevelV2};
					my $YY2=$hashYY2{$ThisChrName}{$LevelV2};
					$YY1=$YY2-($YY2-$YY1)*($Value-$HashConfi_ref->{$Level}{"Ymin"})/$MaxDiffValue;
					my $XX1=sprintf ("%.1f",($StartSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$LevelV2});
					my $XX2=sprintf ("%.1f",($EndSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$LevelV2});
					if (exists $ValueToCustomColor_ref->{$Value} ) {$ValueToColor{$Value}=$ValueToCustomColor_ref->{$Value};}
					$path = $svg->get_path(
						x => [$XX1, $XX1, $XX2,$XX2],
						y => [$YY1, $YY2, $YY2,$YY1],
						-type => 'polygon');
					$svg->polygon(
						%$path,
						style => {
							'fill'           => $ValueToColor{$Value},
							'stroke'         => $ValueToColor{$Value},
							'stroke-width'   => $HHstrokewidth,
							'stroke-opacity' => $HashConfi_ref->{$Level}{"stroke-opacity"},
							'fill-opacity'   => $HashConfi_ref->{$Level}{"fill-opacity"},
						},
					);
				}

			}
			else
			{

				if ( (exists $HashConfi_ref->{$Level}{"yaxis_tick_show"} )  && ( $HashConfi_ref->{$Level}{"yaxis_tick_show"} >0 ) )
				{
					my $StartYLevel=sprintf ($Precision,$HashConfi_ref->{$Level}{"Ymin"}*1.0);
					my $EndYLevel=sprintf ($Precision,$HashConfi_ref->{$Level}{"Ymax"}*1.0);
					my $countTmpChr=$#$ChrArry_ref;
					if ( $HashConfi_ref->{"global"}{"chr_orientation"} ne "vertical" )
					{
						$countTmpChr=0;
					}
					foreach my $thisChr (0..$countTmpChr)
					{
						my $ThisChrName=$ChrArry_ref->[$thisChr];
						my $XX2=$HashConfi_ref->{"global"}{"canvas_margin_left"}-$fontsize*0.5;
						my $YY1=$hashYY1{$ThisChrName}{$Level}+$fontsize*0.1;
						my $YY2=$hashYY2{$ThisChrName}{$Level}-$fontsize*0.1;
						$svg->text('text-anchor','middle','x',$XX2,'y',$YY1,'-cdata',$EndYLevel,'font-family',$HashConfi_ref->{"global"}{"font-family"},'font-size',$fontsize*0.32);
						$svg->text('text-anchor','middle','x',$XX2,'y',$YY2,'-cdata',$EndYLevel,'font-family',$HashConfi_ref->{"global"}{"font-family"},'font-size',$fontsize*0.32);
						$svg->text('text-anchor','middle','x',$XX2,'y',($YY2+$YY1)/2,'-cdata',$StartYLevel,'font-family',$HashConfi_ref->{"global"}{"font-family"},'font-size',$fontsize*0.32);
					}
				}
				my $NowPlot=$PlotInfo->[0];
				my $FileNow=$NowPlot->[0];
				my $CoumnNow=$NowPlot->[1];
				my $StartCount=0;
				if  ($FileData_ref->[$FileNow][0][0] =~s/#/#/) 
				{
					$StartCount=1;
				}
				for ( ; $StartCount<$FileRow_ref->[$FileNow]; $StartCount++)
				{
					my $Value=$FileData_ref->[$FileNow][$StartCount][$CoumnNow];
					next if  ($Value eq "NA");
					$Value=LocalUtils::CheckValueNow($HashConfi_ref,$Level,$Value);

					my $ThisChrName="XXNAX";my $StartSite;my $EndSite;my $LevelV2;

					$LevelV2=$FileData_ref->[$FileNow][$StartCount][0];
					if (exists $GenomeFlag{$LevelV2})
					{
						$LevelV2=~s/Ref//g;
						$ThisChrName=$FileData_ref->[$FileNow][$StartCount][1];
						$StartSite=$FileData_ref->[$FileNow][$StartCount][2];
						$EndSite=$FileData_ref->[$FileNow][$StartCount][3];
					}
					else
					{
						if ( (!exists $SameChrName{$LevelV2})  &&  ( exists $ChrName2DiffGenome{$LevelV2}) )
						{
							$ThisChrName=$LevelV2;
							$LevelV2=$ChrName2DiffGenome{$ThisChrName} ;
							$StartSite=$FileData_ref->[$FileNow][$StartCount][1];
							$EndSite=$FileData_ref->[$FileNow][$StartCount][2];
						}
						elsif ( (exists $SameChrName{$LevelV2})  &&  ( exists $ChrName2DiffGenome{$LevelV2}) )
						{
							print "The chromosome name [$LevelV2] exists on both genomes Ref [$SameChrName{$LevelV2}], and it is impossible to distinguish which one, so skip this line\nYou can add Flag [RefX]  X=[$SameChrName{$LevelV2}] to the previous column of this row of data to distinguish\n";
						}
					}






					next if (!exists $hashYY1{$ThisChrName} ) ;
					if (exists $ReverseChr{$ThisChrName})
					{
						my $TS=$ReverseChr{$ThisChrName}-$EndSite;
						my $TE=$ReverseChr{$ThisChrName}-$StartSite;
						$StartSite=$TS;
						$EndSite=$TE;
					}

					my $YY1=$hashYY1{$ThisChrName}{$LevelV2};
					my $YY2=$hashYY2{$ThisChrName}{$LevelV2};
					$YY2=($YY1+$YY2)/2;
					$YY1=$YY2-($YY2-$YY1)*($Value-$HashConfi_ref->{$Level}{"Ymin"})/$MaxDiffValue;
					my $XX1=sprintf ("%.1f",($StartSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$LevelV2});
					my $XX2=sprintf ("%.1f",($EndSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$LevelV2});
					$path = $svg->get_path(
						x => [$XX1, $XX1, $XX2,$XX2],
						y => [$YY1, $YY2, $YY2,$YY1],
						-type => 'polygon');
					$svg->polygon(
						%$path,
						style => {
							'fill'           => $ColorGradientArray[0],
							'stroke'         => $ColorGradientArray[0],
							'stroke-width'   => $HHstrokewidth,
							'stroke-opacity' => $HashConfi_ref->{$Level}{"stroke-opacity"},
							'fill-opacity'   => $HashConfi_ref->{$Level}{"fill-opacity"},
						},
					);
				}



				$NowPlot=$PlotInfo->[1];
				$FileNow=$NowPlot->[0];
				$CoumnNow=$NowPlot->[1];
				$StartCount=0;
				if  ($FileData_ref->[$FileNow][0][0] =~s/#/#/) 
				{
					$StartCount=1;
				}
				for ( ; $StartCount<$FileRow_ref->[$FileNow]; $StartCount++)
				{
					my $Value=$FileData_ref->[$FileNow][$StartCount][$CoumnNow];
					next if  ($Value eq "NA");	
					$Value=LocalUtils::CheckValueNow($HashConfi_ref,$Level,$Value);

					my $ThisChrName="XXNAX";my $StartSite;my $EndSite;my $LevelV2;

					$LevelV2=$FileData_ref->[$FileNow][$StartCount][0];
					if (exists $GenomeFlag{$LevelV2})
					{
						$LevelV2=~s/Ref//g;
						$ThisChrName=$FileData_ref->[$FileNow][$StartCount][1];
						$StartSite=$FileData_ref->[$FileNow][$StartCount][2];
						$EndSite=$FileData_ref->[$FileNow][$StartCount][3];
					}
					else
					{
						if ( (!exists $SameChrName{$LevelV2})  &&  ( exists $ChrName2DiffGenome{$LevelV2}) )
						{
							$ThisChrName=$LevelV2;
							$LevelV2=$ChrName2DiffGenome{$ThisChrName} ;
							$StartSite=$FileData_ref->[$FileNow][$StartCount][1];
							$EndSite=$FileData_ref->[$FileNow][$StartCount][2];
						}
						elsif ( (exists $SameChrName{$LevelV2})  &&  ( exists $ChrName2DiffGenome{$LevelV2}) )
						{
							print "The chromosome name [$LevelV2] exists on both genomes Ref [$SameChrName{$LevelV2}], and it is impossible to distinguish which one, so skip this line\nYou can add Flag [RefX]  X=[$SameChrName{$LevelV2}] to the previous column of this row of data to distinguish\n";
						}
					}



					next if (!exists $hashYY1{$ThisChrName} ) ;
					if (exists $ReverseChr{$ThisChrName})
					{
						my $TS=$ReverseChr{$ThisChrName}-$EndSite;
						my $TE=$ReverseChr{$ThisChrName}-$StartSite;
						$StartSite=$TS;
						$EndSite=$TE;
					}

					my $YY1=$hashYY1{$ThisChrName}{$LevelV2};
					my $YY2=$hashYY2{$ThisChrName}{$LevelV2};
					$YY1=($YY1+$YY2)/2;
					$YY2=$YY1+($YY2-$YY1)*($Value-$HashConfi_ref->{$Level}{"Ymin"})/$MaxDiffValue;
					my $XX1=sprintf ("%.1f",($StartSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$LevelV2});
					my $XX2=sprintf ("%.1f",($EndSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$LevelV2});
					$path = $svg->get_path(
						x => [$XX1, $XX1, $XX2,$XX2],
						y => [$YY1, $YY2, $YY2,$YY1],
						-type => 'polygon');
					$svg->polygon(
						%$path,
						style => {
							'fill'           => $ColorGradientArray[1],
							'fill-opacity'   => $HashConfi_ref->{$Level}{"fill-opacity"},
							'stroke'         => $ColorGradientArray[1],
							'stroke-width'   => $HHstrokewidth,
							'stroke-opacity' => $HashConfi_ref->{$Level}{"stroke-opacity"},
						},
					);
				}


			}

			if (exists $HashConfi_ref->{$Level}{"cutoff_y"}  )
			{
				my $Value=$HashConfi_ref->{$Level}{"cutoff_y"};
				if (($Value < $HashConfi_ref->{$Level}{"Ymax"})  &&  ( $Value >  $HashConfi_ref->{$Level}{"Ymin"}) )
				{
					my $AA=$HHstrokewidth*3; my $BB=$HHstrokewidth*2;
					my $corCutline="red";  if  (exists $HashConfi_ref->{$Level}{"cutoff_color"}) {$corCutline=$HashConfi_ref->{$Level}{"cutoff_color"};}
					foreach my $thisChr (0..$#$ChrArry_ref)
					{
						my $ThisChrName=$ChrArry_ref->[$thisChr];
						my $XX1=sprintf ("%.1f",$hashXX1{$ThisChrName}{$Level});
						my $XX2=sprintf ("%.1f",($hashChr_ref->{$ThisChrName}/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$Level});
						my $YY1=$hashYY1{$ThisChrName}{$Level};
						my $YY2=$hashYY2{$ThisChrName}{$Level};
						my $labYY=$YY2-($YY2-$YY1)*($Value-$HashConfi_ref->{$Level}{"Ymin"})/$MaxDiffValue;
						$svg->line('x1',$XX1,'y1',$labYY,'x2',$XX2,'y2',$labYY,'stroke',$corCutline,'stroke-width',$HHstrokewidth,'stroke-dasharray',"$AA $BB");
					}
				}
			}

			if (exists $HashConfi_ref->{$Level}{"cutoff1_y"}  )
			{
				my $Value=$HashConfi_ref->{$Level}{"cutoff1_y"};
				if (($Value < $HashConfi_ref->{$Level}{"Ymax"})  &&  ( $Value >  $HashConfi_ref->{$Level}{"Ymin"}) )
				{
					my $AA=$HHstrokewidth*3; my $BB=$HHstrokewidth*2;
					my $corCutline="red";  if  (exists $HashConfi_ref->{$Level}{"cutoff1_color"}) {$corCutline=$HashConfi_ref->{$Level}{"cutoff1_color"};}
					foreach my $thisChr (0..$#$ChrArry_ref)
					{
						my $ThisChrName=$ChrArry_ref->[$thisChr];
						my $XX1=sprintf ("%.1f",$hashXX1{$ThisChrName}{$Level});
						my $XX2=sprintf ("%.1f",($hashChr_ref->{$ThisChrName}/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$Level});
						my $YY1=$hashYY1{$ThisChrName}{$Level};
						my $YY2=$hashYY2{$ThisChrName}{$Level};
						my $labYY=$YY2-($YY2-$YY1)*($Value-$HashConfi_ref->{$Level}{"Ymin"})/$MaxDiffValue;
						$svg->line('x1',$XX1,'y1',$labYY,'x2',$XX2,'y2',$labYY,'stroke',$corCutline,'stroke-width',$HHstrokewidth,'stroke-dasharray',"$AA $BB");
					}
				}
			}
			if (exists $HashConfi_ref->{$Level}{"cutoff2_y"}  )
			{
				my $Value=$HashConfi_ref->{$Level}{"cutoff2_y"};
				if (($Value < $HashConfi_ref->{$Level}{"Ymax"})  &&  ( $Value >  $HashConfi_ref->{$Level}{"Ymin"}) )
				{
					my $AA=$HHstrokewidth*3; my $BB=$HHstrokewidth*2;
					my $corCutline="red";  if  (exists $HashConfi_ref->{$Level}{"cutoff_color"}) {$corCutline=$HashConfi_ref->{$Level}{"cutoff2_color"};}
					foreach my $thisChr (0..$#$ChrArry_ref)
					{
						my $ThisChrName=$ChrArry_ref->[$thisChr];
						my $XX1=sprintf ("%.1f",$hashXX1{$ThisChrName}{$Level});
						my $XX2=sprintf ("%.1f",($hashChr_ref->{$ThisChrName}/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$Level});
						my $YY1=$hashYY1{$ThisChrName}{$Level};
						my $YY2=$hashYY2{$ThisChrName}{$Level};
						my $labYY=$YY2-($YY2-$YY1)*($Value-$HashConfi_ref->{$Level}{"Ymin"})/$MaxDiffValue;
						$svg->line('x1',$XX1,'y1',$labYY,'x2',$XX2,'y2',$labYY,'stroke',$corCutline,'stroke-width',$HHstrokewidth,'stroke-dasharray',"$AA $BB");
					}
				}
			}




		}
		elsif (($HashConfi_ref->{$Level}{"plot_type"}  eq  "scatter" )  || ( $HashConfi_ref->{$Level}{"plot_type"}  eq  "point" ) || ( $HashConfi_ref->{$Level}{"plot_type"}  eq  "points" ))
		{

			my $cirsize=$LevelCorGra/12;
			if  ( (exists $HashConfi_ref->{$Level}{"track_point_size"} )  && ( $HashConfi_ref->{$Level}{"track_point_size"} >0 ) )
			{
				$cirsize=$cirsize*$HashConfi_ref->{$Level}{"track_point_size"};
			}
			my $MaxDiffValue=$HashConfi_ref->{$Level}{"Ymax"}-$HashConfi_ref->{$Level}{"Ymin"};

			if ( (exists $HashConfi_ref->{$Level}{"yaxis_tick_show"} )  && ( $HashConfi_ref->{$Level}{"yaxis_tick_show"} >0 ) )
			{
				my $StartYLevel=sprintf ($Precision,$HashConfi_ref->{$Level}{"Ymin"}*1.0);
				my $EndYLevel=sprintf ($Precision,$HashConfi_ref->{$Level}{"Ymax"}*1.0);
				my $countTmpChr=$#$ChrArry_ref;
				if ( $HashConfi_ref->{"global"}{"chr_orientation"} ne "vertical" )
				{
					$countTmpChr=0;
				}
				foreach my $thisChr (0..$countTmpChr)
				{
					my $ThisChrName=$ChrArry_ref->[$thisChr];
					my $XX2=$HashConfi_ref->{"global"}{"canvas_margin_left"}-$fontsize*0.5;
					my $YY1=$hashYY1{$ThisChrName}{$Level}+$fontsize*0.1;
					my $YY2=$hashYY2{$ThisChrName}{$Level}-$fontsize*0.1;
					$svg->text('text-anchor','middle','x',$XX2,'y',$YY2,'-cdata',$StartYLevel,'font-family',$HashConfi_ref->{"global"}{"font-family"},'font-size',$fontsize*0.32);
					$svg->text('text-anchor','middle','x',$XX2,'y',$YY1,'-cdata',$EndYLevel,'font-family',$HashConfi_ref->{"global"}{"font-family"},'font-size',$fontsize*0.32);
				}
			}	


			if ($NumPlotArry==1)
			{

				$YY1=$HashConfi_ref->{"global"}{"canvas_margin_top"}+$LegendOffsetRatio*$Bodyheight+$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
				$YY2=$YY1+$LevelCorGra*($GradientSteps+1);
				$XX1=$HashConfi_ref->{"global"}{"canvas_margin_left"}+$HashConfi_ref->{"global"}{"canvas_body"}+($Level-1)*$LevelCorGra*4.8+$HashConfi_ref->{$Level}{"colormap_legend_shift_x"};
				$XX2=$XX1+$LevelCorGra;

				if ($HashConfi_ref->{$Level}{"colormap_legend_show"}==0   ||   $HashConfi_ref->{$Level}{"colormap_legend_sizeratio"}<=0 )
				{

				}
				else
				{
					foreach my $k (0..$GradientSteps)
					{
						$YY1= $HashConfi_ref->{"global"}{"canvas_margin_top"}+$LegendOffsetRatio*$Bodyheight+$LevelCorGra*$k+$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
						$YY2=$YY1+$LevelCorGra;
						$svg->circle(cx=>$XX1, cy=>$YY2, r=>$cirsize*5, fill => "$ColorGradientArray[$k]");
						$svg->text('text-anchor','middle','x',$XX2+length($ValueLabelsGradient[$k])+$LevelCorGra*1.88,'y',$YY2,'-cdata',"$ValueLabelsGradient[$k]",'font-family','Arial','font-size',$LevelCorGra);
					}
				}

				my $NowPlot=$PlotInfo->[0];
				my $FileNow=$NowPlot->[0];
				my $CoumnNow=$NowPlot->[1];
				my $StartCount=0;
				if  ($FileData_ref->[$FileNow][0][0] =~s/#/#/) 
				{
					$StartCount=1;
				}
				my %Uniq=();
				for ( ; $StartCount<$FileRow_ref->[$FileNow]; $StartCount++)
				{
					my $Value=$FileData_ref->[$FileNow][$StartCount][$CoumnNow];
					next if  ($Value eq "NA");
					$Value=LocalUtils::CheckValueNow($HashConfi_ref,$Level,$Value);

					my $ThisChrName="XXNAX";my $StartSite;my $EndSite;my $LevelV2;

					$LevelV2=$FileData_ref->[$FileNow][$StartCount][0];
					if (exists $GenomeFlag{$LevelV2})
					{
						$LevelV2=~s/Ref//g;
						$ThisChrName=$FileData_ref->[$FileNow][$StartCount][1];
						$StartSite=$FileData_ref->[$FileNow][$StartCount][2];
						$EndSite=$FileData_ref->[$FileNow][$StartCount][3];
					}
					else
					{
						if ( (!exists $SameChrName{$LevelV2})  &&  ( exists $ChrName2DiffGenome{$LevelV2}) )
						{
							$ThisChrName=$LevelV2;
							$LevelV2=$ChrName2DiffGenome{$ThisChrName} ;
							$StartSite=$FileData_ref->[$FileNow][$StartCount][1];
							$EndSite=$FileData_ref->[$FileNow][$StartCount][2];
						}
						elsif ( (exists $SameChrName{$LevelV2})  &&  ( exists $ChrName2DiffGenome{$LevelV2}) )
						{
							print "The chromosome name [$LevelV2] exists on both genomes Ref [$SameChrName{$LevelV2}], and it is impossible to distinguish which one, so skip this line\nYou can add Flag [RefX]  X=[$SameChrName{$LevelV2}] to the previous column of this row of data to distinguish\n";
						}
					}


					next if (!exists $hashYY1{$ThisChrName});
					if (exists $ReverseChr{$ThisChrName})
					{
						my $TS=$ReverseChr{$ThisChrName}-$EndSite;
						my $TE=$ReverseChr{$ThisChrName}-$StartSite;
						$StartSite=$TS;
						$EndSite=$TE;
					}
					my $YY1=$hashYY1{$ThisChrName}{$LevelV2};
					my $YY2=$hashYY2{$ThisChrName}{$LevelV2};
					$YY1=sprintf("%.1f",$YY2-($YY2-$YY1)*($Value-$HashConfi_ref->{$Level}{"Ymin"})/$MaxDiffValue);
					my $XX1=sprintf ("%.1f",($StartSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$LevelV2});
					my $key=$XX1."_".$YY1;
					next if (exists $Uniq{$key});
					if (exists $ValueToCustomColor_ref->{$Value} ) {$ValueToColor{$Value}=$ValueToCustomColor_ref->{$Value};}
					$svg->circle(cx=>$XX1, cy=>$YY1, r=>$cirsize, fill => "$ValueToColor{$Value}" );
					$Uniq{$key}=1;
				}
			}
			else
			{
				my $NumGradien=$NumPlotArry;
				if (! exists $HashConfi_ref->{$Level}{"colormap_brewer_name"} )
				{			
					my @StartRGB;
					($StartRGB[0],$StartRGB[1],$StartRGB[2] )=HTML2RGB($HashConfi_ref->{$Level}{"colormap_low_color"});
					my @EndRGB;
					($EndRGB[0],$EndRGB[1],$EndRGB[2])=HTML2RGB($HashConfi_ref->{$Level}{"colormap_high_color"});
					my @MidRGB;
					($MidRGB[0],$MidRGB[1],$MidRGB[2])=HTML2RGB($HashConfi_ref->{$Level}{"colormap_mid_color"});

					@ColorGradientArray = ();
  					LocalUtils::generate_gradient_colors(\@StartRGB, \@MidRGB, \@EndRGB, $NumGradien, \@ColorGradientArray);

					$ColorGradientArray[$NumPlotArry]=$HashConfi_ref->{$Level}{"colormap_high_color"};
					if ($NumPlotArry==2) {$ColorGradientArray[1]=$HashConfi_ref->{$Level}{"colormap_high_color"};}
				}
				else
				{
					@ColorGradientArray=();
					my $ColFlag=$HashConfi_ref->{$Level}{"colormap_brewer_name"};
					GetColGradien($ColFlag,$NumGradien,\@ColorGradientArray,$HashConfi_ref);
					if (exists  $HashConfi_ref->{$Level}{"colormap_reverse"})
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

				}


				foreach my $k (1..$NumPlotArry)
				{
					my	$NowPlot=$PlotInfo->[$k-1];
					my  $FileNow=$NowPlot->[0];
					my	$CoumnNow=$NowPlot->[1];
					my  $StartCount=0;
					$ValueLabelsGradient[$k-1]="$FileData_ref->[$FileNow][0][$CoumnNow]";


					$XX1=$HashConfi_ref->{"global"}{"canvas_margin_left"}+$HashConfi_ref->{"global"}{"canvas_body"}+($Level-1)*$LevelCorGra*4.5+$HashConfi_ref->{$Level}{"colormap_legend_shift_x"};
					$XX2=$XX1+$LevelCorGra;
					$YY1= $HashConfi_ref->{"global"}{"canvas_margin_top"}+$LegendOffsetRatio*$Bodyheight+$LevelCorGra*($k-1)+$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
					$YY2=$YY1+$LevelCorGra;
					if ($HashConfi_ref->{$Level}{"colormap_legend_show"}==0   ||   $HashConfi_ref->{$Level}{"colormap_legend_sizeratio"}<=0 )
					{

					}
					else
					{
						$svg->circle(cx=>$XX1, cy=>$YY1, r=>$cirsize*5, fill => "$ColorGradientArray[$k-1]" );
						$svg->text('text-anchor','middle','x',$XX2+length($ValueLabelsGradient[$k-1])+$LevelCorGra*1.88,'y',$YY2,'-cdata',"$ValueLabelsGradient[$k-1]",'font-family','Arial','font-size',$LevelCorGra);
					}


					if  ($FileData_ref->[$FileNow][0][0] =~s/#/#/) 
					{
						$StartCount=1;
					}

					my %Uniq=();
					for ( ; $StartCount<$FileRow_ref->[$FileNow]; $StartCount++)
					{
						my $Value=$FileData_ref->[$FileNow][$StartCount][$CoumnNow];
						next if  ($Value eq "NA");
						$Value=LocalUtils::CheckValueNow($HashConfi_ref,$Level,$Value);

						my $ThisChrName="XXNAX";my $StartSite;my $EndSite;my $LevelV2;

						$LevelV2=$FileData_ref->[$FileNow][$StartCount][0];
						if (exists $GenomeFlag{$LevelV2})
						{
							$LevelV2=~s/Ref//g;
							$ThisChrName=$FileData_ref->[$FileNow][$StartCount][1];
							$StartSite=$FileData_ref->[$FileNow][$StartCount][2];
							$EndSite=$FileData_ref->[$FileNow][$StartCount][3];
						}
						else
						{
							if ( (!exists $SameChrName{$LevelV2})  &&  ( exists $ChrName2DiffGenome{$LevelV2}) )
							{
								$ThisChrName=$LevelV2;
								$LevelV2=$ChrName2DiffGenome{$ThisChrName} ;
								$StartSite=$FileData_ref->[$FileNow][$StartCount][1];
								$EndSite=$FileData_ref->[$FileNow][$StartCount][2];
							}
							elsif ( (exists $SameChrName{$LevelV2})  &&  ( exists $ChrName2DiffGenome{$LevelV2}) )
							{
								print "The chromosome name [$LevelV2] exists on both genomes Ref [$SameChrName{$LevelV2}], and it is impossible to distinguish which one, so skip this line\nYou can add Flag [RefX]  X=[$SameChrName{$LevelV2}] to the previous column of this row of data to distinguish\n";
							}
						}


						next if (!exists $hashYY1{$ThisChrName} ) ;	
						if (exists $ReverseChr{$ThisChrName})
						{
							my $TS=$ReverseChr{$ThisChrName}-$EndSite;
							my $TE=$ReverseChr{$ThisChrName}-$StartSite;
							$StartSite=$TS;
							$EndSite=$TE;
						}

						my $YY1=$hashYY1{$ThisChrName}{$LevelV2};
						my $YY2=$hashYY2{$ThisChrName}{$LevelV2};
						$YY1= sprintf("%.1f",$YY2-($YY2-$YY1)*($Value-$HashConfi_ref->{$Level}{"Ymin"})/$MaxDiffValue);
						my $XX1=sprintf ("%.1f",($StartSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$LevelV2});
						my $key=$XX1."_".$YY1;
						next if (exists $Uniq{$key});
						$svg->circle(cx=>$XX1, cy=>$YY1, r=>$cirsize, fill => "$ColorGradientArray[$k-1]");
						$Uniq{$key}=1;
					}
				}
			}

			if (exists $HashConfi_ref->{$Level}{"cutoff_y"})
			{
				my $Value=$HashConfi_ref->{$Level}{"cutoff_y"};
				my $HHstrokewidth=$HashConfi_ref->{$Level}{"stroke-width"};
				if (($Value < $HashConfi_ref->{$Level}{"Ymax"})  &&  ( $Value >  $HashConfi_ref->{$Level}{"Ymin"}) )
				{
					my $AA=$HHstrokewidth*3; my $BB=$HHstrokewidth*2;
					my $corCutline="red";  if  (exists $HashConfi_ref->{$Level}{"cutoff_color"}) {$corCutline=$HashConfi_ref->{$Level}{"cutoff_color"};}
					foreach my $thisChr (0..$#$ChrArry_ref)
					{
						my $ThisChrName=$ChrArry_ref->[$thisChr];
						my $XX1=sprintf ("%.1f",$hashXX1{$ThisChrName}{$Level});
						my $XX2=sprintf ("%.1f",($hashChr_ref->{$ThisChrName}/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$Level});
						my $YY1=$hashYY1{$ThisChrName}{$Level};
						my $YY2=$hashYY2{$ThisChrName}{$Level};
						my $labYY=$YY2-($YY2-$YY1)*($Value-$HashConfi_ref->{$Level}{"Ymin"})/$MaxDiffValue;
						$svg->line('x1',$XX1,'y1',$labYY,'x2',$XX2,'y2',$labYY,'stroke',$corCutline,'stroke-width',$HHstrokewidth,'stroke-dasharray',"$AA $BB");
					}
				}
			}

			if (exists $HashConfi_ref->{$Level}{"cutoff1_y"})
			{
				my $Value=$HashConfi_ref->{$Level}{"cutoff1_y"};
				my $HHstrokewidth=$HashConfi_ref->{$Level}{"stroke-width"};
				if (($Value < $HashConfi_ref->{$Level}{"Ymax"})  &&  ( $Value >  $HashConfi_ref->{$Level}{"Ymin"}) )
				{
					my $AA=$HHstrokewidth*3; my $BB=$HHstrokewidth*2;
					my $corCutline="red";  if  (exists $HashConfi_ref->{$Level}{"cutoff1_color"}) {$corCutline=$HashConfi_ref->{$Level}{"cutoff1_color"};}
					foreach my $thisChr (0..$#$ChrArry_ref)
					{
						my $ThisChrName=$ChrArry_ref->[$thisChr];
						my $XX1=sprintf ("%.1f",$hashXX1{$ThisChrName}{$Level});
						my $XX2=sprintf ("%.1f",($hashChr_ref->{$ThisChrName}/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$Level});
						my $YY1=$hashYY1{$ThisChrName}{$Level};
						my $YY2=$hashYY2{$ThisChrName}{$Level};
						my $labYY=$YY2-($YY2-$YY1)*($Value-$HashConfi_ref->{$Level}{"Ymin"})/$MaxDiffValue;
						$svg->line('x1',$XX1,'y1',$labYY,'x2',$XX2,'y2',$labYY,'stroke',$corCutline,'stroke-width',$HHstrokewidth,'stroke-dasharray',"$AA $BB");
					}
				}
			}

			if (exists $HashConfi_ref->{$Level}{"cutoff2_y"})
			{
				my $Value=$HashConfi_ref->{$Level}{"cutoff2_y"};
				my $HHstrokewidth=$HashConfi_ref->{$Level}{"stroke-width"};
				if (($Value < $HashConfi_ref->{$Level}{"Ymax"})  &&  ( $Value >  $HashConfi_ref->{$Level}{"Ymin"}) )
				{
					my $AA=$HHstrokewidth*3; my $BB=$HHstrokewidth*2;
					my $corCutline="red";  if  (exists $HashConfi_ref->{$Level}{"cutoff2_color"}) {$corCutline=$HashConfi_ref->{$Level}{"cutoff2_color"};}
					foreach my $thisChr (0..$#$ChrArry_ref)
					{
						my $ThisChrName=$ChrArry_ref->[$thisChr];
						my $XX1=sprintf ("%.1f",$hashXX1{$ThisChrName}{$Level});
						my $XX2=sprintf ("%.1f",($hashChr_ref->{$ThisChrName}/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$Level});
						my $YY1=$hashYY1{$ThisChrName}{$Level};
						my $YY2=$hashYY2{$ThisChrName}{$Level};
						my $labYY=$YY2-($YY2-$YY1)*($Value-$HashConfi_ref->{$Level}{"Ymin"})/$MaxDiffValue;
						$svg->line('x1',$XX1,'y1',$labYY,'x2',$XX2,'y2',$labYY,'stroke',$corCutline,'stroke-width',$HHstrokewidth,'stroke-dasharray',"$AA $BB");
					}
				}
			}




		}
		elsif (($HashConfi_ref->{$Level}{"plot_type"}  eq  "shape" )  || ( $HashConfi_ref->{$Level}{"plot_type"}  eq  "shapes" ) || ( $HashConfi_ref->{$Level}{"plot_type"}  eq  "Shape" ))
		{

			my $cirsize=$LevelCorGra/12;
			if  ( (exists $HashConfi_ref->{$Level}{"track_point_size"} )  && ( $HashConfi_ref->{$Level}{"track_point_size"} >0 ) )
			{
				$cirsize=$cirsize*$HashConfi_ref->{$Level}{"track_point_size"};
			}
			if  ( (exists $HashConfi_ref->{$Level}{"track_geom_shape_size"} )  && ( $HashConfi_ref->{$Level}{"track_geom_shape_size"} >0 ) )
			{
				$cirsize=$cirsize*$HashConfi_ref->{$Level}{"track_geom_shape_size"};
			}
			my $MaxDiffValue=1;
			if ($HashConfi_ref->{$Level}{"IsNumber"}==1 )
			{
				$MaxDiffValue=$HashConfi_ref->{$Level}{"Ymax"}-$HashConfi_ref->{$Level}{"Ymin"};
			}

			if ( (exists $HashConfi_ref->{$Level}{"yaxis_tick_show"} )  && ( $HashConfi_ref->{$Level}{"yaxis_tick_show"} >0 ) )
			{
				my $StartYLevel=sprintf ($Precision,$HashConfi_ref->{$Level}{"Ymin"}*1.0);
				my $EndYLevel=sprintf ($Precision,$HashConfi_ref->{$Level}{"Ymax"}*1.0);
				my $countTmpChr=$#$ChrArry_ref;
				if ( $HashConfi_ref->{"global"}{"chr_orientation"} ne "vertical")
				{
					$countTmpChr=0;
				}
				foreach my $thisChr (0..$countTmpChr)
				{
					my $ThisChrName=$ChrArry_ref->[$thisChr];
					my $XX2=$HashConfi_ref->{"global"}{"canvas_margin_left"}-$fontsize*0.5;
					my $YY1=$hashYY1{$ThisChrName}{$Level}+$fontsize*0.1;
					my $YY2=$hashYY2{$ThisChrName}{$Level}-$fontsize*0.1;
					$svg->text('text-anchor','middle','x',$XX2,'y',$YY2,'-cdata',$StartYLevel,'font-family',$HashConfi_ref->{"global"}{"font-family"},'font-size',$fontsize*0.32);
					$svg->text('text-anchor','middle','x',$XX2,'y',$YY1,'-cdata',$EndYLevel,'font-family',$HashConfi_ref->{"global"}{"font-family"},'font-size',$fontsize*0.32);
				}
			}

			if ($NumPlotArry==1)
			{
				$YY1=$HashConfi_ref->{"global"}{"canvas_margin_top"}+$LegendOffsetRatio*$Bodyheight+$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
				$YY2=$YY1+$LevelCorGra*($GradientSteps+1);
				$XX1=$HashConfi_ref->{"global"}{"canvas_margin_left"}+$HashConfi_ref->{"global"}{"canvas_body"}+($Level-1)*$LevelCorGra*4.8+$HashConfi_ref->{$Level}{"colormap_legend_shift_x"}+$all_chromosomes_spacing;
				$XX2=$XX1+$LevelCorGra;
				my @shapeType=();
				foreach my $k (0..$GradientSteps)
				{
					my $Type= $k % 14;
					$shapeType[$k]=$Type;
				}
				if (exists $HashConfi_ref->{$Level}{"track_geom_shape"} )
				{
					my  @ccc=split/\,/,$HashConfi_ref->{$Level}{"track_geom_shape"};
					foreach my $k (0..$#ccc)
					{
						if ($ccc[$k]<14)
						{				
							$shapeType[$k]=$ccc[$k];
						}
					}
				}
				my %Col2Shape=();
				if ($HashConfi_ref->{$Level}{"colormap_legend_show"}==0   ||   $HashConfi_ref->{$Level}{"colormap_legend_sizeratio"}<=0 )
				{
					foreach my $k (0..$GradientSteps)
					{
						$Col2Shape{"$ColorGradientArray[$k]"}=$shapeType[$k];
					}
				}
				else
				{
					foreach my $k (0..$GradientSteps)
					{
						$YY1= $HashConfi_ref->{"global"}{"canvas_margin_top"}+$LegendOffsetRatio*$Bodyheight+$LevelCorGra*$k+$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
						$YY2=$YY1+$LevelCorGra;
						SVGgetShape($XX1,$YY2-$LevelCorGra*0.5,$LevelCorGra*0.5,$shapeType[$k],$ColorGradientArray[$k],$svg);
						$Col2Shape{"$ColorGradientArray[$k]"}=$shapeType[$k];
						$svg->text('text-anchor','middle','x',$XX2+length($ValueLabelsGradient[$k])+$LevelCorGra*1.88,'y',$YY2,'-cdata',"$ValueLabelsGradient[$k]",'font-family','Arial','font-size',$LevelCorGra);
					}
				}


				my $NowPlot=$PlotInfo->[0];
				my $FileNow=$NowPlot->[0];
				my $CoumnNow=$NowPlot->[1];
				my $StartCount=0;
				if  ($FileData_ref->[$FileNow][0][0] =~s/#/#/) 
				{
					$StartCount=1;
				}
				my %Uniq=();
				for ( ; $StartCount<$FileRow_ref->[$FileNow]; $StartCount++)
				{
					my $Value=$FileData_ref->[$FileNow][$StartCount][$CoumnNow];
					next if  ($Value eq "NA");
					$Value=LocalUtils::CheckValueNow($HashConfi_ref,$Level,$Value);

					my $ThisChrName=$FileData_ref->[$FileNow][$StartCount][0];
					next if (!exists $hashYY1{$ThisChrName} ) ;	
					my $StartSite=$FileData_ref->[$FileNow][$StartCount][1];
					my $EndSite=$FileData_ref->[$FileNow][$StartCount][2];
					my $YY1=$hashYY1{$ThisChrName}{$Level};
					my $YY2=$hashYY2{$ThisChrName}{$Level};
					if ($HashConfi_ref->{$Level}{"IsNumber"}==1 )
					{
						$YY1=sprintf ("%.1f",$YY2-($YY2-$YY1)*($Value-$HashConfi_ref->{$Level}{"Ymin"})/$MaxDiffValue);
					}
					else
					{
						$YY1=($YY1+$YY2)*0.5;
					}
					my $XX1=sprintf ("%.1f",($StartSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$Level});
					my $shapeT=$Col2Shape{$ValueToColor{$Value}};
					my $key=$XX1."_".$YY1."_$shapeT";
					next if (exists $Uniq{$key});
					if (exists $ValueToCustomColor_ref->{$Value} ) {$ValueToColor{$Value}=$ValueToCustomColor_ref->{$Value};}
					SVGgetShape($XX1,$YY1,$cirsize,$shapeT,$ValueToColor{$Value},$svg);
					$Uniq{$key}=1;
				}
			}
			else
			{			
				my $NumGradien=$NumPlotArry;

				if (! exists $HashConfi_ref->{$Level}{"colormap_brewer_name"} )
				{			
					my @StartRGB;
					($StartRGB[0],$StartRGB[1],$StartRGB[2] )=HTML2RGB($HashConfi_ref->{$Level}{"colormap_low_color"});
					my @EndRGB;
					($EndRGB[0],$EndRGB[1],$EndRGB[2])=HTML2RGB($HashConfi_ref->{$Level}{"colormap_high_color"});
					my @MidRGB;
					($MidRGB[0],$MidRGB[1],$MidRGB[2])=HTML2RGB($HashConfi_ref->{$Level}{"colormap_mid_color"});

					@ColorGradientArray = ();
  					LocalUtils::generate_gradient_colors(\@StartRGB, \@MidRGB, \@EndRGB, $NumGradien, \@ColorGradientArray);

					$ColorGradientArray[$NumPlotArry]=$HashConfi_ref->{$Level}{"colormap_high_color"};
					if ($NumPlotArry==2) {$ColorGradientArray[1]=$HashConfi_ref->{$Level}{"colormap_high_color"};}
				}
				else
				{
					@ColorGradientArray=();
					my $ColFlag=$HashConfi_ref->{$Level}{"colormap_brewer_name"};
					GetColGradien($ColFlag,$NumGradien,\@ColorGradientArray,$HashConfi_ref);
					if (exists  $HashConfi_ref->{$Level}{"colormap_reverse"})
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
				}


				my @shapeType=();
				foreach my $kk (1..$NumPlotArry)
				{
					my $k=$kk-1;
					my $Type= $k % 14;
					$shapeType[$k]=$Type;
				}

				if (exists $HashConfi_ref->{$Level}{"track_geom_shape"} )
				{
					my  @ccc=split/\,/,$HashConfi_ref->{$Level}{"track_geom_shape"};
					foreach my $k (0..$#ccc)
					{
						if ($ccc[$k]<14)
						{				
							$shapeType[$k]=$ccc[$k];
						}
					}
				}

				foreach my $k (1..$NumPlotArry)
				{
					my	$NowPlot=$PlotInfo->[$k-1];
					my  $FileNow=$NowPlot->[0];
					my	$CoumnNow=$NowPlot->[1];
					my  $StartCount=0;
					my  $shapeT=$shapeType[$k-1];
					$ValueLabelsGradient[$k-1]="$FileData_ref->[$FileNow][0][$CoumnNow]";

					$XX1=$HashConfi_ref->{"global"}{"canvas_margin_left"}+$HashConfi_ref->{"global"}{"canvas_body"}+($Level-1)*$LevelCorGra*4.5+$HashConfi_ref->{$Level}{"colormap_legend_shift_x"}+$all_chromosomes_spacing;
					$XX2=$XX1+$LevelCorGra;
					$YY1= $HashConfi_ref->{"global"}{"canvas_margin_top"}+$LegendOffsetRatio*$Bodyheight+$LevelCorGra*($k-1)+$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
					$YY2=$YY1+$LevelCorGra;
					if ($HashConfi_ref->{$Level}{"colormap_legend_show"}==0   ||   $HashConfi_ref->{$Level}{"colormap_legend_sizeratio"}<=0 )
					{

					}
					else
					{
						SVGgetShape($XX1,$YY2-$LevelCorGra*0.5,$LevelCorGra*0.5,$shapeT,$ColorGradientArray[$k-1],$svg);
						$svg->text('text-anchor','middle','x',$XX2+length($ValueLabelsGradient[$k-1])+$LevelCorGra*1.88,'y',$YY2,'-cdata',"$ValueLabelsGradient[$k-1]",'font-family','Arial','font-size',$LevelCorGra);
					}


					if  ($FileData_ref->[$FileNow][0][0] =~s/#/#/) 
					{
						$StartCount=1;
					}
					my %Uniq=();
					for ( ; $StartCount<$FileRow_ref->[$FileNow]; $StartCount++)
					{
						my $Value=$FileData_ref->[$FileNow][$StartCount][$CoumnNow];
						next if  ($Value eq "NA");
						$Value=LocalUtils::CheckValueNow($HashConfi_ref,$Level,$Value);

						my $ThisChrName=$FileData_ref->[$FileNow][$StartCount][0];
						next if (!exists $hashYY1{$ThisChrName} ) ;	
						my $StartSite=$FileData_ref->[$FileNow][$StartCount][1];
						my $EndSite=$FileData_ref->[$FileNow][$StartCount][2];
						my $YY1=$hashYY1{$ThisChrName}{$Level};
						my $YY2=$hashYY2{$ThisChrName}{$Level};
						if ($HashConfi_ref->{$Level}{"IsNumber"}==1 )
						{
							$YY1=sprintf ("%.1f",$YY2-($YY2-$YY1)*($Value-$HashConfi_ref->{$Level}{"Ymin"})/$MaxDiffValue);
						}
						else
						{
							$YY1=($YY1+$YY2)*0.5;
						}
						my $XX1=sprintf ("%.1f",($StartSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$Level});
						my $key=$XX1."_".$YY1."_$shapeT";
						next if (exists $Uniq{$key});
						SVGgetShape($XX1,$YY1,$cirsize,$shapeT,$ColorGradientArray[$k-1],$svg);
						$Uniq{$key}=1;
					}
				}
			}


			if (exists $HashConfi_ref->{$Level}{"cutoff_y"})
			{
				my $Value=$HashConfi_ref->{$Level}{"cutoff_y"};
				if (($Value < $HashConfi_ref->{$Level}{"Ymax"})  &&  ( $Value >  $HashConfi_ref->{$Level}{"Ymin"}) )
				{
					my $HHstrokewidth=$HashConfi_ref->{$Level}{"stroke-width"};				
					my $AA=$HHstrokewidth*3; my $BB=$HHstrokewidth*2;
					my $corCutline="red";  if  (exists $HashConfi_ref->{$Level}{"cutoff_color"}) {$corCutline=$HashConfi_ref->{$Level}{"cutoff_color"};}

					foreach my $thisChr (0..$#$ChrArry_ref)
					{
						my $ThisChrName=$ChrArry_ref->[$thisChr];
						my $XX1=sprintf ("%.1f",$hashXX1{$ThisChrName}{$Level});
						my $XX2=sprintf ("%.1f",($hashChr_ref->{$ThisChrName}/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$Level});
						my $YY1=$hashYY1{$ThisChrName}{$Level};
						my $YY2=$hashYY2{$ThisChrName}{$Level};
						my $labYY=$YY2-($YY2-$YY1)*($Value-$HashConfi_ref->{$Level}{"Ymin"})/$MaxDiffValue;
						$svg->line('x1',$XX1,'y1',$labYY,'x2',$XX2,'y2',$labYY,'stroke',$corCutline,'stroke-width',$HHstrokewidth,'stroke-dasharray',"$AA $BB");
					}
				}
			}
			if (exists $HashConfi_ref->{$Level}{"cutoff1_y"})
			{
				my $Value=$HashConfi_ref->{$Level}{"cutoff1_y"};
				if (($Value < $HashConfi_ref->{$Level}{"Ymax"})  &&  ( $Value >  $HashConfi_ref->{$Level}{"Ymin"}) )
				{
					my $HHstrokewidth=$HashConfi_ref->{$Level}{"stroke-width"};				
					my $AA=$HHstrokewidth*3; my $BB=$HHstrokewidth*2;
					my $corCutline="red";  if  (exists $HashConfi_ref->{$Level}{"cutoff1_color"}) {$corCutline=$HashConfi_ref->{$Level}{"cutoff1_color"};}

					foreach my $thisChr (0..$#$ChrArry_ref)
					{
						my $ThisChrName=$ChrArry_ref->[$thisChr];
						my $XX1=sprintf ("%.1f",$hashXX1{$ThisChrName}{$Level});
						my $XX2=sprintf ("%.1f",($hashChr_ref->{$ThisChrName}/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$Level});
						my $YY1=$hashYY1{$ThisChrName}{$Level};
						my $YY2=$hashYY2{$ThisChrName}{$Level};
						my $labYY=$YY2-($YY2-$YY1)*($Value-$HashConfi_ref->{$Level}{"Ymin"})/$MaxDiffValue;
						$svg->line('x1',$XX1,'y1',$labYY,'x2',$XX2,'y2',$labYY,'stroke',$corCutline,'stroke-width',$HHstrokewidth,'stroke-dasharray',"$AA $BB");
					}
				}
			}

			if (exists $HashConfi_ref->{$Level}{"cutoff2_y"})
			{
				my $Value=$HashConfi_ref->{$Level}{"cutoff2_y"};
				if (($Value < $HashConfi_ref->{$Level}{"Ymax"})  &&  ( $Value >  $HashConfi_ref->{$Level}{"Ymin"}) )
				{
					my $HHstrokewidth=$HashConfi_ref->{$Level}{"stroke-width"};				
					my $AA=$HHstrokewidth*3; my $BB=$HHstrokewidth*2;
					my $corCutline="red";  if  (exists $HashConfi_ref->{$Level}{"cutoff2_color"}) {$corCutline=$HashConfi_ref->{$Level}{"cutoff2_color"};}

					foreach my $thisChr (0..$#$ChrArry_ref)
					{
						my $ThisChrName=$ChrArry_ref->[$thisChr];
						my $XX1=sprintf ("%.1f",$hashXX1{$ThisChrName}{$Level});
						my $XX2=sprintf ("%.1f",($hashChr_ref->{$ThisChrName}/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$Level});
						my $YY1=$hashYY1{$ThisChrName}{$Level};
						my $YY2=$hashYY2{$ThisChrName}{$Level};
						my $labYY=$YY2-($YY2-$YY1)*($Value-$HashConfi_ref->{$Level}{"Ymin"})/$MaxDiffValue;
						$svg->line('x1',$XX1,'y1',$labYY,'x2',$XX2,'y2',$labYY,'stroke',$corCutline,'stroke-width',$HHstrokewidth,'stroke-dasharray',"$AA $BB");
					}
				}
			}




		}
		elsif (	($HashConfi_ref->{$Level}{"plot_type"}  eq  "text" )	  )
		{

			if ($NumPlotArry>1)
			{
				print "Error:\tFor -PType txt  one Level [$Level] only One Plot,you can modify to add the Level for it or change the -PType\n";
				for (my $i=0; $i<$NumPlotArry; $i++)
				{
					my $NowPlot=$PlotInfo->[$i];
					print "\t\tFile$NowPlot->[0]\tCoumn$NowPlot->[1]\n";
				}
				exit;
			}

			$YY1=$HashConfi_ref->{"global"}{"canvas_margin_top"}+$LegendOffsetRatio*$Bodyheight+$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
			$YY2=$YY1+$LevelCorGra*($GradientSteps+1);
			$XX1=$HashConfi_ref->{"global"}{"canvas_margin_left"}+$HashConfi_ref->{"global"}{"canvas_body"}+($Level-1)*$LevelCorGra*4.5+$HashConfi_ref->{$Level}{"colormap_legend_shift_x"};
			$XX2=$XX1+$LevelCorGra;
			if ($HashConfi_ref->{$Level}{"colormap_legend_show"}==0   ||   $HashConfi_ref->{$Level}{"colormap_legend_sizeratio"}<=0 )
			{
			}
			else
			{
				foreach my $k (0..$GradientSteps)
				{
					$YY1= $HashConfi_ref->{"global"}{"canvas_margin_top"}+$LegendOffsetRatio*$Bodyheight+$LevelCorGra*$k+$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
					$YY2=$YY1+$LevelCorGra;
					$svg->text('text-anchor','middle','x',$XX1+length($ValueLabelsGradient[$k])+$LevelCorGra*1.88,'y',$YY2,'-cdata',"$ValueLabelsGradient[$k]",'font-family','Arial','font-size',$LevelCorGra,'stroke',$ColorGradientArray[$k]);
				}
			}



			my $NowPlot=$PlotInfo->[0];
			my $FileNow=$NowPlot->[0];
			my $CoumnNow=$NowPlot->[1];
			my $StartCount=0;
			if  ($FileData_ref->[$FileNow][0][0] =~s/#/#/)
			{
				$StartCount=1;
			}
			my $text_font_size=$fontsize*0.5;
			if (exists $HashConfi_ref->{$Level}{"text-font-size"})
			{
				$text_font_size=$HashConfi_ref->{$Level}{"text-font-size"};
			}
			if (exists $HashConfi_ref->{$Level}{"track_text_size"})
			{
				$text_font_size=$text_font_size*$HashConfi_ref->{$Level}{"track_text_size"};
			}
			my $TextAnchor="middle"; 
			if (exists $HashConfi_ref->{$Level}{"track_text_anchor"})
			{
				$TextAnchor=$HashConfi_ref->{$Level}{"track_text_anchor"};
			}

			for ( ; $StartCount<$FileRow_ref->[$FileNow]; $StartCount++)
			{
				my $Value=$FileData_ref->[$FileNow][$StartCount][$CoumnNow];
				next if  ($Value eq "NA");
				$Value=LocalUtils::CheckValueNow($HashConfi_ref,$Level,$Value);

				my $ThisChrName="XXNAX";my $StartSite;my $EndSite;my $LevelV2;

				$LevelV2=$FileData_ref->[$FileNow][$StartCount][0];
				if (exists $GenomeFlag{$LevelV2})
				{
					$LevelV2=~s/Ref//g;
					$ThisChrName=$FileData_ref->[$FileNow][$StartCount][1];
					$StartSite=$FileData_ref->[$FileNow][$StartCount][2];
					$EndSite=$FileData_ref->[$FileNow][$StartCount][3];
				}
				else
				{
					if ( (!exists $SameChrName{$LevelV2})  &&  ( exists $ChrName2DiffGenome{$LevelV2}) )
					{
						$ThisChrName=$LevelV2;
						$LevelV2=$ChrName2DiffGenome{$ThisChrName} ;
						$StartSite=$FileData_ref->[$FileNow][$StartCount][1];
						$EndSite=$FileData_ref->[$FileNow][$StartCount][2];
					}
					elsif ( (exists $SameChrName{$LevelV2})  &&  ( exists $ChrName2DiffGenome{$LevelV2}) )
					{
						print "The chromosome name [$LevelV2] exists on both genomes Ref [$SameChrName{$LevelV2}], and it is impossible to distinguish which one, so skip this line\nYou can add Flag [RefX]  X=[$SameChrName{$LevelV2}] to the previous column of this row of data to distinguish\n";
					}
				}



				next if (!exists $hashYY1{$ThisChrName} ) ;
				if (exists $ReverseChr{$ThisChrName})
				{
					my $TS=$ReverseChr{$ThisChrName}-$EndSite;
					my $TE=$ReverseChr{$ThisChrName}-$StartSite;
					$StartSite=$TS;
					$EndSite=$TE;
				}


				$YY1=$hashYY1{$ThisChrName}{$LevelV2};
				$YY2=$hashYY2{$ThisChrName}{$LevelV2};
				$XX1=sprintf ("%.1f",($StartSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$LevelV2});
				if (exists $ValueToCustomColor_ref->{$Value} ) {$ValueToColor{$Value}=$ValueToCustomColor_ref->{$Value};}

				if ($HashConfi_ref->{$Level}{"track_text_angle"}!=0) 
				{		
					my $Rotate=$HashConfi_ref->{$Level}{"track_text_angle"};
					$YY1=$YY1+($YY2-$YY1)*3/5;
					$svg->text('text-anchor',$TextAnchor,'x',$XX1,'y',$YY1,'-cdata',"$Value",'fill',$ValueToColor{$Value},'font-family',$HashConfi_ref->{$Level}{"font-family"},'font-size',$text_font_size,'transform',"rotate($Rotate,$XX1,$YY1)");
				}
				else
				{
					$svg->text('text-anchor',$TextAnchor,'x',$XX1,'y',$YY2,'-cdata',"$Value",'fill',$ValueToColor{$Value},'font-family',$HashConfi_ref->{$Level}{"font-family"},'font-size',$text_font_size);
				}
			}
		}
		elsif (( $HashConfi_ref->{$Level}{"plot_type"}  eq  "lines" )  || ( $HashConfi_ref->{$Level}{"plot_type"}  eq  "line" ))
		{

			if ( (exists $HashConfi_ref->{$Level}{"yaxis_tick_show"} )  && ( $HashConfi_ref->{$Level}{"yaxis_tick_show"} >0 ) )
			{
				my $StartYLevel=sprintf ($Precision,$HashConfi_ref->{$Level}{"Ymin"}*1.0);
				my $EndYLevel=sprintf ($Precision,$HashConfi_ref->{$Level}{"Ymax"}*1.0);
				my $countTmpChr=$#$ChrArry_ref;
				if ( $HashConfi_ref->{"global"}{"chr_orientation"} ne "vertical" )
				{
					$countTmpChr=0;
				}
				foreach my $thisChr (0..$countTmpChr)
				{
					my $ThisChrName=$ChrArry_ref->[$thisChr];
					my $XX2=$HashConfi_ref->{"global"}{"canvas_margin_left"}-$fontsize*0.5;
					my $YY1=$hashYY1{$ThisChrName}{$Level}+$fontsize*0.1;
					my $YY2=$hashYY2{$ThisChrName}{$Level}-$fontsize*0.1;
					$svg->text('text-anchor','middle','x',$XX2,'y',$YY2,'-cdata',$StartYLevel,'font-family',$HashConfi_ref->{"global"}{"font-family"},'font-size',$fontsize*0.32);
					$svg->text('text-anchor','middle','x',$XX2,'y',$YY1,'-cdata',$EndYLevel,'font-family',$HashConfi_ref->{"global"}{"font-family"},'font-size',$fontsize*0.32);
				}
			}	



			if ( !exists $HashConfi_ref->{$Level}{"colormap_brewer_name"})
			{
				my @StartRGB;
				($StartRGB[0],$StartRGB[1],$StartRGB[2] )=HTML2RGB($HashConfi_ref->{$Level}{"colormap_low_color"});
				my @EndRGB;
				($EndRGB[0],$EndRGB[1],$EndRGB[2])=HTML2RGB($HashConfi_ref->{$Level}{"colormap_high_color"});
				my @MidRGB;
				($MidRGB[0],$MidRGB[1],$MidRGB[2])=HTML2RGB($HashConfi_ref->{$Level}{"colormap_mid_color"});
				if  ($NumGradien!=1)
				{
					@ColorGradientArray = ();
  					LocalUtils::generate_gradient_colors(\@StartRGB, \@MidRGB, \@EndRGB, $NumGradien, \@ColorGradientArray);
				}
				else
				{
					$ColorGradientArray[0]=$HashConfi_ref->{$Level}{"colormap_low_color"};
				}
				$ColorGradientArray[$NumPlotArry]=$HashConfi_ref->{$Level}{"colormap_high_color"};
				if  ($NumPlotArry==2) {$ColorGradientArray[1]=$HashConfi_ref->{$Level}{"colormap_high_color"};}
			}
			else
			{
				@ColorGradientArray=();
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
			}


			my $MaxDiffValue=$HashConfi_ref->{$Level}{"Ymax"}-$HashConfi_ref->{$Level}{"Ymin"};
			my $strokewidthV2=$HashConfi_ref->{"ALL"}{"stroke-width"}*0.88;
			if  (exists  $HashConfi_ref->{$Level}{"stroke-width"} ) {$strokewidthV2= $HashConfi_ref->{$Level}{"stroke-width"} ;}
			foreach my $tmpkk (1..$NumPlotArry)
			{
				my  $ThisBoxbin=$tmpkk-1;
				my	$NowPlot=$PlotInfo->[$ThisBoxbin];
				my  $FileNow=$NowPlot->[0];
				my	$CoumnNow=$NowPlot->[1];
				my  $StartCount=0;
				$ValueLabelsGradient[$ThisBoxbin]="$FileData_ref->[$FileNow][0][$CoumnNow]";
				$XX1=$HashConfi_ref->{"global"}{"canvas_margin_left"}+$HashConfi_ref->{"global"}{"canvas_body"}+($Level-1)*$LevelCorGra*4.5+$HashConfi_ref->{$Level}{"colormap_legend_shift_x"};
				$XX2=$XX1+$LevelCorGra;
				$YY1= $HashConfi_ref->{"global"}{"canvas_margin_top"}+$LegendOffsetRatio*$Bodyheight+$LevelCorGra*$tmpkk+$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
				$YY2=$YY1+$LevelCorGra;
				if ($HashConfi_ref->{$Level}{"colormap_legend_show"}==0   ||   $HashConfi_ref->{$Level}{"colormap_legend_sizeratio"}<=0 )
				{

				}
				else
				{
					$svg->line('x1',$XX1,'y1',$YY1,'x2',$XX2,'y2',$YY2,'stroke',$ColorGradientArray[$ThisBoxbin],'stroke-width',$HashConfi_ref->{"ALL"}{"stroke-width"});
					$svg->text('text-anchor','middle','x',$XX2+length($ValueLabelsGradient[$ThisBoxbin])+$LevelCorGra*1.88,'y',$YY2,'-cdata',"$ValueLabelsGradient[$ThisBoxbin]",'font-family','Arial','font-size',$LevelCorGra);
				}



				if ($FileData_ref->[$FileNow][0][0] =~s/#/#/)
				{
					$StartCount=1;
				}
				my $FirstPoint=1;
				my $pointAX; 
				my $pointAY;
				my $ChrThisNow="NA";

				for ( ; $StartCount<$FileRow_ref->[$FileNow]; $StartCount++)
				{

					my $Value=$FileData_ref->[$FileNow][$StartCount][$CoumnNow];
					if ($Value eq "NA")
					{
						$FirstPoint=1;
						next;
					}

					$Value=LocalUtils::CheckValueNow($HashConfi_ref,$Level,$Value);

					my $ThisChrName="XXNAX";my $StartSite;my $EndSite;my $LevelV2;

					$LevelV2=$FileData_ref->[$FileNow][$StartCount][0];
					if (exists $GenomeFlag{$LevelV2})
					{
						$LevelV2=~s/Ref//g;
						$ThisChrName=$FileData_ref->[$FileNow][$StartCount][1];
						$StartSite=$FileData_ref->[$FileNow][$StartCount][2];
						$EndSite=$FileData_ref->[$FileNow][$StartCount][3];
					}
					else
					{
						if ( (!exists $SameChrName{$LevelV2})  &&  ( exists $ChrName2DiffGenome{$LevelV2}) )
						{
							$ThisChrName=$LevelV2;
							$LevelV2=$ChrName2DiffGenome{$ThisChrName} ;
							$StartSite=$FileData_ref->[$FileNow][$StartCount][1];
							$EndSite=$FileData_ref->[$FileNow][$StartCount][2];
						}
						elsif ( (exists $SameChrName{$LevelV2})  &&  ( exists $ChrName2DiffGenome{$LevelV2}) )
						{
							print "The chromosome name [$LevelV2] exists on both genomes Ref [$SameChrName{$LevelV2}], and it is impossible to distinguish which one, so skip this line\nYou can add Flag [RefX]  X=[$SameChrName{$LevelV2}] to the previous column of this row of data to distinguish\n";
						}
					}



					next if (!exists $hashYY1{$ThisChrName} ) ;
					if (exists $ReverseChr{$ThisChrName})
					{
						my $TS=$ReverseChr{$ThisChrName}-$EndSite;
						my $TE=$ReverseChr{$ThisChrName}-$StartSite;
						$StartSite=$TS;
						$EndSite=$TE;
					}


					$YY1=$hashYY1{$ThisChrName}{$LevelV2};
					$YY2=$hashYY2{$ThisChrName}{$LevelV2};
					$YY1=$YY2-($YY2-$YY1)*($Value-$HashConfi_ref->{$Level}{"Ymin"})/$MaxDiffValue;
					$XX1=sprintf ("%.1f",($StartSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$LevelV2});

					if (($FirstPoint==1)   || ($ChrThisNow ne  $ThisChrName ) )
					{
						$pointAX=$XX1;
						$pointAY=$YY1;
						$ChrThisNow=$ThisChrName;
						$FirstPoint=0;
						next;
					}
					$svg->line('x1',$pointAX,'y1',$pointAY,'x2',$XX1,'y2',$YY1,'stroke',$ColorGradientArray[$ThisBoxbin],'stroke-width',$strokewidthV2);
					$pointAX=$XX1;
					$pointAY=$YY1;
				}
			}
			if (exists $HashConfi_ref->{$Level}{"cutoff_y"})
			{
				my $Value=$HashConfi_ref->{$Level}{"cutoff_y"};
				my $HHstrokewidth=$HashConfi_ref->{$Level}{"stroke-width"};
				my $MaxDiffValue=$HashConfi_ref->{$Level}{"Ymax"}-$HashConfi_ref->{$Level}{"Ymin"};
				if (($Value < $HashConfi_ref->{$Level}{"Ymax"})  &&  ( $Value >  $HashConfi_ref->{$Level}{"Ymin"}) )
				{
					my $AA=$HHstrokewidth*3; my $BB=$HHstrokewidth*2;
					my $corCutline="red";  if  (exists $HashConfi_ref->{$Level}{"cutoff_color"}) {$corCutline=$HashConfi_ref->{$Level}{"cutoff_color"};}
					foreach my $thisChr (0..$#$ChrArry_ref)
					{
						my $ThisChrName=$ChrArry_ref->[$thisChr];
						my $XX1=sprintf ("%.1f",$hashXX1{$ThisChrName}{$Level});
						my $XX2=sprintf ("%.1f",($hashChr_ref->{$ThisChrName}/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$Level});
						my $YY1=$hashYY1{$ThisChrName}{$Level};
						my $YY2=$hashYY2{$ThisChrName}{$Level};
						my $labYY=$YY2-($YY2-$YY1)*($Value-$HashConfi_ref->{$Level}{"Ymin"})/$MaxDiffValue;
						$svg->line('x1',$XX1,'y1',$labYY,'x2',$XX2,'y2',$labYY,'stroke',$corCutline,'stroke-width',$HHstrokewidth,'stroke-dasharray',"$AA $BB");
					}
				}
			}

			if (exists $HashConfi_ref->{$Level}{"cutoff1_y"})
			{
				my $Value=$HashConfi_ref->{$Level}{"cutoff1_y"};
				my $HHstrokewidth=$HashConfi_ref->{$Level}{"stroke-width"};
				my $MaxDiffValue=$HashConfi_ref->{$Level}{"Ymax"}-$HashConfi_ref->{$Level}{"Ymin"};
				if (($Value < $HashConfi_ref->{$Level}{"Ymax"})  &&  ( $Value >  $HashConfi_ref->{$Level}{"Ymin"}) )
				{
					my $AA=$HHstrokewidth*3; my $BB=$HHstrokewidth*2;
					my $corCutline="red";  if  (exists $HashConfi_ref->{$Level}{"cutoff1_color"}) {$corCutline=$HashConfi_ref->{$Level}{"cutoff1_color"};}
					foreach my $thisChr (0..$#$ChrArry_ref)
					{
						my $ThisChrName=$ChrArry_ref->[$thisChr];
						my $XX1=sprintf ("%.1f",$hashXX1{$ThisChrName}{$Level});
						my $XX2=sprintf ("%.1f",($hashChr_ref->{$ThisChrName}/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$Level});
						my $YY1=$hashYY1{$ThisChrName}{$Level};
						my $YY2=$hashYY2{$ThisChrName}{$Level};
						my $labYY=$YY2-($YY2-$YY1)*($Value-$HashConfi_ref->{$Level}{"Ymin"})/$MaxDiffValue;
						$svg->line('x1',$XX1,'y1',$labYY,'x2',$XX2,'y2',$labYY,'stroke',$corCutline,'stroke-width',$HHstrokewidth,'stroke-dasharray',"$AA $BB");
					}
				}
			}


			if (exists $HashConfi_ref->{$Level}{"cutoff2_y"})
			{
				my $Value=$HashConfi_ref->{$Level}{"cutoff2_y"};
				my $HHstrokewidth=$HashConfi_ref->{$Level}{"stroke-width"};
				my $MaxDiffValue=$HashConfi_ref->{$Level}{"Ymax"}-$HashConfi_ref->{$Level}{"Ymin"};
				if (($Value < $HashConfi_ref->{$Level}{"Ymax"})  &&  ( $Value >  $HashConfi_ref->{$Level}{"Ymin"}) )
				{
					my $AA=$HHstrokewidth*3; my $BB=$HHstrokewidth*2;
					my $corCutline="red";  if  (exists $HashConfi_ref->{$Level}{"cutoff2_color"}) {$corCutline=$HashConfi_ref->{$Level}{"cutoff2_color"};}
					foreach my $thisChr (0..$#$ChrArry_ref)
					{
						my $ThisChrName=$ChrArry_ref->[$thisChr];
						my $XX1=sprintf ("%.1f",$hashXX1{$ThisChrName}{$Level});
						my $XX2=sprintf ("%.1f",($hashChr_ref->{$ThisChrName}/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$Level});
						my $YY1=$hashYY1{$ThisChrName}{$Level};
						my $YY2=$hashYY2{$ThisChrName}{$Level};
						my $labYY=$YY2-($YY2-$YY1)*($Value-$HashConfi_ref->{$Level}{"Ymin"})/$MaxDiffValue;
						$svg->line('x1',$XX1,'y1',$labYY,'x2',$XX2,'y2',$labYY,'stroke',$corCutline,'stroke-width',$HHstrokewidth,'stroke-dasharray',"$AA $BB");
					}
				}
			}







		}
		elsif (( $HashConfi_ref->{$Level}{"plot_type"}  eq  "ridgeline" ) )
		{

			if ( (exists $HashConfi_ref->{$Level}{"yaxis_tick_show"} )  && ( $HashConfi_ref->{$Level}{"yaxis_tick_show"} >0 ) )
			{
				my $StartYLevel=sprintf ($Precision,$HashConfi_ref->{$Level}{"Ymin"}*1.0);
				my $EndYLevel=sprintf ($Precision,$HashConfi_ref->{$Level}{"Ymax"}*1.0);
				my $countTmpChr=$#$ChrArry_ref;
				if ( $HashConfi_ref->{"global"}{"chr_orientation"} ne "vertical" )
				{
					$countTmpChr=0;
				}
				foreach my $thisChr (0..$countTmpChr)
				{
					my $ThisChrName=$ChrArry_ref->[$thisChr];
					my $XX2=$HashConfi_ref->{"global"}{"canvas_margin_left"}-$fontsize*0.5;
					my $YY1=$hashYY1{$ThisChrName}{$Level}+$fontsize*0.1;
					my $YY2=$hashYY2{$ThisChrName}{$Level}-$fontsize*0.1;
					$svg->text('text-anchor','middle','x',$XX2,'y',$YY2,'-cdata',$StartYLevel,'font-family',$HashConfi_ref->{"global"}{"font-family"},'font-size',$fontsize*0.32);
					$svg->text('text-anchor','middle','x',$XX2,'y',$YY1,'-cdata',$EndYLevel,'font-family',$HashConfi_ref->{"global"}{"font-family"},'font-size',$fontsize*0.32);
				}
			}	



			if ( !exists $HashConfi_ref->{$Level}{"colormap_brewer_name"})
			{
				my @StartRGB;
				($StartRGB[0],$StartRGB[1],$StartRGB[2] )=HTML2RGB($HashConfi_ref->{$Level}{"colormap_low_color"});
				my @EndRGB;
				($EndRGB[0],$EndRGB[1],$EndRGB[2])=HTML2RGB($HashConfi_ref->{$Level}{"colormap_high_color"});
				my @MidRGB;
				($MidRGB[0],$MidRGB[1],$MidRGB[2])=HTML2RGB($HashConfi_ref->{$Level}{"colormap_mid_color"});
				if  ($NumGradien!=1)
				{
					@ColorGradientArray = ();
  					LocalUtils::generate_gradient_colors(\@StartRGB, \@MidRGB, \@EndRGB, $NumGradien, \@ColorGradientArray);
				}
				else
				{
					$ColorGradientArray[0]=$HashConfi_ref->{$Level}{"colormap_low_color"};
				}
				$ColorGradientArray[$NumPlotArry]=$HashConfi_ref->{$Level}{"colormap_high_color"};
				if  ($NumPlotArry==2) {$ColorGradientArray[1]=$HashConfi_ref->{$Level}{"colormap_high_color"};}
			}
			else
			{
				@ColorGradientArray=();
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
			}


			my $MaxDiffValue=$HashConfi_ref->{$Level}{"Ymax"}-$HashConfi_ref->{$Level}{"Ymin"};
			my $strokewidthV2=$HashConfi_ref->{"ALL"}{"stroke-width"}*0.88;
			if  (exists  $HashConfi_ref->{$Level}{"stroke-width"} ) {$strokewidthV2= $HashConfi_ref->{$Level}{"stroke-width"} ;}
			foreach my $tmpkk (1..$NumPlotArry)
			{
				my  $ThisBoxbin=$tmpkk-1;
				my	$NowPlot=$PlotInfo->[$ThisBoxbin];
				my  $FileNow=$NowPlot->[0];
				my	$CoumnNow=$NowPlot->[1];
				my  $StartCount=0;
				$ValueLabelsGradient[$ThisBoxbin]="$FileData_ref->[$FileNow][0][$CoumnNow]";
				$XX1=$HashConfi_ref->{"global"}{"canvas_margin_left"}+$HashConfi_ref->{"global"}{"canvas_body"}+($Level-1)*$LevelCorGra*4.5+$HashConfi_ref->{$Level}{"colormap_legend_shift_x"};
				$XX2=$XX1+$LevelCorGra;
				$YY1= $HashConfi_ref->{"global"}{"canvas_margin_top"}+$LegendOffsetRatio*$Bodyheight+$LevelCorGra*$tmpkk+$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
				$YY2=$YY1+$LevelCorGra;
				if ($HashConfi_ref->{$Level}{"colormap_legend_show"}==0   ||   $HashConfi_ref->{$Level}{"colormap_legend_sizeratio"}<=0 )
				{

				}
				else
				{
					$svg->line('x1',$XX1,'y1',$YY1,'x2',$XX2,'y2',$YY2,'stroke',$ColorGradientArray[$ThisBoxbin],'stroke-width',$HashConfi_ref->{"ALL"}{"stroke-width"});
					$svg->text('text-anchor','middle','x',$XX2+length($ValueLabelsGradient[$ThisBoxbin])+$LevelCorGra*1.88,'y',$YY2,'-cdata',"$ValueLabelsGradient[$ThisBoxbin]",'font-family','Arial','font-size',$LevelCorGra);
				}



				if ($FileData_ref->[$FileNow][0][0] =~s/#/#/)
				{
					$StartCount=1;
				}
				my $FirstPoint=1;
				my $pointAX; 
				my $pointAY;
				my $ChrThisNow="NA";

				for ( ; $StartCount<$FileRow_ref->[$FileNow]; $StartCount++)
				{

					my $Value=$FileData_ref->[$FileNow][$StartCount][$CoumnNow];
					if ($Value eq "NA")
					{
						$FirstPoint=1;
						next;
					}

					$Value=LocalUtils::CheckValueNow($HashConfi_ref,$Level,$Value);

					my $ThisChrName="XXNAX";my $StartSite;my $EndSite;my $LevelV2;

					$LevelV2=$FileData_ref->[$FileNow][$StartCount][0];
					if (exists $GenomeFlag{$LevelV2})
					{
						$LevelV2=~s/Ref//g;
						$ThisChrName=$FileData_ref->[$FileNow][$StartCount][1];
						$StartSite=$FileData_ref->[$FileNow][$StartCount][2];
						$EndSite=$FileData_ref->[$FileNow][$StartCount][3];
					}
					else
					{
						if ( (!exists $SameChrName{$LevelV2})  &&  ( exists $ChrName2DiffGenome{$LevelV2}) )
						{
							$ThisChrName=$LevelV2;
							$LevelV2=$ChrName2DiffGenome{$ThisChrName} ;
							$StartSite=$FileData_ref->[$FileNow][$StartCount][1];
							$EndSite=$FileData_ref->[$FileNow][$StartCount][2];
						}
						elsif ( (exists $SameChrName{$LevelV2})  &&  ( exists $ChrName2DiffGenome{$LevelV2}) )
						{
							print "The chromosome name [$LevelV2] exists on both genomes Ref [$SameChrName{$LevelV2}], and it is impossible to distinguish which one, so skip this line\nYou can add Flag [RefX]  X=[$SameChrName{$LevelV2}] to the previous column of this row of data to distinguish\n";
						}
					}



					next if (!exists $hashYY1{$ThisChrName} ) ;
					if (exists $ReverseChr{$ThisChrName})
					{
						my $TS=$ReverseChr{$ThisChrName}-$EndSite;
						my $TE=$ReverseChr{$ThisChrName}-$StartSite;
						$StartSite=$TS;
						$EndSite=$TE;
					}


					$YY1=$hashYY1{$ThisChrName}{$LevelV2};
					$YY2=$hashYY2{$ThisChrName}{$LevelV2};
					$YY1=$YY2-($YY2-$YY1)*($Value-$HashConfi_ref->{$Level}{"Ymin"})/$MaxDiffValue;
					$XX1=sprintf ("%.1f",($StartSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$LevelV2});

					if (($FirstPoint==1)   || ($ChrThisNow ne  $ThisChrName ) )
					{
						$pointAX=$XX1;
						$pointAY=$YY1;
						$ChrThisNow=$ThisChrName;
						$FirstPoint=0;
						next;
					}
					$svg->line('x1',$pointAX,'y1',$pointAY,'x2',$XX1,'y2',$YY1,'stroke',$ColorGradientArray[$ThisBoxbin],'stroke-width',$strokewidthV2);
					$path = $svg->get_path(
						x => [$pointAX, $XX1, $XX1,$pointAX],
						y => [$pointAY, $YY1, $YY2,$YY2],
						-type => 'polygon');

					$svg->polygon(
						%$path,
						style => {
							'fill' =>$ColorGradientArray[$ThisBoxbin],
							'stroke'         =>  $ColorGradientArray[$ThisBoxbin],
							'stroke-width'   =>  $strokewidthV2,
							'stroke-opacity' =>  $HashConfi_ref->{$Level}{"stroke-opacity"},
							'fill-opacity'   =>  $HashConfi_ref->{$Level}{"fill-opacity"},
						},
					);


					$pointAX=$XX1;
					$pointAY=$YY1;
				}
			}
			if (exists $HashConfi_ref->{$Level}{"cutoff_y"})
			{
				my $Value=$HashConfi_ref->{$Level}{"cutoff_y"};
				my $HHstrokewidth=$HashConfi_ref->{$Level}{"stroke-width"};
				my $MaxDiffValue=$HashConfi_ref->{$Level}{"Ymax"}-$HashConfi_ref->{$Level}{"Ymin"};
				if (($Value < $HashConfi_ref->{$Level}{"Ymax"})  &&  ( $Value >  $HashConfi_ref->{$Level}{"Ymin"}) )
				{
					my $AA=$HHstrokewidth*3; my $BB=$HHstrokewidth*2;
					my $corCutline="red";  if  (exists $HashConfi_ref->{$Level}{"cutoff_color"}) {$corCutline=$HashConfi_ref->{$Level}{"cutoff_color"};}
					foreach my $thisChr (0..$#$ChrArry_ref)
					{
						my $ThisChrName=$ChrArry_ref->[$thisChr];
						my $XX1=sprintf ("%.1f",$hashXX1{$ThisChrName}{$Level});
						my $XX2=sprintf ("%.1f",($hashChr_ref->{$ThisChrName}/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$Level});
						my $YY1=$hashYY1{$ThisChrName}{$Level};
						my $YY2=$hashYY2{$ThisChrName}{$Level};
						my $labYY=$YY2-($YY2-$YY1)*($Value-$HashConfi_ref->{$Level}{"Ymin"})/$MaxDiffValue;
						$svg->line('x1',$XX1,'y1',$labYY,'x2',$XX2,'y2',$labYY,'stroke',$corCutline,'stroke-width',$HHstrokewidth,'stroke-dasharray',"$AA $BB");
					}
				}
			}

			if (exists $HashConfi_ref->{$Level}{"cutoff1_y"})
			{
				my $Value=$HashConfi_ref->{$Level}{"cutoff1_y"};
				my $HHstrokewidth=$HashConfi_ref->{$Level}{"stroke-width"};
				my $MaxDiffValue=$HashConfi_ref->{$Level}{"Ymax"}-$HashConfi_ref->{$Level}{"Ymin"};
				if (($Value < $HashConfi_ref->{$Level}{"Ymax"})  &&  ( $Value >  $HashConfi_ref->{$Level}{"Ymin"}) )
				{
					my $AA=$HHstrokewidth*3; my $BB=$HHstrokewidth*2;
					my $corCutline="red";  if  (exists $HashConfi_ref->{$Level}{"cutoff1_color"}) {$corCutline=$HashConfi_ref->{$Level}{"cutoff1_color"};}
					foreach my $thisChr (0..$#$ChrArry_ref)
					{
						my $ThisChrName=$ChrArry_ref->[$thisChr];
						my $XX1=sprintf ("%.1f",$hashXX1{$ThisChrName}{$Level});
						my $XX2=sprintf ("%.1f",($hashChr_ref->{$ThisChrName}/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$Level});
						my $YY1=$hashYY1{$ThisChrName}{$Level};
						my $YY2=$hashYY2{$ThisChrName}{$Level};
						my $labYY=$YY2-($YY2-$YY1)*($Value-$HashConfi_ref->{$Level}{"Ymin"})/$MaxDiffValue;
						$svg->line('x1',$XX1,'y1',$labYY,'x2',$XX2,'y2',$labYY,'stroke',$corCutline,'stroke-width',$HHstrokewidth,'stroke-dasharray',"$AA $BB");
					}
				}
			}


			if (exists $HashConfi_ref->{$Level}{"cutoff2_y"})
			{
				my $Value=$HashConfi_ref->{$Level}{"cutoff2_y"};
				my $HHstrokewidth=$HashConfi_ref->{$Level}{"stroke-width"};
				my $MaxDiffValue=$HashConfi_ref->{$Level}{"Ymax"}-$HashConfi_ref->{$Level}{"Ymin"};
				if (($Value < $HashConfi_ref->{$Level}{"Ymax"})  &&  ( $Value >  $HashConfi_ref->{$Level}{"Ymin"}) )
				{
					my $AA=$HHstrokewidth*3; my $BB=$HHstrokewidth*2;
					my $corCutline="red";  if  (exists $HashConfi_ref->{$Level}{"cutoff2_color"}) {$corCutline=$HashConfi_ref->{$Level}{"cutoff2_color"};}
					foreach my $thisChr (0..$#$ChrArry_ref)
					{
						my $ThisChrName=$ChrArry_ref->[$thisChr];
						my $XX1=sprintf ("%.1f",$hashXX1{$ThisChrName}{$Level});
						my $XX2=sprintf ("%.1f",($hashChr_ref->{$ThisChrName}/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$Level});
						my $YY1=$hashYY1{$ThisChrName}{$Level};
						my $YY2=$hashYY2{$ThisChrName}{$Level};
						my $labYY=$YY2-($YY2-$YY1)*($Value-$HashConfi_ref->{$Level}{"Ymin"})/$MaxDiffValue;
						$svg->line('x1',$XX1,'y1',$labYY,'x2',$XX2,'y2',$labYY,'stroke',$corCutline,'stroke-width',$HHstrokewidth,'stroke-dasharray',"$AA $BB");
					}
				}
			}







		}



		elsif (($HashConfi_ref->{$Level}{"plot_type"}  eq  "heatmapAnimated")   ||  ($HashConfi_ref->{$Level}{"plot_type"}  eq  "highlightsAnimated"))
		{
			$YY1=$HashConfi_ref->{"global"}{"canvas_margin_top"}+$LegendOffsetRatio*$Bodyheight+$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
			$YY2=$YY1+$LevelCorGra*($GradientSteps+1);
			$XX1=$HashConfi_ref->{"global"}{"canvas_margin_left"}+$HashConfi_ref->{"global"}{"canvas_body"}+($Level-1)*$LevelCorGra*4.5+$HashConfi_ref->{$Level}{"colormap_legend_shift_x"}+$all_chromosomes_spacing;
			$XX2=$XX1+$LevelCorGra;

			if ($HashConfi_ref->{$Level}{"colormap_legend_show"}==0   ||   $HashConfi_ref->{$Level}{"colormap_legend_sizeratio"}<=0 )
			{

			}
			else
			{
				$path = $svg->get_path(
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

				foreach my $k (0..$GradientSteps)
				{
					$YY1= $HashConfi_ref->{"global"}{"canvas_margin_top"}+$LegendOffsetRatio*$Bodyheight+$LevelCorGra*$k+$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
					$YY2=$YY1+$LevelCorGra;

					$path = $svg->get_path(
						x => [$XX1, $XX1, $XX2,$XX2],
						y => [$YY1, $YY2, $YY2,$YY1],
						-type => 'polygon');

					$svg->polygon(
						%$path,
						style => {
							'fill'           => "$ColorGradientArray[$k]",
							'stroke'         => 'black',
							'stroke-width'   =>  0,
							'stroke-opacity' =>  $HashConfi_ref->{$Level}{"stroke-opacity"},
							'fill-opacity'   =>  $HashConfi_ref->{$Level}{"fill-opacity"},
						},
					);
					$svg->text('text-anchor','middle','x',$XX2+length($ValueLabelsGradient[$k])+$LevelCorGra*1.88,'y',$YY2,'-cdata',"$ValueLabelsGradient[$k]",'font-family','Arial','font-size',$LevelCorGra);
				}
			}


			my $HeatMapstrokewidth=$HashConfi_ref->{$Level}{"stroke-width"};


			my $ThisBoxbin;my $NowPlot;my $CoumnNow;my $FileNow;
			my $StartCount=0;
			my @NowPLotCoumn=();
			my $textDataLine="";
			my $textData="";
			foreach my $tmpkk (1..1)
			{
				$ThisBoxbin=$tmpkk-1;
				$NowPlot=$PlotInfo->[$ThisBoxbin];
				$FileNow=$NowPlot->[0];
				$CoumnNow=$NowPlot->[1];
				$NowPLotCoumn[$ThisBoxbin]=$CoumnNow;
				$textDataLine=$FileData_ref->[$FileNow][0][$CoumnNow];
			}

			foreach my $tmpkk (2..$NumPlotArry)
			{
				$ThisBoxbin=$tmpkk-1;
				$NowPlot=$PlotInfo->[$ThisBoxbin];
				$FileNow=$NowPlot->[0];
				$CoumnNow=$NowPlot->[1];
				$NowPLotCoumn[$ThisBoxbin]=$CoumnNow;
				$textData=$FileData_ref->[$FileNow][0][$CoumnNow];
				$textDataLine=$textDataLine.";".$textData;
			}

			if  ($FileData_ref->[$FileNow][0][0] =~s/#/#/)
			{
				$StartCount=1;
			}
			$YY2=$HashConfi_ref->{"global"}{"canvas_margin_top"}+$LegendOffsetRatio*$Bodyheight+$HashConfi_ref->{$Level}{"colormap_legend_shift_y"}-$LevelCorGra*2;
			my $textLength=$LevelCorGra*$NumPlotArry;
			$svg->text('text-anchor','start','x',$XX1,'y',$YY2,'textlength',$textLength,'-cdata',$textDataLine,'font-family','Arial','font-size',$LevelCorGra);
			$svg->rect('x',$XX1,'y',$YY2,'width',$textLength,'height',$LevelCorGra,'fill',"grey");
			my $animateTxt=$svg->text('text-anchor','start','x',$XX1,'y',$YY2+$LevelCorGra,'-cdata',"Time",'font-family','Arial','font-size',$LevelCorGra);
			$XX2=$XX1+$textLength;
			$animateTxt->animate(attributeName=>"x",from=>$XX1,to=>$XX2,begin=>"0s",dur=>"3s", repeatDur=>'indefinite',"-method"=>"animate");
			$ValueToColor{"NA"}="white";


			for ( ; $StartCount<$FileRow_ref->[$FileNow]; $StartCount++)
			{

				my $Value=$FileData_ref->[$FileNow][$StartCount][$CoumnNow];
				next if  ($Value eq "NA");
				$Value=LocalUtils::CheckValueNow($HashConfi_ref,$Level,$Value);

				my $ThisChrName=$FileData_ref->[$FileNow][$StartCount][0];
				next if (!exists $hashYY1{$ThisChrName} ) ;				
				my $StartSite=$FileData_ref->[$FileNow][$StartCount][1];
				my $EndSite=$FileData_ref->[$FileNow][$StartCount][2];
				my $YY1=$hashYY1{$ThisChrName}{$Level};
				my $YY2=$hashYY2{$ThisChrName}{$Level};
				if (exists $ValueToCustomColor_ref->{$Value} ) {$ValueToColor{$Value}=$ValueToCustomColor_ref->{$Value};}
				my $XX1=sprintf ("%.1f",($StartSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$Level});
				my $XX2=sprintf ("%.1f",($EndSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$Level});
				$path = $svg->get_path(
					x => [$XX1, $XX1, $XX2,$XX2],
					y => [$YY1, $YY2, $YY2,$YY1],
					-type => 'polygon');


				my $Tag=$svg->polygon(
					%$path,
					style => {
						'fill'           => $ValueToColor{$Value},
						'stroke'         => $ValueToColor{$Value},
						'stroke-width'   => $HeatMapstrokewidth,
						'stroke-opacity' => $HashConfi_ref->{$Level}{"stroke-opacity"},
						'fill-opacity'   => $HashConfi_ref->{$Level}{"fill-opacity"},
					},
				);

				my $animateLine=$ValueToColor{$Value};
				for (my $NowAA=$NumPlotArry-2;$NowAA>=0; $NowAA--)
				{
					$Value=$FileData_ref->[$FileNow][$StartCount][$NowPLotCoumn[$NowAA]];
					if (exists $ValueToCustomColor_ref->{$Value} ) {$ValueToColor{$Value}=$ValueToCustomColor_ref->{$Value};}
					$animateLine=$ValueToColor{$Value}.";".$animateLine;
				}
				$Tag->animate(attributeName=>"fill",values=>"$animateLine",dur=>"3s", repeatDur=>'indefinite',"-method"=>"animate");
				$Tag->animate(attributeName=>"stroke",values=>"$animateLine",dur=>"3s", repeatDur=>'indefinite',"-method"=>"animate");
			}
		}
		elsif (( $HashConfi_ref->{$Level}{"plot_type"}  eq  "histogramAnimated" )  || ( $HashConfi_ref->{$Level}{"plot_type"}  eq  "histAnimated" ))
		{
			$XX1=$HashConfi_ref->{"global"}{"canvas_margin_left"}+$HashConfi_ref->{"global"}{"canvas_body"}+($Level-1)*$LevelCorGra*4.5+$HashConfi_ref->{$Level}{"colormap_legend_shift_x"}+$all_chromosomes_spacing;
			my $ThisBoxbin;my $NowPlot;my $CoumnNow;my $FileNow;
			my $StartCount=0;
			my @NowPLotCoumn=();
			my $textDataLine="";
			my $textData="";
			foreach my $tmpkk (1..1)
			{
				$ThisBoxbin=$tmpkk-1;
				$NowPlot=$PlotInfo->[$ThisBoxbin];
				$FileNow=$NowPlot->[0];
				$CoumnNow=$NowPlot->[1];
				$NowPLotCoumn[$ThisBoxbin]=$CoumnNow;
				$textDataLine=$FileData_ref->[$FileNow][0][$CoumnNow];
			}

			foreach my $tmpkk (2..$NumPlotArry)
			{
				$ThisBoxbin=$tmpkk-1;
				$NowPlot=$PlotInfo->[$ThisBoxbin];
				$FileNow=$NowPlot->[0];
				$CoumnNow=$NowPlot->[1];
				$NowPLotCoumn[$ThisBoxbin]=$CoumnNow;
				$textData=$FileData_ref->[$FileNow][0][$CoumnNow];
				$textDataLine=$textDataLine.";".$textData;
			}

			if ($FileData_ref->[$FileNow][0][0] =~s/#/#/)
			{
				$StartCount=1;
			}


			$YY2=$HashConfi_ref->{"global"}{"canvas_margin_top"}+$LegendOffsetRatio*$Bodyheight+$HashConfi_ref->{$Level}{"colormap_legend_shift_y"}-$LevelCorGra*2;

			my $textLength=$LevelCorGra*$NumPlotArry;
			$svg->text('text-anchor','start','x',$XX1,'y',$YY2,'textlength',$textLength,'-cdata',$textDataLine,'font-family','Arial','font-size',$LevelCorGra);
			$svg->rect('x',$XX1,'y',$YY2,'width',$textLength,'height',$LevelCorGra,'fill',"grey");
			my $animateTxt=$svg->text('text-anchor','start','x',$XX1,'y',$YY2+$LevelCorGra,'-cdata',"Time",'font-family','Arial','font-size',$LevelCorGra);
			$XX2=$XX1+$textLength;
			$animateTxt->animate(attributeName=>"x",from=>$XX1,to=>$XX2,begin=>"0s",dur=>"3s", repeatDur=>'indefinite',"-method"=>"animate");
			$ValueToColor{"NA"}="white";




			$YY1=$HashConfi_ref->{"global"}{"canvas_margin_top"}+$LegendOffsetRatio*$Bodyheight+$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
			$YY2=$YY1+$LevelCorGra*($GradientSteps+1);
			$XX1=$HashConfi_ref->{"global"}{"canvas_margin_left"}+$HashConfi_ref->{"global"}{"canvas_body"}+($Level-1)*$LevelCorGra*4.5+$HashConfi_ref->{$Level}{"colormap_legend_shift_x"}+$all_chromosomes_spacing;
			$XX2=$XX1+$LevelCorGra;

			if ($HashConfi_ref->{$Level}{"colormap_legend_show"}==0   ||   $HashConfi_ref->{$Level}{"colormap_legend_sizeratio"}<=0 )
			{

			}
			else
			{
				$path = $svg->get_path(
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
				foreach my $k (0..$GradientSteps)
				{
					$YY1= $HashConfi_ref->{"global"}{"canvas_margin_top"}+$LegendOffsetRatio*$Bodyheight+$LevelCorGra*$k+$HashConfi_ref->{$Level}{"colormap_legend_shift_y"};
					$YY2=$YY1+$LevelCorGra;

					$path = $svg->get_path(
						x => [$XX1, $XX1, $XX2,$XX2],
						y => [$YY1, $YY2, $YY2,$YY1],
						-type => 'polygon');

					$svg->polygon(
						%$path,
						style => {
							'fill'           => "$ColorGradientArray[$k]",
							'stroke'         => 'black',
							'stroke-width'   =>  0,
							'stroke-opacity' =>  $HashConfi_ref->{$Level}{"stroke-opacity"},
							'fill-opacity'   =>  $HashConfi_ref->{$Level}{"fill-opacity"},
						},
					);  
					$svg->text('text-anchor','middle','x',$XX2+length($ValueLabelsGradient[$k])+$LevelCorGra*1.88,'y',$YY2,'-cdata',"$ValueLabelsGradient[$k]",'font-family','Arial','font-size',$LevelCorGra);
				}
			}

			my $MaxDiffValue=$HashConfi_ref->{$Level}{"Ymax"}-$HashConfi_ref->{$Level}{"Ymin"};
			my $HHstrokewidth=$HashConfi_ref->{$Level}{"stroke-width"};


			if ( (exists $HashConfi_ref->{$Level}{"yaxis_tick_show"} )  && ( $HashConfi_ref->{$Level}{"yaxis_tick_show"} >0 ) )
			{
				my $StartYLevel=sprintf ($Precision,$HashConfi_ref->{$Level}{"Ymin"}*1.0);
				my $EndYLevel=sprintf ($Precision,$HashConfi_ref->{$Level}{"Ymax"}*1.0);
				my $countTmpChr=$#$ChrArry_ref;
				if ( $HashConfi_ref->{"global"}{"chr_orientation"} ne "vertical" )
				{
					$countTmpChr=0;
				}
				foreach my $thisChr (0..$countTmpChr)
				{
					my $ThisChrName=$ChrArry_ref->[$thisChr];
					my $XX2=$HashConfi_ref->{"global"}{"canvas_margin_left"}-$fontsize*0.5;
					my $YY1=$hashYY1{$ThisChrName}{$Level}+$fontsize*0.1;
					my $YY2=$hashYY2{$ThisChrName}{$Level}-$fontsize*0.1;
					$svg->text('text-anchor','middle','x',$XX2,'y',$YY2,'-cdata',$StartYLevel,'font-family',$HashConfi_ref->{"global"}{"font-family"},'font-size',$fontsize*0.32);
					$svg->text('text-anchor','middle','x',$XX2,'y',$YY1,'-cdata',$EndYLevel,'font-family',$HashConfi_ref->{"global"}{"font-family"},'font-size',$fontsize*0.32);
				}
			}





			for ( ; $StartCount<$FileRow_ref->[$FileNow]; $StartCount++)
			{
				my $Value=$FileData_ref->[$FileNow][$StartCount][$CoumnNow];
				next if  ($Value eq "NA");
				$Value=LocalUtils::CheckValueNow($HashConfi_ref,$Level,$Value);

				my $ThisChrName=$FileData_ref->[$FileNow][$StartCount][0];
				next if (!exists $hashYY1{$ThisChrName} ) ;	
				my $StartSite=$FileData_ref->[$FileNow][$StartCount][1];
				my $EndSite=$FileData_ref->[$FileNow][$StartCount][2];

				my $YY1A=$hashYY1{$ThisChrName}{$Level};
				my $YY2=$hashYY2{$ThisChrName}{$Level};
				my $heightLL=0;
				if ($Value ne "NA") { $heightLL=($YY2-$YY1A)*($Value-$HashConfi_ref->{$Level}{"Ymin"})/$MaxDiffValue;}
				my $YY1=$YY2-$heightLL;

				my $XX1=sprintf ("%.1f",($StartSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$Level});
				my $XX2=sprintf ("%.1f",($EndSite/$ChrMax)*$HashConfi_ref->{"global"}{"canvas_body"}+$hashXX1{$ThisChrName}{$Level});
				my $widthLL=$XX2-$XX1;
				my $Tag=$svg->rect('x',$XX1,'y',$YY2,'width',$widthLL,'height',$heightLL,'fill',$ValueToColor{$Value},'stroke',$ValueToColor{$Value},'stroke-width',$HHstrokewidth,'stroke-opacity', $HashConfi_ref->{$Level}{"stroke-opacity"},'fill-opacity',$HashConfi_ref->{$Level}{"fill-opacity"});
				my $animateLine=$ValueToColor{$Value};
				my $YY1line=$YY1;
				my $heightLLline=$heightLL;
				for (my $NowAA=$NumPlotArry-2;$NowAA>=0; $NowAA--)
				{
					$Value=$FileData_ref->[$FileNow][$StartCount][$NowPLotCoumn[$NowAA]];
					if (exists $ValueToCustomColor_ref->{$Value} ) {$ValueToColor{$Value}=$ValueToCustomColor_ref->{$Value};}
					$animateLine=$ValueToColor{$Value}.";".$animateLine;
					$heightLL=0;
					if ($Value ne "NA") {$heightLL=($YY2-$YY1A)*($Value-$HashConfi_ref->{$Level}{"Ymin"})/$MaxDiffValue;}
					$YY1=$YY2-$heightLL;
					$YY1line=$YY1.";".$YY1line;
					$heightLLline=$heightLL.";".$heightLLline;
				}
				$Tag->animate(attributeName=>"fill",values=>"$animateLine",dur=>"3s", repeatDur=>'indefinite',"-method"=>"animate");
				$Tag->animate(attributeName=>"stroke",values=>"$animateLine",dur=>"3s", repeatDur=>'indefinite',"-method"=>"animate");
				$Tag->animate(attributeName=>"y",values=>"$YY1line",dur=>"3s", repeatDur=>'indefinite',"-method"=>"animate");
				$Tag->animate(attributeName=>"height",values=>"$heightLLline",dur=>"3s", repeatDur=>'indefinite',"-method"=>"animate");
			}
		}



	}





	return $svg ;



}

######################swimming in the sky and flying in the sea ###########################


