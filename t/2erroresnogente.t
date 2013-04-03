#perl

use strict;
use warnings;
use Test::More tests => 5;
use Test::Exception;
use Asado;

my $asado = Asado->new;

$asado->agregar(
    nombre => 'Juan',
    puso   => 150
);

is( $asado->total, 150, 'total 1' );

dies_ok( sub { $asado->tabla }, 'No se puede con una sola persona' );

$asado->agregar(
    nombre => 'Pedro',
    puso   => 150
);

is( $asado->total, 300, 'total 2' );
is( $asado->gente, 2,   'personas' );

dies_ok( sub { $asado->tabla }, 'No se puede con dos persona' );
