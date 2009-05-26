#
#  $Id$
#
use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN { use_ok( 'BuzzerBeater::Common::Utils', qw(is_match_type) ); }

TODO: {
    eval "use Test::Pod::Coverage";
    todo_skip "Test::Pod::Coverage required for testing pod coverage", 1
        if $@;

    local $TODO = "Pod not written yet!";

    pod_coverage_ok( 'BuzzerBeater::Common::Utils',
        'BuzzerBeater::Common::Utils pod is covered' );
}

ok( is_match_type( 'friendly', 'friendly' ), 'Friendlies are friendly' );
ok( !is_match_type( 'league.rs', 'friendly' ),
    'League matches not friendly' );
ok( !is_match_type( 'bbb', 'friendly' ), 'B3 matches not friendly' );
ok( is_match_type( 'bbb', 'competitive' ), 'B3 matches are competitive' );
ok( is_match_type( 'league.rs', 'competitive' ),
    'League matches are competitive' );
ok( is_match_type( 'bbb', 'WRONG' ), 'Garbage match type passes through' );

