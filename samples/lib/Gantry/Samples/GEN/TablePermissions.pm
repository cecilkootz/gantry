# NEVER EDIT this file.  It was generated and will be overwritten without
# notice upon regeneration of this application.  You have been warned.
package Gantry::Samples::GEN::TablePermissions;

use strict;
use warnings;

use base 'Gantry::Samples';
use JSON;
use Gantry::Utils::TablePerms;

use Gantry::Samples::Model::item qw(
    $ITEM
);

#-----------------------------------------------------------------
# $self->controller_config(  )
#-----------------------------------------------------------------
sub controller_config {
    my ( $self ) = @_;

    return {
        permissions => {
            bits  => 'crud-rud-r--',
            group => 'admin'
        },
    };
} # END controller_config

#-----------------------------------------------------------------
# $self->do_main( $user_id )
#-----------------------------------------------------------------
sub do_main {
    my ( $self, $user_id ) = @_;

    $self->stash->view->template( 'results.tt' );
    $self->stash->view->title( 'Items for Sale' );

    my $real_location = $self->location() || '';
    if ( $real_location ) {
        $real_location =~ s{/+$}{};
        $real_location .= '/';
    }

    my $header_option_suffix = ( $user_id ) ? "/$user_id" : '';

    my @header_options = (
        {
            text => 'Add',
            link => $real_location . "add$header_option_suffix",
            type => 'create',
        },
    );

    my $retval = {
        headings       => [
            'Description',
            'Price',
            'Seller',
        ],
    };

    my $params = $self->params;

    my $search = {};
    if ( $params->{ search } ) {
        my $form = $self->form();

        my @searches;
        foreach my $field ( @{ $form->{ fields } } ) {
            if ( $field->{ searchable } ) {
                push( @searches,
                    ( $field->{ name } => { 'like', "%$params->{ search }%"  } )
                );
            }
        }

        $search = {
            -or => \@searches
        } if scalar( @searches ) > 0;
    }

    my @row_options = (
        {
            text => 'Edit',
            type => 'update',
        },
        {
            text => 'Delete',
            type => 'delete',
        },
    );

    my $perm_obj = Gantry::Utils::TablePerms->new(
        {
            site           => $self,
            real_location  => $real_location,
            header_options => \@header_options,
            row_options    => \@row_options,
        }
    );

    $retval->{ header_options } = $perm_obj->real_header_options;

    my $limit_to_user_id = $perm_obj->limit_to_user_id;
    $search->{ user_id } = $limit_to_user_id if ( $limit_to_user_id );

    if ( $user_id ) {
        $search->{ user_id } = $user_id;
    }

    my $schema = $self->get_schema();
    my @rows   = $ITEM->get_listing(
        {
            schema      => $schema,
            where       => $search,
        }
    );

    ROW:
    foreach my $row ( @rows ) {
        last ROW if $perm_obj->hide_all_data;

        my $id = $row->id;
        my $user_id = ( $row->user_id )
                ? $row->user_id->foreign_display()
                : '';

        push(
            @{ $retval->{rows} }, {
                orm_row => $row,
                data => [
                    $row->descr,
                    $row->price,
                    $user_id,
                ],
                options => $perm_obj->real_row_options( $row ),
            }
        );
    }

    if ( $params->{ json } ) {
        $self->template_disable( 1 );

        my $obj = {
            headings        => $retval->{ headings },
            header_options  => $retval->{ header_options },
            rows            => $retval->{ rows },
        };

        my $json = to_json( $obj, { allow_blessed => 1 } );
        return( $json );
    }

    $self->stash->view->data( $retval );
} # END do_main

#-----------------------------------------------------------------
# $self->form( $row )
#-----------------------------------------------------------------
sub form {
    my ( $self, $row ) = @_;

    my $selections = $ITEM->get_form_selections(
        {
            schema          => $self->get_schema(),
        }
    );

    return {
        row        => $row,
        legend => $self->path_info =~ /edit/i ? 'Edit' : 'Add',
        submit_and_add_another => 1,
        fields     => [
            {
                name => 'descr',
                label => 'Description',
                type => 'text',
                is => 'varchar',
            },
            {
                name => 'price',
                label => 'Price',
                type => 'text',
                is => 'varchar',
            },
        ],
    };
} # END form

1;

=head1 NAME

Gantry::Samples::GEN::TablePermissions - generated support module for Gantry::Samples::TablePermissions

=head1 SYNOPSIS

In Gantry::Samples::TablePermissions:

    use base 'Gantry::Samples::GEN::TablePermissions';

=head1 DESCRIPTION

This module was generated by bigtop and IS subject to regeneration.
Use it in Gantry::Samples::TablePermissions to provide the methods below.
Feel free to override them.

=head1 METHODS

=over 4

=item controller_config

=item do_main

=item form


=back

=head1 AUTHOR

Generated by bigtop and subject to regeneration.

=cut

