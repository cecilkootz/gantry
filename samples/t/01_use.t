use strict;
use warnings;

use Test::More tests => 11;

use_ok( 'Gantry::Samples' );
use_ok( 'Gantry::Samples::FileUpload' );
use_ok( 'Gantry::Samples::AjaxRequest' );
use_ok( 'Gantry::Samples::AuthCookie' );
use_ok( 'Gantry::Samples::AuthCookie::SQLite::Closed' );
use_ok( 'Gantry::Samples::AuthCookie::SQLite' );
use_ok( 'Gantry::Samples::User' );
use_ok( 'Gantry::Samples::User::Group' );
use_ok( 'Gantry::Samples::TablePermissions' );
use_ok( 'Gantry::Samples::TablePermCRUD' );
use_ok( 'Gantry::Samples::SOAP' );
