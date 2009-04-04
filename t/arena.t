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

my $bb = BuzzerBeater::Client->new;

$bb->agent($agent);
is( $bb->agent, $agent, 'Agent set' );

ok( $bb->login($login_params), 'Login successful' );

my $arena;
isa_ok( $arena = $bb->arena, 'BuzzerBeater::Arena' );

my $xml_input = read_file('t/files/arena.xml');
isa_ok( $arena = $bb->arena( { xml => $xml_input } ), 'BuzzerBeater::Arena' );

is( $arena->teamid, 24818, 'teamid getter' );
is( $arena->name, 'Cape Sable Sculpins Center', 'name getter' );
is( $arena->seats->{lowerTier}->{value}, 1388,  'seats getter: value' );
is( $arena->seats->{lowerTier}->{price}, 67,    'seats getter: price' );
is( $arena->expansion,                   undef, 'expansion getter' );

