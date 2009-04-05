#
#  $Id: economy.t,v 1.2 2009-04-05 20:49:16 ken Exp $
#
use strict;
use warnings;

use Test::More qw(no_plan);
use File::Slurp;

BEGIN { use_ok('BuzzerBeater::Client'); }

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
