package TestApp::Controller::Root;

use strict;
use warnings;
use base 'Catalyst::Controller::Swagger';
use Swagger qw(add_meta);

our $root_test_data = {
  swagger_version => '1.2',
  api_version     => '2.2.3',
  info            => {
    title         => 'test project',
    description   => 'test description',
  },
};

__PACKAGE__->config(
  namespace       => '',
  swagger         => $root_test_data,
);

add_meta {
  action => 'test_one',
  params => [
    { name => 'param1', type => 'integer' },
    { name => 'param2', type => 'string' },
    { name => 'param3', type => 'string' },
  ],
};

sub test_one_base :Chained('/') :PathPart('test_one') :CaptureArgs(2) {
  my ( $self, $c ) = @_;
}

sub test_one :Chained('test_one_base') :PathPart('foo') :Args(1): Swagger  {
  my ($self, $c) = @_;

  $c->response->body("test_one");
}

sub test_one_post :Chained('test_one_base') :PathPart('foo') :Args(1): Method('POST'): Swagger {
  my ($self, $c) = @_;
  $c->respons->body("test_one POST");
}

sub test_two :Local :Swagger {
  my ($self, $c) = @_;
  $c->response->body('test_two');
}

1;
