#!/usr/bin/perl -w
# Author: Chris Hokamp
# Function: Load a .TSV tfidf index, and persist using Redis
# Category names are keys, which point to a hash{token}-->value

use strict;
use warnings;

#use Redis;
#use Redis::Hash;
#use Redis::Client;
#use Redis::Client::Hash;
#TESTING - if this doesn't work, just use the string of token,weight as the value
#my $client = Redis::Client->new;
#tie my %cat_hash, 'Redis::Hash', key => 'category', @Redis_new_parameters;

sub getCategoryStore { 
	my %cat_hash = ();

	# Steps:
	#(1) Load and parse the tsv index
	#my $index = $ARGV[0];
	my $index = $_[0];
	chomp($index);
	open INDEX, "<", $index;

	# Category:Albums\t{(a, 532.3337),(r,102.656235),(...)}
	while (my $line = <INDEX>) {
		chomp($line);
		my @cols = split(/\t/, $line);
		my $catName = $cols[0];
		my $weightBag = $cols[1];
		$weightBag =~ s/^\{\(//g;
		$weightBag =~ s/\)\}$//g;
		#print $weightBag."\n";
		
		#Do we need a hack to fix tokens and commas? (Update: appears to be working for now)
		my @tokens_and_weights = split(/\),\(/, $weightBag);
       	 #populate the hash
		my %tokens = ();
       	        foreach my $item (@tokens_and_weights) {
			#print $_."\n";
			my @token_and_weight = split(/,/, $item);
			my $tok = $token_and_weight[0];
			my $weight = $token_and_weight[1];
			$tokens{$tok} = $weight;
		}
       	        $cat_hash{$catName} = \%tokens; 		
		#TEST
#		foreach my $key (keys %cat_hash) {
#			print "key name: $key\n";
#             	        my %tokens = %{$cat_hash{$key}};	
#			foreach my $tok (keys %tokens) {
#				print "token: $tok\n";
#				print "weight: $tokens{$tok}\n";
#			}
	}
	return \%cat_hash;
}
1;
