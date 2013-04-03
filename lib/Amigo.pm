package Amigo;

use Moose;
use Data::Dumper qw(Dumper);
use JSON;
use Sub::Signatures;

has 'nombre' => (is=>'rw',isa=>'Str');
has 'puso' => (is=>'rw');

__PACKAGE__->meta->make_immutable();
