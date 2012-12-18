#!/usr/bin/perl

my $file = shift;
open(I,$file) or die "Couldn't open file $!\n";

my @categories = <I>;
close(I);

my $N = scalar(@categories);

foreach $i (@categories) { 
    chomp($i);
    foreach $j (@categories) {
	chomp($j);
	my $cost = 1;
	if ($i eq $j) { $cost = 0; }
	print "$i\t$j\t$cost\n";
    }
}
    
	
