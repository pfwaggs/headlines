#!/usr/bin/perl

# structure #AAA
# hash =>
# 	msg# =>
# 		headline = str
# 		subs =>
# 			. = .	# substitution pair
# 			......
# 		freqcount =>
# 			. = int
# 			........
#
#		undos = array
#ZZZ

#    preamble #AAA
use warnings;
use strict;
use 5.010;
use Getopt::Long qw(:config no_ignore_case auto_help);
use Pod::Usage;
#use EncodingSubs (qw/reduce/);
use Headline qw(reduce read_config make_chains);
#ZZZ

# solution #AAA
sub solution {
    my %hash_msg = %{$_[0]};
    my $cipher = join('', sort keys %{$hash_msg{subs}});
    my $plain = join('', @{$hash_msg{subs}}{sort keys %{$hash_msg{subs}}});
    my $solution = $hash_msg{headline};
    eval "\$solution =~ y/$cipher/$plain/" if ($cipher and $plain);
    return($solution);
}
#ZZZ

## sub view_deb #AAA
#sub view_dep {
##    system('clear');
##    say 'start view';
#    my %hash = %{$_[0]};
#    foreach my $msg (sort keys %hash) {
#	say "$msg ";
#	view_parts(\%{$hash{$msg}});
#    }
##    say 'end view';
#}
##ZZZ

# sub next_row #AAA
sub next_row {
    my ($a_ref, $h_ref) = @_;
    my @array = @{$a_ref};
    my %hash = %{$h_ref};

    my @new_row;
    for (my $c = 0; $c < scalar @array; $c++) {
	$new_row[$c] = ' ';
	next unless ($hash{lc $array[$c]});
	$new_row[$c] = $hash{lc $array[$c]};
    }
    return((0 < grep {$_ ne ' '} @new_row) ? \@new_row : undef);
}
#ZZZ

# subs hash 

## QUIT done #AAA
#sub QUIT {
#    my ($href, $aref, $file, $str) = @_;
#    my %hash = %$href;
#    system('clear');
#    display_work($href);
#}
##ZZZ

#  undo #AAA
sub undo {
    my ($href, $aref, $file, $str) = @_;
    my %hash = %$href;
    my @undo = @$aref;
    my ($msg, $c) = split(/ /, pop @undo);
#	my %state;
#	@state{qw/cipher plain/} = ($c, '');
#	add_pairs(\%state, \%{$hash{$msg}}) if ($msg =~ /\d/ and $c =~ /^[[:alpha:]]+$/);
    add_pairs({cipher => $c, plain => ''}, \%{$hash{$msg}}) if ($msg =~ /\d/ and $c =~ /^[[:alpha:]]+$/);
    $_[0] = \%hash;
    $_[1] = \@undo;
}
#ZZZ

# clear done #AAA
sub clear {
    my ($href, $aref, $file, $str) = @_;
    return 0 unless $str;
#	my %state;
#	@state{qw/cipher plain/} = ('abcdefghijklmnopqrstuvwxyz', '');
    add_pairs({cipher => 'abcdefghijklmnopqrstuvwxyz', plain => ''}, $href->{$str});
    $_[0] = $href;
}
#ZZZ

