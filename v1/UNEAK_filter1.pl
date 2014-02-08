use warnings;
use Math::BigFloat;

my $infile = $ARGV[0];

my $sampleSize = $ARGV[1];

my $filename = $ARGV[2];
open(OUTFILE, ">$filename");

my $accept_missing = $ARGV[3];

my $accept_hetero = $ARGV[4];


open(IN,$infile); # or die "ERROR, no input file\n";

my @dataArray = ();
my @dataArray1 = ();
my @newDataArray = ();
my $count = 0;
my $missing = 0;

my $entry=<IN>;
print "$entry\n";
#$entry =~ s/\n//g;
chomp($entry);
@dataArray = split('\t',$entry);
for($j = 0; $j < $sampleSize+4; $j++) {
	print OUTFILE "$dataArray[$j]\t";
}
print OUTFILE "A1freq\tA2freq\tObsHet\tExpHet\tFIS\tNo_missing\tAdjSampSize\n";

while($entry=<IN>) {
	#$entry=<IN>;
	#$entry =~ s/\n//g;
	chomp($entry);
	@dataArray = split('\t',$entry);
	
	$missing = 0;
	$obsHetCount = 0;
	$countA1 = 0;
	$countA2 = 0;
	
	for($i = 4; $i < $sampleSize+4; $i++) {
		@dataArray1 = split('\|',$dataArray[$i]);
		$count = 0;
		$count += $dataArray1[0];
		$count += $dataArray1[1];
		$count1 = $dataArray1[0];
		$count2 = $dataArray1[1];	
		$isHet = 0;
		#print "$count\n";
		if($count < 5) {
			$newDataArray[$i] = 'NA';
			$missing++;
		} else {			
			$newDataArray[$i] = &calc_genotype($count1,$count2);
			if($newDataArray[$i] eq 'NA') {
				$missing++;
			} else {
				#$newDataArray[$i] = $dataArray[$i];					
				if($newDataArray[$i] eq '2,1') {
					$isHet = 1;
					$obsHetCount++;
					$countA1++;
					$countA2++;
				} else {
					if($newDataArray[$i] eq '1,1') {
						$countA1+=2;
					}
					if($newDataArray[$i] eq '2,2') {
						$countA2+=2;
					}					
				}		
			}			
		}		
	}
	
	
	$totSampSize = $sampleSize - $missing;
	if($totSampSize > 0) {
		$A1freq = $countA1 / (2.0 * $totSampSize);
		$A2freq = $countA2 / (2.0 * $totSampSize);
		$obsHet = $obsHetCount / $totSampSize;
		$ExpHet = 2.0 * $A1freq * $A2freq;
		if($ExpHet > 0) {
			$FIS = ($ExpHet - $obsHet) / $ExpHet;
		} else {
			$FIS = -9;
		}
		
	} else {
		$A1freq = -9;
		$A2freq = -9;
		$obsHet = -9;
		$ExpHet = -9;
		$FIS = -9;
	}
	
	if($missing < $accept_missing && $obsHet < $accept_hetero && $FIS != -9) {
		print OUTFILE "$dataArray[0]\t$dataArray[1]\t$dataArray[2]\t$dataArray[3]\t";
		for($i = 4; $i < $sampleSize+4; $i++) {
			print OUTFILE "$newDataArray[$i]\t";
		}
		print OUTFILE "$A1freq\t$A2freq\t$obsHet\t$ExpHet\t$FIS\t";
		print OUTFILE "$missing\t$totSampSize\n";
	}
	
}

print "DONE!\n";

##########################################

sub calc_genotype {
	(my $count1,my $count2) = @_;
	my $tot_count = $count1 + $count2;
	my $count1f, $count2f, $tot_countf;
	if($count1 < 170) {
		$count1f = factorial($count1);
	} else {
		$count1f = factorial(Math::BigFloat->new($count1));
		print "Large factorial1: $count1f\n";
	}
	if($count2 < 170) {
		$count2f = factorial($count2);
	} else {
		$count2f = factorial(Math::BigFloat->new($count2));
		print "Large factorial2: $count2f\n";
	}
	if($tot_count < 170) {
		$tot_countf = factorial($tot_count);
	} else {
		$tot_countf = factorial(Math::BigFloat->new($tot_count));
		print "Large factorial Tot: $tot_countf\n";
	}
	my $error_rate = 0.03;
	my $common_bit = log($tot_countf) - (log($count1f) + log($count2f));
	#print "$tot_count\t$common_bit\n";
	my $eq_part2A = $count1 * log(1.0 - ((3*$error_rate)/4));
	#my $eq_part2A = (1.0 - ((3*$error_rate)/4)) ** $count1;
	my $eq_part2B = $tot_count * log(0.5 - ($error_rate/4));
	my $eq_part2C = $count2 * log(1.0 - ((3*$error_rate)/4));
	my $eq_part3A = $count2 * log($error_rate/4);
	my $eq_part3B = 1;
	my $eq_part3C = $count1 * log($error_rate/4);
	#print "$count1\t$count2\t$common_bit\t$eq_part2A\t$eq_part3A\n";
	my $eq_finalA = $common_bit + $eq_part2A + $eq_part3A;
	my $eq_finalB = $common_bit + $eq_part2B + $eq_part3B;
	my $eq_finalC = $common_bit + $eq_part2C + $eq_part3C;
	my $AIC_A = -2 * $eq_finalA;
	my $AIC_B = -2 * $eq_finalB;
	my $AIC_C = -2 * $eq_finalC;
	#my $low_AIC = min($AIC_A,$AIC_B,$AIC_C);
	my @AIC_array = ($AIC_A,$AIC_B,$AIC_C);
	my @sorted_AIC = sort {$a <=> $b} @AIC_array;
	my $low_AIC = $sorted_AIC[0];
	my $second_low_AIC = $sorted_AIC[1];
	my $genotype = '';
	if($second_low_AIC - $low_AIC > 4) {
		if($low_AIC == $AIC_A) {
			$genotype = '1,1';
		}
		if($low_AIC == $AIC_B) {
			$genotype = '2,1';
		}
		if($low_AIC == $AIC_C) {
			$genotype = '2,2';
		}
	} else {
		$genotype = 'NA';
	}
	return $genotype;
}

sub factorial {
    my $n = shift;
    my $s = 1;
    $s *= $n-- while $n > 0;
    return $s;
}



