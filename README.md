# NAME

     Catalyst::Controller::Swagger

# SYNOPSIS

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

    sub test_one :Chained('test_one_base') :PathPart('foo') :Args(1) :Swagger {
      my ($self, $c) = @_;
      $c->response->body("test_one");
    }
    # A swagger route can be flagged to be swagger with the :Swagger attribute
    sub test_two :Local :Swagger {
      my ($self, $c) = @_;
      $c->response->body('test_two');
    }

# DESCRIPTION

Add swagger metadata to any Catalyst route. This module will expose an "api\_docs" route
which will contain JSON that is Swagger 1.2 compatible.

## :Swagger Attribute

When this attribute is applied to an action metadata that is implicit to the route will
be exposed to the api\_docs route. The data that is exposed include the following: path, method,
and route nickname. Any additional metadata that would need to be exposed would need to use
the Swagger::add\_meta function to associate it.

Here is an example of what the default swagger output looks like:

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

## api\_docs route

This is a route that is exposed that will output a JSON data structure that is Swagger 1.2
compatible.

## Swagger::add\_meta

The add\_meta function allows a developer to associate other allowed swagger metadata. For example
params would specify what sort of parameters a route would accept:

     add_meta {
        action => 'test_one', # name of route
        params => [
          { name => 'start', type => 'integer' }
        ],
     };

# Swagger

For further information on Swagger and what it is see: http://www.swagger.io

# CONTRIBUTING

The code for \`catalyst-controller-swagger\` is hosted on GitHub at:

      https://github.com/mediamath/catalyst-controller-swagger/


If you would like to contribute code, documentation, tests, or bugfixes, follow these steps:

     1. Fork the project on GitHub.
     2. Clone the fork to your local machine.
     3. Make your changes and push them back up to your GitHub account.
     4. Send a "pull request" with a brief description of your changes, and a link to a JIRA
     ticket if there is one.


If you are unfamiliar with GitHub, start with their excellent documentation here:

    https://help.github.com/articles/fork-a-repo

# COPYRIGHT & LICENSE

Copyright 2015, Logan Bell & John Napiorkowski / MediaMath

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
