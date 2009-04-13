#
#  $Id: Client.pm,v 1.9 2009-04-12 17:23:17 ken Exp $
#

use strict;
use warnings;

package BuzzerBeater::Client;
use parent 'LWP::UserAgent';

use Carp;

use List::Util qw( shuffle );
use Array::Iterator::Circular;

use LWP::UserAgent;

use XML::Twig;

use BuzzerBeater::Arena;
use BuzzerBeater::Boxscore;
use BuzzerBeater::Countries;
use BuzzerBeater::Economy;
use BuzzerBeater::Player;
use BuzzerBeater::Roster;
use BuzzerBeater::Schedule;
use BuzzerBeater::Standings;
use BuzzerBeater::Teaminfo;
use BuzzerBeater::Teamstats;

########################################################################
#
#  API

#
#  TODO: Document allowable arguments.
#
sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;
    $self->_initialize(@_);
    return $self;
}

sub debug {
    my $self = shift;

    if (@_) {
        my $_debug_level = shift;
        $self->{debug} = $_debug_level;
        return $self;
    }
    else {
        return $self->{debug};
    }
}

sub lastError {
    my $self = shift;
    return $self->{lastError};
}

# TODO Login and logout really should be abstractable a bit more.
#
# login(\%options)
#
# Returns:
#   0 - Error, use $object->{lastError}
#   1 - Successful login

sub login {

    my ( $self, $options ) = @_;

    my $loggedIn = 0;

    my $req = $self->_newRequest(
        {   apiMethod => 'login',
            params    => $options->{params}
        }
    );

    my $response = $self->request($req);

    if ( $response->is_success ) {

        ( $self->debug > 0 ) && printf "%s\n", $response->content;
        if ( $self->debug > 1 ) {
            open RESPONSE, ">dumps/login.xml"
                or croak "Unable to open file to dump xml: $!\n";
            print RESPONSE $response->content;
            close RESPONSE;
        }

        my $twig = XML::Twig->new(
            TwigRoots => {
                loggedIn => sub { $loggedIn = 1 },
                error => sub { $self->_setErrorFromXml(@_) }
            }
        );

        $twig->parse( $response->content );
    }
    else {
        $self->{lastError} = "Unexpected error: " . $response->status_line;
    }
    return $loggedIn;
}

# logout(\%options)
#
# Returns:
#   0 - Error, use $object->{lastError}
#   1 - Successful logout

sub logout {
    my ( $self, $options ) = @_;

    my $loggedOut = 0;

    my $req = $self->_newRequest( { apiMethod => 'logout' } );
    my $response = $self->request($req);

    if ( $response->is_success ) {
        ( $self->debug > 0 ) && printf "%s\n", $response->content;
        if ( $self->debug > 1 ) {
            open RESPONSE, ">dumps/logout.xml"
                or croak "Unable to open file to dump xml: $!\n";
            print RESPONSE $response->content;
            close RESPONSE;
        }

        my $twig = XML::Twig->new(
            TwigRoots => {
                loggedOut => sub { $loggedOut = 1 },
                error => sub { $self->_setErrorFromXml(@_) }
            }
        );

        $twig->parse( $response->content );
    }
    else {
        $self->{lastError} = "Unexpected error: " . $response->status_line;
    }
    return $loggedOut;
}

#  END API
########################################################################

#  Use AUTOLOAD to return our various similar objects
sub AUTOLOAD {

    my $self = shift;

    our $AUTOLOAD;
    ( my $method = $AUTOLOAD ) =~ s/.*:://s;

    my @autos
        = qw( arena boxscore countries economy player roster schedule standings
        teaminfo teamstats);

    my $obj;
    if ( grep {/$method/} @autos ) {
        $obj = $self->_generic( $method, @_ );
    }
    else {
        croak "Method [$method] not defined!";
    }
    return $obj;
}

sub DESTROY {
    my $self = shift;
    $self->logout;  # don't care if it fails
}

sub _initialize {
    my $self = shift;

    my %args = @_;

    if ( exists $args{agent} ) {
        $self->agent( $args{agent} );
    }

    $self->debug(0);
    if ( exists $args{debug} ) {
        $self->debug( $args{debug} );
    }

    $self->{apiUrls} = [
        qw ( http://www.buzzerbeater.com/BBAPI/
            http://www2.buzzerbeater.org/BBAPI/ )
    ];

    $self->{_apiIterator}
        = Array::Iterator::Circular->new( shuffle @{ $self->{apiUrls} } );
    $self->_selectSite;
    $self->{lastError} = '';
    $self->cookie_jar( {} );
}

sub _selectSite {
    my $self = shift;

    #  Choose the next URL in the cycle
    $self->{_apiSite} = $self->{_apiIterator}->next;
}

sub _newRequest {
    my ( $self, $args ) = @_;

    my $url = $self->{_apiSite} . $args->{apiMethod} . '.aspx';

    if ( my $p = $args->{params} ) {
        $url .= '?' . join( '&', map { $_ . '=' . $p->{$_} } keys %$p );
    }

    $self->debug && print "Sending [$url]\n";
    my $req = HTTP::Request->new( GET => $url );
}

sub _setErrorFromXml {
    my ( $self, $t, $error ) = @_;
    $self->{lastError} = $error->att('message');
}

sub _generic {
    my ( $self, $method, $options ) = @_;

    my $return_module = ucfirst $method;
    my $obj           = {};

    # TODO : Check that the module is included
    bless $obj, "BuzzerBeater::$return_module";
    $obj->_initialize(@_);

    $self->_abstractRequest( $method, $options, \$obj );
}

#
# _abstractRequest($method, \%options, \$returnValue)
#
# Initialize the $returnValue object before calling this.
#
# Returns:
#   0 - Error, use $object->{lastError}
#   Other - Successful

sub _abstractRequest {
    my ( $self, $method, $options, $r ) = @_;

    #  TODO: Is the xml option set?  If so make the request
    if ( exists( $options->{xml} ) ) {
        ( $self->debug > 0 ) && printf "%s\n", $options->{xml};
        $$r->_setFromXml( $options->{xml} );
    }
    else {

        my $req = $self->_newRequest(
            {   apiMethod => $method,
                params    => $options->{params}
            }
        );
        my $response = $self->request($req);

        if ( $response->is_success ) {

            if ( $self->debug > 1 ) {
                printf "%s\n", $response->as_string;
            }
            elsif ( $self->debug > 0 ) {
                printf "%s\n", $response->content;
            }

            if ( $self->debug > 1 ) {
                open RESPONSE, ">dumps/$method.xml"
                    or croak "Unable to open file to dump xml: $!\n";
                print RESPONSE $response->content;
                close RESPONSE;
            }
            $$r->_setFromXml( $response->content );
        }
        else {
            $self->{lastError}
                = "Unexpected error: " . $response->status_line;
            ( $self->debug > 0 ) && printf "%s\n", $response->as_string;
        }
    }
}

#  END Private methods
#
########################################################################

1;
