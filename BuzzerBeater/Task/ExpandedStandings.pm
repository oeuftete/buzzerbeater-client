package BuzzerBeater::Task::ExpandedStandings;

use strict;
use warnings;

use Moose;
use Moose::Util::TypeConstraints;

extends 'BuzzerBeater::Task::Base';

has 'season'   => ( is => 'rw', isa => 'Int', );
has 'leagueid' => ( is => 'rw', isa => 'Int', );

sub run {
    my $self = shift;

    #  Get the desired standings.
    my $_standings = $self->client->standings(
        {   params => {
                season   => $self->season,
                leagueid => $self->leagueid,
            }
        }
    );
}

no Moose;
__PACKAGE__->meta->make_immutable;

=head1 NAME

BuzzerBeater::Task::ExpandedStandings - Generate expanded standings
information.

=head1 SYNOPSIS
        
    use BuzzerBeater::Task::ExpandedStandings;

    my $expanded = BuzzerBeater::Task::ExpandedStandings->new(
        client => $bb,
        );
    my $output = $expanded->run;

    # ... then feed it to a template or whatever

=head1 DESCRIPTION


=head2 METHODS

=over

=item new

=item run

=back

=head1 AUTHOR

Ken Crowell <ken@oeuftete.com>

=head1 LICENCE AND COPYRIGHT

Copyright 2010, Ken Crowell (ken@oeuftete.com)

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See perldoc perlartistic.

=cut
