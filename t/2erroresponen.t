#perl

use strict;
use warnings;
use Test::More tests => 3;
use Test::Exception;
use Amigo;
use Asado;

my $asado = Asado->new;

$asado->agregar(Amigo->new(
    nombre => 'Juan',
    puso   => 0)
);

$asado->agregar(Amigo->new(
    nombre => 'Pedro',
    puso   => 0)
);

$asado->agregar(Amigo->new(
    nombre => 'Pablo',
    puso   => 0)
);

is( $asado->total, 0, 'total 1' );
is( $asado->gente, 3, 'personas' );

dies_ok( sub { $asado->tabla }, 'Nadie puso un peso' );
