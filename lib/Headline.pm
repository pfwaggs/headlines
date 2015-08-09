package Headline;

# vim: ai si sw=4 sts=4 et ft=perl fdc=4 fmr=AAA,ZZZ fdm=marker

# preamble #AAA
use strict;
use warnings;
use 5.010;
use File::Spec;
use File::Glob;
use Carp qw( cluck croak carp );
use Data::Dumper;
use JSON;
use XML::Simple;

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
#push @EXPORT_OK, qw(%funcs);
#ZZZ

# Make_File_Handle(file,mode)#AAA
sub Make_File_Handle {
    my %parms = ( file => undef, mode => undef, @_ );
    my $file = $parms{file} // '-';
    my $mode = $parms{mode} // 'stderr';
    my %xlt = ( '<' => 'read', '>' => 'write' );
    my $return;
    if ( $mode =~ /[><]/ ) {
        my ( $vol, $dir_path, $filename ) = File::Spec->splitpath($file);
        if ( $filename =~ /^-/ ) {
            $return = ( $mode eq '<' ) ? *STDIN : *STDOUT;
        } elsif ( $filename =~ m|^[^-][^/]*$| ) {
            open( $return, $mode, $file ) or croak "Can't open $file for " . $xlt{$mode} . 'access. stopping';
        } else {
            carp 'invalid filename. using STDERR';
            $return = *STDERR;
        }
    } else {
        carp 'invalid mode. using STDERR';
        $return = *STDERR;
    }
    return $return;
}
#ZZZ

# Check_Point(file,style,fini) #AAA
push @EXPORT_OK, qw(&Check_Point);
sub Check_Point {
    my $json = JSON->new;
    my $xmls = XML::Simple->new;

    my %parms = ( file => undef, fini => 0, style => 'json_pretty', @_ );
    my ( $file, $fini, $style ) = @parms{qw/file fini style/};
    my $OFH = Make_File_Handle( file => $parms{file}, mode => '>' );
    given( my $style = $parms{style} ) {
        when( $style =~ /^json$/ )        { print( $OFH $json->encode( $_ )         ) foreach @{$parms{items}}; }
        when( $style =~ /^json_pretty$/ ) { print( $OFH $json->pretty->encode( $_ ) ) foreach @{$parms{items}}; }
        when( $style =~ /xml/ )           { print( $OFH $xmls->XMLout( $_ )         ) foreach @{$parms{items}}; }
        default                           { print( $OFH Data::Dumper->Dump( [ values %$_ ], [ keys %$_ ] ) ) foreach @{$parms{items}}; }
    }
#    foreach my $item ( @{$parms{items}} ) {
#        given( $parms{style} ) {
#            when( /^json$/ ) { print $OFH $json->encode( $item ); } #Data::Dumper->Dump( $inputs{struct}, $inputs{names} ); }
#            when( /^json-pretty$/ ) { print $OFH $json->pretty->encode( $item ); } #Data::Dumper->Dump( $inputs{struct}, $inputs{names} ); }
#            when( /xml/ )  { print $OFH $xmls->XMLout( $item ); } #Data::Dumper->Dump( $inputs{struct}, $inputs{names} ); }
#            default { print $OFH Data::Dumper->Dump( [ values %$item ], [ keys %$item ] ); }
#        }
#    }
    croak "we are fini now." if $parms{fini};
}
#ZZZ

