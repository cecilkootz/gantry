package Gantry::Template::TT;
require Exporter;

use Gantry::Init;
use Template;
use vars qw( @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS );
use strict;

############################################################
# Variables                                                #
############################################################
@ISA        = qw( Exporter );
@EXPORT     = qw(
    do_action
    do_error
    do_process
    template_engine
);

@EXPORT_OK  = qw( );


############################################################
# Functions                                                #
############################################################
#-------------------------------------------------
# $self->do_action( 'do_main|do_edit', @p )
#-------------------------------------------------
sub do_action {
    my( $self, $action, @p ) = @_;

    # stash the output from the action ie. do_main, do_edit
    # for use when do_process is call.
    $self->stash->controller->data( $self->$action( @p ) );

} # end do_action

#-------------------------------------------------
# $self->do_error( @err )
#-------------------------------------------------
sub do_error {
    my( $self, @err ) = @_;

    #$self->r->log_error( join( "\n", @err ) );

} # end do_error

#-------------------------------------------------
# $site->do_process(  )
#-------------------------------------------------
sub do_process {
    my( $self ) = @_;

    # Check template disabled flag
    if ( $self->template_disable ) {
        return( $self->stash->controller->data );
    }

    # Process through template tookit
    else {
        my @tt_include_paths;
        my @tt_wrapper;
        my @tt_default_template;

        # Initialize string variables.
        my $page = '';
        my $tmpl_install_dir = '';

        # Use the template defined in controller use template from PerlSetVar
        if (! defined  $self->stash->view->template) {
            $self->stash->view->template( $self->template );
        }

        # If no template has been defined, then just return the data.
        if (! $self->stash->view->template()) {
            return sprintf(
                "%s%s",
                $self->stash->view->data || '',
                $self->stash->controller->data || ''
            )
        }

        # Get base root.
        $tmpl_install_dir = Gantry::Init->base_root();

        # Build include path array.
        @tt_include_paths = ( split(':', $self->root), $tmpl_install_dir );

        # Set template wrapper, if one is defined.
        if ($self->template_wrapper) {
           @tt_wrapper = ( $self->template_wrapper );
        }

        # Set default template.
        @tt_default_template = ( $self->template_default || undef );

        # Initialize TT config parameters.
        my $config = {
            'WRAPPER'       => \@tt_wrapper,
            'INCLUDE_PATH'  => \@tt_include_paths,
            'DEFAULT'       => \@tt_default_template
        };

        # Add in any additional config parameters that may be set by the application.
        # NOTE: This is a minimal list of the Template Toolkit config parameters;
        # it may need to be updated at a later time if an application needs to
        # define one that is not listed below.
        foreach my $param ('tt_compile_dir', 'tt_compile_ext', 'tt_eval_perl', 'tt_absolute') {
            # Make sure the accessor method exists for this gantry config item.
            if ($self->can( $param )) {
                # Replace 'tt_' from config item.
                (my $key = $param) =~ s/tt_(.*?)//io;

                # Set config parameter.
                $config->{uc($key)} = $self->$param;
            }
        }

        # Create Template Toolkit object.
        my $tt = Template->new( $config ) or die sprintf("%s", $Template::ERROR);

        # Process template.
        $tt->process(
            $self->stash->view->template,
            {
                self => $self,
                site => $self,
                view => $self->stash->view,
            },
            \$page,
        ) || die sprintf("Template Error: %s", $tt->error);

        # Return page.
        return( $page );
    }
} # end do_process

#-------------------------------------------------
# $site->template_engine
#-------------------------------------------------
sub template_engine {
    return __PACKAGE__;

} # end template_engine


# EOF
1;

__END__

=head1 NAME

Gantry::Template::TT - Template Toolkit plugin for Gantry.

=head1 SYNOPSIS

  use Gantry::Template::TT;


=head1 DESCRIPTION

Use this module when you want template toolkit to produce your output:

    use Gantry qw/ -Engine=YourChoice -TemplateEngine=TT /;

Then in your do_* method do something like this:

    sub do_something {
        my $self = shift;

        # ... gather data for output

        # set the name of the template TT should use:
        $self->stash->view->template( 'output.tt' );

        # set the data TT should use to fill in the template:
        $self->stash->view->data(
            {
                # vars to pass to TT's process method
            }
        );
    }

This is plugin module that contains the Template Toolkit method calls.

=head1 METHODS

=over 4

=item $site->do_action

C<do_action> is a required function for the template plugin. It purpose
is to call or dispatch to the appropriate method. This function is passed
three parameters:

my( $self, $action, @path_array ) = @_;

This method is responsible for calling the controller method and
storing the output from the controller.

=item $site->do_error

This method gives you the flexibility of logging, re-estabilishing a
database connection, rebuilding the template object, etc.

=item $site->do_process

This method is the final step in the template plugin. Here you need
call the template object passing the controller data and return the
output.

=item $site->template_engine

Always returns the name of this module, which is the name of the current
template engine.

=back

=head1 SEE ALSO

Gantry(3)

=head1 LIMITATIONS


=head1 AUTHOR

Tim Keefer <tkeefer@gmail.com>

=head1 COPYRIGHT and LICENSE

Copyright (c) 2005-6, Tim Keefer.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut
