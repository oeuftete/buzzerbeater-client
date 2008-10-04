#
#  $Id: Schedule.pm,v 1.1 2008-10-04 16:56:39 ken Exp $
#

use strict;
use warnings;

package BuzzerBeater::Schedule;

use XML::Twig;
use Carp;

sub new {
  my $class = shift;
  my $self = {};
  bless $self, $class;
  $self->_initialize(@_);
  return $self;
}

sub _initialize {
  my $self = shift;

  if (@_) {
    my $args = shift;
    $self->setFromXml($args->{xml}) if (exists $args->{xml});
  }
}

sub setFromXml {
  my $self = shift;
  my $xml = shift;

  my $twig = new XML::Twig;
  $twig->parse($xml); # safe_parse or croak?

  my $root = $twig->root;
  my $el = $root->first_child();

  if ($el->gi eq 'schedule') {
    #  Do something eventually
  }

  else {
    carp "Unexpected child element processing schedule xml: " .
      $el->gi;
  }
  return $self;
}

1;
