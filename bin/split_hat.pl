#!/usr/bin/perl
use warnings;
use strict;
use 5.010;
use Getopt::Long qw(:config auto_help no_ignore_case);
use Pod::Usage;
use Headline qw(numerical load_dictionaries);

sub numerical1 {
    my $aref = numerical(1, @_);
    return $aref->[0];
}

my %opts = (words => '', man => 0,);
GetOptions(
    \%opts,
    'seq=s',
    'cuts=s',
    'words=s',
	'man',
);
pod2usage(-verbose => 2) if $opts{man};
pod2usage(-verbose => 1) if $opts{help};

die "no sequence given\n" unless (exists $opts{seq});
die "no cuts given\n" unless (exists $opts{cuts});

my $href = load_dictionaries($opts{words});
my %hash_list = %$href;

my $base = $opts{seq};
my @numbers = split(/\./, $base);

# adjust the split array so that each value is the start of the next string.
my @cuts = split(/,/, $opts{cuts});
my $sum = 0;
foreach (@cuts) {
    $sum += $_;
    $_ = $sum;
}
unshift @cuts, 0;
push @cuts, scalar @numbers;

# just to make sure what we are looking at
say "@cuts";

# build the old and new sequences to match words with
my @seq_old;
my @seq_new;
foreach my $i (0 .. @cuts - 2) {
    push @seq_old, join('.', @numbers[$cuts[$i] .. $cuts[$i+1]-1]);
    my $c = 1;
    my %y = map {$_ => $c++} sort {$a <=> $b} @numbers[$cuts[$i] .. $cuts[$i+1]-1];
    push @seq_new, join('.', map {$y{$_}} @numbers[$cuts[$i] .. $cuts[$i+1]-1]);
}

# check our sequences
foreach my $i (0 .. @seq_old - 1) {
    say "$seq_old[$i] => $seq_new[$i]";
}

my %word_list;
foreach my $pat (@seq_new) {
	my @found = grep {$hash_list{$_} =~ /$pat/} keys %hash_list;
	$word_list{$pat} = [@found];
}

if (scalar(@seq_old) == 2) {

    foreach my $left (@{$word_list{$seq_new[0]}}) {
		foreach my $right (@{$word_list{$seq_new[1]}}) {
			my $str = numerical1("$left$right");
			say "$left $right $str" if ($str eq $base);
		}
    }
} elsif (scalar(@seq_old) == 3) {
    my @word_left = @{$word_list{$seq_new[0]}};
    my @word_middle = @{$word_list{$seq_new[1]}};
    my @word_right = @{$word_list{$seq_new[2]}};

    foreach my $left (@word_left) {
	foreach my $middle (@word_middle) {
	    foreach my $right (@word_right) {
		my $str = numerical1("$left$middle$right");
		say "$left $middle $right $str" if ($str eq $base);
	    }
	}
    }
} else {
    say "can't handle this case yet\n";
}

# documentation #AAA
__END__

=pod

=head1 NAME

split_hat.pl

=head1 SYNOPSIS

split_hat.pl --seq n.n.n.n...n --cut N[,N] [--words /some/path/to/dictionaries]

=head1 DESCRIPTION

B<>

=head1 OPTIONS

=over 8

=item B<--cut>

a comma separated list of lengths to break the given sequence into.

=item B<--seq>

the original sequence to split into pieces.

=item B<--words>

a dictionary to read words from.  default is ~/WORDS

=back

=head1 EXAMPLES

=over 8

=item split_hat.pl --seq 5.1.2.4.9.6.7.3.8.10 --cut 5

searches the default word.hpz file for strings that match numeric strings of
4.1.2.3.5 (5.1.2.4.9) and 2.3.1.4.5 (6.7.3.8.10) in that paired order.

=item split_hat.pl --seq 5.1.2.4.9.6.7.3.8.10 --cut 4,2
searches the default word.phz file for strings that match numeric strings of
4.1.2.3 (5.1.2.4), 2.1 (9.6) and 2.1.3.4 (7.3.8.10) in that paired order.

=back

=cut
#ZZZ
