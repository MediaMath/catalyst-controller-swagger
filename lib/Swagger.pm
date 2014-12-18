use strict;
use warnings;
package Swagger;
use Swagger::V12;

use Sub::Exporter -setup => {
  exports => [
    qw(add_meta generate_parameterized_path meta)
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

sub generate_parameterized_path($$) {
  my ($path, $char) = @_;
  my $i;
  $path =~ s/\Q$char\E/"{param" . ++$i ."}"/eg;
  return $path;
}

sub get_generator {
  my ($configuration) = @_;

  $configuration->{swagger_version} ||= '1.2';

  if ($configuration->{swagger_version} eq '1.2') {
    return Swagger::V12->new(configuration => $configuration);
  }
  die "Invalid version specified";
}

1;


