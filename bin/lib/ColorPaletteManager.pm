package ColorPaletteManager;

#use lib "/home/liaojing/06.BackBin/RectChr-1.39/bin/svg_kit";
use strict;
use Getopt::Long;
use FindBin qw($Bin $RealBin);
use Data::Dumper;
use Switch;
use SVG;
use base 'Exporter';
our @EXPORT_OK = qw(%MAX_COLOR_COUNT %QualColNum RGB2HTML HTML2RGB  GetColGradien SVGgetShape );


######################swimming in the sky and flying in the sea ###########################
## ASCII to integer mapping for hex color conversion
our %Asc2Int=();
$Asc2Int{0}=0;$Asc2Int{1}=1;$Asc2Int{2}=2;$Asc2Int{3}=3;$Asc2Int{4}=4;$Asc2Int{5}=5;
$Asc2Int{6}=6;$Asc2Int{7}=7;$Asc2Int{8}=8;$Asc2Int{9}=9;
$Asc2Int{'A'}=10;$Asc2Int{'B'}=11;$Asc2Int{'C'}=12;$Asc2Int{'D'}=13;$Asc2Int{'E'}=14;$Asc2Int{'F'}=15;
$Asc2Int{'a'}=10;$Asc2Int{'b'}=11;$Asc2Int{'c'}=12;$Asc2Int{'d'}=13;$Asc2Int{'e'}=14;$Asc2Int{'f'}=15;

our %Int2Asc=();
$Asc2Int{0}=0;$Asc2Int{1}=1;$Asc2Int{2}=2;$Asc2Int{3}=3;$Asc2Int{4}=4;$Asc2Int{5}=5;
$Asc2Int{6}=6;$Asc2Int{7}=7;$Asc2Int{8}=8;$Asc2Int{9}=9;
$Asc2Int{10}='A';$Asc2Int{11}='B';$Asc2Int{12}='C';$Asc2Int{13}='D';$Asc2Int{14}='E'; $Asc2Int{15}='F';


###Converts an HTML hex color string (e.g., #FF55AA) to its RGB components####

