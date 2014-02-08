use warnings;

my $infile = $ARGV[0];
open(INFILE, $infile);
print "READING FILE\n";
chomp(@results1 = <INFILE>);
close(INFILE);

my $sample_size = $ARGV[1];

my $filename = $ARGV[2];
open(OUTFILE, ">$filename");


@read_counts = ();
@read_counts_match = ();
@matched = ();

print "PROCESSING FILE\n";
for($i = 0; $i < scalar @results1; $i++) {
	@dataArray = split('\t',$results1[$i]);
	for($k = 0; $k < ($sample_size + 4); $k++) {
		$read_counts[$i][$k] = $dataArray[$k];
	}
	$matched[$i] = 0;	
}

print "CHECKING FOR DUPLICATES\n";
for($i = 0; $i < scalar @results1; $i++) {
	
	if($matched[$i] == 0) {
		$testseq = $read_counts[$i][1];
		$testseq =~ s/TGCA+\Z/TGCA/g;
		$testseq =~ tr/ACGTacgt/TGCAtgca/;
		$testseq = reverse $testseq;
		$testseqsub = substr $testseq, 0, 32;
		
		$count = 0;
		for($j = $i; $j < scalar @results1; $j++) {		
			if($read_counts[$j][2] =~ /$testseqsub/) {
				$matched[$j] = 1;
				$count++;
				#print "$testseqsub\t$results1[$j]\n";
				for($l = 0; $l < ($sample_size + 4); $l++) {
					$read_counts_match[$i][$l] = $read_counts[$j][$l]
				}
			}		
		}
		if($count == 1) {
			print OUTFILE "$read_counts[$i][0]\t$read_counts[$i][1]\t$read_counts[$i][2]\t$read_counts[$i][3]\t";
			#print "$testid\t$count\t$testseqsub\t$read_counts[$i][4]\t$read_counts_match[$i][4]\n";
			for($k = 4; $k < ($sample_size + 4); $k++) {
				@loc_count_query = split('\|',$read_counts[$i][$k]);
				@loc_count_match = split('\|',$read_counts_match[$i][$k]);
				$loc_count_query[0] += $loc_count_match[1];
				$loc_count_query[1] += $loc_count_match[0];
				$read_counts[$i][$k] = join('|', $loc_count_query[0],$loc_count_query[1]); 
				print OUTFILE "$read_counts[$i][$k]\t";
			}
			print OUTFILE "\n";
			#print "$testid\t$count\t$testseqsub\t$read_counts[$i][4]\n";
		}
		if($count == 0) {
			for($k = 0; $k < ($sample_size + 4); $k++) {
				print OUTFILE "$read_counts[$i][$k]\t";
			}
			print OUTFILE "\n";
		}
		if($count > 1) {
			print "$testseqsub\n";
		}
		#print "$results1[$i]\n";
	}
}