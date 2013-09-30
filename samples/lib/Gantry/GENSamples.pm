# NEVER EDIT this file.  It was generated and will be overwritten without
# notice upon regeneration of this application.  You have been warned.
package Gantry::GENSamples;

use strict;
use warnings;

use Gantry qw{ -TemplateEngine=TT };

use JSON;
use Gantry::Utils::TablePerms;

our @ISA = qw( Gantry );


use Gantry::Samples::Model;
sub schema_base_class { return 'Gantry::Samples::Model'; }
use Gantry::Plugins::DBIxClassConn qw( get_schema );

#-----------------------------------------------------------------
# $self->namespace() or Gantry::Samples->namespace()
#-----------------------------------------------------------------
sub namespace {
    return 'Gantry::Samples';
}

#-----------------------------------------------------------------
# $self->init( $r )
#-----------------------------------------------------------------
sub init {
    my ( $self, $r ) = @_;

    # process SUPER's init code
    $self->SUPER::init( $r );

    $self->set_auth_user_password( $self->fish_config( 'auth_user_password' ) || '' );
    $self->set_app_name( $self->fish_config( 'app_name' ) || '' );
    $self->set_auth_user_field( $self->fish_config( 'auth_user_field' ) || '' );
    $self->set_show_dev_navigation( $self->fish_config( 'show_dev_navigation' ) || '' );
    $self->set_root( $self->fish_config( 'root' ) || '' );
} # END init


#-----------------------------------------------------------------
# $self->set_auth_user_password( $new_value )
#-----------------------------------------------------------------
sub set_auth_user_password {
    my ( $self, $value ) = @_;

    $self->{ __auth_user_password__ } = $value;
}

#-----------------------------------------------------------------
# $self->auth_user_password(  )
#-----------------------------------------------------------------
sub auth_user_password {
    my $self = shift;

    return $self->{ __auth_user_password__ };
}

#-----------------------------------------------------------------
# $self->set_app_name( $new_value )
#-----------------------------------------------------------------
sub set_app_name {
    my ( $self, $value ) = @_;

    $self->{ __app_name__ } = $value;
}

#-----------------------------------------------------------------
# $self->app_name(  )
#-----------------------------------------------------------------
sub app_name {
    my $self = shift;

    return $self->{ __app_name__ };
}

#-----------------------------------------------------------------
# $self->set_auth_user_field( $new_value )
#-----------------------------------------------------------------
sub set_auth_user_field {
    my ( $self, $value ) = @_;

    $self->{ __auth_user_field__ } = $value;
}

#-----------------------------------------------------------------
# $self->auth_user_field(  )
#-----------------------------------------------------------------
sub auth_user_field {
    my $self = shift;

    return $self->{ __auth_user_field__ };
}

#-----------------------------------------------------------------
# $self->set_show_dev_navigation( $new_value )
#-----------------------------------------------------------------
sub set_show_dev_navigation {
    my ( $self, $value ) = @_;

    $self->{ __show_dev_navigation__ } = $value;
}

#-----------------------------------------------------------------
# $self->show_dev_navigation(  )
#-----------------------------------------------------------------
sub show_dev_navigation {
    my $self = shift;

    return $self->{ __show_dev_navigation__ };
}

#-----------------------------------------------------------------
# $self->set_root( $new_value )
#-----------------------------------------------------------------
sub set_root {
    my ( $self, $value ) = @_;

    $self->{ __root__ } = $value;
}

#-----------------------------------------------------------------
# $self->root(  )
#-----------------------------------------------------------------
sub root {
    my $self = shift;

    return $self->{ __root__ };
}

#-----------------------------------------------------------------
# $self->do_main( )
#-----------------------------------------------------------------
sub do_main {
    my ( $self ) = @_;

    $self->stash->view->template( 'main.tt' );
    $self->stash->view->title( 'Samples' );

    $self->stash->view->data( { pages => $self->site_links() } );
} # END do_main

#-----------------------------------------------------------------
# $self->site_links( )
#-----------------------------------------------------------------
sub site_links {
    my $self = shift;

    return [
        { link => $self->app_rootp() . '/fileupload', label => 'File Upload' },
        { link => $self->app_rootp() . '/ajaxrequest', label => 'Ajax Request' },
        { link => $self->app_rootp() . '/authcookie', label => 'AuthCookie' },
        { link => $self->app_rootp() . '/authcookie/sqlite/closed', label => 'AuthCookie w/ SQLite Closed' },
        { link => $self->app_rootp() . '/authcookie/sqlite', label => 'AuthCookie w/ SQLite' },
        { link => $self->app_rootp() . '/user', label => 'User' },
        { link => $self->app_rootp() . '/user/group', label => 'User Group' },
        { link => $self->app_rootp() . '/table_perms', label => 'Table Permissions' },
        { link => $self->app_rootp() . '/table_perms_crud', label => 'Table Permissions Manual CRUD' },
    ];
} # END site_links

1;

=head1 NAME

Gantry::GENSamples - generated support module for Gantry::Samples

=head1 SYNOPSIS

In Gantry::Samples:

    use base 'Gantry::GENSamples';

=head1 DESCRIPTION

This module was generated by Bigtop (and IS subject to regeneration) to
provide methods in support of the whole Gantry::Samples
application.

Gantry::Samples should inherit from this module.

=head1 METHODS

=over 4

=item schema_base_class

=item namespace

=item init

=item do_main

=item site_links

=item auth_user_password

=item set_auth_user_password

=item app_name

=item set_app_name

=item auth_user_field

=item set_auth_user_field

=item show_dev_navigation

=item set_show_dev_navigation

=item root

=item set_root


=back

=head1 AUTHOR

John Weigel, E<lt>jweigel@apple.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 John Weigel

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut

