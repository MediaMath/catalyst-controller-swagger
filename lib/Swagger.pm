use strict;
use warnings;
package Swagger;
use Swagger::12;

use Sub::Exporter -setup => {
  exports => [
    qw(add_meta meta)
  ],
};

my %swag_lookup;

sub add_meta($) {
  my $swag_data = shift;
  $swag_lookup{$swag_data->{action}} = $swag_data;
}

sub meta {
  return \%swag_lookup;
}

sub get_generator {
  my ($configuration) = @_;

  $configuration->{swagger_version} // '1.2';
  $configuration->{apiVersion} = delete $configuration->{api_version} || '';

  if ($configuration->{swagger_version} eq '1.2') {
    return Swagger::12->new(configuration => $configuration);
  }
  die "Invalid version specified";
}

1;


