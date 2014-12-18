package Swagger::12;
use Moose;
use namespace::autoclean;
use HTTP::Status;
use JSON::XS;
my $SWAG_VERSION = '1.2';

has configuration => ( is => 'ro', required => 1);
has swagger_data => (is => 'rw', builder => '_build_swag_data');

use Types::Standard qw(Str);

# TODO: This could become more sophisticated
# using something like type::tiny, this is just
# meta data for now and enforcing type strictness
# at the application might be overreaching.
# Further the swagger documentation doesn't even make it
# clear how strict this should be.
my %types = (
  integer   => { type => 'integer', format => 'int32' },
  long      => { type => 'integer', format => 'int64' },
  float     => { type => 'number', format => 'float' },
  double    => { type => 'number', format => 'double' },
  string    => { type => 'string', format => undef },
  byte      => { type => 'string', format => 'byte' },
  date      => { type => 'string', format => 'date' },
  date_time => { type => 'string', format => 'date-time' },
);

sub _build_swag_data {
  my $self = shift;

  delete $self->configuration->{swagger_version};

  unless (@{$self->configuration}{qw(basePath apiVersion resourcePath)}) {
    @{$self->configuration}{qw(basePath apiVersion resourcePath)} =
      delete @{$self->configuration}{qw(base_path api_version resource_path)};
  }

  die "A base path must be supplied in the configuration"
    unless $self->configuration->{basePath};

  my $swagger_data = {
    swaggerVersion => $SWAG_VERSION,
    %{$self->configuration},
  };
  return $swagger_data;
}

sub add_resource {
  my ($self, $path, $method, $node) = @_;

  my %path_params = map { $_ => 1 } $path =~ m/{([^}]*)}/g;

  my @params;
  my @responses;
  if ($node->{response_messages}) {
    for my $response(@{$node->{response_messages}}) {
      die "Invalid status code supplied: $response->{code}"
        unless HTTP::Status::status_message($response->{code});
      push @responses, {
        code    => $response->{code},
        message => $response->{message},
      }
    }
  }
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

      # For simplicity just default to a "string" type.
      $param->{type} ||= 'string';
      my $type = $types{$param->{type}} || $param->{type};
      push @params, {
        allowMultiple => JSON::XS::true,
        defaultValue  => $param->{default} || JSON::XS::false,
        description   => $param->{description},
        format        => $type->{format},
        required      => $param->{required} ? JSON::XS::true : JSON::XS::false,
        name          => $param->{name},
        type          => $type->{type},
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
      nickname   => $method . '_' . $path,
      (@params ? (parameters => \@params) : ()),
      (@responses ? (responseMessages => \@responses) : ()),
    }]
  };
}

__PACKAGE__->meta->make_immutable;
