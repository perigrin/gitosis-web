use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'Gitosis::Web' }
BEGIN { use_ok 'Gitosis::Web::Controller::Account' }

ok( request('/account')->is_success, 'Request should succeed' );


