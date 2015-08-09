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
my $changed = 0;
foreach ( keys %$href ) {
    say STDERR 'make pairs for '.$_ if ! exists $href->{$_}{pairs};
    if ( ! exists $href->{$_}{pairs} and defined $href->{$_}{cipher} and defined $href->{$_}{plain} ) {
	$href->{$_}{pairs} = Make_Pairs( href => $href, msg => $_ );
	delete $href->{$_}{cipher};
	delete $href->{$_}{plain};
	$changed++;
    }
}
Check_Point( items => [ $href ], file => $ARGV[0] ) if $changed;
