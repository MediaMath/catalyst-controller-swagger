use strict;
use warnings;

use Test::Most;
use Test::Deep;
use JSON::XS;

my $class = 'Catalyst::Controller::Swagger';

use_ok $class;
subtest "verify that model does what it should" => sub {
  use Test::WWW::Mechanize::Catalyst 'TestApp';
  my $mech = Test::WWW::Mechanize::Catalyst->new;
  $mech->get_ok('/test_one/1/3/foo/2');
  my $response = $mech->get('/api_docs');

  my $root_test_data = $TestApp::Controller::Root::root_test_data;
  my $swagger_data = JSON::XS::decode_json($response->content);

  cmp_deeply $swagger_data, {
    swaggerVersion => '1.2',
    info           => {
      title        => 'test project',
      description  => 'test description',
    },
    apiVersion     => '2.2.3',
    apis           => [
      {
        path => '/test_one/*/*/foo/*',
        operations => {
          method  => 'GET',
          summary => '',
          notes   => '',
          type    => '',
          nickname => 'GET_/test_one/*/*/foo/*',
          parameters => [{
            allowMultiple => JSON::XS::true,
            name          => 'start',
            paramType     => undef,
            defaultValue  => JSON::XS::false,
            description   => undef,
            format        => 'integer',
            paramType     => 'query',
            required      => JSON::XS::false,
            type          => 'integer',
          }],
          summary => '',
        },
      },
      {
        path         => '/test_one/*/*/foo/*',
        operations   => {
          method     => 'POST',
          summary    => '',
          notes      => '',
          type => '',
          nickname   => 'POST_/test_one/*/*/foo/*',
          parameters => [],
          summary    => '',
        },
      },
      {
        path         => '/test_two',
        operations   => {
          method     => 'GET',
          summary    => '',
          notes      => '',
          type => '',
          nickname   => 'GET_/test_two',
          parameters => [],
          summary    => '',
        },
      }
    ],
  };
};

done_testing;
1;
