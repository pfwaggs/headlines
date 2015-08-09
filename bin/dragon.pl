#!/usr/bin/perl
use warnings;
use strict;
use 5.010;
use Headline qw(isolog read_config);

sub isolog1 {
	my $aref = isolog(@_);
	return $aref->[0];
}

my %isologs;

my $aref = read_config($ARGV[0]);
my %headlines = %$aref;
shift @ARGV;

foreach my $msg (keys %headlines) {
	my @ary = split(/\s+/, $headlines{$msg});
	foreach (0 .. @ary - 1) {
		my $word = "\L$ary[$_]";
		$word =~ s/[^[:alpha:]]//g;
		push @{$isologs{isolog1($word)}}, "$msg:" . ($_ + 1);
	}
}

foreach (@ARGV) {
    my $tmp = isolog1($_);
    if ($isologs{$tmp}) {
		say $_;
		map {say "\t$_"} @{$isologs{$tmp}};
    }
}

# documentation #AAA
__END__

=pod

=head1 NAME

dragon.pl

=head1 SYNOPSIS

dragon.pl headline-file word [word...]

=head1 DESCRIPTION

dragon.pl reads in the headline file (first arg) and drags all the given words
through the messages and reports locations where they may fit.

=head1 ARGUMENTS

=over 8

=item B<headline=file>

file containing the headlines you are searching through.

=item B<word [word...]>

list of words to look for in messages.

=back

=head1 EXAMPLES

=over 8

=item dragon.pl headlines first second third

drags first, second, and third through headlines looking for isolog matches.

=back

=cut
#ZZZ
