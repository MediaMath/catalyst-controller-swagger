package TestApp::Controller::Root;

use strict;
use warnings;
use base 'Catalyst::Controller::Swagger';
use Swagger qw(add_meta);

our $root_test_data = {
  api_version  => '2.2.3',
  info          => {
    title       => 'test project',
    description => 'test description',
  },
};

__PACKAGE__->config(
  namespace       => '',
  swagger         => $root_test_data,
);

add_meta {
  action => 'test_one',
  params => [
    { name => 'start', type => 'integer' }
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
