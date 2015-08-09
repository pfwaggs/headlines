#!/usr/bin/perl

# structures #AAA
# msg =>
# 	# =>
# 		input
# 		output
# 		offset
# 		plain
#ZZZ

#preamble #AAA
use warnings;
use strict;
use 5.010;
use Getopt::Long qw(:config no_ignore_case);
use Pod::Usage;

use Headline qw(read_config load_dictionaries);
#ZZZ

# read options and initialize #AAA
pod2usage(-verbose => 1) unless @ARGV;
my %opts=(encode => 1, matrix => 1, interactive => 0, state => 0, words => '', );
GetOptions(
    \%opts,
    'cipher=s',
    'encode!',
    'matrix!',
    'phrase=s',
    'slides',
    'interactive',
    'file=s',
    'words=s',
    'state',
    'man',
) or die "invalid option";
pod2usage(-verbose=>2) if ($opts{man});

die "no cipher component given\n" unless ($opts{cipher});

(my $cipher = $opts{cipher}) =~ s/ //g if ($opts{cipher});
$cipher = "\L$cipher";
my $cipher2=$cipher.$cipher;
my %offset;
my %solve;
my %msg;
my @order;
my $href;

($opts{phrase}) ? $href = { 1 => $opts{phrase}}
    : ($opts{file}) ? $href = read_config($opts{file})
    : die "nothing to do\n";
map {$msg{$_}{input} = $href->{$_}} keys %$href;
#ZZZ

# main junk #AAA
if ($opts{interactive}) {
    foreach (sort keys %msg) {
	my $msg = $msg{$_}{input}; #{headline};
	system('clear');
	foreach my $slide (0 .. 25) {
	    my $out = "\L$msg";
	    my $tmp = substr($cipher2, $slide, 26);
	    eval "\$out =~ y/$cipher/$tmp/";
	    die $@ if $@;
	    printf STDERR "%2d %s %s\n\n", $slide, ($opts{slides}) ? $tmp : '', $out;
	}
	if ($opts{matrix}) {
	    say STDERR "which row looks good? ";
	    chomp($msg{$_}{offset} = <STDIN>);
	} else {
	    die "\n";
	}
    }
} else {
    my $href = load_dictionaries($opts{words});
    my %hwords = %$href;

    # find the longest alphabetical word then check all decrypts in hword to
    # find the correct offset
    foreach my $msg (sort keys %msg) {
	my $word = '';
	$msg{$msg}{offset} = 0;
#	foreach (split(/ /, $msg{$msg}{headline})) {
	foreach (split(/\s+/, $msg{$msg}{input})) {
	    next if (/[^[:alpha:]]/);
	    $word = $_ if (length $word   < length $_ );
	}

	foreach my $slide (0 .. 25) {
	    my $out = "\L$word";
	    my $plain = substr($cipher2, $slide, 26);
	    eval "\$out =~ y/$cipher/$plain/";
	    die $@ if $@;
	    next unless ($hwords{$out});
	    $msg{$msg}{offset} = $slide;
	    last;
	}
    }
}
#ZZZ

# prep output #AAA
foreach (sort keys %msg) {
    my $output = "\L$msg{$_}{input}";
    my $plain = substr($cipher2, $msg{$_}{offset}, 26);
    eval "\$output =~ y/$cipher/$plain/";
    $msg{$_}{output} = $output;
    if ($opts{encode}) {
	@{$msg{$_}}{qw/input output/} = @{$msg{$_}}{qw/output input/};
	$msg{$_}{offset} = 26 - $msg{$_}{offset};
    }
}
#ZZZ

# show results #AAA
#system('clear');
if ($opts{state}) {
    open(my $OFH1, '>', 'current-state') or die "can't open current-state for write $!";
    open(my $OFH2, '>', 'solution') or die "can't open solution for write $!";
    printf $OFH1 "%2d : %s\n\n", 0, $cipher;
    foreach (sort keys %msg) {
	my $plain = 
	printf $OFH1 "%2d : %s\n", $_, substr($cipher2, $msg{$_}{offset}, 26);
	say $OFH1 '';
	printf $OFH2 "%2d : %s\n", $_, $msg{$_}{input};
    }
} elsif ($opts{matrix}) {
    printf "%2d : %s\n", 0, $cipher;
    foreach (sort keys %msg) {
	printf "%2d : %s\n", $_, substr($cipher2, $msg{$_}{offset}, 26);
    }
} else {
    foreach (sort keys %msg) {
	printf "%s %s %s\n", $_, "\U$cipher", "\U$msg{$_}{input}";
	printf "%s %s %s\n\n", $_, lc substr($cipher2, $msg{$_}{offset}, 26), "\L$msg{$_}{output}";
    }
}
#ZZZ

# documentation #AAA
__END__
=pod

=head1 NAME

grinder.pl

=head1 SYNOPSIS

grinder.pl [options] --cipher cipher-component file

=head1 DESCRIPTION

B<>

=head1 OPTIONS

=over 8

=item B<encode/noencode>

determines if the output data is for an encoding or decoding matrix.  default
is encoding.  use --noencode to get decoding matrix.

=item B<matrix/nomatrix>

determines if a matrix will be output for the results.  default is matrix.
use --nomatrix to disable matrix output format.

=item B<nointeractive/interactive>

determines if the program will be automatic or interactive.  default is
nointeractive.  enable with --interactive.

=item B<phrase=string>

provide a string to be decoded at all offsets of the cipher component.

=item B<man>

man page

=back

=head1 ARGUMENTS

=over 8

=item B<cipher=string>

provide the cipher component to use for dragging.

=back

=head1 EXAMPLES

=over 8

=item grinder.pl --cipher=abcdefghijklmnopqrstuvwxyz --nointeractive file

read in the file words to get the words to check.  take each line from 'file'
and check each substitution alignment to see if it contains words in the
'words' file.

=item grinder.pl --cipher=abcdefghijklmnopqrstuvwxyz --nomatrix --nointeractive file

similar to above but instead of a matrix output you get two rows for each
line, the first row is the cipher component followed by the decrypted text.  the
second row is the cipher component slide and the encrypted text.  this is the
encoding form.

=item grinder.pl --cipher=abcdefghijklmnopqrstuvwxyz --noencode file

now we generate the decoding matrix and the work is done interactively.

=back

=cut
#ZZZ
