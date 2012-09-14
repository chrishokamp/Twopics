#!/usr/bin/perl -w
#Author: Chris Hokamp
#Function: Load an ontology and create a graph

use strict;
use warnings;
use Redis;

# Steps:
# (1) Load topic-abstracts index (do tf-icf for this on the fly?)
# (2) Split on \t, then get the topic hierarchy
# (3) Store the aggregated abstracts into redis with the Category name as the key

#GLOBAL
my %categoryGraph = ();

my $categoryIndex = $ARGV[0];
chomp ($categoryIndex);

open INDEX, "<", $categoryIndex;

while (my $line = <INDEX>) {
	chomp($line);
	my @fields = split(/\t/, $line);
	my $category_name = $fields[0];

	#many categories have multiple paths
	my @paths = split(/\s/, $fields[2]);
	#foreach path, load the nodes into the hash (remeber that some of these nodes might NOT have context yet!)	
	foreach my $path (@paths) {
		my @nodes = split(/\//, $path);
		
		my $currentNodeRef = ();
		my %temp = ();
		#print "The top node is: $topNode\n";
		if (exists $categoryGraph{$nodes[0]}) {
			$currentNodeRef  = $categoryGraph{$nodes[0]};
			shift(@nodes);
		} else {
			if (@nodes == 1) {
				$temp{'_LEAF_'} = 1;
			} else {
				$temp{'_LEAF_'} = 0;
			}

			$categoryGraph{$nodes[0]} = \%temp;
						
			$currentNodeRef = $categoryGraph{$nodes[0]};
			shift(@nodes);
		}
		
		#now go down the tree, updating or adding nodes as needed	
		if (@nodes >= 1) {
			my $level = 1;
			my $l = @nodes;
			foreach my $node(@nodes) {
			#	print $_."\n";
				$l--;
				$level++;
				if (exists $currentNodeRef->{$node}) {
					#move one level down
					$currentNodeRef = $currentNodeRef->{$node};
							
				} else {
					my %leaf = ();
					if ($l == 0) {
						$leaf{'_LEAF_'} = 1;
						
					} else {
						$leaf{'_LEAF_'} = 0;
					}
					$currentNodeRef->{$node} = \%leaf; 	
					$currentNodeRef = \%leaf;			
				}
				#TEST
				print "node level: $level\n";
				print "node is: $node\n";
			}
		}
		
	}
	
	#test
	#print $category_name."\n";
}
print "DONE\n\n";


sub printPaths {
	my %hash = %{$_[0]};
	my $k = keys %hash;
	print "the number of keys is: $k\n";
	 
	foreach my $key (keys %hash) {
		print "the key is: $key\n";
		#print "the value is $hash{$key}\n";
		my $v = $hash{$key};
		if (ref($v) eq 'HASH') { 
			if ($v->{'_LEAF_'} == 0) {
				&printPaths($v);
	#			print "$key\n";

			}
		}
	}
}

&printPaths(\%categoryGraph);	
		
#
#sub modify_hash {
#	my ($base, $ref) = @_;
#	for my $k (keys %$ref) {
#		if(exist



