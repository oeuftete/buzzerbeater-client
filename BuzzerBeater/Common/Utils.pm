#
#  $Id$
#

use strict;
use warnings;

package BuzzerBeater::Common::Utils;

use parent qw(Exporter);
our @EXPORT_OK = qw(is_match_type encode_bb_text);

use Carp qw(carp);

#  This is what mixins/roles are for, I guess.
sub is_match_type {

    my ( $type, $wanted ) = @_;

    my %type_grep = (
        friendly => sub { shift eq 'friendly' },
        bbb    => sub { shift =~ m/^bbb/ },
        league => sub { shift =~ m/^league/ },
        cup    => sub { shift =~ m/^cup/ },
        pl     => sub { shift =~ m/^pl/ },
    );

    $type_grep{competitive} = sub {
        my $t = shift;
        $type_grep{bbb}->($t)
            || $type_grep{league}->($t)
            || $type_grep{cup}->($t);
    };

    if ( exists $type_grep{$wanted} ) {
        return $type_grep{$wanted}->($type);
    }

    carp "Bad type filter [$wanted]!  Type filter ignored.";
    return 1;
}

sub encode_bb_text {
    my $bb_text = shift;
    $bb_text =~ s/%/'/g;
    return $bb_text;
}

1;
