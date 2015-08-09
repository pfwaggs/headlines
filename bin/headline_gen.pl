#!/usr/bin/perl
use warnings;
use strict;
use 5.010;
use Getopt::Long;

use Headline qw(numerical col_extract reduce read_config);

sub make_alpha {
    my %data = %{$_[0]};
    my  $aref ;
    if ( $data{hat} =~ /^[\d\.]*$/ ) {
        push @{$aref}, $data{hat} ;
    } else {
        $aref = numerical(0, $data{hat});
    }
    my @num = split(/\./, $aref->[0]);
#    say join(' ', @num);
    $aref = reduce($data{key} . 'abcdefghijklmnopqrstuvwxyz');
    my $str = $aref->[0];
    my $zzz = scalar @num;
    my $width = qr/.{$zzz}/;
    $str =~ s/($width)/$1 /g;
    my @table;
    my $c = 0;
    map {push @{$table[$c++]}, split(/\s*/, $_)} (split(/\s/, $str));
#    map {say join(' ', @$_)} @table;
    $aref = col_extract(\@num, \@table);
#    map {say $_} @$aref;
#    say join('', @$aref);
    say $_ foreach @$aref ;
    say join('', @$aref ) ;
    return join('', @$aref);
}

sub make_matrix {
    my %data = %{$_[0]};
    $data{alphabet} = make_alpha(\%data);
    push my @setting, split(/ */,$data{setting});
    my @matrix;
    $matrix[0] = $data{alphabet};
    my $alpha = $data{alphabet}.$data{alphabet};
    map {push @matrix, substr($alpha, index($alpha, $_), 26)} (@setting);
    return @matrix;
}

sub encrypt_data {
    my @matrix = @{$_[0]};
    my %data = %{$_[1]};
    my %results;
    foreach my $i (sort keys %data) {
        eval "\$data{\$i} =~ y/$matrix[0]/$matrix[$i]/";
        die $@ if $@;
        $results{$i} = "\U$data{$i}";
    }
    return(%results);
}

my %opts = ( crypto => 'crypto', file => 'text', );
GetOptions(\%opts,
    'key=s',
    'hat=s',
    'setting=s',
    'crypto=s',
    'file=s',
);

my %data;
my %crypto;
my $href = read_config($opts{crypto}) if (-s $opts{crypto});
$crypto{key} = ($opts{key}) ? $opts{key} : $href->{key};
$crypto{hat} = ($opts{hat}) ? $opts{hat} : $href->{hat};
$crypto{setting} = ($opts{setting}) ? $opts{setting} : $href->{setting};

$href = read_config($opts{file}) if (-s $opts{file});
foreach (keys %$href) {
    $data{$_} = "\L$href->{$_}";
}

my @matrix = make_matrix(\%crypto);
my %enc = encrypt_data(\@matrix, \%data);
map {say "$_. $enc{$_}\n"} (sort keys %enc);