# Read_Config(file [,pattern,rev,despace]) #AAA
push @EXPORT_OK, qw(&Read_Config);
sub Read_Config {
    my %parms = ( file => undef, pattern => qr/\s[:=]\s/, rev => 0, despace => [qw/kf kb vf vb/], @_ );
    my ( $file, $pattern, $rev, @despace ) = @parms{qw/file pattern rev despace/};
    my $IFH = Make_File_Handle( file => $file, mode => '<' );
    my $href;
    my $xmls;
    my $jsn;
    given ( $file ) {
        when( /xml$/ ) {
            $xmls = XML::Simple->new;
            $href = $xmls->XMLin( $IFH );
        }
        when( /jsn$/ ) {
            $jsn = JSON->new;
            local $/;
            $href = <$IFH>;
            $href = $jsn->decode( $href );
        }
        default{
            my %hash;
            while (<$IFH>) {
                chomp;
                s/\#.*//;
                next if /^\s*$/;
                next unless /$pattern/;
                my ( $key, $val ) = split( /$pattern/, $_, 2 );
                $key =~ s/^\s*// if 'kf' ~~ @despace;
                $key =~ s/\s*$// if 'kb' ~~ @despace;
                $val =~ s/^\s*// if 'vf' ~~ @despace;
                $val =~ s/\s*$// if 'vb' ~~ @despace;
                ( $key, $val ) = ( $val, $key) if $rev;
                $hash{$key} = $val;
            }
            $href = \%hash;
        }
    }
    return $href;
}
#ZZZ

# Msg_Set_Init #AAA
push @EXPORT_OK, qw(&Msg_Set_Init);
sub Msg_Set_Init {
    $Carp::Verbose = 1;
    my %inputs = ( file => undef, pattern => qr/\s+[:=]\s+/, @_ );
    ( defined $inputs{file} ) ? my $file = $inputs{file} : croak 'input not defined. stopping';
    my $pattern = $inputs{pattern};
    my $href = Read_Config( file => $file, pattern => $pattern );
    if ( $file !~ /xml/ and $file !~ /jsn/ ) {
        my %msg;
        foreach ( keys %$href ) {
            $msg{$_}{msg} = $href->{$_};
            $msg{$_}{pairs} = {};
        }
        $href = \%msg;
    }
    return $href;
}
#ZZZ

