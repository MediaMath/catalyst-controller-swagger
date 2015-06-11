use strict;
use warnings;

use Test::More;
use Test::Exception;
use Test::Deep;
use JSON::XS;
use File::FindLib 'lib';

my $class = 'Swagger::V2';
use_ok $class;

my $test_data = {
  title          => "Swagger Sample App",                        
  description    => "This is a sample server Petstore server.",
  termsOfService => "http://swagger.io/terms/",
  contact        => {
    name  => "API Support",
    url   => "http=>//www.swagger.io/support",
    email => 'support@swagger.io',
  },
  license        => {
    name => "Apache 2.0",
    url  => "http=>//www.apache.org/licenses/LICENSE-2.0.html"
  },
  version  => "1.0.1"
};


my $test = $class->new(configuration => $test_data);

cmp_deeply $test->swagger_data, {
  swaggerVersion => '2.0',
  %{$test_data},
};

$test->add_resource('/foo', 'GET', {
  params => [
    { name => 'foo' }
  ]
});

cmp_deeply $test->swagger_data, {
  swaggerVersion => '2.0',
  %{$test_data},
  paths => {
    '/foo' => {
      'GET' => {
        summary      => '',
        description  => '',
        tags         => [],
        parameters   => [
          {
            name        => 'foo',
            in          => 'query',
            description => '',
            required    => JSON::XS::false,
            type        => 'string',
            format      => '',
          }
        ],
        consume      => ignore(),
        produces     => [],
        externalDocs => '',
      }
    }
  }
};


throws_ok(sub {$test->add_resource('/bar/{Foo}', 'GET', {params => [{in => 'path'}]})}, qr/The parameter must live within the path/);
throws_ok(sub {$test->add_resource('/bar/{Foo}', 'GET', {params => [{name => 'Bar'}]})}, qr/The parameter must live within the path/);
lives_ok(sub {$test->add_resource('/bar/{Foo}', 'GET', {params => [{name => 'Foo'}]})});

done_testing;
