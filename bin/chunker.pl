#!/usr/bin/perl
use warnings;
use strict;
use 5.010;
use Getopt::Long qw(:config auto_help);
use Pod::Usage;

#use EncodingSubs (qw/col_extract reduce make_chains/);
use Headline qw(col_extract reduce make_chains);

# invert #AAA
sub invert {
    my @inverse;
    my $d = 0;
    foreach (@{$_[0]}) {
	$inverse[$_] = $d++;
    }
    return(@inverse);
};
#ZZZ

# options #AAA
#my @order=(qw/alpha cut left right widths/);
my %opts=(sep => '  ');
GetOptions(
    \%opts,
    'man',
    'left',
    'right',
    'alpha=s',
    'cut=s',
    'widths=s',
    'sep=s',
    'reverse',
) or pod2usage(1);

pod2usage(-verbose => 2) if ($opts{man});
pod2usage(-message => 'no alphabet given', -verbose => 0) unless ($opts{alpha});
pod2usage(-message => 'no width(s) given', -verbose => 0) unless ($opts{widths});
#ZZZ

my @alpha = split(/ */, $opts{alpha});
$opts{alpha} = join('', $alpha[0], reverse(@alpha[1 .. 25])) if ($opts{reverse});

# determine useable widths
my @widths = ($opts{widths} eq 'all') ? (qw/1 3 5 7 9 11 2 13/)
    : ($opts{widths} eq 'odd') ? (qw/1 3 5 7 9 11 13/)
    : ($opts{widths} eq 'even') ? (qw/2 4 6 8 10 12/)
    : ($opts{widths} =~ /^\d+\.\.\d+$/) ? eval $opts{widths}
    : split(/;/, $opts{widths});

my %decimation;
use integer;
foreach (@widths) {
    my @table;
    my $c = 0;
    my $width = qr/.{$_}/;
    (my $str = $opts{alpha}) =~ s/($width)/$1 /g;
    map {push @{$table[$c++]}, split(/ */, $_)} (split(/ /, $str));
    my @order;
    my $col = 0;
#    my $additive = ((26 % $_) ? $_ * (1 + 26 / $_) : 27) % 26;  # why does this work?
    my $additive = (26 % $_) ? ($_ - 26 % $_) : 1 ;
    while ($#order < $_ - 1) {
	push @order, $col;
	$col += $additive;
	$col %= $_;
    }
    @order = invert(\@order);
    my $aref = col_extract(\@order, \@table);
    my @ary = @$aref;
    $decimation{$_} = join('', @ary);
}

if ($opts{cut}) {
    foreach my $key (keys %decimation) {
	my $ignore;
	if ($opts{left}) {
	    $ignore = join('', split(/.?.?[$opts{cut}]/, $decimation{$key}));
	    $decimation{$key} =~ s/[$ignore]/ /g unless (0 == length $ignore);
	    $decimation{$key} =~ s/(.?.?[$opts{cut}])/ $1/g;
	} elsif ($opts{right}) {
	    $ignore = join('', split(/[$opts{cut}].?.?/, $decimation{$key}));
	    $decimation{$key} =~ s/[$ignore]/ /g unless (0 == length $ignore);
	    $decimation{$key} =~ s/([$opts{cut}].?.?)/$1 /g;
	} else {
	    $ignore = join('', split(/.?[$opts{cut}].?/, $decimation{$key}));
	    $decimation{$key} =~ s/[$ignore]/ /g unless (0 == length $ignore);
	    $decimation{$key} =~ s/(.?[$opts{cut}].?)/ $1 /g;
	}
	$decimation{$key} =~ s/($opts{sep})+/$opts{sep}/g;
    }
}

foreach (@widths) {
    my $count = grep{/\w/} split(/\s*/, $decimation{$_});
    printf "%2d (%2d) %s\n", $_, $count, $decimation{$_};
}

# documentation #AAA
__END__
=head1 NAME

chunker.pl

=head1 SYNOPSIS

chunker.pl [left|right] [--cut letters] --width (all|odd|even) --alpha junk

=head1 DESCRIPTION

B<chunker.pl> takes a given alphabet and decimates it on the given widths.
optionally, for each cut letter given we display a trigram containing that letter and set off by a space from the rest of the decimation.  if the left
or right option is specified then the cut letter is preceded or succeded by a space respectively.

=head1 OPTIONS

=over 8

=item B<[left|right]>

place the spaces on the right or left as indicated

=item B<--cut letters>

the list of letters to blockoff in the decimation

=item B<--sep separater>

character to separate the cuts with (default is '  ')

=back

=head1 ARGUMENTS

=over 8

=item B<--width (odd|even|all|user)>

widths will be specified as:
    odd: (3,5,7,9,11,13) decimations will be shown.
    even: (2,4,6,8,10,12) decimations will be shown.
    all: (odd plus 2) decimations will be shown.
    user: use either a colon separated list of widths or a single range specified item.

=item B<--alpha alphabet>

user supplied alphabet

=back

=head1 EXAMPLES

=over 8

=item chunker.pl --width all hcktzmfovliqxadnubgpwsejry

     3 htflxngsrczoiaupeykmvqdbwj
     5 hminwyzldprtvagjkoxbecfqus
     7 hodsklujzqgyfawcvnetibrmxp
     9 hlgcipkqwtxszaemdjfnrouyvb
    11 hqeogtdyisfbkarlwmucxjvpzn
     2 hkzfvixdugwerctmolqanbpsjy
    13 hacdkntuzbmgfpowvsleijqrxy

=item chunker.pl --cut wxyz --width odd hcktzmfovliqxadnubgpwsejry --sep '   '

     3 htf   lxn   gsr   czo   iaup   eyk   mvqd   bwj   
     5 hmi   n   wy   zl   dprtvagjk   oxb   ecfqus
     7 hodsklu   jzq   gyf   awc   vnetibr   mxp   
     9 hlgcipk   qwt   xs   za   emdjfnro   uyv   b
    11 hqeogt   dyi   sfbkar   lwm   u   cxj   v   pzn   
     2 h   kzf   v   ixd   u   gwe   rctmolqanbps   jy   
    13 hacdknt   uzb   mgfp   owv   sleijq   r   xy   

=back

=cut
#ZZZ
