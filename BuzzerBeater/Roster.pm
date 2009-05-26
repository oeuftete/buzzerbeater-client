#
#  $Id$
#

use strict;
use warnings;

package BuzzerBeater::Roster;

use XML::Twig;
use Carp;

use BuzzerBeater::Player;

sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;
    $self->_initialize(@_);
    return $self;
}

sub _initialize {
    my $self = shift;

    if (@_) {
        my $args = shift;
        $self->_setFromXml( $args->{xml} ) if ( exists $args->{xml} );
    }
}

sub _setFromXml {
    my $self = shift;
    my $xml  = shift;

    my $twig = XML::Twig->new();
    $twig->parse($xml);    # safe_parse or croak?

    my $root = $twig->root;
    my $el   = $root->first_child();

    if ( $el->gi eq 'roster' ) {

        #  Set teamid
        $self->{teamid}  = $el->att('teamid');
        $self->{players} = [];

        foreach my $player ( $el->children ) {
            my $p = BuzzerBeater::Player->new();
            $p->id( $player->att('id') );

            foreach my $playerEl ( $player->children ) {
                if ( $playerEl->gi eq 'skills' ) {
                    foreach my $skill ( $playerEl->children ) {
                        $p->skills( $skill->gi, $skill->text );
                    }
                }
                elsif ( $playerEl->gi eq 'nationality' ) {
                    $p->nationality( $playerEl->text, $playerEl->att('id') );
                }
                else {
                    $p->basic( $playerEl->gi, $playerEl->text );
                }
            }
            push @{ $self->{players} }, $p;
        }
    }

    else {
        carp "Unexpected child element processing roster xml: " . $el->gi;
    }
    return $self;
}

sub teamid  { my $self = shift; return $self->{teamid} }
sub players { my $self = shift; return $self->{players} }

#  Searches for players by id or name.
sub findPlayer {

    my $self   = shift;
    my $findId = shift;

    # TODO: Iterate over $self->{players}
    # Does $p->id match?
    foreach my $p ( @{ $self->{players} } ) {
        return $p if ( $p->id == $findId );
    }
    return undef;
}

1;
