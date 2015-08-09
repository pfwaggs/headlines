#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use 5.010;

use Headline qw(col_extract reduce make_chains read_config);

my %opts;
GetOptions(
    \%opts,
    'msg=i',
    'man',
) or pod2usage(1);
pod2usage(-verbose => 2) if ($opts{man});

my $aref = read_config($ARGV[0]);

my @cipher ;
my @plain ;
foreach my $pair ( split( /\s/, $aref->{$opts{msg}} ) ) {
    my ( $cipher, $plain ) = split( //, $pair) ;
    push @cipher, $cipher ;
    push @plain, $plain ;
}
my %hash;

#my ($cipher, $plain) = split(/:/, $aref->{$opts{msg}});
#$cipher =~ s/^(?:\s*)(.*?)(?:\s*)$/$1/;	# strip leading and trailing spaces
#$cipher =~ s/[^[:alpha:]]//g;
#$plain =~ s/^(?:\s*)(.*?)(?:\s*)$/$1/;
#$plain =~ s/[^[:alpha:]]//g;
##$aref = reduce($cipher);
##say "cipher : " . join('', @$aref);
##$aref = reduce($plain);
##say "plain  : " . join('', @$aref);
#my @cipher = split(/\s*/, $cipher);
#my @plain = split(/\s*/, $plain);

@hash{@cipher} = (@plain);
my @chains = make_chains(\%hash);
say "msg $opts{msg}";
map {say join(' ', split(/ */, $_))} sort @chains;
say '';

# documentation #AAA
__END__
=head1 NAME

chainit.pl

=head1 SYNOPSIS

chainit.pl --msg=n file

=head1 DESCRIPTION

B<chainit> takes an input file and produces a list of chains composed of corresponding elements between two lines of text in the input file.

=head1 ARGUMENTS

=over 8

=item B<--msg N>

specify the message you want to see the chains for.

=item B<filename>

filename is a file with two lines of text that the chains will be built from.

=back

=head1 EXAMPLES

the file can contain either a solution set or a state set.  this means you can have a file composed of entries that match the following:

 1 : LNIABWC NY 'CMX' CSNJOC LPZB WBPCNX SN AWMXO RT :\
     holders of 'sin' stocks have reason to drink up

 (solution set) or,

 1 : A B C I J L M N O P R S T W X Y Z :\
     d e s l c h i o k a u t p r n f v
 (state set)

and they can even be intermixed (heaven alone knows why you would do that) with no problems.

=item chainit.pl --msg 1 headline.state

 msg 1
 b e
 j c s t p a d
 m i l h
 w r u
 x n o k
 y f
 z v

=cut
#ZZZ
