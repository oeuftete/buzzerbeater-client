package BuzzerBeater::Task::Base;

use strict;
use warnings;

use Moose;
use Moose::Util::TypeConstraints;

use BuzzerBeater::Client;

subtype 'BB_Client' => as 'Object' =>
    where { $_->isa('BuzzerBeater::Client') };

coerce 'BB_Client' => from 'HashRef' => via {
    my $bb = BuzzerBeater::Client->new;
    $bb->login(
        {   params => {
                login => $_->{login},
                code  => $_->{code},
            }
        }
    );
    return $bb;
};

has 'client' => (
    is     => 'ro',
    isa    => 'BB_Client',
    coerce => 1,
);

no Moose;
__PACKAGE__->meta->make_immutable;

=head1 NAME

BuzzerBeater::Task::Base - Base class for all BB-client using tasks.

=head1 SYNOPSIS
        
    package My::Task;

    use Moose;
    extends 'BuzzerBeater::Task::Base';

    # The rest...

    my $task = My::Task->new(
        client => $bb,
        #  other stuff
    );

=head1 DESCRIPTION

This base class provides the setup for the C<client> attribute, which can be
passed to the inheriting class's constructor as a BuzzerBeater::Client object
or as a hashref that contains a C<login> and C<code>.

=head1 AUTHOR

Ken Crowell <ken@oeuftete.com>

=head1 LICENCE AND COPYRIGHT

Copyright 2009, Ken Crowell (ken@oeuftete.com)

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See perldoc perlartistic.

=cut