# Make_Pairs #AAA
push @EXPORT_OK, qw( &Make_Pairs );
sub Make_Pairs {
    my %parms = ( cipher => undef, plain => undef, @_ );
    my @cipher;
    my @plain;
    if ( defined $parms{cipher} and defined $parms{plain} ) {
        @cipher = ( ref $parms{cipher} eq 'ARRAY' ) ? $parms{cipher} : split( //, $parms{cipher} );
        @plain  = ( ref  $parms{plain} eq 'ARRAY' ) ?  $parms{plain} : split( //,  $parms{plain} );
    } else {
        cluck 'incomplete info passed in';
        cluck 'cipher ref: ' . ref $parms{cipher};
        cluck 'plain  ref: ' . ref  $parms{plain};
        croak 'fix this in the calling routine. stopping';
    }
    my $return;
    $return->{$cipher[$_]} = $plain[$_] foreach ( 0 .. ( keys @cipher ) - 1 );
    return $return;
}
#ZZZ

# Make_Chains(href,msg) #AAA
push @EXPORT_OK, qw( &Make_Chains );
sub Make_Chains {
    my %parms = ( href => undef, cipher => undef, plain => undef, @_ );
    my @cipher = ();
    my @plain = ();
    my $href;
    if ( defined $parms{href} ) {
        $href = $parms{href} if ( ref $parms{href} eq 'HASH' );
    } else {
        $href = Make_Pairs( @_ ) if ( defined $parms{cipher} and defined $parms{plain} );
    }
    
    croak 'nothing useable passed in' unless ( 0 < keys %$href );
    @cipher =   keys %$href;
    @plain  = values %$href;
    my $return = [];
    foreach my $start ( grep { ! ( $_ ~~ @plain ) } @cipher ) {
        my @sub_chain = ();
        push @sub_chain, $start;
# nb. this way will catch the last letter in the chain and add it to the list
        while ( $href->{$start} ~~ @plain ) {
            $start = $href->{$start};
            push @sub_chain, $start
        }
        push @{$return}, join( ' ', @sub_chain );
    }
    return $return;
}
#ZZZ

# Make_Table_From_String() #AAA
push @EXPORT_OK, qw( &Make_Table_From_String );
sub Make_Table_From_String {
    my %parms = ( str => '', width => 0, @_ );
    my @str = split( //, $parms{str} );
    my $width = $parms{width};
    push @str, ' ' while ( @str % $width );
    my @return;
    while ( @str ) {
        push @return, [ splice( @str, 0, $width) ];
    }
    return \@return;
}
#ZZZ

# Extract_Columns_From_Table #AAA
push @EXPORT_OK, qw( &Extract_Columns_From_Table );
sub Extract_Columns_From_Table {
    my %parms = ( table => undef, order => undef, @_ );
    croak 'table not defined' unless defined $parms{table};
    croak 'order not defined' unless defined $parms{order};
    my @table = @{$parms{table}};
    my @order = @{$parms{order}};
    map { $_-- } @order unless 0 ~~ @order;
    croak 'incompatible table and order' if scalar @order != scalar @{$table[0]};
    my @return;
    foreach my $col ( @order ) {
        my @tmp;
        foreach my $row ( @table ) {
            push @tmp, $row->[$col];
        }
        push @return, [ @tmp ];
    }
    return \@return;
}
#ZZZ

# we are good to this point. look at small utilities (reduce, numerical,
# pattern, etc) then try to get headline generator to work.

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

## make_chains #AAA
##push @EXPORT_OK, qw(&make_chains);
#sub make_chains {
#    my %hash = %{$_[0]};
#    my %hash2 = map {lc $_ => $hash{$_}} keys %hash;
#
#    my $start = join('', keys %hash2);
#    my $end = join('', values %hash2);
#    $end = qr/[$end]/;
#    $start =~ s/$end//g;
#    my @chains;
#    my $c = 0;
#    foreach (sort split(/ */, $start)) {
#        my $chain = $_;
#        while ($hash2{$_}) {
#            $chain .= $hash2{$_};
#            $_ = $hash2{$_};
#        }
#	$chains[$c] = $chain;
#        $c++;
#    }
#    return @chains;
#}
##ZZZ

# col_extract #AAA
push @EXPORT_OK, qw(&col_extract);
sub col_extract {
    my @call = caller(0);
    my @order = @{$_[0]};
    my @table = @{$_[1]};
    my @alpha;
    my $c = 0;
    foreach my $column (@order) {
#	$column--;  # our column numbers are 1 based
	foreach my $row (@table) {
	    $alpha[$column] .= $row->[$c] if ($row->[$c]);
	}
	$c++;
    }
#    shift @alpha;
	say STDERR $call[3] . ": fix col_extract to take a MxN and return an NxM";
    return (\@alpha);
}
#ZZZ

# reduce #AAA
push @EXPORT_OK, qw(&reduce);
sub reduce {
    my @reduce;
    my @list = @_;
    foreach (@list) {
	my $new = '';
	map {$new .= $_ unless ($new =~ /$_/)} (split(/ */, $_));
	push @reduce, $new;
    }
    return(\@reduce);
}
#ZZZ

# reduce1 #AAA
push @EXPORT_OK, qw(&reduce1);
sub reduce1 {
	return (reduce(@_))->[0];
}
$funcs{reduce1} = \&reduce1;
#ZZZ

# numerical #AAA
push @EXPORT_OK, qw( &numerical ) ;
sub numerical {
my  @numerical ;
my  ( $offset, @list ) = @_ ;
    foreach ( @list ) {
    my  $c = $offset ;
    my  @l = map { $_ . substr( '000' . $c++, -3 ) } split( /\s*/, $_ ) ;
	$c = $offset ;
    my  %l = map { $_ => $c++ } sort @l ;
	push @numerical, join( '.', map{ $l{$_} } @l ) ;
    }
    return( \@numerical ) ;
}
$funcs{numerical} = \&numerical ;
#ZZZ

# numerical0 #AAA
push @EXPORT_OK, qw( &numerical0 ) ;
sub numerical0 {
    return numerical( 0, @_ ) ;
}
$funcs{numerical0} = \&numerical0 ;
#ZZZ

# numerical1 #AAA
push @EXPORT_OK, qw( &numerical1 ) ;
sub numerical1 {
    return numerical( 1, @_ ) ;
}
$funcs{numerical1} = \&numerical1 ;
#ZZZ

## numericalstr #AAA
#push @EXPORT_OK, qw(&numericalstr);
#sub numericalstr {
#    return (join('.', map {1+$_} numerical($_[0])));
#}
#$funcs{numericalstr} = \&numericalstr;
##ZZZ

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
push @EXPORT_OK, qw( &isolog ) ;
sub isolog {
my  @isolog ;
my  @list = map { lc $_ } @_ ;
    foreach ( @list ) {
    my  $u = 'A' ;
	while ( /[[:lower:]]/ ) {
        my  @l = grep { /[[:lower:]]/ } split( /\s*/, $_ ) ;
	    s/$l[0]/$u/g ;
	    $u++ ;
	}
	push @isolog, $_ ;
    }
    return( \@isolog ) ;
}
$funcs{isolog} = \&isolog ;
#ZZZ

# isolog1 #AAA
push @EXPORT_OK, qw(\&isolog1);
sub isolog1 {
    return (isolog(@_))->[0];
}
$funcs{isolog1} = \&isolog1;
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
    my @anagrams;
    my @list = @_;
    foreach (@list) {
	push @anagrams, join('', sort split(/\s*/, $_));
    }
    return(\@anagrams);
}
$funcs{anagram} = \&anagram;
#ZZZ

# anagram1 #AAA
push @EXPORT_OK, qw(&anagram1);
sub anagram1 {
    return (anagram(@_))->[0];
}
$funcs{anagram1} = \&anagram1;
#ZZZ

# read_config #AAA
push @EXPORT_OK, qw(&read_config);
sub read_config {
    my ($file, $separator) = @_;
    $separator = ':' unless ($separator);
    $separator = qr/$separator/ ;
    my %hash;
    open( my $IFH, "<$file") or die "can't open $file for read\n";
    while (<$IFH>) {
	chomp;
	next if (/^$/);
	my ($good, undef) = split(/#/, $_, 2);
	while ($good =~ /\\$/) { # this  part concats lines with a \ at the end
	    chomp (my $next = <$IFH>);
	    $good =~ s/\\$//;
	    $good .= $next;
	}
#	my ($key, $val) = split(/$separator/, $good, 2);

	my ($key, $val) = split( $separator, $good, 2);
        $key =~ s/(^\s*)|(\s*$)//g ;
        $val =~ s/(^\s*)|(\s*$)//g ;
	$hash{$key} = $val;
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
	my ($key, $val) = split(/\W/, $good, 2);
	($key) = map {s/^\s+//; s/\s+$//; $_} ($key);
	($val) = map {s/^\s+//; s/\s+$//; $_} ($val);
	$hash{$key} = $val;
    }
    return(\%hash);
}
#ZZZ

# load_dictionaries #AAA
push @EXPORT_OK, qw(&load_dictionaries);
sub load_dictionaries {
    my %h_words;
	my $DIR_DICT = ($_[0]) ? $_[0] : $ENV{HPZDICT};
    while (<$DIR_DICT/*.hpz>) {
		say STDERR "reading in $_";
		my $c = 0;
		my $href = read_config($_);
		foreach (keys %$href) {
			next if $h_words{$_};
			print STDERR "\r" . $c++;
			$h_words{$_} = $href->{$_};
#	    my ($pattern, $numerical, $anagram) = split(/:/, $href->{$_});
#	    $h_words{$_}{pattern} = $pattern;
#	    $h_words{$_}{numerical} = $numerical;
#	    $h_words{$_}{anagram} = $anagram;
		}
		say '';
    }
    return(\%h_words);
}
#ZZZ

# make_dict_entry #AAA
push @EXPORT_OK, qw(&make_dict_entry);
sub make_dict_entry {
	my @terms = qw/isolog1 numerical1 anagram1/;
	my %ans;
	foreach (@terms) {
		$ans{$_} = $funcs{$_}($_[0]);
	}
	return ':' . join(':', @ans{@terms}) . ':';
}
#ZZZ

1;
