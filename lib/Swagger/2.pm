package Swagger::2;

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

  my @params;
  if ($node->{params}) {
    for my $param(@{$node->{params}}) {
      my $in = $param->{in} ? $param->{in} :
        $method =~ /post|put/i ? 'formData' : 'query';
      push @params, {
        name        => $param->{name},
        in          => $in,
        description => $param->{description} || '',
        required    => ($in eq 'path' || $param->{required} == 1) ? JSON::XS::true : JSON::XS::false,
      };
    }
  }

  $self->swagger_data->{paths}{$path}{$method} = {
    summary     => $node->{summary} || '',
    description => $node->{description} || '',
    tags       => $node->{tags} || [],
    externalDocs => $node->{externalDocs} || '',
    consume   => $node->{consumes} || '',
    produces => $node->{produces} || [],
    parameters => [],
  };
}

__PACKAGE__->meta->make_immutable;
