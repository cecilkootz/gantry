use Test::More;

eval 'use Test::CheckManifest;';

if ($@) {
    plan skip_all => 'Test::CheckManifest required to test MANIFEST';
}

ok_manifest();
