use Test::More;
use strict;
use warnings;

plan tests => 5;

BEGIN {
    use FindBin;
    use lib "$FindBin::Bin/../lib";
}

use Math::Clipper ':all';
use Slic3r;

{
    my $square = [ # ccw
        [10, 10],
        [20, 10],
        [20, 20],
        [10, 20],
    ];
    my $hole_in_square = [  # cw
        [14, 14],
        [14, 16],
        [16, 16],
        [16, 14],
    ];
    my $square2 = [  # ccw
        [5, 12],
        [25, 12],
        [25, 18],
        [5, 18],
    ];
    my $clipper = Math::Clipper->new;
    $clipper->add_subject_polygons([ $square, $hole_in_square ]);
    $clipper->add_clip_polygons([ $square2 ]);
    my $intersection = $clipper->ex_execute(CT_INTERSECTION, PFT_NONZERO, PFT_NONZERO);
    is_deeply $intersection, [
        {
            holes => [
                [
                    [14, 16],
                    [16, 16],
                    [16, 14],
                    [14, 14],
                ],
            ],
            outer => [
                [10, 18],
                [10, 12],
                [20, 12],
                [20, 18],
            ],
        },
    ], 'hole is preserved after intersection';
}

#==========================================================

{
    # suppose we have a square with a hole and we want to cover the hole with a patch
    my $contour1 = [ [0,0],   [40,0],  [40,40], [0,40]  ];  # ccw
    my $contour2 = [ [10,10], [30,10], [30,30], [10,30] ];  # ccw
    my $hole     = [ [15,15], [15,25], [25,25], [25,15] ];  # cw
    
    my $clipper = Math::Clipper->new;
    $clipper->add_subject_polygons([ $contour1, $contour2, $hole ]);
    
    my $union = $clipper->ex_execute(CT_UNION, PFT_NONZERO, PFT_NONZERO);
    is_deeply $union, [{ holes => [], outer => [ [0,40], [0,0], [40,0], [40,40] ] }],
        'union of two ccw and one cw is a contour with no holes';
    
    $clipper->clear;
    $clipper->add_subject_polygons([ $contour1, $contour2 ]);
    $clipper->add_clip_polygons([ $hole ]);
    my $diff = $clipper->ex_execute(CT_DIFFERENCE, PFT_NONZERO, PFT_NONZERO);
    is_deeply $diff, [{ holes => [[ [15,25], [25,25], [25,15], [15,15] ]], outer => [ [0,40], [0,0], [40,0], [40,40] ] }],
        'difference of a cw from two ccw is a contour with one hole';
}

#==========================================================

{
    # suppose we have a square with a hole and we want to cover the hole with a patch
    # and extract the anchor area
    my $contour  = [ [0,0],   [40,0],  [40,40], [0,40]  ];  # ccw
    my $hole     = [ [15,15], [15,25], [25,25], [25,15] ];  # cw
    my $patch    = [ [10,10], [30,10], [30,30], [10,30] ];  # ccw
    
    my $clipper = Math::Clipper->new;
    $clipper->add_subject_polygons([ $contour, $hole ]);
    $clipper->add_clip_polygons([ $patch ]);
    
    my $union = $clipper->ex_execute(CT_INTERSECTION, PFT_NONZERO, PFT_NONZERO);
    is_deeply $union, [{
        holes => [ [ [15,25], [25,25], [25,15], [15,15] ] ],
        outer => [ [10,30], [10,10], [30,10], [30,30] ],
    }], 'intersection of two ccw and one cw is a contour with hole';
}

#==========================================================

{
    my $wkt = q[5079998 72180618,71119999 72180618,71304176 72164504,71482762 72116656,71650308 72038519,71801757 71932486,71932486 71801757,72038519 71650308,72116656 71482762,72164504 71304176,72180618 71119999,72180618 5079998,72164504 4895824,72116656 4717244,72038519 4549687,71932486 4398245,71801757 4267515,71650308 4161473,71482762 4083341,71304175 4035490,71119999 4019380,5079997 4019380,4895823 4035491,4717244 4083341,4606963 4134765,4398245 4267515,4267515 4398245,4161474 4549686,4083341 4717244,4035491 4895824,4019380 5079997,4019380 71119999,4035491 71304176,4083341 71482763,4161473 71650307,4267515 71801757,4398245 71932486,4497919 72002279,4717244 72116657,4895823 72164504];
    my $p = Slic3r::Polygon->new(map [ split / /, $_ ], split /,/, $wkt);
    is is_counter_clockwise($p), is_counter_clockwise($p->safety_offset), 'offset polygon has same orientation';
}

__END__