sub  HTML2RGB 
{
	my  $sColor = shift ;
	my $R=0;
	my $G=0;
	my $B=0;
	#十六进制颜色值的正则表达式
	if (($sColor =~ /^#([0-9a-fA-f]{3}|[0-9a-fA-f]{6})$/)  &&  (length ($sColor)==7))
	{
		my @temp=split //,$sColor;
		$R=$Asc2Int{$temp[1]}*16+$Asc2Int{$temp[2]};
		$G=$Asc2Int{$temp[3]}*16+$Asc2Int{$temp[4]};
		$B=$Asc2Int{$temp[5]}*16+$Asc2Int{$temp[6]};
	}
	return ($R,$G,$B);
};


###Converts an RGB value (either as a string like "rgb(255,128,0)" or "#FF55AA") into a standard HTML hex format#
sub RGB2HTML
{
	my  $sColor = shift ;
	if ( $sColor=~s/#/#/)
	{
		return $sColor;
	}
	$sColor=~s/rgb\(//;
	$sColor=~s/\)//;
	my @RGB=split/\,/,$sColor;
	my $A1=$Asc2Int{int($RGB[0]/16)};	my $A2=$Asc2Int{$RGB[0]%16};
	my $B1=$Asc2Int{int($RGB[1]/16)};	my $B2=$Asc2Int{$RGB[1]%16};
	my $C1=$Asc2Int{int($RGB[2]/16)};	my $C2=$Asc2Int{$RGB[2]%16};
	my $HTML="#$A1$A2$B1$B2$C1$C2";
	return $HTML;
}





######################swimming in the sky and flying in the sea ###########################

our %MAX_COLOR_COUNT=();
our %QualColNum=();
#### Maximum number of colors in each palette (used for validation and selection)####

$MAX_COLOR_COUNT{"Accent"}=8;  $MAX_COLOR_COUNT{"Dark2"}=8;   $MAX_COLOR_COUNT{"Paired"}=12;   $MAX_COLOR_COUNT{"Pastel1"}=9;   $MAX_COLOR_COUNT{"Pastel2"}=8;   $MAX_COLOR_COUNT{"Set1"}=9;   $MAX_COLOR_COUNT{"Set2"}=8;   $MAX_COLOR_COUNT{"Set3"}=12;
$QualColNum{"Accent"}=8; $QualColNum{"Dark2"}=8;   $QualColNum{"Paired"}=12;   $QualColNum{"Pastel1"}=9;   $QualColNum{"Pastel2"}=8;   $QualColNum{"Set1"}=9;   $QualColNum{"Set2"}=8;   $QualColNum{"Set3"}=12;


$MAX_COLOR_COUNT{"BrBG"}=11;
$MAX_COLOR_COUNT{"PRGn"}=11;
$MAX_COLOR_COUNT{"PuOr"}=11;
$MAX_COLOR_COUNT{"RdBu"}=11;
$MAX_COLOR_COUNT{"RdGy"}=11;
$MAX_COLOR_COUNT{"RdYlBu"}=11;
$MAX_COLOR_COUNT{"RdYlGn"}=11;
$MAX_COLOR_COUNT{"GnYlRd"}=11;
$MAX_COLOR_COUNT{"Spectral"}=11;
$MAX_COLOR_COUNT{"Blues"}=9;
$MAX_COLOR_COUNT{"BuGn"}=9;
$MAX_COLOR_COUNT{"BuPu"}=9;
$MAX_COLOR_COUNT{"GnBu"}=9;
$MAX_COLOR_COUNT{"Greens"}=9;
$MAX_COLOR_COUNT{"Greys"}=9;
$MAX_COLOR_COUNT{"Oranges"}=9;
$MAX_COLOR_COUNT{"OrRd"}=9;
$MAX_COLOR_COUNT{"PuBu"}=9;
$MAX_COLOR_COUNT{"PuBuGn"}=9;
$MAX_COLOR_COUNT{"PuRd"}=9;
$MAX_COLOR_COUNT{"Purples"}=9;
$MAX_COLOR_COUNT{"RdPu"}=9;
$MAX_COLOR_COUNT{"Reds"}=9;
$MAX_COLOR_COUNT{"YlGn"}=9;
$MAX_COLOR_COUNT{"YlGnBu"}=9;
$MAX_COLOR_COUNT{"YlOrBr"}=9;
$MAX_COLOR_COUNT{"YlOrRd"}=9;



###Generates a gradient color array based on the specified palette name ($Flag) and number of colors ($Num)###
sub GetColGradien
{
	my $Flag=$_[0];
	my $Num=$_[1];
	my $CorArry=$_[2];
	my $HashConfi=$_[3];

	if ($Num>255)
    {
        print "Max Gradien must < 255\t:$Num\twe change $Num --->255\n";
        $Num=255;
    }
    elsif  ($Num<1)
    {
        print "Min Gradien must >=1 \t:$Num\twe change $Num --->1\n";
        $Num=1;
    }

	if  (!exists $MAX_COLOR_COUNT{$Flag})
	{
		my $RealBin=$HashConfi->{"global"}{RealBin};
    	my $file="$RealBin/../ColorsBrewer/$Flag";
		
		open (IACC,"$file") || die "input file can't open $!";
		my $temp=0;
		while(<IACC>)
		{
        	chomp ;
        	my @inf=split ;
        	my ($R,$G,$B)=ColorPaletteManager::HTML2RGB($inf[0]);
        	my $BB="rgb($R,$G,$B)";
        	@$CorArry[$temp]=$BB;
			$temp++;
		}
		close IACC;
		$temp--;
		return $temp;
	}
	my %HashColData=();


	######################swimming in the sky and flying in the sea ###########################
	$HashColData{"Accent"}{3}{R}="127,190,253";
	$HashColData{"Accent"}{3}{G}="201,174,192";
	$HashColData{"Accent"}{3}{B}="127,212,134";
	$HashColData{"Accent"}{4}{R}="127,190,253,255";
	$HashColData{"Accent"}{4}{G}="201,174,192,255";
	$HashColData{"Accent"}{4}{B}="127,212,134,153";
	$HashColData{"Accent"}{5}{R}="127,190,253,255,56";
	$HashColData{"Accent"}{5}{G}="201,174,192,255,108";
	$HashColData{"Accent"}{5}{B}="127,212,134,153,176";
	$HashColData{"Accent"}{6}{R}="127,190,253,255,56,240";
	$HashColData{"Accent"}{6}{G}="201,174,192,255,108,2";
	$HashColData{"Accent"}{6}{B}="127,212,134,153,176,127";
	$HashColData{"Accent"}{7}{R}="127,190,253,255,56,240,191";
	$HashColData{"Accent"}{7}{G}="201,174,192,255,108,2,91";
	$HashColData{"Accent"}{7}{B}="127,212,134,153,176,127,23";
	$HashColData{"Accent"}{8}{R}="127,190,253,255,56,240,191,102";
	$HashColData{"Accent"}{8}{G}="201,174,192,255,108,2,91,102";
	$HashColData{"Accent"}{8}{B}="127,212,134,153,176,127,23,102";
	$HashColData{"Blues"}{3}{R}="222,158,49";
	$HashColData{"Blues"}{3}{G}="235,202,130";
	$HashColData{"Blues"}{3}{B}="247,225,189";
	$HashColData{"Blues"}{4}{R}="239,189,107,33";
	$HashColData{"Blues"}{4}{G}="243,215,174,113";
	$HashColData{"Blues"}{4}{B}="255,231,214,181";
	$HashColData{"Blues"}{5}{R}="239,189,107,49,8";
	$HashColData{"Blues"}{5}{G}="243,215,174,130,81";
	$HashColData{"Blues"}{5}{B}="255,231,214,189,156";
	$HashColData{"Blues"}{6}{R}="239,198,158,107,49,8";
	$HashColData{"Blues"}{6}{G}="243,219,202,174,130,81";
	$HashColData{"Blues"}{6}{B}="255,239,225,214,189,156";
	$HashColData{"Blues"}{7}{R}="239,198,158,107,66,33,8";
	$HashColData{"Blues"}{7}{G}="243,219,202,174,146,113,69";
	$HashColData{"Blues"}{7}{B}="255,239,225,214,198,181,148";
	$HashColData{"Blues"}{8}{R}="247,222,198,158,107,66,33,8";
	$HashColData{"Blues"}{8}{G}="251,235,219,202,174,146,113,69";
	$HashColData{"Blues"}{8}{B}="255,247,239,225,214,198,181,148";
	$HashColData{"Blues"}{9}{R}="247,222,198,158,107,66,33,8,8";
	$HashColData{"Blues"}{9}{G}="251,235,219,202,174,146,113,81,48";
	$HashColData{"Blues"}{9}{B}="255,247,239,225,214,198,181,156,107";
	$HashColData{"BrBG"}{3}{R}="216,245,90";
	$HashColData{"BrBG"}{3}{G}="179,245,180";
	$HashColData{"BrBG"}{3}{B}="101,245,172";
	$HashColData{"BrBG"}{4}{R}="166,223,128,1";
	$HashColData{"BrBG"}{4}{G}="97,194,205,133";
	$HashColData{"BrBG"}{4}{B}="26,125,193,113";
	$HashColData{"BrBG"}{5}{R}="166,223,245,128,1";
	$HashColData{"BrBG"}{5}{G}="97,194,245,205,133";
	$HashColData{"BrBG"}{5}{B}="26,125,245,193,113";
	$HashColData{"BrBG"}{6}{R}="140,216,246,199,90,1";
	$HashColData{"BrBG"}{6}{G}="81,179,232,234,180,102";
	$HashColData{"BrBG"}{6}{B}="10,101,195,229,172,94";
	$HashColData{"BrBG"}{7}{R}="140,216,246,245,199,90,1";
	$HashColData{"BrBG"}{7}{G}="81,179,232,245,234,180,102";
	$HashColData{"BrBG"}{7}{B}="10,101,195,245,229,172,94";
	$HashColData{"BrBG"}{8}{R}="140,191,223,246,199,128,53,1";
	$HashColData{"BrBG"}{8}{G}="81,129,194,232,234,205,151,102";
	$HashColData{"BrBG"}{8}{B}="10,45,125,195,229,193,143,94";
	$HashColData{"BrBG"}{9}{R}="140,191,223,246,245,199,128,53,1";
	$HashColData{"BrBG"}{9}{G}="81,129,194,232,245,234,205,151,102";
	$HashColData{"BrBG"}{9}{B}="10,45,125,195,245,229,193,143,94";
	$HashColData{"BrBG"}{10}{R}="84,140,191,223,246,199,128,53,1,0";
	$HashColData{"BrBG"}{10}{G}="48,81,129,194,232,234,205,151,102,60";
	$HashColData{"BrBG"}{10}{B}="5,10,45,125,195,229,193,143,94,48";
	$HashColData{"BrBG"}{11}{R}="84,140,191,223,246,245,199,128,53,1,0";
	$HashColData{"BrBG"}{11}{G}="48,81,129,194,232,245,234,205,151,102,60";
	$HashColData{"BrBG"}{11}{B}="5,10,45,125,195,245,229,193,143,94,48";
	$HashColData{"BuGn"}{3}{R}="229,153,44";
	$HashColData{"BuGn"}{3}{G}="245,216,162";
	$HashColData{"BuGn"}{3}{B}="249,201,95";
	$HashColData{"BuGn"}{4}{R}="237,178,102,35";
	$HashColData{"BuGn"}{4}{G}="248,226,194,139";
	$HashColData{"BuGn"}{4}{B}="251,226,164,69";
	$HashColData{"BuGn"}{5}{R}="237,178,102,44,0";
	$HashColData{"BuGn"}{5}{G}="248,226,194,162,109";
	$HashColData{"BuGn"}{5}{B}="251,226,164,95,44";
	$HashColData{"BuGn"}{6}{R}="237,204,153,102,44,0";
	$HashColData{"BuGn"}{6}{G}="248,236,216,194,162,109";
	$HashColData{"BuGn"}{6}{B}="251,230,201,164,95,44";
	$HashColData{"BuGn"}{7}{R}="237,204,153,102,65,35,0";
	$HashColData{"BuGn"}{7}{G}="248,236,216,194,174,139,88";
	$HashColData{"BuGn"}{7}{B}="251,230,201,164,118,69,36";
	$HashColData{"BuGn"}{8}{R}="247,229,204,153,102,65,35,0";
	$HashColData{"BuGn"}{8}{G}="252,245,236,216,194,174,139,88";
	$HashColData{"BuGn"}{8}{B}="253,249,230,201,164,118,69,36";
	$HashColData{"BuGn"}{9}{R}="247,229,204,153,102,65,35,0,0";
	$HashColData{"BuGn"}{9}{G}="252,245,236,216,194,174,139,109,68";
	$HashColData{"BuGn"}{9}{B}="253,249,230,201,164,118,69,44,27";
	$HashColData{"BuPu"}{3}{R}="224,158,136";
	$HashColData{"BuPu"}{3}{G}="236,188,86";
	$HashColData{"BuPu"}{3}{B}="244,218,167";
	$HashColData{"BuPu"}{4}{R}="237,179,140,136";
	$HashColData{"BuPu"}{4}{G}="248,205,150,65";
	$HashColData{"BuPu"}{4}{B}="251,227,198,157";
	$HashColData{"BuPu"}{5}{R}="237,179,140,136,129";
	$HashColData{"BuPu"}{5}{G}="248,205,150,86,15";
	$HashColData{"BuPu"}{5}{B}="251,227,198,167,124";
	$HashColData{"BuPu"}{6}{R}="237,191,158,140,136,129";
	$HashColData{"BuPu"}{6}{G}="248,211,188,150,86,15";
	$HashColData{"BuPu"}{6}{B}="251,230,218,198,167,124";
	$HashColData{"BuPu"}{7}{R}="237,191,158,140,140,136,110";
	$HashColData{"BuPu"}{7}{G}="248,211,188,150,107,65,1";
	$HashColData{"BuPu"}{7}{B}="251,230,218,198,177,157,107";
	$HashColData{"BuPu"}{8}{R}="247,224,191,158,140,140,136,110";
	$HashColData{"BuPu"}{8}{G}="252,236,211,188,150,107,65,1";
	$HashColData{"BuPu"}{8}{B}="253,244,230,218,198,177,157,107";
	$HashColData{"BuPu"}{9}{R}="247,224,191,158,140,140,136,129,77";
	$HashColData{"BuPu"}{9}{G}="252,236,211,188,150,107,65,15,0";
	$HashColData{"BuPu"}{9}{B}="253,244,230,218,198,177,157,124,75";
	$HashColData{"Dark2"}{3}{R}="27,217,117";
	$HashColData{"Dark2"}{3}{G}="158,95,112";
	$HashColData{"Dark2"}{3}{B}="119,2,179";
	$HashColData{"Dark2"}{4}{R}="27,217,117,231";
	$HashColData{"Dark2"}{4}{G}="158,95,112,41";
	$HashColData{"Dark2"}{4}{B}="119,2,179,138";
	$HashColData{"Dark2"}{5}{R}="27,217,117,231,102";
	$HashColData{"Dark2"}{5}{G}="158,95,112,41,166";
	$HashColData{"Dark2"}{5}{B}="119,2,179,138,30";
	$HashColData{"Dark2"}{6}{R}="27,217,117,231,102,230";
	$HashColData{"Dark2"}{6}{G}="158,95,112,41,166,171";
	$HashColData{"Dark2"}{6}{B}="119,2,179,138,30,2";
	$HashColData{"Dark2"}{7}{R}="27,217,117,231,102,230,166";
	$HashColData{"Dark2"}{7}{G}="158,95,112,41,166,171,118";
	$HashColData{"Dark2"}{7}{B}="119,2,179,138,30,2,29";
	$HashColData{"Dark2"}{8}{R}="27,217,117,231,102,230,166,102";
	$HashColData{"Dark2"}{8}{G}="158,95,112,41,166,171,118,102";
	$HashColData{"Dark2"}{8}{B}="119,2,179,138,30,2,29,102";
	$HashColData{"GnBu"}{3}{R}="224,168,67";
	$HashColData{"GnBu"}{3}{G}="243,221,162";
	$HashColData{"GnBu"}{3}{B}="219,181,202";
	$HashColData{"GnBu"}{4}{R}="240,186,123,43";
	$HashColData{"GnBu"}{4}{G}="249,228,204,140";
	$HashColData{"GnBu"}{4}{B}="232,188,196,190";
	$HashColData{"GnBu"}{5}{R}="240,186,123,67,8";
	$HashColData{"GnBu"}{5}{G}="249,228,204,162,104";
	$HashColData{"GnBu"}{5}{B}="232,188,196,202,172";
	$HashColData{"GnBu"}{6}{R}="240,204,168,123,67,8";
	$HashColData{"GnBu"}{6}{G}="249,235,221,204,162,104";
	$HashColData{"GnBu"}{6}{B}="232,197,181,196,202,172";
	$HashColData{"GnBu"}{7}{R}="240,204,168,123,78,43,8";
	$HashColData{"GnBu"}{7}{G}="249,235,221,204,179,140,88";
	$HashColData{"GnBu"}{7}{B}="232,197,181,196,211,190,158";
	$HashColData{"GnBu"}{8}{R}="247,224,204,168,123,78,43,8";
	$HashColData{"GnBu"}{8}{G}="252,243,235,221,204,179,140,88";
	$HashColData{"GnBu"}{8}{B}="240,219,197,181,196,211,190,158";
	$HashColData{"GnBu"}{9}{R}="247,224,204,168,123,78,43,8,8";
	$HashColData{"GnBu"}{9}{G}="252,243,235,221,204,179,140,104,64";
	$HashColData{"GnBu"}{9}{B}="240,219,197,181,196,211,190,172,129";
	$HashColData{"Greens"}{3}{R}="229,161,49";
	$HashColData{"Greens"}{3}{G}="245,217,163";
	$HashColData{"Greens"}{3}{B}="224,155,84";
	$HashColData{"Greens"}{4}{R}="237,186,116,35";
	$HashColData{"Greens"}{4}{G}="248,228,196,139";
	$HashColData{"Greens"}{4}{B}="233,179,118,69";
	$HashColData{"Greens"}{5}{R}="237,186,116,49,0";
	$HashColData{"Greens"}{5}{G}="248,228,196,163,109";
	$HashColData{"Greens"}{5}{B}="233,179,118,84,44";
	$HashColData{"Greens"}{6}{R}="237,199,161,116,49,0";
	$HashColData{"Greens"}{6}{G}="248,233,217,196,163,109";
	$HashColData{"Greens"}{6}{B}="233,192,155,118,84,44";
	$HashColData{"Greens"}{7}{R}="237,199,161,116,65,35,0";
	$HashColData{"Greens"}{7}{G}="248,233,217,196,171,139,90";
	$HashColData{"Greens"}{7}{B}="233,192,155,118,93,69,50";
	$HashColData{"Greens"}{8}{R}="247,229,199,161,116,65,35,0";
	$HashColData{"Greens"}{8}{G}="252,245,233,217,196,171,139,90";
	$HashColData{"Greens"}{8}{B}="245,224,192,155,118,93,69,50";
	$HashColData{"Greens"}{9}{R}="247,229,199,161,116,65,35,0,0";
	$HashColData{"Greens"}{9}{G}="252,245,233,217,196,171,139,109,68";
	$HashColData{"Greens"}{9}{B}="245,224,192,155,118,93,69,44,27";
	$HashColData{"Greys"}{3}{R}="240,189,99";
	$HashColData{"Greys"}{3}{G}="240,189,99";
	$HashColData{"Greys"}{3}{B}="240,189,99";
	$HashColData{"Greys"}{4}{R}="247,204,150,82";
	$HashColData{"Greys"}{4}{G}="247,204,150,82";
	$HashColData{"Greys"}{4}{B}="247,204,150,82";
	$HashColData{"Greys"}{5}{R}="247,204,150,99,37";
	$HashColData{"Greys"}{5}{G}="247,204,150,99,37";
	$HashColData{"Greys"}{5}{B}="247,204,150,99,37";
	$HashColData{"Greys"}{6}{R}="247,217,189,150,99,37";
	$HashColData{"Greys"}{6}{G}="247,217,189,150,99,37";
	$HashColData{"Greys"}{6}{B}="247,217,189,150,99,37";
	$HashColData{"Greys"}{7}{R}="247,217,189,150,115,82,37";
	$HashColData{"Greys"}{7}{G}="247,217,189,150,115,82,37";
	$HashColData{"Greys"}{7}{B}="247,217,189,150,115,82,37";
	$HashColData{"Greys"}{8}{R}="255,240,217,189,150,115,82,37";
	$HashColData{"Greys"}{8}{G}="255,240,217,189,150,115,82,37";
	$HashColData{"Greys"}{8}{B}="255,240,217,189,150,115,82,37";
	$HashColData{"Greys"}{9}{R}="255,240,217,189,150,115,82,37,0";
	$HashColData{"Greys"}{9}{G}="255,240,217,189,150,115,82,37,0";
	$HashColData{"Greys"}{9}{B}="255,240,217,189,150,115,82,37,0";
	$HashColData{"Oranges"}{3}{R}="254,253,230";
	$HashColData{"Oranges"}{3}{G}="230,174,85";
	$HashColData{"Oranges"}{3}{B}="206,107,13";
	$HashColData{"Oranges"}{4}{R}="254,253,253,217";
	$HashColData{"Oranges"}{4}{G}="237,190,141,71";
	$HashColData{"Oranges"}{4}{B}="222,133,60,1";
	$HashColData{"Oranges"}{5}{R}="254,253,253,230,166";
	$HashColData{"Oranges"}{5}{G}="237,190,141,85,54";
	$HashColData{"Oranges"}{5}{B}="222,133,60,13,3";
	$HashColData{"Oranges"}{6}{R}="254,253,253,253,230,166";
	$HashColData{"Oranges"}{6}{G}="237,208,174,141,85,54";
	$HashColData{"Oranges"}{6}{B}="222,162,107,60,13,3";
	$HashColData{"Oranges"}{7}{R}="254,253,253,253,241,217,140";
	$HashColData{"Oranges"}{7}{G}="237,208,174,141,105,72,45";
	$HashColData{"Oranges"}{7}{B}="222,162,107,60,19,1,4";
	$HashColData{"Oranges"}{8}{R}="255,254,253,253,253,241,217,140";
	$HashColData{"Oranges"}{8}{G}="245,230,208,174,141,105,72,45";
	$HashColData{"Oranges"}{8}{B}="235,206,162,107,60,19,1,4";
	$HashColData{"Oranges"}{9}{R}="255,254,253,253,253,241,217,166,127";
	$HashColData{"Oranges"}{9}{G}="245,230,208,174,141,105,72,54,39";
	$HashColData{"Oranges"}{9}{B}="235,206,162,107,60,19,1,3,4";
	$HashColData{"OrRd"}{3}{R}="254,253,227";
	$HashColData{"OrRd"}{3}{G}="232,187,74";
	$HashColData{"OrRd"}{3}{B}="200,132,51";
	$HashColData{"OrRd"}{4}{R}="254,253,252,215";
	$HashColData{"OrRd"}{4}{G}="240,204,141,48";
	$HashColData{"OrRd"}{4}{B}="217,138,89,31";
	$HashColData{"OrRd"}{5}{R}="254,253,252,227,179";
	$HashColData{"OrRd"}{5}{G}="240,204,141,74,0";
	$HashColData{"OrRd"}{5}{B}="217,138,89,51,0";
	$HashColData{"OrRd"}{6}{R}="254,253,253,252,227,179";
	$HashColData{"OrRd"}{6}{G}="240,212,187,141,74,0";
	$HashColData{"OrRd"}{6}{B}="217,158,132,89,51,0";
	$HashColData{"OrRd"}{7}{R}="254,253,253,252,239,215,153";
	$HashColData{"OrRd"}{7}{G}="240,212,187,141,101,48,0";
	$HashColData{"OrRd"}{7}{B}="217,158,132,89,72,31,0";
	$HashColData{"OrRd"}{8}{R}="255,254,253,253,252,239,215,153";
	$HashColData{"OrRd"}{8}{G}="247,232,212,187,141,101,48,0";
	$HashColData{"OrRd"}{8}{B}="236,200,158,132,89,72,31,0";
	$HashColData{"OrRd"}{9}{R}="255,254,253,253,252,239,215,179,127";
	$HashColData{"OrRd"}{9}{G}="247,232,212,187,141,101,48,0,0";
	$HashColData{"OrRd"}{9}{B}="236,200,158,132,89,72,31,0,0";
	$HashColData{"Paired"}{3}{R}="166,31,178";
	$HashColData{"Paired"}{3}{G}="206,120,223";
	$HashColData{"Paired"}{3}{B}="227,180,138";
	$HashColData{"Paired"}{4}{R}="166,31,178,51";
	$HashColData{"Paired"}{4}{G}="206,120,223,160";
	$HashColData{"Paired"}{4}{B}="227,180,138,44";
	$HashColData{"Paired"}{5}{R}="166,31,178,51,251";
	$HashColData{"Paired"}{5}{G}="206,120,223,160,154";
	$HashColData{"Paired"}{5}{B}="227,180,138,44,153";
	$HashColData{"Paired"}{6}{R}="166,31,178,51,251,227";
	$HashColData{"Paired"}{6}{G}="206,120,223,160,154,26";
	$HashColData{"Paired"}{6}{B}="227,180,138,44,153,28";
	$HashColData{"Paired"}{7}{R}="166,31,178,51,251,227,253";
	$HashColData{"Paired"}{7}{G}="206,120,223,160,154,26,191";
	$HashColData{"Paired"}{7}{B}="227,180,138,44,153,28,111";
	$HashColData{"Paired"}{8}{R}="166,31,178,51,251,227,253,255";
	$HashColData{"Paired"}{8}{G}="206,120,223,160,154,26,191,127";
	$HashColData{"Paired"}{8}{B}="227,180,138,44,153,28,111,0";
	$HashColData{"Paired"}{9}{R}="166,31,178,51,251,227,253,255,202";
	$HashColData{"Paired"}{9}{G}="206,120,223,160,154,26,191,127,178";
	$HashColData{"Paired"}{9}{B}="227,180,138,44,153,28,111,0,214";
	$HashColData{"Paired"}{10}{R}="166,31,178,51,251,227,253,255,202,106";
	$HashColData{"Paired"}{10}{G}="206,120,223,160,154,26,191,127,178,61";
	$HashColData{"Paired"}{10}{B}="227,180,138,44,153,28,111,0,214,154";
	$HashColData{"Paired"}{11}{R}="166,31,178,51,251,227,253,255,202,106,255";
	$HashColData{"Paired"}{11}{G}="206,120,223,160,154,26,191,127,178,61,255";
	$HashColData{"Paired"}{11}{B}="227,180,138,44,153,28,111,0,214,154,153";
	$HashColData{"Paired"}{12}{R}="166,31,178,51,251,227,253,255,202,106,255,177";
	$HashColData{"Paired"}{12}{G}="206,120,223,160,154,26,191,127,178,61,255,89";
	$HashColData{"Paired"}{12}{B}="227,180,138,44,153,28,111,0,214,154,153,40";
	$HashColData{"Pastel1"}{3}{R}="251,179,204";
	$HashColData{"Pastel1"}{3}{G}="180,205,235";
	$HashColData{"Pastel1"}{3}{B}="174,227,197";
	$HashColData{"Pastel1"}{4}{R}="251,179,204,222";
	$HashColData{"Pastel1"}{4}{G}="180,205,235,203";
	$HashColData{"Pastel1"}{4}{B}="174,227,197,228";
	$HashColData{"Pastel1"}{5}{R}="251,179,204,222,254";
	$HashColData{"Pastel1"}{5}{G}="180,205,235,203,217";
	$HashColData{"Pastel1"}{5}{B}="174,227,197,228,166";
	$HashColData{"Pastel1"}{6}{R}="251,179,204,222,254,255";
	$HashColData{"Pastel1"}{6}{G}="180,205,235,203,217,255";
	$HashColData{"Pastel1"}{6}{B}="174,227,197,228,166,204";
	$HashColData{"Pastel1"}{7}{R}="251,179,204,222,254,255,229";
	$HashColData{"Pastel1"}{7}{G}="180,205,235,203,217,255,216";
	$HashColData{"Pastel1"}{7}{B}="174,227,197,228,166,204,189";
	$HashColData{"Pastel1"}{8}{R}="251,179,204,222,254,255,229,253";
	$HashColData{"Pastel1"}{8}{G}="180,205,235,203,217,255,216,218";
	$HashColData{"Pastel1"}{8}{B}="174,227,197,228,166,204,189,236";
	$HashColData{"Pastel1"}{9}{R}="251,179,204,222,254,255,229,253,242";
	$HashColData{"Pastel1"}{9}{G}="180,205,235,203,217,255,216,218,242";
	$HashColData{"Pastel1"}{9}{B}="174,227,197,228,166,204,189,236,242";
	$HashColData{"Pastel2"}{3}{R}="179,253,203";
	$HashColData{"Pastel2"}{3}{G}="226,205,213";
	$HashColData{"Pastel2"}{3}{B}="205,172,232";
	$HashColData{"Pastel2"}{4}{R}="179,253,203,244";
	$HashColData{"Pastel2"}{4}{G}="226,205,213,202";
	$HashColData{"Pastel2"}{4}{B}="205,172,232,228";
	$HashColData{"Pastel2"}{5}{R}="179,253,203,244,230";
	$HashColData{"Pastel2"}{5}{G}="226,205,213,202,245";
	$HashColData{"Pastel2"}{5}{B}="205,172,232,228,201";
	$HashColData{"Pastel2"}{6}{R}="179,253,203,244,230,255";
	$HashColData{"Pastel2"}{6}{G}="226,205,213,202,245,242";
	$HashColData{"Pastel2"}{6}{B}="205,172,232,228,201,174";
	$HashColData{"Pastel2"}{7}{R}="179,253,203,244,230,255,241";
	$HashColData{"Pastel2"}{7}{G}="226,205,213,202,245,242,226";
	$HashColData{"Pastel2"}{7}{B}="205,172,232,228,201,174,204";
	$HashColData{"Pastel2"}{8}{R}="179,253,203,244,230,255,241,204";
	$HashColData{"Pastel2"}{8}{G}="226,205,213,202,245,242,226,204";
	$HashColData{"Pastel2"}{8}{B}="205,172,232,228,201,174,204,204";
	$HashColData{"PiYG"}{3}{R}="233,247,161";
	$HashColData{"PiYG"}{3}{G}="163,247,215";
	$HashColData{"PiYG"}{3}{B}="201,247,106";
	$HashColData{"PiYG"}{4}{R}="208,241,184,77";
	$HashColData{"PiYG"}{4}{G}="28,182,225,172";
	$HashColData{"PiYG"}{4}{B}="139,218,134,38";
	$HashColData{"PiYG"}{5}{R}="208,241,247,184,77";
	$HashColData{"PiYG"}{5}{G}="28,182,247,225,172";
	$HashColData{"PiYG"}{5}{B}="139,218,247,134,38";
	$HashColData{"PiYG"}{6}{R}="197,233,253,230,161,77";
	$HashColData{"PiYG"}{6}{G}="27,163,224,245,215,146";
	$HashColData{"PiYG"}{6}{B}="125,201,239,208,106,33";
	$HashColData{"PiYG"}{7}{R}="197,233,253,247,230,161,77";
	$HashColData{"PiYG"}{7}{G}="27,163,224,247,245,215,146";
	$HashColData{"PiYG"}{7}{B}="125,201,239,247,208,106,33";
	$HashColData{"PiYG"}{8}{R}="197,222,241,253,230,184,127,77";
	$HashColData{"PiYG"}{8}{G}="27,119,182,224,245,225,188,146";
	$HashColData{"PiYG"}{8}{B}="125,174,218,239,208,134,65,33";
	$HashColData{"PiYG"}{9}{R}="197,222,241,253,247,230,184,127,77";
	$HashColData{"PiYG"}{9}{G}="27,119,182,224,247,245,225,188,146";
	$HashColData{"PiYG"}{9}{B}="125,174,218,239,247,208,134,65,33";
	$HashColData{"PiYG"}{10}{R}="142,197,222,241,253,230,184,127,77,39";
	$HashColData{"PiYG"}{10}{G}="1,27,119,182,224,245,225,188,146,100";
	$HashColData{"PiYG"}{10}{B}="82,125,174,218,239,208,134,65,33,25";
	$HashColData{"PiYG"}{11}{R}="142,197,222,241,253,247,230,184,127,77,39";
	$HashColData{"PiYG"}{11}{G}="1,27,119,182,224,247,245,225,188,146,100";
	$HashColData{"PiYG"}{11}{B}="82,125,174,218,239,247,208,134,65,33,25";
	$HashColData{"PRGn"}{3}{R}="175,247,127";
	$HashColData{"PRGn"}{3}{G}="141,247,191";
	$HashColData{"PRGn"}{3}{B}="195,247,123";
	$HashColData{"PRGn"}{4}{R}="123,194,166,0";
	$HashColData{"PRGn"}{4}{G}="50,165,219,136";
	$HashColData{"PRGn"}{4}{B}="148,207,160,55";
	$HashColData{"PRGn"}{5}{R}="123,194,247,166,0";
	$HashColData{"PRGn"}{5}{G}="50,165,247,219,136";
	$HashColData{"PRGn"}{5}{B}="148,207,247,160,55";
	$HashColData{"PRGn"}{6}{R}="118,175,231,217,127,27";
	$HashColData{"PRGn"}{6}{G}="42,141,212,240,191,120";
	$HashColData{"PRGn"}{6}{B}="131,195,232,211,123,55";
	$HashColData{"PRGn"}{7}{R}="118,175,231,247,217,127,27";
	$HashColData{"PRGn"}{7}{G}="42,141,212,247,240,191,120";
	$HashColData{"PRGn"}{7}{B}="131,195,232,247,211,123,55";
	$HashColData{"PRGn"}{8}{R}="118,153,194,231,217,166,90,27";
	$HashColData{"PRGn"}{8}{G}="42,112,165,212,240,219,174,120";
	$HashColData{"PRGn"}{8}{B}="131,171,207,232,211,160,97,55";
	$HashColData{"PRGn"}{9}{R}="118,153,194,231,247,217,166,90,27";
	$HashColData{"PRGn"}{9}{G}="42,112,165,212,247,240,219,174,120";
	$HashColData{"PRGn"}{9}{B}="131,171,207,232,247,211,160,97,55";
	$HashColData{"PRGn"}{10}{R}="64,118,153,194,231,217,166,90,27,0";
	$HashColData{"PRGn"}{10}{G}="0,42,112,165,212,240,219,174,120,68";
	$HashColData{"PRGn"}{10}{B}="75,131,171,207,232,211,160,97,55,27";
	$HashColData{"PRGn"}{11}{R}="64,118,153,194,231,247,217,166,90,27,0";
	$HashColData{"PRGn"}{11}{G}="0,42,112,165,212,247,240,219,174,120,68";
	$HashColData{"PRGn"}{11}{B}="75,131,171,207,232,247,211,160,97,55,27";
	$HashColData{"PuBu"}{3}{R}="236,166,43";
	$HashColData{"PuBu"}{3}{G}="231,189,140";
	$HashColData{"PuBu"}{3}{B}="242,219,190";
	$HashColData{"PuBu"}{4}{R}="241,189,116,5";
	$HashColData{"PuBu"}{4}{G}="238,201,169,112";
	$HashColData{"PuBu"}{4}{B}="246,225,207,176";
	$HashColData{"PuBu"}{5}{R}="241,189,116,43,4";
	$HashColData{"PuBu"}{5}{G}="238,201,169,140,90";
	$HashColData{"PuBu"}{5}{B}="246,225,207,190,141";
	$HashColData{"PuBu"}{6}{R}="241,208,166,116,43,4";
	$HashColData{"PuBu"}{6}{G}="238,209,189,169,140,90";
	$HashColData{"PuBu"}{6}{B}="246,230,219,207,190,141";
	$HashColData{"PuBu"}{7}{R}="241,208,166,116,54,5,3";
	$HashColData{"PuBu"}{7}{G}="238,209,189,169,144,112,78";
	$HashColData{"PuBu"}{7}{B}="246,230,219,207,192,176,123";
	$HashColData{"PuBu"}{8}{R}="255,236,208,166,116,54,5,3";
	$HashColData{"PuBu"}{8}{G}="247,231,209,189,169,144,112,78";
	$HashColData{"PuBu"}{8}{B}="251,242,230,219,207,192,176,123";
	$HashColData{"PuBu"}{9}{R}="255,236,208,166,116,54,5,4,2";
	$HashColData{"PuBu"}{9}{G}="247,231,209,189,169,144,112,90,56";
	$HashColData{"PuBu"}{9}{B}="251,242,230,219,207,192,176,141,88";
	$HashColData{"PuBuGn"}{3}{R}="236,166,28";
	$HashColData{"PuBuGn"}{3}{G}="226,189,144";
	$HashColData{"PuBuGn"}{3}{B}="240,219,153";
	$HashColData{"PuBuGn"}{4}{R}="246,189,103,2";
	$HashColData{"PuBuGn"}{4}{G}="239,201,169,129";
	$HashColData{"PuBuGn"}{4}{B}="247,225,207,138";
	$HashColData{"PuBuGn"}{5}{R}="246,189,103,28,1";
	$HashColData{"PuBuGn"}{5}{G}="239,201,169,144,108";
	$HashColData{"PuBuGn"}{5}{B}="247,225,207,153,89";
	$HashColData{"PuBuGn"}{6}{R}="246,208,166,103,28,1";
	$HashColData{"PuBuGn"}{6}{G}="239,209,189,169,144,108";
	$HashColData{"PuBuGn"}{6}{B}="247,230,219,207,153,89";
	$HashColData{"PuBuGn"}{7}{R}="246,208,166,103,54,2,1";
	$HashColData{"PuBuGn"}{7}{G}="239,209,189,169,144,129,100";
	$HashColData{"PuBuGn"}{7}{B}="247,230,219,207,192,138,80";
	$HashColData{"PuBuGn"}{8}{R}="255,236,208,166,103,54,2,1";
	$HashColData{"PuBuGn"}{8}{G}="247,226,209,189,169,144,129,100";
	$HashColData{"PuBuGn"}{8}{B}="251,240,230,219,207,192,138,80";
	$HashColData{"PuBuGn"}{9}{R}="255,236,208,166,103,54,2,1,1";
	$HashColData{"PuBuGn"}{9}{G}="247,226,209,189,169,144,129,108,70";
	$HashColData{"PuBuGn"}{9}{B}="251,240,230,219,207,192,138,89,54";
	$HashColData{"PuOr"}{3}{R}="241,247,153";
	$HashColData{"PuOr"}{3}{G}="163,247,142";
	$HashColData{"PuOr"}{3}{B}="64,247,195";
	$HashColData{"PuOr"}{4}{R}="230,253,178,94";
	$HashColData{"PuOr"}{4}{G}="97,184,171,60";
	$HashColData{"PuOr"}{4}{B}="1,99,210,153";
	$HashColData{"PuOr"}{5}{R}="230,253,247,178,94";
	$HashColData{"PuOr"}{5}{G}="97,184,247,171,60";
	$HashColData{"PuOr"}{5}{B}="1,99,247,210,153";
	$HashColData{"PuOr"}{6}{R}="179,241,254,216,153,84";
	$HashColData{"PuOr"}{6}{G}="88,163,224,218,142,39";
	$HashColData{"PuOr"}{6}{B}="6,64,182,235,195,136";
	$HashColData{"PuOr"}{7}{R}="179,241,254,247,216,153,84";
	$HashColData{"PuOr"}{7}{G}="88,163,224,247,218,142,39";
	$HashColData{"PuOr"}{7}{B}="6,64,182,247,235,195,136";
	$HashColData{"PuOr"}{8}{R}="179,224,253,254,216,178,128,84";
	$HashColData{"PuOr"}{8}{G}="88,130,184,224,218,171,115,39";
	$HashColData{"PuOr"}{8}{B}="6,20,99,182,235,210,172,136";
	$HashColData{"PuOr"}{9}{R}="179,224,253,254,247,216,178,128,84";
	$HashColData{"PuOr"}{9}{G}="88,130,184,224,247,218,171,115,39";
	$HashColData{"PuOr"}{9}{B}="6,20,99,182,247,235,210,172,136";
	$HashColData{"PuOr"}{10}{R}="127,179,224,253,254,216,178,128,84,45";
	$HashColData{"PuOr"}{10}{G}="59,88,130,184,224,218,171,115,39,0";
	$HashColData{"PuOr"}{10}{B}="8,6,20,99,182,235,210,172,136,75";
	$HashColData{"PuOr"}{11}{R}="127,179,224,253,254,247,216,178,128,84,45";
	$HashColData{"PuOr"}{11}{G}="59,88,130,184,224,247,218,171,115,39,0";
	$HashColData{"PuOr"}{11}{B}="8,6,20,99,182,247,235,210,172,136,75";
	$HashColData{"PuRd"}{3}{R}="231,201,221";
	$HashColData{"PuRd"}{3}{G}="225,148,28";
	$HashColData{"PuRd"}{3}{B}="239,199,119";
	$HashColData{"PuRd"}{4}{R}="241,215,223,206";
	$HashColData{"PuRd"}{4}{G}="238,181,101,18";
	$HashColData{"PuRd"}{4}{B}="246,216,176,86";
	$HashColData{"PuRd"}{5}{R}="241,215,223,221,152";
	$HashColData{"PuRd"}{5}{G}="238,181,101,28,0";
	$HashColData{"PuRd"}{5}{B}="246,216,176,119,67";
	$HashColData{"PuRd"}{6}{R}="241,212,201,223,221,152";
	$HashColData{"PuRd"}{6}{G}="238,185,148,101,28,0";
	$HashColData{"PuRd"}{6}{B}="246,218,199,176,119,67";
	$HashColData{"PuRd"}{7}{R}="241,212,201,223,231,206,145";
	$HashColData{"PuRd"}{7}{G}="238,185,148,101,41,18,0";
	$HashColData{"PuRd"}{7}{B}="246,218,199,176,138,86,63";
	$HashColData{"PuRd"}{8}{R}="247,231,212,201,223,231,206,145";
	$HashColData{"PuRd"}{8}{G}="244,225,185,148,101,41,18,0";
	$HashColData{"PuRd"}{8}{B}="249,239,218,199,176,138,86,63";
	$HashColData{"PuRd"}{9}{R}="247,231,212,201,223,231,206,152,103";
	$HashColData{"PuRd"}{9}{G}="244,225,185,148,101,41,18,0,0";
	$HashColData{"PuRd"}{9}{B}="249,239,218,199,176,138,86,67,31";
	$HashColData{"Purples"}{3}{R}="239,188,117";
	$HashColData{"Purples"}{3}{G}="237,189,107";
	$HashColData{"Purples"}{3}{B}="245,220,177";
	$HashColData{"Purples"}{4}{R}="242,203,158,106";
	$HashColData{"Purples"}{4}{G}="240,201,154,81";
	$HashColData{"Purples"}{4}{B}="247,226,200,163";
	$HashColData{"Purples"}{5}{R}="242,203,158,117,84";
	$HashColData{"Purples"}{5}{G}="240,201,154,107,39";
	$HashColData{"Purples"}{5}{B}="247,226,200,177,143";
	$HashColData{"Purples"}{6}{R}="242,218,188,158,117,84";
	$HashColData{"Purples"}{6}{G}="240,218,189,154,107,39";
	$HashColData{"Purples"}{6}{B}="247,235,220,200,177,143";
	$HashColData{"Purples"}{7}{R}="242,218,188,158,128,106,74";
	$HashColData{"Purples"}{7}{G}="240,218,189,154,125,81,20";
	$HashColData{"Purples"}{7}{B}="247,235,220,200,186,163,134";
	$HashColData{"Purples"}{8}{R}="252,239,218,188,158,128,106,74";
	$HashColData{"Purples"}{8}{G}="251,237,218,189,154,125,81,20";
	$HashColData{"Purples"}{8}{B}="253,245,235,220,200,186,163,134";
	$HashColData{"Purples"}{9}{R}="252,239,218,188,158,128,106,84,63";
	$HashColData{"Purples"}{9}{G}="251,237,218,189,154,125,81,39,0";
	$HashColData{"Purples"}{9}{B}="253,245,235,220,200,186,163,143,125";
	$HashColData{"RdBu"}{3}{R}="239,247,103";
	$HashColData{"RdBu"}{3}{G}="138,247,169";
	$HashColData{"RdBu"}{3}{B}="98,247,207";
	$HashColData{"RdBu"}{4}{R}="202,244,146,5";
	$HashColData{"RdBu"}{4}{G}="0,165,197,113";
	$HashColData{"RdBu"}{4}{B}="32,130,222,176";
	$HashColData{"RdBu"}{5}{R}="202,244,247,146,5";
	$HashColData{"RdBu"}{5}{G}="0,165,247,197,113";
	$HashColData{"RdBu"}{5}{B}="32,130,247,222,176";
	$HashColData{"RdBu"}{6}{R}="178,239,253,209,103,33";
	$HashColData{"RdBu"}{6}{G}="24,138,219,229,169,102";
	$HashColData{"RdBu"}{6}{B}="43,98,199,240,207,172";
	$HashColData{"RdBu"}{7}{R}="178,239,253,247,209,103,33";
	$HashColData{"RdBu"}{7}{G}="24,138,219,247,229,169,102";
	$HashColData{"RdBu"}{7}{B}="43,98,199,247,240,207,172";
	$HashColData{"RdBu"}{8}{R}="178,214,244,253,209,146,67,33";
	$HashColData{"RdBu"}{8}{G}="24,96,165,219,229,197,147,102";
	$HashColData{"RdBu"}{8}{B}="43,77,130,199,240,222,195,172";
	$HashColData{"RdBu"}{9}{R}="178,214,244,253,247,209,146,67,33";
	$HashColData{"RdBu"}{9}{G}="24,96,165,219,247,229,197,147,102";
	$HashColData{"RdBu"}{9}{B}="43,77,130,199,247,240,222,195,172";
	$HashColData{"RdBu"}{10}{R}="103,178,214,244,253,209,146,67,33,5";
	$HashColData{"RdBu"}{10}{G}="0,24,96,165,219,229,197,147,102,48";
	$HashColData{"RdBu"}{10}{B}="31,43,77,130,199,240,222,195,172,97";
	$HashColData{"RdBu"}{11}{R}="103,178,214,244,253,247,209,146,67,33,5";
	$HashColData{"RdBu"}{11}{G}="0,24,96,165,219,247,229,197,147,102,48";
	$HashColData{"RdBu"}{11}{B}="31,43,77,130,199,247,240,222,195,172,97";
	$HashColData{"RdGy"}{3}{R}="239,255,153";
	$HashColData{"RdGy"}{3}{G}="138,255,153";
	$HashColData{"RdGy"}{3}{B}="98,255,153";
	$HashColData{"RdGy"}{4}{R}="202,244,186,64";
	$HashColData{"RdGy"}{4}{G}="0,165,186,64";
	$HashColData{"RdGy"}{4}{B}="32,130,186,64";
	$HashColData{"RdGy"}{5}{R}="202,244,255,186,64";
	$HashColData{"RdGy"}{5}{G}="0,165,255,186,64";
	$HashColData{"RdGy"}{5}{B}="32,130,255,186,64";
	$HashColData{"RdGy"}{6}{R}="178,239,253,224,153,77";
	$HashColData{"RdGy"}{6}{G}="24,138,219,224,153,77";
	$HashColData{"RdGy"}{6}{B}="43,98,199,224,153,77";
	$HashColData{"RdGy"}{7}{R}="178,239,253,255,224,153,77";
	$HashColData{"RdGy"}{7}{G}="24,138,219,255,224,153,77";
	$HashColData{"RdGy"}{7}{B}="43,98,199,255,224,153,77";
	$HashColData{"RdGy"}{8}{R}="178,214,244,253,224,186,135,77";
	$HashColData{"RdGy"}{8}{G}="24,96,165,219,224,186,135,77";
	$HashColData{"RdGy"}{8}{B}="43,77,130,199,224,186,135,77";
	$HashColData{"RdGy"}{9}{R}="178,214,244,253,255,224,186,135,77";
	$HashColData{"RdGy"}{9}{G}="24,96,165,219,255,224,186,135,77";
	$HashColData{"RdGy"}{9}{B}="43,77,130,199,255,224,186,135,77";
	$HashColData{"RdGy"}{10}{R}="103,178,214,244,253,224,186,135,77,26";
	$HashColData{"RdGy"}{10}{G}="0,24,96,165,219,224,186,135,77,26";
	$HashColData{"RdGy"}{10}{B}="31,43,77,130,199,224,186,135,77,26";
	$HashColData{"RdGy"}{11}{R}="103,178,214,244,253,255,224,186,135,77,26";
	$HashColData{"RdGy"}{11}{G}="0,24,96,165,219,255,224,186,135,77,26";
	$HashColData{"RdGy"}{11}{B}="31,43,77,130,199,255,224,186,135,77,26";
	$HashColData{"RdPu"}{3}{R}="253,250,197";
	$HashColData{"RdPu"}{3}{G}="224,159,27";
	$HashColData{"RdPu"}{3}{B}="221,181,138";
	$HashColData{"RdPu"}{4}{R}="254,251,247,174";
	$HashColData{"RdPu"}{4}{G}="235,180,104,1";
	$HashColData{"RdPu"}{4}{B}="226,185,161,126";
	$HashColData{"RdPu"}{5}{R}="254,251,247,197,122";
	$HashColData{"RdPu"}{5}{G}="235,180,104,27,1";
	$HashColData{"RdPu"}{5}{B}="226,185,161,138,119";
	$HashColData{"RdPu"}{6}{R}="254,252,250,247,197,122";
	$HashColData{"RdPu"}{6}{G}="235,197,159,104,27,1";
	$HashColData{"RdPu"}{6}{B}="226,192,181,161,138,119";
	$HashColData{"RdPu"}{7}{R}="254,252,250,247,221,174,122";
	$HashColData{"RdPu"}{7}{G}="235,197,159,104,52,1,1";
	$HashColData{"RdPu"}{7}{B}="226,192,181,161,151,126,119";
	$HashColData{"RdPu"}{8}{R}="255,253,252,250,247,221,174,122";
	$HashColData{"RdPu"}{8}{G}="247,224,197,159,104,52,1,1";
	$HashColData{"RdPu"}{8}{B}="243,221,192,181,161,151,126,119";
	$HashColData{"RdPu"}{9}{R}="255,253,252,250,247,221,174,122,73";
	$HashColData{"RdPu"}{9}{G}="247,224,197,159,104,52,1,1,0";
	$HashColData{"RdPu"}{9}{B}="243,221,192,181,161,151,126,119,106";
	$HashColData{"Reds"}{3}{R}="254,252,222";
	$HashColData{"Reds"}{3}{G}="224,146,45";
	$HashColData{"Reds"}{3}{B}="210,114,38";
	$HashColData{"Reds"}{4}{R}="254,252,251,203";
	$HashColData{"Reds"}{4}{G}="229,174,106,24";
	$HashColData{"Reds"}{4}{B}="217,145,74,29";
	$HashColData{"Reds"}{5}{R}="254,252,251,222,165";
	$HashColData{"Reds"}{5}{G}="229,174,106,45,15";
	$HashColData{"Reds"}{5}{B}="217,145,74,38,21";
	$HashColData{"Reds"}{6}{R}="254,252,252,251,222,165";
	$HashColData{"Reds"}{6}{G}="229,187,146,106,45,15";
	$HashColData{"Reds"}{6}{B}="217,161,114,74,38,21";
	$HashColData{"Reds"}{7}{R}="254,252,252,251,239,203,153";
	$HashColData{"Reds"}{7}{G}="229,187,146,106,59,24,0";
	$HashColData{"Reds"}{7}{B}="217,161,114,74,44,29,13";
	$HashColData{"Reds"}{8}{R}="255,254,252,252,251,239,203,153";
	$HashColData{"Reds"}{8}{G}="245,224,187,146,106,59,24,0";
	$HashColData{"Reds"}{8}{B}="240,210,161,114,74,44,29,13";
	$HashColData{"Reds"}{9}{R}="255,254,252,252,251,239,203,165,103";
	$HashColData{"Reds"}{9}{G}="245,224,187,146,106,59,24,15,0";
	$HashColData{"Reds"}{9}{B}="240,210,161,114,74,44,29,21,13";
	$HashColData{"RdYlBu"}{3}{R}="252,255,145";
	$HashColData{"RdYlBu"}{3}{G}="141,255,191";
	$HashColData{"RdYlBu"}{3}{B}="89,191,219";
	$HashColData{"RdYlBu"}{4}{R}="215,253,171,44";
	$HashColData{"RdYlBu"}{4}{G}="25,174,217,123";
	$HashColData{"RdYlBu"}{4}{B}="28,97,233,182";
	$HashColData{"RdYlBu"}{5}{R}="215,253,255,171,44";
	$HashColData{"RdYlBu"}{5}{G}="25,174,255,217,123";
	$HashColData{"RdYlBu"}{5}{B}="28,97,191,233,182";
	$HashColData{"RdYlBu"}{6}{R}="215,252,254,224,145,69";
	$HashColData{"RdYlBu"}{6}{G}="48,141,224,243,191,117";
	$HashColData{"RdYlBu"}{6}{B}="39,89,144,248,219,180";
	$HashColData{"RdYlBu"}{7}{R}="215,252,254,255,224,145,69";
	$HashColData{"RdYlBu"}{7}{G}="48,141,224,255,243,191,117";
	$HashColData{"RdYlBu"}{7}{B}="39,89,144,191,248,219,180";
	$HashColData{"RdYlBu"}{8}{R}="215,244,253,254,224,171,116,69";
	$HashColData{"RdYlBu"}{8}{G}="48,109,174,224,243,217,173,117";
	$HashColData{"RdYlBu"}{8}{B}="39,67,97,144,248,233,209,180";
	$HashColData{"RdYlBu"}{9}{R}="215,244,253,254,255,224,171,116,69";
	$HashColData{"RdYlBu"}{9}{G}="48,109,174,224,255,243,217,173,117";
	$HashColData{"RdYlBu"}{9}{B}="39,67,97,144,191,248,233,209,180";
	$HashColData{"RdYlBu"}{10}{R}="165,215,244,253,254,224,171,116,69,49";
	$HashColData{"RdYlBu"}{10}{G}="0,48,109,174,224,243,217,173,117,54";
	$HashColData{"RdYlBu"}{10}{B}="38,39,67,97,144,248,233,209,180,149";
	$HashColData{"RdYlBu"}{11}{R}="165,215,244,253,254,255,224,171,116,69,49";
	$HashColData{"RdYlBu"}{11}{G}="0,48,109,174,224,255,243,217,173,117,54";
	$HashColData{"RdYlBu"}{11}{B}="38,39,67,97,144,191,248,233,209,180,149";

	$HashColData{"RdYlGn"}{3}{R}="252,255,145";
	$HashColData{"RdYlGn"}{3}{G}="141,255,207";
	$HashColData{"RdYlGn"}{3}{B}="89,191,96";
	$HashColData{"RdYlGn"}{4}{R}="215,253,166,26";
	$HashColData{"RdYlGn"}{4}{G}="25,174,217,150";
	$HashColData{"RdYlGn"}{4}{B}="28,97,106,65";
	$HashColData{"RdYlGn"}{5}{R}="215,253,255,166,26";
	$HashColData{"RdYlGn"}{5}{G}="25,174,255,217,150";
	$HashColData{"RdYlGn"}{5}{B}="28,97,191,106,65";
	$HashColData{"RdYlGn"}{6}{R}="215,252,254,217,145,26";
	$HashColData{"RdYlGn"}{6}{G}="48,141,224,239,207,152";
	$HashColData{"RdYlGn"}{6}{B}="39,89,139,139,96,80";
	$HashColData{"RdYlGn"}{7}{R}="215,252,254,255,217,145,26";
	$HashColData{"RdYlGn"}{7}{G}="48,141,224,255,239,207,152";
	$HashColData{"RdYlGn"}{7}{B}="39,89,139,191,139,96,80";
	$HashColData{"RdYlGn"}{8}{R}="215,244,253,254,217,166,102,26";
	$HashColData{"RdYlGn"}{8}{G}="48,109,174,224,239,217,189,152";
	$HashColData{"RdYlGn"}{8}{B}="39,67,97,139,139,106,99,80";
	$HashColData{"RdYlGn"}{9}{R}="215,244,253,254,255,217,166,102,26";
	$HashColData{"RdYlGn"}{9}{G}="48,109,174,224,255,239,217,189,152";
	$HashColData{"RdYlGn"}{9}{B}="39,67,97,139,191,139,106,99,80";
	$HashColData{"RdYlGn"}{10}{R}="165,215,244,253,254,217,166,102,26,0";
	$HashColData{"RdYlGn"}{10}{G}="0,48,109,174,224,239,217,189,152,104";
	$HashColData{"RdYlGn"}{10}{B}="38,39,67,97,139,139,106,99,80,55";
	$HashColData{"RdYlGn"}{11}{R}="165,215,244,253,254,255,217,166,102,26,0";
	$HashColData{"RdYlGn"}{11}{G}="0,48,109,174,224,255,239,217,189,152,104";
	$HashColData{"RdYlGn"}{11}{B}="38,39,67,97,139,191,139,106,99,80,55";

	$HashColData{"GnYlRd"}{3}{R}="145,255,252";
	$HashColData{"GnYlRd"}{3}{G}="207,255,141";
	$HashColData{"GnYlRd"}{3}{B}="96,191,89";
	$HashColData{"GnYlRd"}{4}{R}="26,166,253,215";
	$HashColData{"GnYlRd"}{4}{G}="150,217,174,25";
	$HashColData{"GnYlRd"}{4}{B}="65,106,97,28";
	$HashColData{"GnYlRd"}{5}{R}="26,166,255,253,215";
	$HashColData{"GnYlRd"}{5}{G}="150,217,255,174,25";
	$HashColData{"GnYlRd"}{5}{B}="65,106,191,97,28";
	$HashColData{"GnYlRd"}{6}{R}="26,145,217,254,252,215";
	$HashColData{"GnYlRd"}{6}{G}="152,207,239,224,141,48";
	$HashColData{"GnYlRd"}{6}{B}="80,96,139,139,89,39";
	$HashColData{"GnYlRd"}{7}{R}="26,145,217,255,254,252,215";
	$HashColData{"GnYlRd"}{7}{G}="152,207,239,255,224,141,48";
	$HashColData{"GnYlRd"}{7}{B}="80,96,139,191,139,89,39";
	$HashColData{"GnYlRd"}{8}{R}="26,102,166,217,254,253,244,215";
	$HashColData{"GnYlRd"}{8}{G}="152,189,217,239,224,174,109,48";
	$HashColData{"GnYlRd"}{8}{B}="80,99,106,139,139,97,67,39";
	$HashColData{"GnYlRd"}{9}{R}="26,102,166,217,255,254,253,244,215";
	$HashColData{"GnYlRd"}{9}{G}="152,189,217,239,255,224,174,109,48";
	$HashColData{"GnYlRd"}{9}{B}="80,99,106,139,191,139,97,67,39";
	$HashColData{"GnYlRd"}{10}{R}="0,26,102,166,217,254,253,244,215,165";
	$HashColData{"GnYlRd"}{10}{G}="104,152,189,217,239,224,174,109,48,0";
	$HashColData{"GnYlRd"}{10}{B}="55,80,99,106,139,139,97,67,39,38";
	$HashColData{"GnYlRd"}{11}{R}="0,26,102,166,217,255,254,253,244,215,165";
	$HashColData{"GnYlRd"}{11}{G}="104,152,189,217,239,255,224,174,109,48,0";
	$HashColData{"GnYlRd"}{11}{B}="55,80,99,106,139,191,139,97,67,39,38";


	$HashColData{"Set1"}{3}{R}="228,55,77";
	$HashColData{"Set1"}{3}{G}="26,126,175";
	$HashColData{"Set1"}{3}{B}="28,184,74";
	$HashColData{"Set1"}{4}{R}="228,55,77,152";
	$HashColData{"Set1"}{4}{G}="26,126,175,78";
	$HashColData{"Set1"}{4}{B}="28,184,74,163";
	$HashColData{"Set1"}{5}{R}="228,55,77,152,255";
	$HashColData{"Set1"}{5}{G}="26,126,175,78,127";
	$HashColData{"Set1"}{5}{B}="28,184,74,163,0";
	$HashColData{"Set1"}{6}{R}="228,55,77,152,255,255";
	$HashColData{"Set1"}{6}{G}="26,126,175,78,127,255";
	$HashColData{"Set1"}{6}{B}="28,184,74,163,0,51";
	$HashColData{"Set1"}{7}{R}="228,55,77,152,255,255,166";
	$HashColData{"Set1"}{7}{G}="26,126,175,78,127,255,86";
	$HashColData{"Set1"}{7}{B}="28,184,74,163,0,51,40";
	$HashColData{"Set1"}{8}{R}="228,55,77,152,255,255,166,247";
	$HashColData{"Set1"}{8}{G}="26,126,175,78,127,255,86,129";
	$HashColData{"Set1"}{8}{B}="28,184,74,163,0,51,40,191";
	$HashColData{"Set1"}{9}{R}="228,55,77,152,255,255,166,247,153";
	$HashColData{"Set1"}{9}{G}="26,126,175,78,127,255,86,129,153";
	$HashColData{"Set1"}{9}{B}="28,184,74,163,0,51,40,191,153";
	$HashColData{"Set2"}{3}{R}="102,252,141";
	$HashColData{"Set2"}{3}{G}="194,141,160";
	$HashColData{"Set2"}{3}{B}="165,98,203";
	$HashColData{"Set2"}{4}{R}="102,252,141,231";
	$HashColData{"Set2"}{4}{G}="194,141,160,138";
	$HashColData{"Set2"}{4}{B}="165,98,203,195";
	$HashColData{"Set2"}{5}{R}="102,252,141,231,166";
	$HashColData{"Set2"}{5}{G}="194,141,160,138,216";
	$HashColData{"Set2"}{5}{B}="165,98,203,195,84";
	$HashColData{"Set2"}{6}{R}="102,252,141,231,166,255";
	$HashColData{"Set2"}{6}{G}="194,141,160,138,216,217";
	$HashColData{"Set2"}{6}{B}="165,98,203,195,84,47";
	$HashColData{"Set2"}{7}{R}="102,252,141,231,166,255,229";
	$HashColData{"Set2"}{7}{G}="194,141,160,138,216,217,196";
	$HashColData{"Set2"}{7}{B}="165,98,203,195,84,47,148";
	$HashColData{"Set2"}{8}{R}="102,252,141,231,166,255,229,179";
	$HashColData{"Set2"}{8}{G}="194,141,160,138,216,217,196,179";
	$HashColData{"Set2"}{8}{B}="165,98,203,195,84,47,148,179";
	$HashColData{"Set3"}{3}{R}="141,255,190";
	$HashColData{"Set3"}{3}{G}="211,255,186";
	$HashColData{"Set3"}{3}{B}="199,179,218";
	$HashColData{"Set3"}{4}{R}="141,255,190,251";
	$HashColData{"Set3"}{4}{G}="211,255,186,128";
	$HashColData{"Set3"}{4}{B}="199,179,218,114";
	$HashColData{"Set3"}{5}{R}="141,255,190,251,128";
	$HashColData{"Set3"}{5}{G}="211,255,186,128,177";
	$HashColData{"Set3"}{5}{B}="199,179,218,114,211";
	$HashColData{"Set3"}{6}{R}="141,255,190,251,128,253";
	$HashColData{"Set3"}{6}{G}="211,255,186,128,177,180";
	$HashColData{"Set3"}{6}{B}="199,179,218,114,211,98";
	$HashColData{"Set3"}{7}{R}="141,255,190,251,128,253,179";
	$HashColData{"Set3"}{7}{G}="211,255,186,128,177,180,222";
	$HashColData{"Set3"}{7}{B}="199,179,218,114,211,98,105";
	$HashColData{"Set3"}{8}{R}="141,255,190,251,128,253,179,252";
	$HashColData{"Set3"}{8}{G}="211,255,186,128,177,180,222,205";
	$HashColData{"Set3"}{8}{B}="199,179,218,114,211,98,105,229";
	$HashColData{"Set3"}{9}{R}="141,255,190,251,128,253,179,252,217";
	$HashColData{"Set3"}{9}{G}="211,255,186,128,177,180,222,205,217";
	$HashColData{"Set3"}{9}{B}="199,179,218,114,211,98,105,229,217";
	$HashColData{"Set3"}{10}{R}="141,255,190,251,128,253,179,252,217,188";
	$HashColData{"Set3"}{10}{G}="211,255,186,128,177,180,222,205,217,128";
	$HashColData{"Set3"}{10}{B}="199,179,218,114,211,98,105,229,217,189";
	$HashColData{"Set3"}{11}{R}="141,255,190,251,128,253,179,252,217,188,204";
	$HashColData{"Set3"}{11}{G}="211,255,186,128,177,180,222,205,217,128,235";
	$HashColData{"Set3"}{11}{B}="199,179,218,114,211,98,105,229,217,189,197";
	$HashColData{"Set3"}{12}{R}="141,255,190,251,128,253,179,252,217,188,204,255";
	$HashColData{"Set3"}{12}{G}="211,255,186,128,177,180,222,205,217,128,235,237";
	$HashColData{"Set3"}{12}{B}="199,179,218,114,211,98,105,229,217,189,197,111";
	$HashColData{"Spectral"}{3}{R}="252,255,153";
	$HashColData{"Spectral"}{3}{G}="141,255,213";
	$HashColData{"Spectral"}{3}{B}="89,191,148";
	$HashColData{"Spectral"}{4}{R}="215,253,171,43";
	$HashColData{"Spectral"}{4}{G}="25,174,221,131";
	$HashColData{"Spectral"}{4}{B}="28,97,164,186";
	$HashColData{"Spectral"}{5}{R}="215,253,255,171,43";
	$HashColData{"Spectral"}{5}{G}="25,174,255,221,131";
	$HashColData{"Spectral"}{5}{B}="28,97,191,164,186";
	$HashColData{"Spectral"}{6}{R}="213,252,254,230,153,50";
	$HashColData{"Spectral"}{6}{G}="62,141,224,245,213,136";
	$HashColData{"Spectral"}{6}{B}="79,89,139,152,148,189";
	$HashColData{"Spectral"}{7}{R}="213,252,254,255,230,153,50";
	$HashColData{"Spectral"}{7}{G}="62,141,224,255,245,213,136";
	$HashColData{"Spectral"}{7}{B}="79,89,139,191,152,148,189";
	$HashColData{"Spectral"}{8}{R}="213,244,253,254,230,171,102,50";
	$HashColData{"Spectral"}{8}{G}="62,109,174,224,245,221,194,136";
	$HashColData{"Spectral"}{8}{B}="79,67,97,139,152,164,165,189";
	$HashColData{"Spectral"}{9}{R}="213,244,253,254,255,230,171,102,50";
	$HashColData{"Spectral"}{9}{G}="62,109,174,224,255,245,221,194,136";
	$HashColData{"Spectral"}{9}{B}="79,67,97,139,191,152,164,165,189";
	$HashColData{"Spectral"}{10}{R}="158,213,244,253,254,230,171,102,50,94";
	$HashColData{"Spectral"}{10}{G}="1,62,109,174,224,245,221,194,136,79";
	$HashColData{"Spectral"}{10}{B}="66,79,67,97,139,152,164,165,189,162";
	$HashColData{"Spectral"}{11}{R}="158,213,244,253,254,255,230,171,102,50,94";
	$HashColData{"Spectral"}{11}{G}="1,62,109,174,224,255,245,221,194,136,79";
	$HashColData{"Spectral"}{11}{B}="66,79,67,97,139,191,152,164,165,189,162";
	$HashColData{"YlGn"}{3}{R}="247,173,49";
	$HashColData{"YlGn"}{3}{G}="252,221,163";
	$HashColData{"YlGn"}{3}{B}="185,142,84";
	$HashColData{"YlGn"}{4}{R}="255,194,120,35";
	$HashColData{"YlGn"}{4}{G}="255,230,198,132";
	$HashColData{"YlGn"}{4}{B}="204,153,121,67";
	$HashColData{"YlGn"}{5}{R}="255,194,120,49,0";
	$HashColData{"YlGn"}{5}{G}="255,230,198,163,104";
	$HashColData{"YlGn"}{5}{B}="204,153,121,84,55";
	$HashColData{"YlGn"}{6}{R}="255,217,173,120,49,0";
	$HashColData{"YlGn"}{6}{G}="255,240,221,198,163,104";
	$HashColData{"YlGn"}{6}{B}="204,163,142,121,84,55";
	$HashColData{"YlGn"}{7}{R}="255,217,173,120,65,35,0";
	$HashColData{"YlGn"}{7}{G}="255,240,221,198,171,132,90";
	$HashColData{"YlGn"}{7}{B}="204,163,142,121,93,67,50";
	$HashColData{"YlGn"}{8}{R}="255,247,217,173,120,65,35,0";
	$HashColData{"YlGn"}{8}{G}="255,252,240,221,198,171,132,90";
	$HashColData{"YlGn"}{8}{B}="229,185,163,142,121,93,67,50";
	$HashColData{"YlGn"}{9}{R}="255,247,217,173,120,65,35,0,0";
	$HashColData{"YlGn"}{9}{G}="255,252,240,221,198,171,132,104,69";
	$HashColData{"YlGn"}{9}{B}="229,185,163,142,121,93,67,55,41";
	$HashColData{"YlGnBu"}{3}{R}="237,127,44";
	$HashColData{"YlGnBu"}{3}{G}="248,205,127";
	$HashColData{"YlGnBu"}{3}{B}="177,187,184";
	$HashColData{"YlGnBu"}{4}{R}="255,161,65,34";
	$HashColData{"YlGnBu"}{4}{G}="255,218,182,94";
	$HashColData{"YlGnBu"}{4}{B}="204,180,196,168";
	$HashColData{"YlGnBu"}{5}{R}="255,161,65,44,37";
	$HashColData{"YlGnBu"}{5}{G}="255,218,182,127,52";
	$HashColData{"YlGnBu"}{5}{B}="204,180,196,184,148";
	$HashColData{"YlGnBu"}{6}{R}="255,199,127,65,44,37";
	$HashColData{"YlGnBu"}{6}{G}="255,233,205,182,127,52";
	$HashColData{"YlGnBu"}{6}{B}="204,180,187,196,184,148";
	$HashColData{"YlGnBu"}{7}{R}="255,199,127,65,29,34,12";
	$HashColData{"YlGnBu"}{7}{G}="255,233,205,182,145,94,44";
	$HashColData{"YlGnBu"}{7}{B}="204,180,187,196,192,168,132";
	$HashColData{"YlGnBu"}{8}{R}="255,237,199,127,65,29,34,12";
	$HashColData{"YlGnBu"}{8}{G}="255,248,233,205,182,145,94,44";
	$HashColData{"YlGnBu"}{8}{B}="217,177,180,187,196,192,168,132";
	$HashColData{"YlGnBu"}{9}{R}="255,237,199,127,65,29,34,37,8";
	$HashColData{"YlGnBu"}{9}{G}="255,248,233,205,182,145,94,52,29";
	$HashColData{"YlGnBu"}{9}{B}="217,177,180,187,196,192,168,148,88";
	$HashColData{"YlOrBr"}{3}{R}="255,254,217";
	$HashColData{"YlOrBr"}{3}{G}="247,196,95";
	$HashColData{"YlOrBr"}{3}{B}="188,79,14";
	$HashColData{"YlOrBr"}{4}{R}="255,254,254,204";
	$HashColData{"YlOrBr"}{4}{G}="255,217,153,76";
	$HashColData{"YlOrBr"}{4}{B}="212,142,41,2";
	$HashColData{"YlOrBr"}{5}{R}="255,254,254,217,153";
	$HashColData{"YlOrBr"}{5}{G}="255,217,153,95,52";
	$HashColData{"YlOrBr"}{5}{B}="212,142,41,14,4";
	$HashColData{"YlOrBr"}{6}{R}="255,254,254,254,217,153";
	$HashColData{"YlOrBr"}{6}{G}="255,227,196,153,95,52";
	$HashColData{"YlOrBr"}{6}{B}="212,145,79,41,14,4";
	$HashColData{"YlOrBr"}{7}{R}="255,254,254,254,236,204,140";
	$HashColData{"YlOrBr"}{7}{G}="255,227,196,153,112,76,45";
	$HashColData{"YlOrBr"}{7}{B}="212,145,79,41,20,2,4";
	$HashColData{"YlOrBr"}{8}{R}="255,255,254,254,254,236,204,140";
	$HashColData{"YlOrBr"}{8}{G}="255,247,227,196,153,112,76,45";
	$HashColData{"YlOrBr"}{8}{B}="229,188,145,79,41,20,2,4";
	$HashColData{"YlOrBr"}{9}{R}="255,255,254,254,254,236,204,153,102";
	$HashColData{"YlOrBr"}{9}{G}="255,247,227,196,153,112,76,52,37";
	$HashColData{"YlOrBr"}{9}{B}="229,188,145,79,41,20,2,4,6";
	$HashColData{"YlOrRd"}{3}{R}="255,254,240";
	$HashColData{"YlOrRd"}{3}{G}="237,178,59";
	$HashColData{"YlOrRd"}{3}{B}="160,76,32";
	$HashColData{"YlOrRd"}{4}{R}="255,254,253,227";
	$HashColData{"YlOrRd"}{4}{G}="255,204,141,26";
	$HashColData{"YlOrRd"}{4}{B}="178,92,60,28";
	$HashColData{"YlOrRd"}{5}{R}="255,254,253,240,189";
	$HashColData{"YlOrRd"}{5}{G}="255,204,141,59,0";
	$HashColData{"YlOrRd"}{5}{B}="178,92,60,32,38";
	$HashColData{"YlOrRd"}{6}{R}="255,254,254,253,240,189";
	$HashColData{"YlOrRd"}{6}{G}="255,217,178,141,59,0";
	$HashColData{"YlOrRd"}{6}{B}="178,118,76,60,32,38";
	$HashColData{"YlOrRd"}{7}{R}="255,254,254,253,252,227,177";
	$HashColData{"YlOrRd"}{7}{G}="255,217,178,141,78,26,0";
	$HashColData{"YlOrRd"}{7}{B}="178,118,76,60,42,28,38";
	$HashColData{"YlOrRd"}{8}{R}="255,255,254,254,253,252,227,177";
	$HashColData{"YlOrRd"}{8}{G}="255,237,217,178,141,78,26,0";
	$HashColData{"YlOrRd"}{8}{B}="204,160,118,76,60,42,28,38";
	$HashColData{"YlOrRd"}{9}{R}="255,255,254,254,253,252,227,189,128";
	$HashColData{"YlOrRd"}{9}{G}="255,237,217,178,141,78,26,0,0";
	$HashColData{"YlOrRd"}{9}{B}="204,160,118,76,60,42,28,38,38";


	if  (exists  $HashColData{$Flag}{$Num}{R})
	{
		my @RR=split /\,/,$HashColData{$Flag}{$Num}{R};
		my @GG=split /\,/,$HashColData{$Flag}{$Num}{G};
		my @BB=split /\,/,$HashColData{$Flag}{$Num}{B};
		my $Count=$Num-1;
		foreach my $k (0..$Count)
		{
			@$CorArry[$k]="rgb($RR[$k],$GG[$k],$BB[$k])";
		}
		return $Count ;
	}
	elsif ($Num<$MAX_COLOR_COUNT{$Flag})
	{
		my @GG=split /\,/,$HashColData{$Flag}{3}{G};
		my @BB=split /\,/,$HashColData{$Flag}{3}{B};
		my @RR=split /\,/,$HashColData{$Flag}{3}{R};
		foreach my $k (0..2)
		{
			@$CorArry[$k]="rgb($RR[$k],$GG[$k],$BB[$k])";
		}
		return $Num;
	}
	else
	{
		my $CorNumDefaut=$MAX_COLOR_COUNT{$Flag};
		for (my $Count=$CorNumDefaut ; $Count>=3 ; $Count--)
		{
			my $BBEE=$Count-1;
			my $ccc=($Num-$Count) % $BBEE;
			if ($ccc==0)
			{
				my @RR=split /\,/,$HashColData{$Flag}{$Count}{R};
				my @GG=split /\,/,$HashColData{$Flag}{$Count}{G};
				my @BB=split /\,/,$HashColData{$Flag}{$Count}{B};
				my $bin=int (($Num-$Count) / $BBEE)+1;
				my $NowArry;
				foreach  my $kk  (1..$#RR)
				{
					my $binRR=($RR[$kk]-$RR[$kk-1])*1.0/$bin;
					my $binGG=($GG[$kk]-$GG[$kk-1])*1.0/$bin;
					my $binBB=($BB[$kk]-$BB[$kk-1])*1.0/$bin;

					foreach my $this (0..$bin)
					{
						$NowArry=($kk-1)*$bin+$this;
						my $NewRR=int($RR[$kk-1]+$binRR*$this);
						my $NewGG=int($GG[$kk-1]+$binGG*$this);
						my $NewBB=int($BB[$kk-1]+$binBB*$this);
						@$CorArry[$NowArry]="rgb($NewRR,$NewGG,$NewBB)";
					}
				}
				$NowArry++;
				$RR[-1]++; $GG[-1]++; $BB[-1]++;
				@$CorArry[$NowArry]="rgb($RR[-1],$GG[-1],$BB[-1])";
				return $NowArry--;
			}
		}

		$Num--;
		for (my $Count=$CorNumDefaut ; $Count>=3 ; $Count--)
		{
			my $BBEE=$Count-1;
			my $ccc=($Num-$Count) % $BBEE;
			if ($ccc==0)
			{
				my @RR=split /\,/,$HashColData{$Flag}{$Count}{R};
				my @GG=split /\,/,$HashColData{$Flag}{$Count}{G};
				my @BB=split /\,/,$HashColData{$Flag}{$Count}{B};
				my $bin=int (($Num-$Count) / $BBEE)+1;
				my $NowArry;
				foreach  my $kk  (1..$#RR)
				{
					my $binRR=($RR[$kk]-$RR[$kk-1])*1.0/$bin;
					my $binGG=($GG[$kk]-$GG[$kk-1])*1.0/$bin;
					my $binBB=($BB[$kk]-$BB[$kk-1])*1.0/$bin;

					foreach my $this (0..$bin)
					{
						$NowArry=($kk-1)*$bin+$this;
						my $NewRR=int($RR[$kk-1]+$binRR*$this);
						my $NewGG=int($GG[$kk-1]+$binGG*$this);
						my $NewBB=int($BB[$kk-1]+$binBB*$this);
						@$CorArry[$NowArry]="rgb($NewRR,$NewGG,$NewBB)";
					}
				}

				$NowArry++;
				$RR[-1]=$RR[-1]+1;$GG[-1]=$GG[-1]+1;$BB[-1]=$BB[-1]-1;
				@$CorArry[$NowArry]="rgb($RR[-1],$GG[-1],$BB[-1])";
				$RR[-1]=$RR[-1]-1;$GG[-1]=$GG[-1]+1;$BB[-1]=$BB[-1]+1;
				@$CorArry[$NowArry+1]="rgb($RR[-1],$GG[-1],$BB[-1])";

				return $NowArry--;
			}
		}

	}

}




#########Draws a shape (circle, square, triangle, etc.) at a given coordinate using SVG. Supports multiple shapes via switch statement.####

sub SVGgetShape
{
	my  $XX = shift ;
	my  $YY = shift ;
	my  $size = shift ;
	my  $shape = shift ;
	my  $Col =  shift;
	my  $svg = shift ;
	my  $HH=$size/6;  if ($HH<1) {$HH=1;}
	switch($shape)
	{
		case 0 {$svg->circle(cx=>$XX, cy=>$YY, r=>$size, fill => $Col);}
		case 1 {my $XX1=$XX-$size;my $YY1=$YY-$size;$svg->rect('x',$XX1,'y',$YY1,'width',$size*2,'height',$size*2,'fill',$Col,'stroke',$Col,'stroke-width',$HH);}
		case 2 {
			my $XX1=$XX-$size;my $YY1=$YY-$size;
			my $XX2=$XX+$size;my $YY2=$YY+$size;
			my $path = $svg->get_path(
				x => [$XX, $XX2, $XX,$XX1],
				y => [$YY1, $YY, $YY2,$YY],
				-type => 'polygon');
			$svg->polygon(
				%$path,
				style => {
					'fill'           => $Col,
					'stroke'         => $Col,
					'stroke-width'   =>  0,
				},
			);
		}
		case 3 {
			my $AA=$size/2; my $BB=$AA*1.732;
			my $XX1=$XX-$BB;my $XX2=$XX+$BB;
			my $YY1=$YY-$BB;my $YY2=$YY+$AA;
			my $path = $svg->get_path(
				x => [$XX, $XX2, $XX1],
				y => [$YY1, $YY2, $YY2],
				-type => 'polygon');
			$svg->polygon(
				%$path,
				style => {
					'fill'           => $Col,
				'stroke'         => $Col,
					'stroke-width'   => $HH,
				},
			);
		}
		case 4 {
			my $AA=$size/2; my $BB=$AA*1.732;
			my $XX1=$XX-$BB;my $XX2=$XX+$BB;
			my $YY1=$YY-$BB;my $YY2=$YY+$AA;
			my $path = $svg->get_path(
				x => [$XX1, $XX2, $XX],
				y => [$YY1, $YY1, $YY2],
				-type => 'polygon');
			$svg->polygon(
				%$path,
				style => {
					'fill'           => $Col,
					'stroke'         => $Col,
					'stroke-width'   =>  $HH,
				},
			);
		}
		case 5 {
			my $XXA=$XX ; my $YYA=$YY-$size;				
			my $AA=$size*0.951; my $BB=$size*0.309;
			my $XXE=$XX+$AA ; my $YYE=$YY-$BB;
			my $XXB=$XX-$AA ; my $YYB=$YYE;				
			my $DD=$BB*0.7265;  my $EE=$BB*1.701;
			my $XXH=$XX+$DD ; my $YYH=$YYE;
			my $XXI=$XX-$DD ; my $YYI=$YYE;
			my $FF=$size*0.5878; my $HHH=$size*0.809;
			my $XXC=$XX-$FF; my  $YYC=$YY+$HHH;
			my $XXD=$XX+$FF; my $YYD=$YY+$HHH;
			my $XXF=$XX;   my $YYF=$YY+$EE;
			my $AAA=$EE*0.951; my $BBB=$EE*0.309;
			my $XXG=$XX+$AAA ; my $YYG=$YY+$BBB;
			my $XXJ=$XX-$AAA ; my $YYJ=$YYG;				
			my $path = $svg->get_path(
				x => [$XXA,$XXH,$XXE,$XXG,$XXD,$XXF,$XXC,$XXJ,$XXB,$XXI],
				y => [$YYA,$YYH,$YYE,$YYG,$YYD,$YYF,$YYC,$YYJ,$YYB,$YYI],
				-type => 'polygon');
			$svg->polygon(
				%$path,
				style => {
					'fill'           => $Col,
					'stroke'         => $Col,
					'stroke-width'   => $HH,
				},
			);
		}
		case 6 {$svg->circle(cx=>$XX, cy=>$YY, r=>$size, fill => "none",'stroke',$Col,'stroke-width',$HH );}
		case 7 {my $XX1=$XX-$size;my $YY1=$YY-$size;$svg->rect('x',$XX1,'y',$YY1,'width',$size*2,'height',$size*2,'fill',"none",'stroke',$Col,'stroke-width',$HH);}
		case 8 {
			my $XX1=$XX-$size;my $YY1=$YY-$size;
			my $XX2=$XX+$size;my $YY2=$YY+$size;
			my $path = $svg->get_path(
				x => [$XX, $XX2, $XX,$XX1],
				y => [$YY1, $YY, $YY2,$YY],
				-type => 'polygon');
			$svg->polygon(
				%$path,
				style => {
					'fill'           => "none",
					'stroke'         => $Col,
					'stroke-width'   => $HH,
				},
			);
		}
		case 9 {
			my $AA=$size/2; my $BB=$AA*1.732;
			my $XX1=$XX-$BB;my $XX2=$XX+$BB;
			my $YY1=$YY-$BB;my $YY2=$YY+$AA;
			my $path = $svg->get_path(
				x => [$XX, $XX2, $XX1],
				y => [$YY1, $YY2, $YY2],
				-type => 'polygon');
			$svg->polygon(
				%$path,
				style => {
					'fill'           => "none",
					'stroke'         => $Col,
					'stroke-width'   => $HH,
				},
			);
		}
		case 10 {
			my $AA=$size/2; my $BB=$AA*1.732;
			my $XX1=$XX-$BB;my $XX2=$XX+$BB;
			my $YY1=$YY-$BB;my $YY2=$YY+$AA;
			my $path = $svg->get_path(
				x => [$XX1, $XX2, $XX],
				y => [$YY1, $YY1, $YY2],
				-type => 'polygon');
			$svg->polygon(
				%$path,
				style => {
					'fill'           => "none",
					'stroke'         => $Col,
					'stroke-width'   => $HH,
				},
			);
		}
		case 11 {
			my $XXA=$XX ; my $YYA=$YY-$size;				
			my $AA=$size*0.951; my $BB=$size*0.309;
			my $XXE=$XX+$AA ; my $YYE=$YY-$BB;
			my $XXB=$XX-$AA ; my $YYB=$YYE;				
			my $DD=$BB*0.7265;  my $EE=$BB*1.701;
			my $XXH=$XX+$DD ; my $YYH=$YYE;
			my $XXI=$XX-$DD ; my $YYI=$YYE;
			my $FF=$size*0.5878; my $HHH=$size*0.809;
			my $XXC=$XX-$FF; my  $YYC=$YY+$HHH;
			my $XXD=$XX+$FF; my $YYD=$YY+$HHH;
			my $XXF=$XX;   my $YYF=$YY+$EE;
			my $AAA=$EE*0.951; my $BBB=$EE*0.309;
			my $XXG=$XX+$AAA ; my $YYG=$YY+$BBB;
			my $XXJ=$XX-$AAA ; my $YYJ=$YYG;				
			my $path = $svg->get_path(
				x => [$XXA,$XXH,$XXE,$XXG,$XXD,$XXF,$XXC,$XXJ,$XXB,$XXI],
				y => [$YYA,$YYH,$YYE,$YYG,$YYD,$YYF,$YYC,$YYJ,$YYB,$YYI],
				-type => 'polygon');
			$svg->polygon(
				%$path,
				style => {
					'fill'           => 'none',
					'stroke'         => $Col,
					'stroke-width'   => $HH,
				},
			);

		}
		case 12 {
			my $AA=$size/2; my $BB=$AA*1.732;
			$YY=$YY-$AA;  $XX=$XX-$size*0.067;				
			my $XX1=$XX-$BB;my $YY1=$YY+$AA;
			my $XX2=$XX;    my $YY2=$YY;
			my $XX3=$XX+$size;my $YY3=$YY;
			my $XX4=$XX3 ;my $YY4=$YY+$size;
			my $XX5=$XX ; my $YY5=$YY4;

			my $path = $svg->get_path(
				x => [$XX1, $XX2, $XX3,$XX4,$XX5],
				y => [$YY1, $YY2, $YY3,$YY4,$YY5],
				-type => 'polygon');
			$svg->polygon(
				%$path,
				style => {
					'fill'           => $Col,
					'stroke'         => $Col,
					'stroke-width'   => $HH,
				},
			);
		}
		case 13 {
			my $AA=$size/2; my $BB=$AA*1.732;
			$YY=$YY-$AA;	$XX=$XX-$size*0.933;
			my $XX1=$XX;    my $YY1=$YY;
			my $XX2=$XX+$size;    my $YY2=$YY;
			my $XX3=$XX2+$BB ;   my $YY3=$YY+$AA;
			my $XX4=$XX2 ;my $YY4=$YY+$size;
			my $XX5=$XX ; my $YY5=$YY4;
			my $path = $svg->get_path(
				x => [$XX1, $XX2, $XX3,$XX4,$XX5],
				y => [$YY1, $YY2, $YY3,$YY4,$YY5],
				-type => 'polygon');
			$svg->polygon(
				%$path,
				style => {
					'fill'           => $Col,
					'stroke'         => $Col,
					'stroke-width'   => $HH,
				},
			);
		}

	case 14 {
            # 绘制左半圆
			my $radius=$size;
			my $start_x=$XX; 
			my $start_y=$YY-$radius;
			my $end_x=$start_x;
			my $end_y=$YY+$radius;
			
			my $path = $svg->path(
			    d => "M $start_x $start_y " .  # 移动到起点
	                 "A $radius $radius 0 1 0 $end_x $end_y",  # 绘制半圆
			    style => {
			        fill => $Col,
			        stroke =>'none'
			    }
			);
        }
        case 15 {
            # 绘制右半圆           
			my $radius=$size;	
			my $start_x=$XX; 
			my $start_y=$YY-$radius;
			my $end_x=$start_x;
			my $end_y=$YY+$radius;
			my $path = $svg->path(
			    d => "M $start_x $start_y " .  # 移动到起点
	                 "A $radius $radius 0 1 1 $end_x $end_y",  # 绘制半圆
			    style => {
			        fill => $Col,
			    	stroke =>'none'
			    }
			);
		}
		case 16 {
        # 绘制上半圆
        my $radius = $size;
        my $start_x = $XX - $radius;
        my $start_y = $YY;
        my $end_x = $XX + $radius;
        my $end_y = $start_y;

        my $path = $svg->path(
            d => "M $start_x $start_y " .  # 移动到起点
                 "A $radius $radius 0 0 0 $end_x $end_y",  # 绘制上半圆
            style => {
                fill => $Col,
			    stroke =>'none'
            }
        );
    }
    case 17 {
        # 绘制下半圆
        my $radius = $size;
        my $start_x = $XX - $radius;
        my $start_y = $YY;
        my $end_x = $XX + $radius;
        my $end_y = $start_y;

        my $path = $svg->path(
            d => "M $start_x $start_y " .  # 移动到起点
                 "A $radius $radius 0 0 1 $end_x $end_y",  # 绘制下半圆
            style => {
                fill => $Col,
			    stroke =>'none'
            }
        );
    }
	case 18 {
            # 绘制左半圆
			my $radius=$size;
			my $start_x=$XX+$radius; 
			my $start_y=$YY-$radius;
			my $end_x=$start_x;
			my $end_y=$YY+$radius;
			
			my $path = $svg->path(
			    d => "M $start_x $start_y " .  # 移动到起点
	                 "A $radius $radius 0 1 0 $end_x $end_y",  # 绘制半圆
			    style => {
			        fill => $Col,
			        stroke =>'none'
			    }
			);
        }
        case 19 {
            # 绘制右半圆           
			my $radius=$size;	
			my $start_x=$XX-$radius; 
			my $start_y=$YY-$radius;
			my $end_x=$start_x;
			my $end_y=$YY+$radius;
			my $path = $svg->path(
			    d => "M $start_x $start_y " .  # 移动到起点
	                 "A $radius $radius 0 1 1 $end_x $end_y",  # 绘制半圆
			    style => {
			        fill => $Col,
			        stroke => 'none'
			    }
			);
		}




	}
}
######################swimming in the sky and flying in the sea ########################

