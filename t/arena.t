#
use strict;
use warnings;

use Test::More qw(no_plan);
use File::Slurp;

BEGIN { use_ok('BuzzerBeater::Client'); }

my $bb = BuzzerBeater::Client->new;

my $xml_input = read_file('t/files/arena.xml');
isa_ok( my $arena = $bb->arena( { xml => $xml_input } ),
    'BuzzerBeater::Arena' );

is( $arena->teamid, 24818, 'teamid getter' );
is( $arena->name, 'Cape Sable Sculpins Center', 'name getter' );
is( $arena->seats->{lowerTier}->{value}, 1388,  'seats getter: value' );
is( $arena->seats->{lowerTier}->{price}, 67,    'seats getter: price' );
is( $arena->expansion,                   undef, 'expansion getter' );
