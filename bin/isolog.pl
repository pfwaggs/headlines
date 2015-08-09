#!/usr/bin/perl
use warnings;
use strict;
use 5.010;

use Getopt::Long qw(:config no_ignore_case);

use Headline qw(isolog reduce load_dictionaries);

my %opts = ( words => '', );
GetOptions(
    \%opts,
    'first=s',
    'second=s',
    'words=s',
    'man',
) or die "illegal option";
$opts{first} = lc $opts{first};
$opts{second} = lc $opts{second};

my $href = load_dictionaries($opts{words});
my %hwords = %$href;

my $aref = isolog($opts{first}, $opts{second});
my @isolog = @$aref; 
$aref = reduce($opts{first}, $opts{second});
my @reduced = map {uc $_} @$aref;

say "$opts{first} $isolog[0] $reduced[0]";
say "$opts{second} $isolog[1] $reduced[1]";

say "compliment letters from $opts{first} in $opts{second}";
(my $tmp = $opts{second}) =~ s/[^$opts{first}]/./g;
say $tmp;

my @isolog_list_0 = grep {$hwords{$_} =~ /^$isolog[0]:/} keys %hwords;
my @isolog_list_1 = grep {$hwords{$_} =~ /^$isolog[1]:/} keys %hwords;

foreach my $guess (@isolog_list_0) {
	$guess =~ s/[^[:alpha:]]//g;
    my $aref = reduce($guess);
    my $tmp = $aref->[0];
    my $tr = "tr/$reduced[0]/$tmp/";
    my $up = "\U$opts{second}";
    eval "\$up =~ $tr";
    $up =~ s/[[:upper:]]/./g;
    my @ans = grep {/^$up$/} @isolog_list_1;
    if (@ans) {
	say $guess;
	map {say "\t$_"} @ans;
    }
}

#for my $test (@isolog_list_2) {
#    eval "";
#}
#foreach my $guess (@isolog_list_1) {
#    my $reduce_1 = reduce($guess);
#    my $tr = "tr/$reduced[0]/reduce($guess)/";
#    foreach my $word_2 (@isolog_list_2) {
#	eval "\$z =~ tr/$reduced{$_}/$a/";
#    }
#}
