#!/usr/bin/perl

my $profile = shift;

unless (defined($profile)) {
    die "Usage: ./make_predictionfile.pl profilename\n";
}

my @concepts;
my %predictions;# = {'A'=>{},'B'=>{},'best'=>{}};
my %scores;

my %response   = ('broken'=>1,'good'=>2,'bad'=>3, 'nearby'=>4);
my $dsindex    = 2; #DS MaxLikelihoodCategory

my $filename = "$profile.results/object-probabilities.txt";
open my $data, "<", $filename or die "Couldn't find worker statistics:\n$! <$filename\n";
<$data>; #drop field header line
while(<$data>) {
    s/\s+$//;s/^\s+//;
    my @parts = split;
    my $concept = $parts[0];
    my $dscat = $parts[$dsindex];
    my $dsprob = $parts[$response{$dscat}];
    push @concepts,$concept;
    $predictions{$concept} = $dscat;
    $scores{$concept} = $dsprob;
    }
    close($data);


for my $concept (@concepts) {
    print "$concept\t";
    print "$predictions{$concept}\t$scores{$concept}\n";
}
