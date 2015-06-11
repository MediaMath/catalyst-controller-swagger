use strict;
use warnings;

use Test::More;
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

  warn $response->content;

  cmp_deeply $swagger_data, {
    swaggerVersion => '1.2',
    info           => {
      title        => 'test project',
      description  => 'test description',
    },
    apiVersion     => '2.2.3',
    authorizations => {},
    basePath       => 'http://localhost:3000',
    resourcePath   => '/',
    apis           => [
      {
        path => '/test_one/{param1}/{param2}/foo/{param3}',
        operations => [{
          method  => 'GET',
          summary => '',
          notes   => '',
          type    => '',
          nickname => 'GET_/test_one/{param1}/{param2}/foo/{param3}',
          parameters => [
            {
              allowMultiple => JSON::XS::true,
              name          => 'param1',
              paramType     => undef,
              defaultValue  => JSON::XS::false,
              description   => undef,
              format        => 'int32',
              paramType     => 'path',
              required      => JSON::XS::false,
              type          => 'integer',
            },
            {
              allowMultiple => JSON::XS::true,
              name          => 'param2',
              paramType     => undef,
              defaultValue  => JSON::XS::false,
              description   => undef,
              format        => undef,
              paramType     => 'path',
              required      => JSON::XS::false,
              type          => 'string',
            },
            {
              allowMultiple => JSON::XS::true,
              name          => 'param3',
              paramType     => undef,
              defaultValue  => JSON::XS::false,
              description   => undef,
              format        => undef,
              paramType     => 'path',
              required      => JSON::XS::false,
              type          => 'string',
            },
          ],
          summary => '',
          responseMessages => [
            {
              code    => 404,
              message => 'Ah shoot johny the service is not here!',
            }
          ]
        }],
      },
      {
        path         => '/test_one/{param1}/{param2}/foo/{param3}',
        operations   => [{
          method     => 'POST',
          summary    => '',
          notes      => '',
          type => '',
          nickname   => 'POST_/test_one/{param1}/{param2}/foo/{param3}',
          summary    => '',
        }],
      },
      {
        path         => '/test_two',
        operations   => [{
          method     => 'GET',
          summary    => '',
          notes      => '',
          type => '',
          nickname   => 'GET_/test_two',
          summary    => '',
        }],
      }
    ],
  };
};

done_testing;
1;
