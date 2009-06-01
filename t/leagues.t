#
#  $Id$
#
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

    pod_coverage_ok( 'BuzzerBeater::Leagues',
        'BuzzerBeater::Leagues pod is covered' );
}

my $bb = BuzzerBeater::Client->new;

my $leagues;

{
    my $xml_input = read_file('t/files/leagues.xml');
    isa_ok( $leagues = $bb->leagues( { xml => $xml_input } ),
        'BuzzerBeater::Leagues' );

    is( $leagues->countryid, 4, 'Country id' );
    is( $leagues->level,     3, 'League level' );

    my $lh = $leagues->leagues;
    is( scalar keys %$lh, 16,      'Number of leagues returned' );
    is( $lh->{137},       'III.5', 'League name by id' );
}

{
    my $xml_input = read_file('t/files/leagues_utf8_league_name.xml');
    isa_ok( $leagues = $bb->leagues( { xml => $xml_input } ),
        'BuzzerBeater::Leagues' );
    my $lh = $leagues->leagues;
    is( $lh->{1847}, 'Virslīga', 'utf-8 league name' );
}
