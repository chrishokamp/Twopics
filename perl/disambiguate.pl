#!/usr/bin/perl -w
# Author: Chris Hokamp
# Run category disambiguation --> output the category path and the similarity score
# Category names are keys, which point to a hash{token}-->value
use buildGraph;
use createDataStore;

my $catGraphRef = &getCategoryGraph('one.txt');
my %categoryGraph = %{$catGraphRef};
my $dataStoreRef = &getCategoryStore('data/categories-tfidf.tsv');
my %categoryStore = %{$dataStoreRef};

my $sample = "the olympics took place in summer 2008";

sub drive {
	my $query = $_[0];

	my @tokens = split(/ /, $query);
	#turn this into a hash with tfidf weights

#Steps:
# (1) get the contexts for nodes at level 1
# (2) disambiguate and return the winner
# (3) if !(leaf), get the set of nodes below {category}
# (4) repeat (2)
        #build hash of contexts for this level
	       
	my %contexts = ();
        foreach my $category (keys %categoryGraph) {
		$contexts{$category} = $categoryStore{$category};
		# the score subroutine will return the winning category as a string
		# if the graph has a non-empty hash as the value for that String, continue
	 			
		#TEST 
	#	print "Category name: $category\n";
	#	
	#	foreach my $token (keys %{$categoryStore{$category}}) {
	#		print "\tToken: $token\n";		
	#	}
	}
	my $winner = &score(\%contexts, $query);	
	my %topNode = %categoryGraph;
	while ($winner != -1) {
		%topNode = %{$topNode{$winner}};
		foreach my $cat (keys %topNode) {
			my %contexts = ();
			$contexts{$cat} = $categoryStore{$cat};
 		}
		&score(\%contexts, $query);
	}
#my $score = 0;
	#while ($score != -1) {
	#	my %currentTopNode = 

}

sub score {
	my %currentNode = %{$_[0]};
	my %query = %{$_[1]}; #The query still needs to be converted into a tf-idf hash 
	my $size = keys %currentNode;
	if ($size == 0) {
		return -1;
	}
	#Now write the tf-idf comparison code

}

#print Dumper(%categoryStore);
&drive($sample);
