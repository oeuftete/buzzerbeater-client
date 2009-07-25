#
#  $Id$
#
use utf8;
use strict;
use warnings;

use Test::More;
use File::Slurp;

BEGIN { use_ok('BuzzerBeater::Client'); }

TODO: {
    eval "use Test::Pod::Coverage";
    todo_skip "Test::Pod::Coverage required for testing pod coverage", 1
        if $@;

    local $TODO = "Pod not written yet!";

    pod_coverage_ok( 'BuzzerBeater::Countries',
        'BuzzerBeater::Countries pod is covered' );
}

my $bb = BuzzerBeater::Client->new;

my $countries;
my $xml_input = read_file('t/files/countries.xml');
isa_ok( $countries = $bb->countries( { xml => $xml_input } ),
    'BuzzerBeater::Countries' );

my @country_list = $countries->country_list;
my $china        = $country_list[4];
is( $china->{name},  'China', 'Fifth country listed is China' );
is( $china->{users}, 921,     'China has 921 users in the test XML' );

my %country_by_id = $countries->country_list_by_id;
is( $country_by_id{34}->{name}, 'Bolivia', 'By id: name lookup' );

my %country_by_name = $countries->country_list_by_name;
is( $country_by_name{Nippon}->{firstSeason},
    3, 'By name: first season lookup' );

ok( exists $country_by_name{'Ísland'}, 'utf-8 country name' );
done_testing;
