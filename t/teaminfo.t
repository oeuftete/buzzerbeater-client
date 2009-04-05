#
#  $Id: teaminfo.t,v 1.6 2009-04-05 20:49:16 ken Exp $
#
use strict;
use warnings;

use Test::More qw(no_plan);
use File::Slurp;

BEGIN { use_ok('BuzzerBeater::Client'); }

my $bb = BuzzerBeater::Client->new;

#  User team
{
    my $xml_input = read_file('t/files/teaminfo.xml');
    isa_ok( my $teaminfo = $bb->teaminfo( { xml => $xml_input } ),
        'BuzzerBeater::Teaminfo' );

    is( $teaminfo->league,    'Naismith', 'Check league name' );
    is( $teaminfo->leagueid,  128,        'Check league ID' );
    is( $teaminfo->country,   'Canada',   'Check country name' );
    is( $teaminfo->owner,     'oeuftete', 'Check owner' );
    is( $teaminfo->shortName, 'CSI',      'Check short name' );
}

#  Bot team
{
    my $xml_input = read_file('t/files/teaminfo_bot.xml');
    isa_ok( my $teaminfo = $bb->teaminfo( { xml => $xml_input } ),
        'BuzzerBeater::Teaminfo' );

    is( $teaminfo->owner(), undef, 'Check empty owner on bot' );
}
