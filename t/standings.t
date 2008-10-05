#
use strict;
use warnings;

use Test::More qw(no_plan);
use File::Slurp;

BEGIN { use_ok('BuzzerBeater::Client'); }

my $user         = 'oeuftete';
my $access_code  = 'alphonse';
my $agent        = 'oeuftete-test-app/0.1';
my $login_params = { params => { login => $user, code => $access_code } };

my $bb = new BuzzerBeater::Client;

$bb->agent($agent);
is( $bb->agent, $agent, 'Agent set' );

my $standings;
SKIP: {
    skip 'Site problems', 2 if $ENV{BB_SITE_PROBLEMS};
    ok( $bb->login($login_params), 'Login successful' );

    isa_ok( $standings = $bb->standings, 'BuzzerBeater::Standings' );
}

my $xml_input = read_file('t/files/standings.xml');
isa_ok( $standings = $bb->standings( { xml => $xml_input } ),
    'BuzzerBeater::Standings' );
is( $standings->league(),  'Naismith', 'Check league name' );
is( $standings->country(), 'Canada',   'Check country name' );

my $team_standings;
isa_ok( $team_standings = $standings->team(24818), 'HASH' );
is( $team_standings->{id}, 24818, 'Same team id back we supplied' );
is( $team_standings->{pf}, 1077,  'Points for correct' );
is( $team_standings->{conference}, 'Great 8', 'Conference name correct' );

