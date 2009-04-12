#
#  $Id: roster.t,v 1.3 2009-04-12 12:29:27 ken Exp $
#
use strict;
use warnings;

use Test::More qw(no_plan);
use File::Slurp;

BEGIN { use_ok('BuzzerBeater::Client'); }

my $bb = BuzzerBeater::Client->new();

my $roster;
my $xml_input = read_file('t/files/roster.xml');
isa_ok( $roster = $bb->roster( { xml => $xml_input } ),
    'BuzzerBeater::Roster' );

is( $roster->teamid, 24818, 'Check team id' );

{
    my $found_player = $roster->findPlayer(4639936);
    isa_ok( $found_player, 'BuzzerBeater::Player' );
    is( $found_player->name, 'Adriano Fabiano',
        'Check name of found player' );
}

{
    my $player_list = $roster->players;
    isa_ok( $player_list,      'ARRAY' );
    isa_ok( $player_list->[0], 'BuzzerBeater::Player' );
    is( scalar(@$player_list), 12, 'Twelve players in the roster' );
}
