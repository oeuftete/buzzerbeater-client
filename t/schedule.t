#
#  $Id$
#
use strict;
use warnings;

use Test::More qw(no_plan);
use File::Slurp;

BEGIN { use_ok('BuzzerBeater::Client'); }

TODO: {
    eval "use Test::Pod::Coverage";
    todo_skip "Test::Pod::Coverage required for testing pod coverage", 1
        if $@;

    local $TODO = "Pod not written yet!";

    pod_coverage_ok( 'BuzzerBeater::Schedule',
        'BuzzerBeater::Schedule pod is covered' );
}

my $bb = BuzzerBeater::Client->new;

my $xml_input = read_file('t/files/schedule.xml');
isa_ok( my $schedule = $bb->schedule( { xml => $xml_input } ),
    'BuzzerBeater::Schedule' );

is( $schedule->teamid(), 24818, 'Check team id' );
is( $schedule->season(), 6,     'Check season' );

is( scalar @{ $schedule->matches() },
    40, 'Correct number of matches returned' );

is( scalar @{ $schedule->matches( { type => 'WRONG' } ) },
    40, 'All matches returned with bad filter' );

is( scalar @{ $schedule->matches( { completed => 1 } ) },
    31, 'Correct number of completed matches returned' );

is( scalar @{ $schedule->matches( { type => 'friendly' } ) },
    1, 'Correct number of scrimmages returned' );

is( scalar @{ $schedule->matches( { type => 'bbb' } ) },
    0, 'Correct number of B3 matches returned' );

#  Competitive matches (as argument)
{
    my @cm = @{ $schedule->matches( { type => 'competitive' } ) };
    is( scalar @cm, 31, 'Correct number of competitive matches returned' );
    is( $cm[1]->{id}, 6351251, 'Match ID for arbitrary competitive match' );
}

#  Competitive matches (shortcut method)
{
    my @cm = @{ $schedule->competitive_matches() };
    is( scalar @cm, 31,
        'Correct number of competitive matches returned (shortcut)' );
    is( $cm[1]->{id}, 6351251,
        'Match ID for arbitrary competitive match (shortcut)' );

    is( scalar @{ $schedule->competitive_matches( { completed => 1 } ) },
        22, 'Correct number of completed competitive matches returned' );
}
