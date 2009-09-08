#
#  $Id$
#

package BuzzerBeater::Client;

use strict;
use warnings;

use parent 'LWP::UserAgent';

use Carp;

use List::Util qw( shuffle );
use Array::Iterator::Circular;

use LWP::UserAgent;

use XML::Twig;

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

# TODO Login and logout really should be abstractable a bit more.  Maybe:
#
# BB::AbstractPage
#   BB::AbstractAuth (login, logout)
#   BB::AbstractData (everything else)
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

        ( $self->debug > 0 ) && printf STDERR "%s\n", $response->content;
        if ( $self->debug > 1 ) {
            open my $response_fh, '>', 'dumps/login.xml'
                or croak "Unable to open file to dump xml: $!\n";
            print $response_fh $response->content;
            close $response_fh;
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
        ( $self->debug > 0 ) && printf STDERR "%s\n", $response->content;
        if ( $self->debug > 1 ) {
            open my $response_fh, '>', 'dumps/logout.xml'
                or croak "Unable to open file to dump xml: $!\n";
            print $response_fh $response->content;
            close $response_fh;
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

    return $self->_generic( $method, @_ );
}

sub DESTROY {
    my $self = shift;
    $self->logout;    # don't care if it fails
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

    if ( exists $ENV{BB_DEBUG} ) {
        $self->debug( $ENV{BB_DEBUG} );
    }

    $self->{apiUrls} = [
        qw ( http://old.buzzerbeater.com/BBAPI/ )
    ];

    $self->{_apiIterator}
        = Array::Iterator::Circular->new( [ shuffle @{ $self->{apiUrls} } ] );
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

    $self->debug && print STDERR "Sending [$url]\n";
    my $req = HTTP::Request->new( GET => $url );
}

#  TODO: Should this go in a new BB::AbstractPage?
sub _setErrorFromXml {
    my ( $self, $t, $error ) = @_;
    $self->{lastError} = $error->att('message');
}

sub _generic {
    my ( $self, $method, $options ) = @_;

    my $return_module = ucfirst $method;

    my $_submodule = "BuzzerBeater::$return_module";

    ## no critic (StringyEval)
    eval "require $_submodule";
    croak $@ if $@;

    #  TODO: OK, this is not done well, is it?
    #
    #  What needs to happen:
    #    - return $_submodule->new(@_)
    #    - Let $_submodule's new call its _initialize
    #    - Define a BB::AbstractPage, and put _abstractRequest there.
    #
    my $obj = {};
    bless $obj, $_submodule;

    #  TODO: Really, @_ ???
    $obj->_initialize(@_);

    $self->_abstractRequest( $method, $options, \$obj );
}

#  TODO: Move this to a new BB::AbstractPage
#
# _abstractRequest($method, \%options, \$returnValue)
#
# Initialize the $returnValue object before calling this.
#
# Returns:
#   undef - Error, use $object->{lastError}
#   Other - Successful

sub _abstractRequest {
    my ( $self, $method, $options, $r ) = @_;

    #  TODO: Is the xml option set?  If so make the request
    if ( exists( $options->{xml} ) ) {
        ( $self->debug > 0 ) && printf STDERR "%s\n", $options->{xml};
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
                printf STDERR "%s\n", $response->as_string;
            }
            elsif ( $self->debug > 0 ) {
                printf STDERR "%s\n", $response->content;
            }

            if ( $self->debug > 1 ) {
                open my $response_fh, '>', 'dumps/$method.xml'
                    or croak "Unable to open file to dump xml: $!\n";
                print $response_fh $response->content;
                close $response_fh;
            }
            $$r->_setFromXml( $response->content );
        }
        else {
            $self->{lastError}
                = "Unexpected error: " . $response->status_line;
            ( $self->debug > 0 ) && printf STDERR "%s\n",
                $response->as_string;
            return;
        }
    }
}

#  END Private methods
#
########################################################################

1;
