#!/usr/bin/perl
use  warnings ;
use  strict ;
use  5.010 ;
use  Getopt::Long qw( :config no_ignore_case auto_help ) ;
use  Pod::Usage ;

BEGIN { unshift @INC, "$ENV{HEADLINES}/lib" unless ( grep { /$ENV{HEADLINES}/ } @INC ) ; } ;

use  Headline qw( %funcs ) ;

my  %opts = ( verbose => 0, man => 0, ) ;
    GetOptions(
        \%opts,
        'isolog|i',
        'anagram|a',
        'numerical1|n',
        'all',
        'man',
    ) ;
    pod2usage( -verbose => 1 ) if $opts{help} ;
    pod2usage( -verbose => 2 ) if $opts{man} ;

my  @funcs = qw/isolog numerical1 anagram/ ;
my  @use_funcs = ( $opts{all} ) ? ( @funcs ) : grep { $opts{$_} } @funcs ;

my  %hash_ans ;
    @hash_ans{@ARGV} = '' ;
    foreach ( @use_funcs ) {
    my  $aref = $funcs{$_}( @ARGV ) ;
        $hash_ans{$ARGV[$_]} .= ':' . $aref->[$_] foreach 0 .. @ARGV - 1 ;
    }
    map { say "$_\t$hash_ans{$_}:" } sort keys %hash_ans ;

# documentation #AAA
__END__

=pod

=head1 NAME

wordpats.pl

=head1 SYNOPSIS

wordpats.pl [--isolog | --anagram | --numeric | --all] word [word ...]

=head1 DESCRIPTION

generates wordpatterns for given words

B<>

=head1 OPTIONS

=over 8

=item B<--isolog>

generate isolog patterns.

=item B<--numeric>

generate numerical patterns.

=item B<--anagram>

generate anagram patterns.

=item B<--all>

generates all possible patterns.

=back

=head1 EXAMPLES

=over 8

=item wordpats.pl [--isolog] first second third

will generate the isologs for the words first, second and third.

=item wordpats.pl --all first secnd third

generate the isolog, numerical and anagram patterns.

=back

=cut
#ZZZ
