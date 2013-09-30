package Gantry::Plugins::DBIxClassConn;
use strict; use warnings;

use base 'Exporter';

our @EXPORT = qw( get_schema get_auth_schema get_model_schema );
my $schemas;

sub get_schema {
    my $self = shift;
    my $base = $self->schema_base_class;
    
    return get_model_schema(
        $self,
        $base,
        $base->get_db_options,
        $self->fish_config( 'dbconn' ),
        $self->fish_config( 'dbuser' ),
        $self->fish_config( 'dbpass' ),
    );
}

sub get_auth_schema {
    my $self = shift;
    my $base;
    my ( $dbconn, $dbuser, $dbpass );
    
    # Use auth db info if available.
    if ( $self->can('schema_auth_base_class') ) {
        $base   = $self->schema_auth_base_class;
        $dbconn = $self->fish_config( 'auth_dbconn' );
        $dbuser = $self->fish_config( 'auth_dbuser' );
        $dbpass = $self->fish_config( 'auth_dbpass' );
    }
    else {
        $base   = $self->schema_base_class;
        $dbconn = $self->fish_config( 'dbconn' );
        $dbuser = $self->fish_config( 'dbuser' );
        $dbpass = $self->fish_config( 'dbpass' );
    }

    return get_model_schema(
        $self,
        $base,
        $base->get_db_options,
        $dbconn,
        $dbuser,
        $dbpass,
    );    
}

sub get_model_schema {
    my $self = shift;
    my ( $base, $db_options, $dbconn, $dbuser, $dbpass ) = @_;
    my $db_options_str  = '';
    my @db_option_keys;
    my $handle;

    # Concat the db options in alphabetical order into a string
    # to use as part of the schema identifier.
    @db_option_keys = sort {$a cmp $b} keys %$db_options;
    for ( my $i = 0; $i <= $#db_option_keys; $i++ ) {
        $db_options_str .= $db_option_keys[$i] . '=' . $db_options->{$db_option_keys[$i]};
        $db_options_str .= ',' unless $i == $#db_option_keys;
    }
        
    $handle =   $base . ',' .
                $dbconn . ',' .
                $dbuser . ',' .
                ( $dbpass || '' ) . ',' .
                $db_options_str;

    # If persistent dbhs are enabled then store the schema in a global
    # location so it will not disconnect from the db at the end of the request.
    if ( $self->persistent_dbh() ) {
        if ( $schemas->{$handle} ) {
            # Save reference to schema in __SCHEMAS__ so it can be
            # rolled back / disconnected during cleanup if necessary.
            $self->{__SCHEMAS__}->{$handle} = $schemas->{$handle};

            return $schemas->{$handle};
        }

        $schemas->{$handle} = $base->connect(
            $dbconn,
            $dbuser,
            $dbpass,
            $db_options
        );

        # Save reference to schema in __SCHEMAS__ so it can be
        # rolled back / disconnected during cleanup if necessary.
        $self->{__SCHEMAS__}->{$handle} = $schemas->{$handle};

        return $schemas->{$handle};
    }
    else {
        # Persistent dbhs are disabled so no need to maintain a global reference.
        if ( $self->{__SCHEMAS__}->{$handle} ) {
            return $self->{__SCHEMAS__}->{$handle};
        }

        $self->{__SCHEMAS__}->{$handle} = $base->connect(
            $dbconn,
            $dbuser,
            $dbpass,
            $db_options
        );

        return $self->{__SCHEMAS__}->{$handle};
    }
}

1;

__END__

=head1 NAME

Gantry::Plugins::DBIxClassConn - DBIx::Class schema accessor mixin

=head1 SYNOPSIS

In any controller:

    use YourModel;
    use YourAuthModel;
    sub schema_base_class { return 'YourModel'; }
    sub schema_auth_base_class { return 'YourAuthModel'; }
    use Gantry::Plugins::DBIxClassConn;

    sub some_method {
        my $self   = shift;
        #...

        my $schema = $self->get_schema;

        my $other_schema = $self->get_model_schema(
            'YourModel',
            $db_options,
            $db_conn,
            $db_user,
            $db_pass
        );

        # Use $schema as instructed in DBIx::Class docs.
    }

    sub some_auth_method {
        my $self        = shift;
        my $auth_schema = $self->get_auth_schema();
    }

    package YourModel;

    sub get_db_options {
        return { AutoCommit => 1 };  # or whatever options you want
    }

    package YourAuthModel;

    sub get_db_options {
        return { AutoCommit => 1 };  # or whatever options you want
    }

Alternatively, in your controller which uses Gantry::Plugins::DBIxClassConn:

    sub some_method {
        my $self = shift;

        my @rows = $MY_TABLE->gsearch( $self, { ... }, { ... } );
    }

=head1 DESCRIPTION

This mixin gives you an accessor which returns the DBIx::Class schema
object for your data model.  It expects dbconn, dbuser, and dbpass
to be in your site conf, so it can call fish config to get them.
If you use get_auth_schema, it expects auth_dbconn, auth_dbuser and
auth_dbpass to be in your site conf.

In order for this module to help you, your model (and/or auth model)
must provide one helper:

=over 4

=item get_db_options

This supplies the default DBI parameters to the connection method.
This is usually sufficient:

    sub get_db_options { return {}; }

Note that the return value must be a hash reference.

=back

If you model inherits from Gantry::Utils::DBIxClass, it will have a family
of convenience methods meant to reduce typing.  These are the same methods
DBIx::Class makes available through resultsets, but with a couple of
twists.  First, the names of the methods have a g in front.  Second,
the g methods expect to be called as class methods on the model.  Third,
the g methods expect the Gantry site object as their first (non-invoking)
parameter.  The rest of the parameters are the same as for the corresponding
call via a DBIC resultset.

Note that for the g methods to work on the model, your site object must
use this mixin.  The g methods call get_schema.

=head1 METHOD EXPORTED into YOUR PACKAGE

=over 4

=item get_schema

Exported.

Returns a DBIx::Class schema ready for use (if you set up your connection
info in the right way, see Gantry::Docs::DBConn).

=item get_auth_schema

Exported.

Returns a DBIx::Class schema ready for use (if you set up your connection
info in the right way, see Gantry::Docs::DBConn).

=item get_model_schema ($model, $db_options, $dbconn, $dbuser, $dbpass)

Exported.

Returns a DBIx::Class schema ready for use. This is a helper method to assist
you in creating a persistent connection with a model other then the base
model for your application. Instead of calling the connect method on the model
you can pass the model, database connect options, database connection string,
database user name, and database password and this method will connect the
model for you. The advantage is if there is already an existing connection to
the database the method will return the existing schema, otherwise, it will
connect the model and return the schema to you.

=back

=head1 SEE ALSO

Gantry::Docs::DBConn, Gantry::Utils::ModelHelper, but only if you use
a different ORM than DBIx::Class.

=head1 AUTHOR

Phil Crow <philcrow2000@yahoo.com>

=head1 COPYRIGHT and LICENSE

Copyright (c) 2006, Phil Crow

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut
