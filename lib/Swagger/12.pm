package Swagger::12;
use Moose;
use namespace::autoclean;

my $SWAG_VERSION = '1.2';

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
        format        => $param->{type} // '',
        required      => $param->{required} ? JSON::XS::true : JSON::XS::false,
        name          => $param->{name},
        type          => $param->{type} // 'string',
        paramType     => $param_type,
      };
    }
    if (scalar keys %path_params) {
      die "The parameter must live within the path";
    }
  }

  push @{$self->swagger_data->{apis}}, {
    path => $path,
    operations => {
      method     => $method,
      summary    => $node->{summary} || '',
      notes      => $node->{notes} || '',
      type       => $node->{type} || '',
      nickname   => $method . '_' . $path, # Raisin style
      parameters => \@params,
    }
  };
}

__PACKAGE__->meta->make_immutable;
