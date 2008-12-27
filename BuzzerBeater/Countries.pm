#
#  $Id: Countries.pm,v 1.1 2008-12-27 18:21:09 ken Exp $
#

use strict;
use warnings;

package BuzzerBeater::Countries;

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
        $self->setFromXml( $args->{xml} ) if ( exists $args->{xml} );
    }

    $self->{countries} = [];
}

sub setFromXml {
    my $self = shift;
    my $xml  = shift;

    my %c;

    my $twig = new XML::Twig;
    $twig->parse($xml);    # safe_parse or croak?

    my $root = $twig->root;
    my $el   = $root->first_child();

    if ( $el->gi eq 'countries' ) {

        #  Loop over the country list.
        foreach my $country ( $el->children ) {

            #  Countries as an array of hashes?  Maintain a list of id/name
            #  mappings for easy lookup?

            my %_c_details = %{ $country->atts };
            $_c_details{name} = encode_utf8( $country->text );

            push @{ $self->{country} }, \%_c_details;

        }
    }

    else {
        carp "Unexpected child element processing countries xml: " . $el->gi;
    }
    return $self;
}

sub country_list { my $self = shift; return @{ $self->{country} }; }

sub country_list_by_id {
    my $self = shift;
    return map {
        my %_temp = %{$_};
        delete $_temp{id};
        $_->{id} => \%_temp;
    } @{ $self->{country} };
}

sub country_list_by_name {
    my $self = shift;
    return map {
        my %_temp = %{$_};
        delete $_temp{name};
        $_->{name} => \%_temp;
    } @{ $self->{country} };
}

1;
