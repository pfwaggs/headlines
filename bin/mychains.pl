#!/usr/bin/perl
use warnings;
use strict;
use 5.010;
BEGIN {
    unshift @INC, "$ENV{HEADLINES}/lib" unless ( "ENV{HEADLINES}/lib" ~~ @INC );
};
use Headline qw( Msg_Set_Init Make_Chains Check_Point );
my $msgs = Msg_Set_Init( file => $ARGV[0] );
my $chains = Make_Chains( href => $msgs->{$ARGV[1]}{pairs} );
Check_Point( items => [ $chains ] );
