use Test::More;
use Gantry::Conf ();

plan skip_all => 'set TEST_CONFIG to enable this test' unless $ENV{TEST_CONFIG};

my @avail_configs = qw/base/;
my $instances = {
    base => 'samples',
};
my $configs = {
    samples => [
        qw/
            template_wrapper
            auth_user_password
            doc_root
            app_name
            doc_rootp
            auth_group_join_table
            auth_user_field
            auth_group_table
            show_dev_navigation
            root
            dbconn
            auth_table
        /
    ],
};

diag( "" );
diag( "which config would you like to test?" );
diag( "0. samples" );
diag( "1. None" );
my $p = <STDIN>;
chomp( $p );

if ( $p >= 1) {
    plan skip_all => "config test";
}
else {
    my $instance = $instances->{$avail_configs[$p]};
    my $gconf;

    # Set number of tests to number of config items to test
    # plus 1 for the gantry config test.
    plan tests => scalar( @{$configs->{$instance}} ) + 1;

    diag( "" );
    diag( "Location of gantry config file [/etc/gantry.conf]: ");
    my $config_file = <STDIN>;
    chomp( $config_file );

    unless ($config_file) {
        $config_file = File::Spec->catfile( qw/ \/ etc gantry.conf / );
    }

    eval {
        $gconf = Gantry::Conf->retrieve(
            {
                instance    => "$instance",
                config_file => "$config_file",
            }
        );
    };

    ok(! $@, 'loaded gantry config');

    # Warn about any items found in the gantry config that are missing
    # from the app.
    foreach my $item (@{$configs->{$instance}}) {
        is( exists $gconf->{$item}, 1, "$item found in config" );
        delete $gconf->{$item};
    }

    if (scalar(keys %$gconf)) {
        diag( "" );
        diag( 'The following config items were found but are not present in the app config' );
    }

    foreach my $item (keys %$gconf) {
        diag( $item );
    }
}
