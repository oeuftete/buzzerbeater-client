#
#  $Id: player.t,v 1.1 2009-04-12 12:25:41 ken Exp $
#
use strict;
use warnings;

use Test::More qw(no_plan);
use File::Slurp;

BEGIN { use_ok('BuzzerBeater::Client'); }

my $bb = BuzzerBeater::Client->new();

my $xml_input = read_file('t/files/player.xml');
isa_ok( my $player = $bb->player( { xml => $xml_input } ),
    'BuzzerBeater::Player' );

is( $player->id,    2563479, 'Player id' );
is( $player->owner, 24818,   'Player\'s owner' );

is( $player->name, 'Miroslaw Tchorzewski', 'Name' );

#  Nationality
{
    my $nat = $player->nationality;
    is( $nat->{id},   58,,      'Nationality name' );
    is( $nat->{name}, 'Polska', 'Nationality name' );
}

#  Skills
{
    my $skills = $player->skills;
    is( $skills->{jumpShot}, 4, 'Skill value' );
}

#  Basic data
{
    my $basic = $player->basic;
    is( $basic->{age},    30, 'Age' );
    is( $basic->{jersey}, 49, 'Jersey' );
}

#  Setters
