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

    pod_coverage_ok( 'BuzzerBeater::Economy',
        'BuzzerBeater::Economy pod is covered' );
}

my $bb = BuzzerBeater::Client->new();

my $economy;
my $xml_input = read_file('t/files/economy.xml');
isa_ok( $economy = $bb->economy( { xml => $xml_input } ),
    'BuzzerBeater::Economy' );

is( $economy->balance, 2903213, 'check current balance' );
cmp_ok( $economy->playerSalaries, '==', 211542,
    'check current player salaries' );
is( $economy->lastWeek->{matchRevenue}->{'8440607'},
    334017, 'Check a match\'s revenue from last week' );
is( $economy->thisWeek->{matchRevenue}->{'10335700'},
    90000, 'Check a match\'s revenue from this week' );
