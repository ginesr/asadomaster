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

$asado->agregar(
    nombre => 'Pepe',
    puso   => 50
);

is( $asado->total, 200, 'total 2' );

$asado->agregar(
    nombre => 'Laura',
    puso   => 0
);

$asado->agregar(
    nombre => 'Pablo',
    puso   => 0
);

is( $asado->total, 200, 'total 3' );
is( $asado->gente, 4,   'gente que participa' );

$asado->agregar(
    nombre => 'Felipe',
    puso   => 0
);

$asado->agregar(
    nombre => 'Maria',
    puso   => 10
);

my $tabla = $asado->tabla;

foreach my $row (@$tabla) {
    printf( "%-7s %7s %10s %11s %-29s\n", @$row );
}

ok( $asado->para_web, 'resultado json' );
