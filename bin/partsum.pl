#!/usr/bin/perl
use warnings;
use strict;
use 5.010;
use Digest::MD5;

my $step = Digest::MD5->new;

while (<>) {
    my @line = split(/ /, $_);
    if (/^$/) {
	$step->add($_);
    } else {
	print $_;
	$step->add($line[0]);
	print substr($step->clone->hexdigest, 0, 5);
	next if (/^$/);
	shift @line;
	foreach (@line) {
	    $step->add(' '.$_);
	    print ' '.substr($step->clone->hexdigest, 0, 5);
	}
    }
    print "\n";
}
print $step->hexdigest."\n";
