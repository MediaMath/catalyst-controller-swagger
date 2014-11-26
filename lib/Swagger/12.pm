package Swagger::12;
use Moose;
use namespace::autoclean;
use JSON::XS;
my $SWAG_VERSION = '1.2';

has configuration => ( is => 'ro', required => 1);
has swagger_data => (is => 'rw', builder => '_build_swag_data');

use Types::Standard qw(Str);

sub _build_swag_data {
  my $self = shift;
  delete $self->configuration->{swagger_version};
  die "A resource path must be supplied in the configuration" unless $self->configuration->{base_path};
  my ($base_path, $api_version, $resource_path) =
    delete @{$self->configuration}{qw(base_path api_version resource_path)};

  my $swagger_data = {
    swaggerVersion => $SWAG_VERSION,
    apiVersion     => $api_version,
    basePath       => $base_path,
    resourcePath   => $resource_path,
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
      my $param_type = $param->{in} ? $param->{in} :
                       $path_params{$param->{name}} ? 'path' :
                       $method =~ /post|put/i ? 'form' : 'query';

      if ($param_type eq 'path') {
        if ($path_params{$param->{name}}) {
          delete $path_params{$param->{name}};
        } else {
          $path_params{$param->{name}} = 1;
        }
      }

      push @params, {
        allowMultiple => JSON::XS::true,
        defaultValue  => $param->{default} // JSON::XS::false,
        description   => $param->{description},
        format        => $param->{format} || '',
        required      => $param->{required} ? JSON::XS::true : JSON::XS::false,
        name          => $param->{name},
        type          => $param->{type} || '',
        paramType     => $param_type,
      };
    }
    if (scalar keys %path_params) {
      die "The parameter must live within the path";
    }
  }

  push @{$self->swagger_data->{apis}}, {
    path => $path,
    operations => [{
      method     => $method,
      summary    => $node->{summary} || '',
      notes      => $node->{notes} || '',
      type       => $node->{type} || '',
      nickname   => $method . '_' . $path, # Raisin style
#      response
      parameters => \@params,
    }]
  };
}

__PACKAGE__->meta->make_immutable;