# save #AAA
sub save {
    my ($href, $aref, $file, $str) = @_;
    my %hash = %$href;
    my $FILE = "$file";
    open( my $OFH1, '>', "$FILE.sol") || die "can't open $FILE.sol for write $!";
    foreach (sort keys %hash) {
#		printf OFH "%d : %s\n", $_, solution(\%{$hash{$_}}); #$hash{$_}{solution};
        printf $OFH1 "%d : %s :\\\n    %s\n\n", $_, $hash{$_}{headline}, solution(\%{$hash{$_}});
    }
    close $OFH1 or die "can't close $FILE.sol $!";

    open( my $OFH2, '>', "$FILE.state") || die "can't open $FILE.state $!";
    foreach my $msg (sort keys %hash) {
        my @tmp ;
        push( @tmp, $_.$hash{$msg}{subs}{$_} ) foreach sort keys %{$hash{$msg}{subs}} ;
#        printf $OFH2 "%d : %s :\\\n    %s\n\n", $msg, join(' ', sort keys %{$hash{$msg}{subs}}), join(' ', @{$hash{$msg}{subs}}{sort keys %{$hash{$msg}{subs}}});
        printf $OFH2 "%d : %s\n", $msg, join( ' ', @tmp ) ;
    }
    close $OFH2 or die "can't close $FILE.state $!";

    open( my $OFH3, '>', "$FILE.chain") || die "can't open $FILE.chain $!";
    foreach my $msg (sort keys %hash) {
        printf $OFH3 "%s : %s\n", $msg, join(':', make_chains(\%{$hash{$msg}{subs}}));
    }
    close $OFH3 or die "can't close $FILE.chain $!";
}
#ZZZ

## sol done #AAA
#sub sol {
#    my ($href, $aref, $file, $str) = @_;
#    my %hash = %$href;
#    open(OFH, ">$file-tmp.sol") || die "can't open $file-tmp.sol for write";
#    foreach (sort keys %hash) {
##		printf OFH "%d : %s\n", $_, solution(\%{$hash{$_}}); #$hash{$_}{solution};
#		printf OFH "%d : %s :\\\n    %s\n\n", $_, $hash{$_}{headline}, solution(\%{$hash{$_}});
#    }
#    close OFH;
#}
##ZZZ

# guess done #AAA
sub guess {
    my ($href, $aref, $file, $str) = @_;
    my %hash = %$href;
    my @undo = @$aref;
    my ($msg, $cipher, $plain) = split(/\s/, $str, 3);
#	my %state;
#	@state{qw/cipher plain/} = ($cipher, $plain);
#	add_pairs(\%state, \%{$hash{$msg}});
    add_pairs({cipher => $cipher, plain => $plain}, \%{$hash{$msg}});
    push @undo, "$msg $cipher";
    $_[0] = \%hash;
    $_[1] = \@undo;
}
#ZZZ

# view done #AAA
sub view {
    my ($href, $aref, $file, $str) = @_;
    my %hash = %$href;
    return 0 unless $str;
    foreach my $msg (sort split(/\s+/, $str)) {
	say "$msg ";
	view_parts(\%{$hash{$msg}});
    }
    chomp (my $p = <STDIN>);
}
#ZZZ

## state done #AAA
#sub state_save {
#    my ($href, $aref, $file, $str) = @_;
#    my %hash = %$href;
#    open(OFH, ">$file-tmp.state") || die "can't open $file-tmp.state";
#    foreach my $msg (sort keys %hash) {
#		say "saving $msg";
#		printf OFH "%d : %s :\\\n    %s\n\n", $msg, join(' ', sort keys %{$hash{$msg}{subs}}), join(' ', @{$hash{$msg}{subs}}{sort keys %{$hash{$msg}{subs}}});
#    }
#    close OFH;
#}
##ZZZ

# quit done #AAA
sub quit {
    my ($href, $aref, $file, $str) = @_;
    my %hash = %$href;
    save($href, $aref, $file, $str);
    system('clear');
    display_work($href);
}
#ZZZ

# drag #AAA
sub drag {
    my ($href, $aref, $file, $str) = @_;
    my %hash = %$href;
    my ($msg, $drag) = split(/\s/, $str);
    system('clear');
    my $a_ref = chain_drag(\%{$hash{$msg}}, \%{$hash{$drag}});
    foreach (@{$a_ref}) {
	say "@{$_}";
    }
    chomp (my $p = <STDIN>);
    system('clear');
}
#ZZZ

my %subs = ( 
     quit => \&quit,
     save => \&save,
     undo => \&undo,
    clear => \&clear,
     drag => \&drag,
     view => \&view,
    guess => \&guess,
);

