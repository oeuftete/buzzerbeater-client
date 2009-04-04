#
#  $Id: roster.t,v 1.1 2009-04-04 12:49:42 ken Exp $
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

my $bb = BuzzerBeater::Client->new();

$bb->agent($agent);
is( $bb->agent, $agent, 'Agent set' );

my $roster;
SKIP: {
    skip 'Site problems', 2 if $ENV{BB_SITE_PROBLEMS};
    ok( $bb->login($login_params), 'Login successful' );

    isa_ok( $roster = $bb->roster, 'BuzzerBeater::Roster' );
}

my $xml_input = read_file('t/files/roster.xml');
isa_ok( $roster = $bb->roster( { xml => $xml_input } ),
    'BuzzerBeater::Roster' );

is( $roster->teamid, 24818, 'Check team id' );

my $found_player = $roster->findPlayer(4639936);
isa_ok( $found_player, 'BuzzerBeater::Player' );
is( $found_player->getName, 'Adriano Fabiano', 'Check name of found player' );

my $player_list = $roster->players;
isa_ok( $player_list,      'ARRAY' );
isa_ok( $player_list->[0], 'BuzzerBeater::Player' );
is( scalar(@$player_list), 12, 'Twelve players in the roster' );
