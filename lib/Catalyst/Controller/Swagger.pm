package Catalyst::Controller::Swagger;
use Moose;
BEGIN { extends 'Catalyst::Controller' };
use namespace::autoclean;

has swagger => (is => 'ro');

use Swagger qw(meta);
use JSON::XS;

sub api_docs : Local {
  my ($self, $c) = @_;

  my $configuration = $self->{swagger};

  $configuration->{apiVersion} = delete $configuration->{api_version} || '';

  my $swagger_data = {
    swaggerVersion  => '1.2',
    %$configuration,
  };

  my $swag_lookup = meta();

  for my $controller_name ( $c->controllers ) {
    my $controller = $c->controller($controller_name);
    for my $action_method ($controller->get_action_methods) {
      my ($swagger_attr) = grep {/swagger/i} @{$action_method->attributes};
      my $action_name = $action_method->name;
      my $swag_data = $swag_lookup->{$action_name};

      if ($swagger_attr || $swag_data) {

        my $action = $controller->action_for($action_name);
        my ($method) = $action->list_extra_info->{HTTP_METHODS} ? $action->list_extra_info->{HTTP_METHODS}[0] : 'GET';

        my $dispatcher = $c->dispatcher;
        my $path = $swag_data->{path};
        my $expanded = $dispatcher->expand_action($action);

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
           $path = '/' . join('/', @path);
         } else {
           $path = $c->uri_for($action)->path;
         }
       }

       if ($path) {
         # Parameter generation
         my @params;
         if ($swag_data->{params}) {
           for my $param(@{$swag_data->{params}}) {
             my $param_type = $param->{in} ? $param->{in} :
                              $method =~ /post|put/i ? 'form' : 'query';

             push @params, {
               allowMultiple => JSON::XS::true,
               defaultValue  => $param->{default} // JSON::XS::false,
               description   => $param->{description},
               format        => $param->{type} // '',
               required      => $param->{required} ? JSON::XS::true : JSON::XS::false,
               name          => $param->{name},
               type          => $param->{type} // 'string',
               paramType     => $param_type,
             };
           }
         }

         push @{$swagger_data->{apis}}, {
           path => $path,
           operations => {
             method     => $method,
             summary    => $swag_data->{summary} || '',
             notes      => $swag_data->{notes} || '',
             type       => $swag_data->{type} || '',
             nickname   => $method . '_' . $path, # Raisin style
             parameters => \@params,
           }
         };
       }
      }
    }

  };

  $c->response->body(JSON::XS::encode_json($swagger_data));
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

