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

ok( $bb->login($login_params), 'Login successful' );

my $standings;
isa_ok( $standings = $bb->standings, 'BuzzerBeater::Standings' );

my $xml_input = read_file('t/files/standings.xml');
isa_ok( $standings = $bb->standings( { xml => $xml_input } ), 'BuzzerBeater::Standings' );

is( $standings->teamid, 24818, 'teamid getter' );
is( $standings->name, 'Cape Sable Sculpins Center', 'name getter' );
is( $standings->seats->{lowerTier}->{value}, 1388,  'seats getter: value' );
is( $standings->seats->{lowerTier}->{price}, 67,    'seats getter: price' );
is( $standings->expansion,                   undef, 'expansion getter' );

