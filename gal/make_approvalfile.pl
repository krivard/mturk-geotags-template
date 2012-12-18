#!/usr/bin/perl

use Text::CSV;

my $results = shift;
my $profile = shift;
my $minScore = shift;

my @forceapprove;
my $d = shift;
while (defined($d)) {
    push @forceapprove,$d;
    $d = shift;
}

#my @forceapprove = @_;
#for my $a (@_) { 
#    print "\t$a\n";
#}
 
unless (defined($profile)) {
    die "Usage: ./make_approvalfile.pl hit.resultsfile.csv profilename [minScore=0.0+ [approvedWorkerId1 approvedWorkerId2 ...]]\n\tOutput: {profilename}.upload.csv {profilename}.workerstatus\n";
}
unless (defined($minScore)) { $minScore = 0.0; }
$minScore *= 100;

my $minCount = 0;
my $minAccuracy = 50;

my %maxli;
my %mincost;
my %count, $totalCount, $rejectCount;
my %status;
my %approve,%reject,%unsure;
open my $data, "<$profile.results/worker-statistics-summary.txt" or die "Couldn't find worker statistics:\n$!\n";
<$data>; #drop field header line
while(<$data>) {
    s/\s+$//;s/^\s+//;
    ($worker,$nan,$nan,$dsml,$nan,$dsmc,@trash) = split;
    $maxli{$worker} = $dsml;
    $mincost{$worker} = $dsmc;
    $count{$worker} = $trash[7];
    $totalCount+=$count{$worker};
    if ( ($dsml > $minScore || $dsmc > $minScore) 
	|| ($count{$worker} < $minCount) ) {
	$approve{$worker} = 1;
    } elsif ($dsml eq "N/A" || $dsmc eq "N/A") {
	$unsure{$worker} = 1;
    } else {
	$reject{$worker} = 1;
    }
}

for my $a (@forceapprove) { 
    print "\tForcing approval of worker $a\n";
    $approve{$a} = 1;
    delete $unsure{$a};
    delete $reject{$a};
}

my %weights = (
    broken => 0.1,
    good => 0.3,
    bad => 0.3,
    nearby => 0.3
    );
for my $w (keys %unsure) {
    #print "$w\t$count{$w}\n";
    open my $details,"<$profile.results/worker-statistics-detailed.txt" or die "Couldn't open detailed worker statistics file:\n$!\n";
    my %matrix, $scorecount=0;
    while(<$details>) { last if $_=~/$w/; } #skip to this worker
    while(<$details>) { last if $_=~/Matrix/; } #skip to confusion matrix
    while(<$details>) { # read matrix
	last if $_=~/Matrix/;
	~s/P\[//g;
	for (split) {
	    next if $_=~/---/;
	    s/->/ /;
	    s/\]=/ /;
	    s/%//;
	    my @parts = split;
	    $matrix{$parts[0]}{$parts[1]} = $parts[2];
	    #print "$parts[0]\t$parts[1]\t$matrix{$parts[0]}{$parts[1]}\n";
	    $scorecount+=$weights{$parts[0]};
	}
    }
    $scorecount/=4;
    my $accuracy = 0;
    $accuracy += $weights{good}   * ($matrix{good}{good} + $matrix{good}{nearby});
    $accuracy += $weights{bad}    * ($matrix{bad}{bad} + $matrix{bad}{nearby});
    $accuracy += $weights{nearby} * ($matrix{nearby}{nearby} + $matrix{nearby}{good} + $matrix{nearby}{bad});
    $accuracy += $weights{broken} * ($matrix{broken}{broken});
    $accuracy /= $scorecount;
    
    if ($accuracy > $minAccuracy) {
	$approve{$w} = 1;
    } else {
	$reject{$w} = 1;
    }
    delete $unsure{$w};
    #print "$w\t$scorecount\t$accuracy\n\n";
    #last;
}


for my $w (keys %approve) { $status{$w} = "approve"; }
for my $w (keys %reject)  { $status{$w} = "reject"; }
for my $w (keys %unsure)  { $status{$w} = "unsure"; }


open my $workerstatus,">$profile.workerstatus" or die "Couldn't open worker status file:\n$!\n";
print $workerstatus "WorkerId\tApprove/Reject\tDSMaxLikelihoodQuality\tDSMinCostQuality\tResponseCount\n";
foreach my $workerid (keys %status) {
    #my $foo = "reject";
    #$foo = "approve" if $status{$workerid} eq "x";
    #$foo = "mystery" if $status{$workerid} eq "?";
    print $workerstatus "$workerid\t$status{$workerid}\t$maxli{$workerid}\t$mincost{$workerid}\t$count{$workerid}\n";
}
close($workerstatus);
my $rejectSize = scalar(keys %reject), $totalSize = scalar(keys %status);
my $rejectHITcount = 0; for (keys %reject) { $rejectHITcount += $count{$_}; } 
print "Rejecting $rejectSize workers of $totalSize totalling $rejectHITcount of $totalCount HITs\n";

open  my $download, "<$results" or die "Couldn't open $results file:\n$!\n";
my $csv = Text::CSV->new();
my @rows;
my $i=0;
while (my $row = $csv->getline($download)) {
    if ($i > 0) {
	#print $row->[15];
	#print " $status{$row->[15]}";
	if ($status{$row->[15]} eq "approve") {
	    $row->[33] = "x";#$status{$row->[15]};
	} elsif ($status{$row->[15]} eq "reject") {
	    $row->[34] = "Worker responses consistent with spam/random chance"; #$status{$row->[15]};
	    unless ($row->[31] eq "") {
		print "$row->[15] $row->[28]:$row->[29] $row->[31]\n";
	    }
	} else {
	    print "$row->[15] $row->[28]:$row->[29] $row->[31]\t(unsure)\n";
	}
	#print " ,$row->[33],$row->[34]\n";
    }
    $i++;
    push @rows,$row;
}
close($download);

$csv->eol("\n");
open  my $upload,">$profile.upload.csv" or die "Couldn't open $profile.upload.csv file:\n$!\n";
$csv->print ($upload,$_) for @rows;
close($upload) or die "upload file:\n$!\n";
