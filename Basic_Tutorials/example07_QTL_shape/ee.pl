#!/usr/bin/perl
use strict;
use warnings;

sub draw_color_legend {
    my (
        $svg,
        $LegendOffsetRatio,
        $Bodyheight,
        $ColorBarSize,
        $ColorGradientArray_ref,
        $ValueLabelsGradient_ref,
        $HashConfi_ref,
        $Level,
        $legend_type,
        $shapeType_ref = undef
    ) = @_;

    print "Function called with \$shapeType_ref: ";
    if (defined $shapeType_ref) {
        print $shapeType_ref;
    } else {
        print "undef";
    }
    print "\n";
}

# 调用子例程，不传递 $shapeType_ref 参数
draw_color_legend(1, 2, 3, 4, [], [], {}, "level1", "type");

# 调用子例程，传递 $shapeType_ref 参数
draw_color_legend(1, 2, 3, 4, [], [], {}, "level1", "type", "test");
