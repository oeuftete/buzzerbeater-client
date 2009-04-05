#
#  $Id: teamstats.t,v 1.3 2009-04-05 20:49:16 ken Exp $
#
use strict;
use warnings;

use Test::More qw(no_plan);
use File::Slurp;

BEGIN { use_ok('BuzzerBeater::Client'); }

my $bb = BuzzerBeater::Client->new();

my $teamstats;
my $xml_input = read_file('t/files/teamstats_totals.xml');
isa_ok( $teamstats = $bb->teamstats( { xml => $xml_input } ),
    'BuzzerBeater::Teamstats' );

is( $teamstats->id,     24818, 'Check team id' );
is( $teamstats->season, 7,     'Check season' );

is( $teamstats->teamTotals->{ast}, 232, 'Team stat total' );
