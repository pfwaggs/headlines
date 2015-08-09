#!/usr/bin/perl
use warnings;
use strict;
use 5.010;
use Getopt::Long qw(:config no_ignore_case);
use Pod::Usage;

use Headline qw(%funcs load_dictionaries);

my %opts = ( words => '', );
GetOptions(
    \%opts,
    'find',
    'words=s',
    'pat=s',
    'man',
    'isolog|i',
    'anagram|a',
    'numerical1|n',
) or pod2usage(1);
pod2usage( -verbose => 2 ) if ( $opts{man} );

my @type = grep {$opts{$_}} qw/isolog numerical1 anagram/;
pod2usage( -verbose => 1 ) unless ( 1 == scalar @type );
my $type = $type[0];

my $href = load_dictionaries($opts{words});
my %hwords = %$href;

my @list = @ARGV;
if ($opts{find}) {
    my $aref = $funcs{$type}(@ARGV);
    @list = @$aref;
}
foreach my $word (@list) {
    say $word;
    map {say "\t$_"} grep {$hwords{$_} =~ /:$word:/} sort keys %hwords;
}


# documentation #AAA
__END__
=head1 NAME

findword

=head1 SYNOPSIS

findword [--find] [--isolog|--numeric|--anagram)] [--words wordlist-dir] word [word ...]

=head1 DESCRIPTION

B<findword> will take the command line items and either generate the search
terms (if the --find option is given) or will generate the search pattern
using the arguments directly.  It then scans through the wordlist looking for
lines that match the generated pattern.  Any matching lines are parsed to
isolate the first word and these words are grouped according to the pattern it
was found under.

=head1 OPTIONS

=over 8

=item B<--find>

indicates the argument items should be used to generate the search pattern terms

=item B<--isolog | --numerical | --anagram>

indicates the type of search

=item B<--words word-dir>

specify directory where word dictionaries (*.hpz) come from.  (default is ~/WORDS)

=back

=head1 ARGUMENTS

=over 8

=item B<--words> words

the path of the word directory to load word dictionaries from

=item B<word [word ...]>

the list of "words" to use

=back

=head1 EXAMPLES

=over 8

=item findword --find --isolog hello world

this will find all words that match the isologs for 'hello' or 'world' (ABCCD or ABCDE) and group them according to the
derived isolog.

=item findword --isolog --words wordlist ABCCE ABCDE

same as above but the command line arguments are the actual isologs searched for.

=back

=cut
#ZZZ