# sub display_work #AAA
sub display_work {
    my %hash = %{$_[0]};
    foreach my $msg (sort keys %hash) {
	say "$msg:";
	printf "\t%s\n", join(' ', sort keys %{$hash{$msg}{subs}});
	printf "\t%s\n", join(' ', @{$hash{$msg}{subs}}{sort keys %{$hash{$msg}{subs}}});
	say '';
	printf "\t%s\n", join(' ', split(//, $hash{$msg}{headline}));
	printf "\t%s\n", join(' ', split(//, solution(\%{$hash{$msg}}))); #$hash{$msg}{solution}));
	say "\n";
    }
}
#ZZZ

# reduce1 #AAA
sub reduce1 {
    my $aref = reduce(@_);
    return $aref->[0];
}
#ZZZ

# add_pairs #AAA
sub add_pairs {
#    my ($cipher, $plain, $h_ref) = (@_);
    my ($state_href, $msgs_href) = (@_);
    my %hash_msg = %$msgs_href;
    my $cipher = reduce1("\U$state_href->{cipher}");
    my $plain = $state_href->{plain} // $cipher;
#    return ($h2_ref) unless (length($cipher) == length($plain));
    if ( $plain !~ /\./ ) {
        $plain = reduce1($plain) ;
        return 0 if (length($cipher) != length($plain)) ;
    }
    my %hash_msg_tmp; ################################################### TODO do we need this?  better way?  maybe add pairs after all data read in?
    @hash_msg_tmp{split(/ */, $cipher)} = (split(/ */, $plain));
    map {$hash_msg{subs}{$_} = $hash_msg_tmp{$_}} grep {exists $hash_msg{subs}{$_}} keys %hash_msg_tmp;
    map {$hash_msg{subs}{$_} = '.'} grep {$_ eq $hash_msg{subs}{$_}} keys %{$hash_msg{subs}};
    $_[1] = \%hash_msg;
#    return(\%hash_msg);
}
#ZZZ

## sub save_state #AAA
#sub save_state {
#    my %hash = %{$_[0]};
#    open(OFH,">$_[1]") or die "can't open $_[1]";
#    foreach my $msg (sort keys %hash) {
##	printf OFH "%d : cipher : %s\n", $msg, $hash{$msg}{cipher};
##	printf OFH "%d :  plain : %s\n", $msg, $hash{$msg}{plain};
#	printf OFH "%d : cipher : %s\n", $msg, join(' ', sort keys %{$hash{$msg}{subs}});
#	printf OFH "%d :  plain : %s\n\n", $msg, join(' ', @{$hash{$msg}{subs}}{sort keys %{$hash{$msg}{subs}}});
#    }
#    close OFH;
#}
##ZZZ
## sub save_sol #AAA
#sub save_sol {
#    my %hash = %{$_[0]};
#    open(OFH,">$_[1]") or die "can't open $_[1]";
#    foreach my $msg (sort keys %hash) {
#	printf OFH "%d : headline : %s\n", $msg, $hash{$msg}{headline};
#	printf OFH "%d : solution : %s\n\n", $msg, $hash{$msg}{solution};
#    }
#    close OFH;
#}
##ZZZ
# chain_drag #AAA
sub chain_drag {
    my ($h1_ref, $h2_ref) = @_;
    my %hash1 = %{$h1_ref};
    my %hash2 = %{$h2_ref};
    
    my (@cipher, @plain);
    foreach (keys %{$hash1{subs}}) {
	push @cipher, lc $_;
    }
    foreach (values %{$hash1{subs}}) {
	push @plain, lc $_;
    }

    my %chains;
    @chains{@cipher} = @plain;
    $chains{' '} = ' ';
    my %reverse_chains = reverse %chains;

    my @matrix;
    $matrix[0] = [split(//, $hash2{headline})];
    my $a_ref = next_row($matrix[0], \%reverse_chains);
    while($a_ref) {
	unshift @matrix, $a_ref;
	$a_ref = next_row($a_ref, \%reverse_chains);
    }
    $a_ref = next_row($matrix[-1], \%chains);
    while($a_ref) {
	push @matrix, $a_ref;
	$a_ref = next_row($a_ref, \%chains);
    }
    return(\@matrix);
}
#ZZZ
#    view_parts #AAA
sub view_parts {
    my %hash_msg = %{$_[0]};
    printf "%16s :  %s\n", 'headline', $hash_msg{headline};
    printf "%16s :  %s\n", 'solution', solution(\%hash_msg);
#    foreach my $part (qw/headline solution/) {
#	printf "%16s => %s\n", $part, $hash_msg{$part}; # "\t$part => $hash_msg{$part}" if ($hash_msg{$part});
#    }
#    printf "%16s :", 'frequency';
#    foreach my $letter (sort keys %{$hash_msg{freqcount}}) {
#	printf "%3d", $hash_msg{freqcount}{$letter};
#    }
#    printf "\n";
    printf "%16s :  %s\n", 'cipher', join('  ', sort keys %{$hash_msg{subs}});
    printf "%16s :  %s\n", 'plain', join('  ', @{$hash_msg{subs}}{sort keys %{$hash_msg{subs}}});
    printf "%16s :  %s\n", 'chains', join(' ', make_chains(\%{$hash_msg{subs}}));
    printf "\n\n";

}
#ZZZ

# TODO need to reexamine the init stuff.  read data in then update pairs for all in
# one routine?
# init stuff #AAA
pod2usage(-verbose => 1) unless @ARGV;

my %opts = ('use-state' => 0,);
my @opts = ( 'man', 'use-state', ) ;
GetOptions( \%opts, @opts) ;
pod2usage(-verbose => 1) if ($opts{help});
pod2usage(-verbose => 2) if ($opts{man});
#pod2usage(0) unless ($ARGV);

# init stuff 
my $file=$ARGV[0];
(my $file_base = $file) =~ s/\.\w+$//;
say "file is $file";
say "file_base is $file_base";
#$file =~ s/.enc// if ($file =~ /.enc$/);
my %msgs;
my $href = read_config($file);
map {s/\.$//; $msgs{$_}{headline} = $href->{$_}} (keys %$href);
foreach my $msg (keys %msgs) {
    (my $letters = $msgs{$msg}{headline}) =~ s/[^[:alpha:]]//g;
    my $aref = reduce ($letters);
    my $reduced = $aref->[0];
    map {$msgs{$msg}{subs}{$_} = '.'} split(/\s*/, $reduced);
    (my $text = $msgs{$msg}{headline}) =~ s/[^[:alpha:]]//g;
    foreach my $letter (split(/\s*/, $text)) {
	$msgs{$msg}{freqcount}{$letter}++;
    }
}

#foreach my $msg (keys %hash) {
#    say "$msg";
##    headlines subs freqcount undo
#    say "\theadline";
#    say "\t\t$hash{$msg}{headline}";
#    say "\tsubs";
#    map {say "\t\t$_ $hash{$msg}{subs}{$_}"} (sort keys %{$hash{$msg}{subs}});
#    say "\tfreqcount";
#    map {say "\t\t$_ $hash{$msg}{freqcount}{$_}"} (sort keys %{$hash{$msg}{freqcount}});
#    say "\tundo";
#    map {say "\t\t$_"} @{$hash{$msg}{undo}};
#}

if (-s "$file_base.state" and $opts{'use-state'}) {
    my $href = read_config("$file_base.state");
    my %state;
    foreach my $msg (keys %$href) {
        foreach my $pair ( split( /\s/, $href->{$msg} ) ) {
            my ($cipher, $plain) = split( //, $pair ) ;
            $state{$msg}{cipher} .= "$cipher " ;
            $state{$msg}{plain} .= "$plain " ;
        }
    }
    foreach my $msg ( sort keys %msgs) {
#	%{$hash{$msg}} = %{add_pairs($state{$msg}{cipher}, $state{$msg}{plain}, \%{$hash{$msg}})};
#	add_pairs($state{$msg}{cipher}, $state{$msg}{plain}, \%{$hash{$msg}});
	add_pairs(\%{$state{$msg}}, \%{$msgs{$msg}});
    }
}
#ZZZ

#    main #AAA
my @undo;
while (1) {
    system('clear');
    my ($command, $msg, $c, $p, $drag);
    display_work(\%msgs);
    say "command(quit save undo clear drag view #)? ";
    chomp(my $ans = <STDIN>);
    $ans = 'guess ' . $ans if ($ans =~ /^\d/);
    ($command, my $args) = split(/\s+/, $ans, 2);
    say "command is $command";
    say "args are $args" if $args;
    $subs{$command}(\%msgs, \@undo, $file_base, $args);
    last if ($command =~ /^[qQ]/);

#    system('clear');
#    (($ans =~ /^\d/) ? ($msg, $c, $p) : ($command, $msg, $drag)) = split(/\s+/, $ans);
#    $command = 'trial' unless ($command);
#    $msg = '' unless ($msg);
#    $c = '' unless ($c);
#    $p = '' unless ($p);
#    map {say $_} (qq/$command $msg $c $p/);
#    if ($command =~ /^quit/) {
#	save_state(\%hash, "$file_base.state");
#	system('clear');
#	display_work(\%hash);
#	last;
#    } elsif ($command =~ /^Quit/) {
#	system('clear');
#	display_work(\%hash);
#	last;
#    } elsif ($command =~ /^undo/i) {				# working on undo
#	($msg, $c) = split(/ /, pop @undo);
#	next unless ($msg =~ /\d/ and $c =~ /^[[:alpha:]]+$/);
#	%{$hash{$msg}} = %{add_pairs($c, '', \%{$hash{$msg}})};
#    } elsif ($command =~ /^clear/i) {
#	next unless ($msg =~ /\d/);
#	$c = 'abcdefghijklmnopqrstuvwxyz';
#	%{$hash{$msg}} = %{add_pairs($c, $p, \%{$hash{$msg}})};
#    } elsif ($command =~ /^sol/i) {
#	save_sol(\%hash, "$file_base.sol");
#    } elsif ($command =~ /^state/i) {
#	save_state(\%hash, "$file_base.state");
#    } elsif ($command =~ /^view/) {
#	($msg =~ /\d/) ? view_parts(\%{$hash{$msg}}) : view(\%hash);
#    } elsif ($command =~ /^drag/) {
#	system('clear');
#	my $a_ref = chain_drag(\%{$hash{$msg}}, \%{$hash{$drag}});
#	foreach (@{$a_ref}) {
#	    say "@{$_}";
#	}
#	chomp ($p = <STDIN>);
#	system('clear');
#    } else {
#	next unless ($msg =~ /\d/);
#	say "$msg $c $p";
#	push @undo, "$msg $c";
#	%{$hash{$msg}} = %{add_pairs($c, $p, \%{$hash{$msg}})};
#    }
}
#ZZZ

# documentation#AAA
__END__

=pod

=head1 NAME

guess.pl

=head1 SYNOPSIS

guess.pl [options] file

=head1 DESCRIPTION

B<guess.pl>

used to take an input file of encrypted headlines and allow an interactive solution of the headlines.  after starting you will be presented with a list of headlines and a command line.  you can enter a guess, undo, save, save state

=head1 OPTIONS

=over 8

=item B<use-state>

use the state file when reading in the encrypted headlines.  <default is to ignore the file>

=back

=head1 ARGUMENTS

=over 8

=item B<file>

name of file that contains the numbered headlines, one per line.

=back

=cut
#ZZZ
