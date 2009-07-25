#
#  $Id$
#
use utf8;
use strict;
use warnings;

use Test::More;
use Test::Warn;
use File::Slurp;

BEGIN { use_ok('BuzzerBeater::Client'); }

TODO: {
    eval "use Test::Pod::Coverage";
    todo_skip "Test::Pod::Coverage required for testing pod coverage", 1
        if $@;

    local $TODO = "Pod not written yet!";

    pod_coverage_ok( 'BuzzerBeater::Player',
        'BuzzerBeater::Player pod is covered' );
}

my $bb = BuzzerBeater::Client->new();

#  Basic case.
{
    my $xml_input = read_file('t/files/player.xml');
    isa_ok( my $player = $bb->player( { xml => $xml_input } ),
        'BuzzerBeater::Player' );

    is( $player->id,    2563479, 'Player id' );
    is( $player->owner, 24818,   'Player\'s owner' );

    is( $player->name, 'Miroslaw Tchorzewski', 'Name' );

    #  Nationality
    my $nat = $player->nationality;
    is( $nat->{id},   58,,      'Nationality name' );
    is( $nat->{name}, 'Polska', 'Nationality name' );

    #  Skills
    my $skills = $player->skills;
    is( $skills->{jumpShot}, 4, 'Skill value' );

    #  Basic data
    my $basic = $player->basic;
    is( $basic->{age},    30, 'Age' );
    is( $basic->{jersey}, 49, 'Jersey' );

    #  Salary estimation
    is( int( $player->josef_ka ), 3374, 'Salary estimation' );
}

#  Extended characters in name.
{
    my $xml_input = read_file('t/files/player_unicode_name.xml');
    my $player = $bb->player( { xml => $xml_input } );

    is( $player->name, 'Ozren Ðukanovic', 'Extended character name' );
}

#  Non-owned player.
{
    my $xml_input = read_file('t/files/player_private.xml');
    my $player = $bb->player( { xml => $xml_input } );

    #  Skills
    my $skills = $player->skills;
    is( $skills->{potential}, 8, 'Public skill value' );

    #  Salary estimation
    warning_like { is( $player->josef_ka, undef, 'Salary estimation fails' ) }
    qr/estimation not possible/, 'Expected warning message';
}
done_testing;
