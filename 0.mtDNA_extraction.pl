#!/usr/bin/perl

use warnings;
use strict;

# my vars
my $database = "$ARGV[0]"; # the first argu is the database
my $bad_ids = "$ARGV[1]"; # the second argu are the bad ids
my $output = "reads_without_mt_seqs.fsa"; # the default argu
my $get_bad_ids = "just_bad_ids.txt";

# Getting the bad ids to remove them
open (ID, "<$bad_ids") || die "I can't open $bad_ids file!! $! \n";
open (OID, ">$get_bad_ids") || die "I can't cretae $get_bad_ids file !! $! \n";

# my required vars
my $idget;
while (<ID>) {
    chomp;
    next unless /^SRR/;
    if (/(SRR.+)/) {
        $idget = $1;
        print OID "$idget\n"; 
    }
}

close ID;
close OID;

# Reading an entire bad ids into a var
open (BIDS, "< $get_bad_ids") || die "I can't open $get_bad_ids files $!\n";
my %data;
while (<BIDS>){
    chomp;
    $data{$_} = 1;
}
close BIDS;

# matching loop
open (DB, "< $database") ||  die "I can't open $database file $! \n";
open (OUT, ">$output") ||  die "I can't create $output file $! \n";

# My required vars
my %hash;
my $id;
my %check;

#loop to print id and seq
while (<DB>) {
    chomp;
    if (/^>(SRR\d+\.\d+)/) {
        $id = $1;
        $check{$1} = 1;
       # print "$id\n";
    }else{
       $hash{$id} .= $_;
    }
}

# check missing ids
open (BIDS_2, "< $get_bad_ids") || die "I can't open $get_bad_ids files $!\n";
while (<BIDS_2>){
    chomp;
    if($check{$_}){
        print "id found -> $_\n";
    }else{
        print "id did not find -> $_\n";
    }
}
close BIDS_2;

#getting clean seqs
foreach my $key (keys %hash) {
   if ($data{$key}) {
	   #print "$key\n";
       next;
    }else{
        print OUT ">$key\n$hash{$key}\n"; 
        }
}

# close connections
close DB;
close OUT;

# remove tmp files
#unlink $get_bad_ids;
