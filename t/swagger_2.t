use strict;
use warnings;

use Test::Most;
use Test::Deep;

my $class = 'Swagger::2';
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

$test->add_resource('/foo', 'GET', {});

cmp_deeply $test->swagger_data, {
  swaggerVersion => '2.0',
  %{$test_data},
  paths => {
    '/foo' => {
      'GET' => {
        summary      => '',
        description  => '',
        tags         => [],
        parameters   => ignore(),
        consume      => ignore(),
        produces     => ignore(),
        externalDocs => '',
      }
    }
  }
};


done_testing;
