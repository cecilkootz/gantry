#!/usr/bin/perl
use strict;

use lib qw( ../lib );

use CGI::Carp qw( fatalsToBrowser );

use Gantry::Samples qw{
    -Engine=CGI
    -TemplateEngine=TT
    -PluginNamespace=Gantry::Samples
    AuthCookie Static
};

use Gantry::Engine::CGI;

my $cgi = Gantry::Engine::CGI->new( {
    config => {
        GantryConfInstance => 'samples',
        GantryConfFile => 'docs/app.gantry.conf',
    },
    locations => {
        '/' => 'Gantry::Samples',
        '/fileupload' => 'Gantry::Samples::FileUpload',
        '/ajaxrequest' => 'Gantry::Samples::AjaxRequest',
        '/authcookie' => 'Gantry::Samples::AuthCookie',
        '/authcookie/sqlite/closed' => 'Gantry::Samples::AuthCookie::SQLite::Closed',
        '/authcookie/sqlite' => 'Gantry::Samples::AuthCookie::SQLite',
        '/user' => 'Gantry::Samples::User',
        '/user/group' => 'Gantry::Samples::User::Group',
        '/table_perms' => 'Gantry::Samples::TablePermissions',
        '/table_perms_crud' => 'Gantry::Samples::TablePermCRUD',
        '/GantrySoapService' => 'Gantry::Samples::SOAP',
    },
} );

$cgi->dispatch();

if ( $cgi->{config}{debug} ) {
    foreach ( sort { $a cmp $b } keys %ENV ) {
        print "$_ $ENV{$_}<br />\n";
    }
}
