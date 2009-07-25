#
#  $Id$
#
use utf8;
use strict;
use warnings;

use Test::More qw(no_plan);
use File::Slurp;

BEGIN { use_ok('BuzzerBeater::Client'); }

TODO: {
    eval "use Test::Pod::Coverage";
    todo_skip "Test::Pod::Coverage required for testing pod coverage", 1
        if $@;

    local $TODO = "Pod not written yet!";

    pod_coverage_ok( 'BuzzerBeater::Arena',
        'BuzzerBeater::Arena pod is covered' );
}

my $bb = BuzzerBeater::Client->new;

{
    my $xml_input = read_file('t/files/arena.xml');
    isa_ok( my $arena = $bb->arena( { xml => $xml_input } ),
        'BuzzerBeater::Arena' );

    is( $arena->teamid, 24818, 'teamid' );
    is( $arena->name, 'Cape Sable Sculpins Center', 'name' );
    is( $arena->seats->{lowerTier}->{number}, 1388, 'seat type number' );
    is( $arena->seats->{lowerTier}->{price},  67,   'seat type price' );
    is( $arena->size, 13039 + 1388 + 317 + 22, 'total arena size' );
    is( $arena->expansion, undef, 'no expansion' );
}

{
    my $xml_input = read_file('t/files/arena_expansion.xml');
    isa_ok( my $arena = $bb->arena( { xml => $xml_input } ),
        'BuzzerBeater::Arena' );

    my $e = $arena->expansion;
    is( $e->{daysLeft},  1,   'Days remaining in expansion' );
    is( $e->{lowerTier}, 100, 'Expansion seats for one type' );
    is( $arena->expansion_size, 800 + 100 + 30 + 0, 'total expansion size' );

}

{
    my $xml_input = read_file('t/files/arena_unicode.xml');
    isa_ok( my $arena = $bb->arena( { xml => $xml_input } ),
        'BuzzerBeater::Arena' );

    is( $arena->name, 'BC Törööö Center', 'name with extra chars' );
}
