#!/usr/bin/env perl

# vim: ai si sw=4 sts=4 et fdc=4 fmr=AAA,ZZZ fdm=marker

use warnings;
use strict;
use feature ':5.10';

#use Getopt::Long qw( :config no_ignore_case auto_help );
#my %opts;
#my @opts;
#my @commands;
#GetOptions( \%opts, @opts, @commands ) or die 'something goes here';
#use Pod::Usage;
#use File::Basename;
#use Cwd;

my @lines;
while (<>) {
    chomp;
    next unless $_;
    push @lines, $_;
}

my %letters;
my @temp = split( //, $lines[0] );
while (my ($ndx, $val) = each @temp ) {
    $letters{$val} = substr( $lines[1], $ndx, 1 );
}
my %revs;
%revs = reverse %letters;
say join( ' ', sort keys %letters );
say join( ' ', @letters{sort keys %letters});
say '';
say join( ' ', sort keys %revs );
say join( ' ', @revs{sort keys %revs});
