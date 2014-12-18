package Swagger::V2;

use Moose;
use namespace::autoclean;

my $SWAG_VERSION = '2.0';
use JSON::XS;

has configuration => ( is => 'ro', required => 1);
has swagger_data => (is => 'rw', builder => '_build_swag_data');

sub _build_swag_data {
  my $self = shift;
  delete $self->configuration->{swagger_version};
  my $swagger_data = {
    swaggerVersion  => $SWAG_VERSION,
    %{$self->configuration},
  };
  return $swagger_data;
}

sub add_resource {
  my ($self, $path, $method, $node) = @_;

  my %path_params = map { $_ => 1 } $path =~ m/{([^}]*)}/g;

  my @params;

  if ($node->{params}) {
    for my $param(@{$node->{params}}) {
      $param->{name} ||= '';

      my $in = $param->{in} ? $param->{in} :
               $path_params{$param->{name}} ? 'path' :
               $method =~ /post|put/i ? 'formData' : 'query';

      if ($in eq 'path') {
        if ($path_params{$param->{name}}) {
          delete $path_params{$param->{name}};
        } else {
          $path_params{$param->{name}} = 1;
        }
      }

      my %additional_key_vals;
      if ($in eq 'body' && !$param->{schema}) {
        die "If a paramater is a formData a schema field is required";
      } elsif ($in eq 'body') {
        $additional_key_vals{schema} = $param->{schema};
      } else {
        %additional_key_vals = (
          type => $param->{type} || 'string', #TODO: This is probably not correct
          format => $param->{format} || '',
          #TODO items, and this is required if type is 'Array'
        );
      }

      push @params, {
        name        => $param->{name},
        in          => $in,
        description => $param->{description} || '',
        required    => ($in eq 'path' || ($param->{required} || 0) == 1) ? JSON::XS::true : JSON::XS::false,
        %additional_key_vals,
      };
    }

    if (scalar keys %path_params) {
      die "The parameter must live within the path";
    }
  }

  $self->swagger_data->{paths}{$path}{$method} = {
    summary      => $node->{summary} || '',
    description  => $node->{description} || '',
    tags         => $node->{tags} || [],
    externalDocs => $node->{externalDocs} || '',
    consume      => $node->{consumes} || '',
    produces     => $node->{produces} || [],
    parameters   => \@params,
  };
}

__PACKAGE__->meta->make_immutable;
