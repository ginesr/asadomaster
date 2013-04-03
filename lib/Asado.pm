package Asado;

use Moose;
use Data::Dumper qw(Dumper);
use JSON;

has 'calculado' => ( is => 'rw', isa => 'Bool' );
has 'resto' => ( is => 'rw', isa => 'Num' );

my $total;
my @gente;

sub agregar {

    my $self = shift;
    my $args = {@_};

    $total += $args->{puso};
    push @gente, $args;

    return $self;

}

sub para_web {

    my $self     = shift;
    my $cada_uno = $self->total / $self->gente;
    my $json     = {};
    
    $self->tabla;

    $json->{pone_cada_uno} = $cada_uno;
    $json->{gastado}       = $self->total;
    $json->{personas}      = $self->gente;
    #$json->{crudo}        = $self->crudo;
    $json->{resultado}     = $self->indexado;

    return to_json($json);

}

sub crudo {
    
    my $self = shift;
    return \@gente
    
}

sub tabla {

    my $self  = shift;
    my $loop = 0;
    my $resto = 0;
    
    return $self->resultado if $self->calculado;

    $self->recalcular;

    while ( my $sobran = $self->se_debe ) {
        $self->repartir;
        # TODO: en caso de infinitos decimales redondear mejor
        $self->resto($sobran);
        last if ++$loop > 100;
    }

    return $self->resultado;

}

sub indexado {

    my $self      = shift;
    my $resultado = {
        personas   => [],
        por_nombre => {},
    };

    foreach my $persona (@gente) {

        my $nombre  = $persona->{nombre};
        my $debe    = 0;
        my $ledeben = 0;

        if ( $persona->{le_debian} >= 0 ) {
            $ledeben = $persona->{le_debian};
        }
        else {
            $debe = $persona->{le_debian} * -1;
        }

        my $detalle = ( exists $persona->{detalle} ) ? join ',', map { "$_->{quien} \$$_->{cuanto}" } @{ $persona->{detalle} } : '';

        push @{ $resultado->{personas} }, $nombre,

          $resultado->{por_nombre}{$nombre} = {
            puso       => $persona->{puso},
            le_deben   => $ledeben,
            debe_poner => $debe,
            detalle    => $detalle,
          };
    }

    return $resultado;
}

sub resultado {

    my $self = shift;
    my $resultado = [ [ 'Quien', 'Puso', 'Le Deben', 'Debe Poner', 'Quienes' ] ];

    foreach my $persona (@gente) {

        my $debe    = '--';
        my $ledeben = '--';

        if ( $persona->{le_debian} >= 0 ) {
            $ledeben = '$' . $persona->{le_debian};
        }
        else {
            $debe = $persona->{le_debian} * -1;
        }

        my $puso = ( $persona->{puso} > 0 ) ? '$' . $persona->{puso} : '--';
        my $quienes = ( exists $persona->{quien} ) ? join ',', @{ $persona->{quien} } : '';
        my $detalle = ( exists $persona->{detalle} ) ? join ',', map { "$_->{quien} \$$_->{cuanto}" } @{ $persona->{detalle} } : '';

        push @$resultado, [ $persona->{nombre}, $puso, $ledeben, $debe, $detalle ];
    }

    return $resultado;

}

sub se_debe {

    my $self  = shift;
    my $deben = 0;

    foreach (@gente) {
        if ( exists $_->{le_deben} ) {
            $deben += $_->{le_deben};
        }
    }

    return $deben;

}

sub repartir {

    my $self = shift;

    foreach my $gente (@gente) {

        if ( $self->le_deben($gente) ) {

            my $quien = $self->recolectar($gente);

            $gente->{quien}   = [] unless exists $gente->{quien};
            $gente->{detalle} = [] unless exists $gente->{detalle};

            if ($quien) {
                push @{ $gente->{quien} }, $quien->{nombre};
                push @{ $gente->{detalle} },
                  {
                    quien  => $quien->{nombre},
                    cuanto => $quien->{pone}
                  };
                $gente->{le_deben} -= $quien->{pone};
            }
        }
    }

    return $self;
}

sub le_deben {

    my $self    = shift;
    my $persona = shift;

    if (   exists $persona->{le_deben}
        && exists $persona->{debe}
        && $persona->{debe} == 0
        && $persona->{le_deben} > 0 )
    {
        return 1;
    }
    return;
}

sub recolectar {

    my $self  = shift;
    my $gente = shift;

    foreach my $quien (@gente) {
        if ( $quien == $gente ) {
            next;
        }
        if ( $quien->{debe} < 0 ) {

            my $debe_pos = ( $quien->{debe} * -1 );

            if ( $gente->{le_deben} < $debe_pos ) {
                $quien->{debe} += $gente->{le_deben};
                $quien->{pone} = $gente->{le_deben};
            }

            if ( $gente->{le_deben} > $debe_pos ) {
                $quien->{debe} += $debe_pos;
                $quien->{pone} = $debe_pos;
            }

            if ( $gente->{le_deben} == $debe_pos ) {
                $quien->{debe} = 0;
                $quien->{pone} = $debe_pos;
            }

            $quien->{a_quien} = [] unless exists $quien->{a_quien};
            push @{ $quien->{a_quien} }, $gente->{nombre};

            return $quien;
        }
    }
    return;
}

sub recalcular {

    my $self     = shift;
    my $cada_uno = $self->total / $self->gente;
    
    if ($self->gente <= 2) {
        die 'No hay suficiente gente';
    }
    if ($cada_uno == 0) {
        die 'Nadie puso un peso';
    }

    return $self if $self->calculado;

    foreach my $gente (@gente) {

        my $key       = 'debe';
        my $decimales = $gente->{puso} - $cada_uno;

        if ( $gente->{puso} > $cada_uno ) {
            $key = 'le_deben';
        }

        $gente->{debe}      = 0;
        $gente->{cada_uno}  = $self->redondeo($cada_uno);
        $gente->{$key}      = $self->redondeo($decimales);
        $gente->{le_debian} = $self->redondeo($decimales);
    }

    $self->calculado(1);

    return $self;
}

sub redondeo {

    my $self   = shift;
    my $number = shift;

    if ( $number == 0 ) { return $number }

    return int( $number + $number / abs( $number * 2 ) );

}

sub total {

    my $self = shift;
    return $total;

}

sub gente {

    my $self = shift;
    return scalar @gente;

}

__PACKAGE__->meta->make_immutable();
