package Catalyst::Controller::Swagger;
use Moose;
BEGIN { extends 'Catalyst::Controller' };
use namespace::autoclean;

has swagger => (is => 'ro');

use Swagger qw(meta generate_parameterized_path);
use JSON::XS;
# ABSTRACT: Swagger For Catalyst
sub api_docs : Local {
  my ($self, $c) = @_;

  my $swag_generator = Swagger::get_generator($self->{swagger});
  my $swag_lookup    = meta();

  for my $controller_name ( $c->controllers ) {
    my $controller = $c->controller($controller_name);
    for my $action_method ($controller->get_action_methods) {

      my ($swagger_attr) = grep {/swagger/i} @{$action_method->attributes};

      my $action_name    = $action_method->name;
      my $swag_data      = $swag_lookup->{$action_name};

      if ($swagger_attr || $swag_data) {

        my $action   = $controller->action_for($action_name);
        my ($method) = $action->list_extra_info->{HTTP_METHODS} ?
                       $action->list_extra_info->{HTTP_METHODS}[0] :
                       'GET';

        my $dispatcher = $c->dispatcher;
        my $path       = $swag_data->{path};
        my $expanded   = $dispatcher->expand_action($action);

       unless ($path) {
         if ($expanded->can('chain')) {
           # This is sort of crazy
           # However there isn't an easy way to get full path
           # from a chained action.
           # Perhaps someone with more knowledge of catalyst internals
           # can make this more elegant.
           my @path;
           for my $chain_part (@{$expanded->chain}) {
             push @path, join('/',$chain_part->attributes->{PathPart}[0],
                              ($chain_part->attributes->{CaptureArgs} ? join('/',('*') x $chain_part->attributes->{CaptureArgs}[0]) : ()),
                              ($chain_part->attributes->{Args} ? join('/',('*') x $chain_part->attributes->{Args}[0]) : ()),
                            );
           }
           $path = generate_parameterized_path('/' . join('/', @path),'*');
         } else {
           $path = $c->uri_for($action)->path;
         }
       }

       if ($path) {
         $swag_generator->add_resource($path, $method, $swag_data);
       }
      }
    }

  };

  $c->response->body(JSON::XS::encode_json($swag_generator->swagger_data));
}


1;

=head1 NAME

     Catalyst::Controller::Swagger

=head1 SYNOPSIS

     package MyApp::Controller::Root;
     use base 'Catalyst::Controller::Swagger';
     use Swagger qw(add_meta);

    __PACKAGE__->config(
       swagger => {
         api_version  => '2.2.3',
         info          => {
           title       => 'test project',
           description => 'test description',
         },
       }
     };


     add_meta {
        action => 'test_one',
        params => [
          { name => 'start', type => 'integer' }
        ],
     };

    sub test_one_base :Chained('/') :PathPart('test_one') :CaptureArgs(2) {
      my ( $self, $c ) = @_;
    }

    sub test_one :Chained('test_one_base') :PathPart('foo') :Args(1): Swagger {
      my ($self, $c) = @_;
      $c->response->body("test_one");
    }
    # A swagger route can be flagged to be swagger with the :Swagger attribute
    sub test_two :Local :Swagger {
      my ($self, $c) = @_;
      $c->response->body('test_two');
    }


=head1 DESCRIPTION

Add swagger meta data to ones routes. Currently one can either use the Swagger module
to add explicit data or tag a route via the :Swagger attribute.

=cut

=head1 Swagger

For further information on Swagger and what it is see: http://www.swagger.io

=cut

=head1 CONTRIBUTING

The code for `catalyst-controller-swagger` is hosted on GitHub at:
 
   https://github.com/mediamath/catalyst-controller-swagger/
 
If you would like to contribute code, documentation, tests, or bugfixes, follow these steps:
 
  1. Fork the project on GitHub.
  2. Clone the fork to your local machine.
  3. Make your changes and push them back up to your GitHub account.
  4. Send a "pull request" with a brief description of your changes, and a link to a JIRA 
  ticket if there is one.
 
If you are unfamiliar with GitHub, start with their excellent documentation here:
 
  https://help.github.com/articles/fork-a-repo

=cut

=head1 COPYRIGHT & LICENSE
 
Copyright 2014, Logan Bell/MediaMath
 
This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
 
=cut

