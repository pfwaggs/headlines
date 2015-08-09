#!/usr/bin/perl
use warnings;
use strict;
use 5.010;
use Headline qw( Msg_Set_Init Check_Point Make_Chains Make_Pairs );
use File::Glob; # ':glob';
sub next_filename {
    my %parms = ( @_ );
    my @list = bsd_glob($parms{pattern});
    return sprintf "%03d", 1+(keys @list);
}


( my $ofile = $ARGV[0] ) =~ s/\.\w*$//;
my $href = Msg_Set_Init( file => $ARGV[0], pattern => qr/. / );
Check_Point( items => [ $href ], file => 'tryme.jsn', style => 'json' );
