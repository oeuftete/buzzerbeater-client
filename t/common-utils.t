#
#  $Id: common-utils.t,v 1.1 2009-04-04 01:15:29 ken Exp $
#
use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN { use_ok( 'BuzzerBeater::Common::Utils', qw(is_match_type) ); }

ok( is_match_type( 'friendly', 'friendly' ), 'Friendlies are friendly' );
ok( !is_match_type( 'league.rs', 'friendly' ),
    'League matches not friendly' );
ok( !is_match_type( 'bbb', 'friendly' ), 'B3 matches not friendly' );
ok( is_match_type( 'bbb', 'competitive' ), 'B3 matches are competitive' );
ok( is_match_type( 'league.rs', 'competitive' ),
    'League matches are competitive' );
ok( is_match_type( 'bbb', 'WRONG' ), 'Garbage match type passes through' );

