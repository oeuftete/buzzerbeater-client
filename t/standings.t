#
use strict;
use warnings;

use Test::More qw(no_plan);
use File::Slurp;

BEGIN { use_ok('BuzzerBeater::Client'); }

my $bb = BuzzerBeater::Client->new();

my $xml_input = read_file('t/files/standings.xml');
isa_ok( my $standings = $bb->standings( { xml => $xml_input } ),
    'BuzzerBeater::Standings' );
is( $standings->league,  'Naismith', 'Check league name' );
is( $standings->country, 'Canada',   'Check country name' );

{
    isa_ok( my $team_standings = $standings->team(24818), 'HASH' );
    is( $team_standings->{id}, 24818, 'Same team id back we supplied' );
    is( $team_standings->{pf}, 1077,  'Points for correct' );
    is( $team_standings->{conference}, 'Great 8', 'Conference name correct' );
}
