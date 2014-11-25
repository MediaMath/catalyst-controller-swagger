use strict;
use warnings;
package TestApp;

use Catalyst::Runtime;

use parent qw/Catalyst/;

__PACKAGE__->config( 
    name => 'TestApp' ,
    "Controller::Root" => {}
);

__PACKAGE__->setup(qw/Static::Simple/);

1; 
