package misc2;

# preamble #AAA
use strict;
use warnings;
use 5.010;

BEGIN {
    use Exporter ();
    our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);
    $VERSION = sprintf "%d.%03d", q$REVISION: 1.1$ =~ /(\d+)/g;
    @ISA = qw(Exporter);
    @EXPORT = ();
    %EXPORT_TAGS = ();
    @EXPORT_OK = ();
}
our @EXPORT_OK;
our %funcs;
%funcs = ();
push @EXPORT_OK, qw(%funcs);
#ZZZ

## garbage #AAA
#sub col_extract {
#    my @order=@{$_[0]};
#    shift @_;
#    my @table=@_;
#    my %extract;
#    my $c=0;
#    map {$extract{$c++}=$_-1} (@order);
#    my @alpha;
#    foreach my $column (keys %extract) {
#	foreach my $row (@table) {
#	    $alpha[$extract{$column}].=$row->[$column] if ($row->[$column]);
#	}
#    }
#    return (@alpha);
#}
#ZZZ

# make_chains #AAA
push @EXPORT_OK, qw(&make_chains);
sub make_chains {
    my %hash = %{$_[0]};
    my %hash2 = map {lc $_ => $hash{$_}} keys %hash;

    my $start = join('', keys %hash2);
    my $end = join('', values %hash2);
    $end = qr/[$end]/;
    $start =~ s/$end//g;
    my @chains;
    my $c = 0;
    foreach (sort split(/ */, $start)) {
        my $chain = $_;
        while ($hash2{$_}) {
            $chain .= $hash2{$_};
            $_ = $hash2{$_};
        }
	$chains[$c] = $chain;
        $c++;
    }
    return @chains;
}
#ZZZ

# col_extract #AAA
push @EXPORT_OK, qw(&col_extract);
sub col_extract {
    my @order = @{$_[0]};
    my @table = @{$_[1]};
    my @alpha;
    foreach my $column (@order) {
	foreach my $row (@table) {
	    $alpha[$order[$column]] .= $row->[$column] if ($row->[$column]);
	}
    }
    return (@alpha);
}
#ZZZ

# reduce #AAA
push @EXPORT_OK, qw(&reduce);
sub reduce {
    my $new = '';
    map {$new .= $_ unless ($new =~ /$_/)} (split(/ */, $_[0]));
    return $new;
}
#ZZZ

# numerical #AAA
push @EXPORT_OK, qw(&numerical);
sub numerical {
    my $c = 'a';
    my @l = map {$_.$c++} (split(/ */, $_[0]));
    #$c=1;
    $c = 0;
    my %l = map {$_ => $c++} (sort @l);
    #return (join('.',map {$l{$_}} (@l)));
    #say join('.',map {$l{$_}} (@l));
    return map{$l{$_}} (@l);
}
$funcs{numerical} = \&numerical;
#ZZZ

# numericalstr #AAA
push @EXPORT_OK, qw(&numericalstr);
sub numericalstr {
    return (join('.', map {1+$_} numerical($_[0])));
}
#ZZZ

# letters #AAA
push @EXPORT_OK, qw(&letters);
sub letters {
    my $c = 'a';
    my @l = map {$_.$c++} (split(/ */, $_[0]));
    $c = 'A';
    my %l = map {$_ => $c++} (sort @l);
    my $ltr;
    map {$ltr .= $l{$_}} (@l);
    return $ltr;
}
#ZZZ

# isolog #AAA
push @EXPORT_OK, qw(&isolog);
sub isolog {
    my $u = 'A';
    my $_ = $_[0];
    while (/[[:lower:]]/) {
	my @l = grep {/[[:lower:]]/} (split(/ */, $_));
	s/$l[0]/$u/g;
	$u++;
    }
    return $_;
}
$funcs{isolog} = \&isolog;
#ZZZ

## wsplit #AAA
#sub wsplit {
#    my $right = $_[0];
#    my $left = '';
#    my $l;
#    while ($left ne $right) {
#	my @r = split(/ */, $right);
#	$l = shift @r;
#	$right = join('',@r);
#	last unless ($right);
#	last if ($right =~ /$l/);
#	$left .= $l;
#    }
#    return ($left ne $right) ? $left : undef;
#}
##ZZZ

# subpattern #AAA
push @EXPORT_OK, qw(&subpattern);
sub subpattern {
    my $_ = $_[0];
    my $left = wsplit($_);
    my $right = reverse($_);
    $right = reverse(wsplit($right));
    s/(^$left)(.*)($right$)/$2/;
    return join('.', $left, $_, $right);
}
#ZZZ

# anagram #AAA
push @EXPORT_OK, qw(&anagram);
sub anagram {
    return (join('', sort split(' *', $_[0])));
}
$funcs{anagram} = \&anagram;
#ZZZ

# read_config #AAA
push @EXPORT_OK, qw(&read_config);
sub read_config {
    my $file = $_[0];
    my %hash;
    open(IFH, "<$file") or die "can't open $file for read\n";
    while (<IFH>) {
	chomp;
	next if (/^$/);
	my ($good, undef) = split(/#/, $_, 2);
	my ($msg, $key, $val) = split(/:/, $good, 3);
	($msg) = map {s/^\s+//; s/\s+$//; $_} ($msg);
	($key) = map {s/^\s+//; s/\s+$//; $_} ($key);
	($val) = map {s/^\s+//; s/\s+$//; $_} ($val);
	$msg = undef if ($msg =~ /^$/);
#	($key, $val) = cleave_line($val) if ($val =~ /^(headline|cipher|plain) : /);
	((defined $msg) ? $hash{$msg}{$key} : $hash{$key}) = $val;
    }
    return(\%hash);
}
#ZZZ

# new read_config #AAA
push @EXPORT_OK, qw(&new_read_config);
sub new_read_config {
    my $file = $_[0];
    my %hash;
    open (IFILE, "<$file") or die "can't hopen $file for read\n";
    while (<IFILE>) {
	chomp;
	next if (/^$/);
	my ($good, undef) = split(/#/, $_, 2);
	my ($key, $val) = split(/:/, $good, 2);
	($key) = map {s/^\s+//; s/\s+$//; $_} ($key);
	($val) = map {s/^\s+//; s/\s+$//; $_} ($val);
	$hash{$key} = $val;
    }
    return(\%hash);
}
#ZZZ

1;
