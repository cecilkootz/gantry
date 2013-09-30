package Gantry::Stash::View::Form;
package form;

use strict;

sub new {
    my $class   = shift;
    my $input   = shift;

    my $self;
    
    if ( $input ) { $self = bless( $input, $class ); }
    else          { $self = bless( {},     $class ); }

    return $self;
}

sub results {
    my( $self, $p ) = ( shift, shift );

    $self->{results} = $p if defined $p;
    return( $self->{results} );
}


sub error_text {
    my( $self, $p ) = ( shift, shift );

    $self->{error_text} = $p if defined $p;
    return( $self->{error_text} );

} # end error_text

sub message {
    my( $self, $p ) = ( shift, shift );

    $self->{message} = $p if defined $p;
    return( $self->{message} );
}

sub TO_JSON {
    my $self = shift;
    my $row;
    my $j = { %$self };
        
    # If we have an orm row then we need to convert it's data values into a hash
    # to be returned as part of the json data.
    if ( defined $self->{row} ) {
        my %cols = $self->{row}->get_columns;
        
        # Remove orm row since it can't be jsonified plus we don't want to return
        # everything even if it could be.
        delete $j->{row};
        
        # Add column values for the fields in the form.
        foreach my $field ( @{$self->{fields}} ) {
            $j->{row}->{$field->{name}} = $cols{$field->{name}};
        }
    }
    
    # If we have results we need to convert them.
    if ( defined $self->{results} ) {
        my $results = { %{ $self->{results} } };
        my $msgs = $self->{results}->msgs;
        
        # If there are msgs add them to the results.
        if ($msgs) {
            $results->{msgs} = $msgs;
        }

        $j->{results} = $results;
    }
    
    return $j;
}

1;

__END__

=head1 NAME

Gantry::Stash::View::Form - Stash object for the view's form

=head1 SYNOPSIS

    $self->stash->view->form( { } );

=head1 DESCRIPTION

This module manages the form contents for Gantry::Plugins::AutoCRUD and
Gantry::Plugins::CRUD, see their docs for details of what goes into the hash.

=head1 METHODS

=over 4

=item new

Pass in a proper hash suitable for use by one of the crud plugins.  It
will be blessed into this class.

=item results

Used by add/edit templates to track form validation violations.

=item error_text

Not currently used.

=item message

Used by some templates for question text to present to the user.

=item TO_JSON

Handles conversion of blessed form object into a json data structure. This is
useful in combination with the JSON module's to_json method when the
convert_blessed option is specified.

=back

=head1 SEE ALSO

Gantry::Plugins::AutoCRUD(3), Gantry(3), Gantry::Stash(3)

=head1 LIMITATIONS

=head1 AUTHOR

Phil Crow <pcrow@sunflowerbroadband.com>

Tim Keefer <tkeefer@gmail.com>

=head1 COPYRIGHT and LICENSE

Copyright (c) 2005, Phil Crow.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut

