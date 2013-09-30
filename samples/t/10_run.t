use strict;
use warnings;

use Test::More tests => 10;

use Gantry::Samples qw{
    -Engine=CGI
    -TemplateEngine=TT
    -PluginNamespace=Gantry::Samples
    AuthCookie Static
};

use Gantry::Server;
use Gantry::Engine::CGI;

# these tests must contain valid template paths to the core gantry templates
# and any application specific templates

my $cgi = Gantry::Engine::CGI->new( {
    config => {
        dbconn => 'dbi:SQLite:dbname=app.db',
        app_name => 'Samples',
        auth_group_join_table => 'user_user_group',
        auth_group_table => 'user_group',
        auth_table => 'user',
        auth_user_field => 'username',
        auth_user_password => 'username',
        doc_root => 'html',
        doc_rootp => '/static',
        root => 'html:html/templates:../root/moxie:../root',
        show_dev_navigation => '1',
        template_wrapper => 'genwrapper.tt',
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
    },
} );

my @tests = qw(
    /
    /fileupload
    /ajaxrequest
    /authcookie
    /authcookie/sqlite/closed
    /authcookie/sqlite
    /user
    /user/group
    /table_perms
    /table_perms_crud
);

my $server = Gantry::Server->new();
$server->set_engine_object( $cgi );

SKIP: {

    eval {
        require DBD::SQLite;
    };
    skip 'DBD::SQLite is required for run tests.', 10 if ( $@ );

    unless ( -f 'app.db' ) {
        skip 'app.db sqlite database required for run tests.', 10;
    }

    foreach my $location ( @tests ) {
        my( $status, $page ) = $server->handle_request_test( $location );
        ok( $status eq '200',
                "expected 200, received $status for $location" );

        if ( $status ne '200' ) {
            print STDERR $page . "\n\n";
        }
    }

}
