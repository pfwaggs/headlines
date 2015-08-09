#!/usr/bin/perl
use warnings;
use strict;
use 5.010;
use Getopt::Long qw(:config auto_help);
use Pod::Usage;

#use lib "/home/wapembe/headlines";
#use modules::EncodingSubs (qw/col_extract/);
use Headline qw(col_extract read_config load_dictionaries);

say STDERR "$0: we deprecated the use of words and file";
my %opts=(omit => 0, words => '', );
GetOptions(
    \%opts,
    'man',
    'reverse',
    'omit=i',
    'file=s',
    'words=s',
) or pod2usage(1);
pod2usage(-verbose => 2) if ($opts{man});

#my $href = load_dictionaries($opts{words});
#my %hwords = %$href;

#die "no input file specified\n" unless ($opts{file});
my $file = $ARGV[0];
die "no input file specified\n" unless ($file);
my $href = read_config($file);
my %table = %$href;
my @chart;
foreach (sort keys %table) {
    push @{$chart[$_]}, split(/ */, $table{$_});
}

my @order=(0 .. @{$chart[1]} - 1);
splice @chart, $opts{omit} - 1, 1 if ($opts{omit});
# @transpose consists of strings and not arrays of chars like chart  should be
# changed for consistency
my $aref = col_extract(\@order, \@chart);
my @transpose = @$aref;
@transpose = map {join('', reverse(split(' *', $_)))} @transpose if ($opts{reverse});
map {say $_} @transpose;
say '';

#my @words = map {join('', $_)} (@transpose);
#map {say $_} (@words);

#my $column = 0;
#foreach (@transpose) {
#    last if ($hwords{$_});
#} continue {
#    $column++;
#}
#say "setting is $transpose[$column]";
#
#open(OFH, ">$opts{file}") or die "can't open $opts{file} for write\n";
#foreach (sort keys %table) {
#    printf OFH "%2d : %s\n", $_, substr($table{$_}x2, $column, 26);
#}

# documentation #AAA
__END__
=head1 NAME

flipit.pl

=head1 SYNOPSIS

flipit.pl [--omit n] [--reverse] filename

=head1 DESCRIPTION

B<flipit.pl> will transpose contents of a given file.

=head1 OPTIONS

=over 8

=item B<--omit N>

removes column N from output

=item B<--reverse>

this prints out the strings reversed

=back

=head1 ARGUMENTS

=over 8

=item B<filename>

file containing the data to be transposed.  note that each row must be the same length.

=back

=head1 EXAMPLES

=over 8

=item flipit.pl testfile

suppose that testfile contains:
    no ... fi
    ge ... xc
    eh ... cg
    lv ... su
    in ... yf
    dx ... vz

then the output is:
    ngelid
    oehvnx
    ......
    ......
    ......
    fxcsyv
    icgufz

=item flipit.pl --reverse --omit 2 testfile

with testfile as above we get:
    dilen
    xnvho
    .....
    .....
    .....
    vyscf
    zfugi

=item B<n.b.>

removing a column happens before the reversal.

=back

=cut
#ZZZ
