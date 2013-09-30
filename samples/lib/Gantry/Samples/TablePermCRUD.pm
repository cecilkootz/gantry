package Gantry::Samples::TablePermCRUD;

use strict;

use base 'Gantry::Samples::GEN::TablePermCRUD';

use Gantry::Plugins::CRUD;

use Gantry::Samples::Model::item qw(
    $ITEM
);

#-----------------------------------------------------------------
# $self->do_main( $user_id )
#-----------------------------------------------------------------
# This method inherited from Gantry::Samples::GEN::TablePermCRUD

my $form = Gantry::Plugins::CRUD->new(
    add_action      => \&form_add,
    edit_action     => \&form_edit,
    delete_action   => \&form_delete,
    form            => __PACKAGE__->can( 'form' ),
    redirect        => \&form_redirect,
    text_descr      => 'item for sale',
);

#-----------------------------------------------------------------
# $self->form_redirect( $data )
# The generated version mimics the default behavior, feel free
# to delete the redirect key from the constructor call for $crud
# and this sub.
#-----------------------------------------------------------------
sub form_redirect {
    my ( $self, $data ) = @_;
    return $self->location;
}

#-------------------------------------------------
# $self->do_add( )
#-------------------------------------------------
sub do_add {
    my $self = shift;

    Gantry::Plugins::CRUD::verify_permission( { site => $self } );

    $form->add( $self, { data => \@_ } );
}

#-------------------------------------------------
# $self->form_add( $params, $data )
#-------------------------------------------------
sub form_add {
    my ( $self, $params, $data ) = @_;

    # make a new row in the $ITEM table using data from $params
    # remember to add commit if needed

    $ITEM->gupdate_or_create( $self, $params );
}

#-------------------------------------------------
# $self->do_delete( $doomed_id, $confirm )
#-------------------------------------------------
sub do_delete {
    my ( $self, $doomed_id, $confirm ) = @_;

    my $row = $ITEM->gfind( $self, $doomed_id );

    Gantry::Plugins::CRUD::verify_permission( { site => $self, row => $row } );

    $form->delete( $self, $confirm, { row => $row } );
}

#-------------------------------------------------
# $self->form_delete( $data )
#-------------------------------------------------
sub form_delete {
    my ( $self, $data ) = @_;

    # fish the id (or the actual row) from the data hash
    # delete it
    # remember to add commit if needed

    $data->{ row }->delete;
}

#-------------------------------------------------
# $self->do_edit( $id )
#-------------------------------------------------
sub do_edit {
    my ( $self, $id ) = @_;

    my $row = $ITEM->gfind( $self, $id );

    Gantry::Plugins::CRUD::verify_permission( { site => $self, row => $row } );

    $form->edit( $self, { row => $row } );
}

#-------------------------------------------------
# $self->form_edit( $param, $data )
#-------------------------------------------------
sub form_edit {
    my( $self, $params, $data ) = @_;

    # retrieve the row from the data hash
    # update the row
    # remember to add commit if needed

    $data->{row}->update( $params );
}

#-----------------------------------------------------------------
# $self->form( $data )
#-----------------------------------------------------------------
# This method inherited from Gantry::Samples::GEN::TablePermCRUD



1;

=head1 NAME

Gantry::Samples::TablePermCRUD - A controller in the Gantry::Samples application

=head1 SYNOPSIS

This package is meant to be used in a stand alone server/CGI script or the
Perl block of an httpd.conf file.

Stand Alone Server or CGI script:

    use Gantry::Samples::TablePermCRUD;

    my $cgi = Gantry::Engine::CGI->new( {
        config => {
            #...
        },
        locations => {
            '/someurl' => 'Gantry::Samples::TablePermCRUD',
            #...
        },
    } );

httpd.conf:

    <Perl>
        # ...
        use Gantry::Samples::TablePermCRUD;
    </Perl>

    <Location /someurl>
        SetHandler  perl-script
        PerlHandler Gantry::Samples::TablePermCRUD
    </Location>

If all went well, one of these was correctly written during app generation.

=head1 DESCRIPTION

This module was originally generated by Bigtop.  But feel free to edit it.
You might even want to describe the table this module controls here.

=head1 METHODS

=over 4

=item get_model_name

=item text_descr

=item schema_base_class

=item get_orm_helper

=item form_redirect

=item do_add

=item form_add

=item do_delete

=item form_delete

=item do_edit

=item form_edit


=back


=head1 METHODS INHERITED FROM Gantry::Samples::GEN::TablePermCRUD

=over 4

=item controller_config

=item do_main

=item form


=back


=head1 DEPENDENCIES

    Gantry::Samples
    Gantry::Samples::GEN::TablePermCRUD
    Gantry::Samples::Model::item
    Gantry::Plugins::CRUD

=head1 AUTHOR

Phil Crow, E<lt>phil@localdomainE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 Phil Crow

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut