#perl

use strict;
use warnings;
use Test::More tests => 6;
use Test::Exception;
use Asado;
use Amigo;

my $asado = Asado->new;

$asado->agregar(
    Amigo->new(
        nombre => 'Juan',
        puso   => 150
    )
);

is( $asado->total, 150, 'total 1' );

$asado->agregar(
    Amigo->new(
        nombre => 'Pepe',
        puso   => 50
    )
);

is( $asado->total, 200, 'total 2' );

$asado->agregar(
    Amigo->new(
        nombre => 'Laura',
        puso   => 0
    )
);

$asado->agregar(
    Amigo->new(
        nombre => 'Pablo',
        puso   => 0
    )
);

is( $asado->total, 200, 'total 3' );
is( $asado->gente, 4,   'gente que participa' );

$asado->agregar(
    Amigo->new(
        nombre => 'Felipe',
        puso   => 0
    )
);

$asado->agregar(
    Amigo->new(
        nombre => 'Maria',
        puso   => 10
    )
);

my $tabla = $asado->tabla;

foreach my $row (@$tabla) {
    printf( "%-7s %7s %10s %11s %-29s\n", @$row );
}

ok( $asado->para_web, 'resultado json' );
is( $asado->resto, 0,'resto' );
