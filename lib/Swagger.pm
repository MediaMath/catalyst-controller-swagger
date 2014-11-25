use strict;
use warnings;
package Swagger;

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

1;


