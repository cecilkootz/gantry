# NEVER EDIT this file.  It was generated and will be overwritten without
# notice upon regeneration of this application.  You have been warned.
package Gantry::Samples::GEN::User;

use strict;
use warnings;

use base 'Gantry::Samples';
use JSON;
use Gantry::Utils::TablePerms;

use Gantry::Samples::Model::user qw(
    $USER
);

#-----------------------------------------------------------------
# $self->controller_config(  )
#-----------------------------------------------------------------
sub controller_config {
    my ( $self ) = @_;

    return {
        authed_methods => [
        { action => 'do_delete',  group => '' },
        ],

    mykey => 'somevalue',
    };
} # END controller_config

#-----------------------------------------------------------------
# $self->do_main(  )
#-----------------------------------------------------------------
sub do_main {
    my ( $self ) = @_;

    $self->stash->view->template( 'results.tt' );
    $self->stash->view->title( 'User' );

    my $real_location = $self->location() || '';
    if ( $real_location ) {
        $real_location =~ s{/+$}{};
        $real_location .= '/';
    }

    my @header_options = (
        {
            text => 'Add',
            link => $real_location . "add",
            type => 'create',
        },
    );

    my $retval = {
        headings       => [
            'Active',
            'Username',
            'Email',
            'Lname',
        ],
    };

    $retval->{ livesearch } = 1;

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
            text => 'Groups',
            type => 'retrieve',
        },
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

    my $schema = $self->get_schema();
    my @rows   = $USER->get_listing(
        {
            schema      => $schema,
            where       => $search,
            order_by    => 'username',
        }
    );

    ROW:
    foreach my $row ( @rows ) {
        last ROW if $perm_obj->hide_all_data;

        my $id = $row->id;

        push(
            @{ $retval->{rows} }, {
                orm_row => $row,
                data => [
                    $row->active_display(),
                    $row->username,
                    $row->email,
                    $row->lname,
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

    my $selections = $USER->get_form_selections(
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
                options => [
                    { label => 'Yes', value => '1' },
                    { label => 'No', value => '0' },
                ],
                name => 'active',
                label => 'Active',
                type => 'select',
                is => 'int4',
            },
            {
                searchable => 1,
                name => 'username',
                label => 'Username',
                type => 'text',
                is => 'varchar',
            },
            {
                name => 'password',
                label => 'Password',
                type => 'password',
                is => 'varchar',
            },
            {
                searchable => 1,
                name => 'email',
                optional => 1,
                label => 'Email',
                type => 'text',
                is => 'varchar',
            },
            {
                searchable => 1,
                name => 'fname',
                optional => 1,
                label => 'Fname',
                type => 'text',
                is => 'varchar',
            },
            {
                searchable => 1,
                name => 'lname',
                optional => 1,
                label => 'Lname',
                type => 'text',
                is => 'varchar',
            },
        ],
    };
} # END form

1;

=head1 NAME

Gantry::Samples::GEN::User - generated support module for Gantry::Samples::User

=head1 SYNOPSIS

In Gantry::Samples::User:

    use base 'Gantry::Samples::GEN::User';

=head1 DESCRIPTION

This module was generated by bigtop and IS subject to regeneration.
Use it in Gantry::Samples::User to provide the methods below.
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

