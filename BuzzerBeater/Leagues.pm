#
#  $Id$
#

use strict;
use warnings;

package BuzzerBeater::Leagues;

use Encode;
use XML::Twig;
use Carp;

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

    $self->{leagues} = [];
}

sub _setFromXml {
    my $self = shift;
    my $xml  = shift;

    my $twig = XML::Twig->new();
    $twig->parse($xml);    # safe_parse or croak?

    my $root = $twig->root;
    my $el   = $root->first_child();

    if ( $el->gi eq 'division' ) {

        #  TODO: Check to make sure level and country id are what was
        #  specified.
        $self->{countryid} = $el->att('countryid');
        $self->{level}     = $el->att('level');

        #  Loop over the country list.
        my %leagues;
        foreach my $league ( $el->children ) {
            $leagues{ $league->att('id') } = $league->text;
        }
        $self->{leagues} = \%leagues;
    }

    else {
        carp "Unexpected child element processing leagues xml: " . $el->gi;
    }
    return $self;
}

sub leagues   { my $self = shift; return $self->{leagues}; }
sub countryid { my $self = shift; return $self->{countryid}; }
sub level     { my $self = shift; return $self->{level}; }

1;
