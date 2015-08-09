#!/usr/bin/perl
use warnings;
use strict;
use 5.010;
use Headline qw( Extract_Columns_From_Table Make_Table_From_String Check_Point ); #Msg_Set_Init Check_Point Make_Chains Make_Pairs );
use File::Glob; # ':glob';

my $aref = Make_Table_From_String( str => 'abcdefghijklmnopqrstuvwxyz', width => 5 );
$aref = Extract_Columns_From_Table( table => $aref, order => [1, 2, 5, 4, 3] );
Check_Point( items => [ $aref ] );

#( my $ofile = $ARGV[0] ) =~ s/\.\w*$//;
#my $href = Msg_Set_Init( file => $ARGV[0], pattern => qr/. / );
#my %solutions;
#
#foreach my $msg ( sort keys %$href ) {
#    next if ! $href->{$msg}{pairs};
#    my $cipher = uc join( '', keys %{$href->{$msg}{pairs}} );
#    my $plain = join( '', values %{$href->{$msg}{pairs}} );
#    my $tmsg = $href->{$msg}{msg};
#    eval "\$tmsg =~ tr/$cipher/$plain/";
#    $solutions{$msg} = uc $tmsg;
#}
#
#Check_Point( items => [ $href, \%solutions ] ); #, { chains => $aref } ] );
