#
#  $Id: leagues.t,v 1.3 2009-04-05 20:49:16 ken Exp $
#
use strict;
use warnings;

use Test::More qw(no_plan);
use File::Slurp;

BEGIN { use_ok('BuzzerBeater::Client'); }

my $bb = BuzzerBeater::Client->new;

my $leagues;
my $xml_input = read_file('t/files/leagues.xml');
isa_ok( $leagues = $bb->leagues( { xml => $xml_input } ),
    'BuzzerBeater::Leagues' );

is( $leagues->countryid, 4, 'Country id');
is( $leagues->level, 3, 'League level');

my $lh = $leagues->leagues;
is( scalar keys %$lh, 16, 'Number of leagues returned');
is( $lh->{137}, 'III.5', 'League name by id');
