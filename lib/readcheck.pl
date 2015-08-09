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
my %solutions;

foreach my $msg ( sort keys %$href ) {
    next if ! $href->{$msg}{pairs};
    my $cipher = uc join( '', keys %{$href->{$msg}{pairs}} );
    my $plain = join( '', values %{$href->{$msg}{pairs}} );
    my $tmsg = $href->{$msg}{msg};
    eval "\$tmsg =~ tr/$cipher/$plain/";
    $solutions{$msg} = uc $tmsg;
}

Check_Point( items => [ $href, \%solutions ] ); #, { chains => $aref } ] );
