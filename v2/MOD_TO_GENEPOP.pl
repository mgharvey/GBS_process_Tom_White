use warnings;

my $infile = $ARGV[0];

my $sampleSize = $ARGV[1];

my $filename = $ARGV[2];
open(OUTFILE, ">$filename");


open(IN,$infile); # or die "ERROR, no input file\n";


my @dataArray = ();
my @lab = ();
my @LOCID = ();

my $entry=<IN>;
chomp($entry);
@dataArray = split('\t',$entry);

for(my $x = 4; $x < 4 + $sampleSize; $x++) {	
	$lab[$x-4] = $dataArray[$x];
}

#print "$lab[0]\n";

$locCount = 0;

while($entry=<IN>) {
	chomp($entry);
	@dataArray = split('\t',$entry);
	$LOCID[$locCount] = $dataArray[0];
	for(my $k = 4; $k < 4 + $sampleSize; $k++) {
		$this_geno = $dataArray[$k];
		if($this_geno eq 'NA') {
			$new_geno = '000000';
		} 
		if($this_geno eq '2,1') {
			$new_geno = '002001';
		} 
		if($this_geno eq '1,1') {
			$new_geno = '001001';
		} 
		if($this_geno eq '2,2') {
			$new_geno = '002002';
		} 
	
		$genArray[$locCount][$k-4] = $new_geno;
	}
	
	#print "$LOCID[$locCount]\n";
	$locCount++;
}

print OUTFILE "DATAFILE\n";
for(my $x = 0; $x < $locCount; $x++) {
	print OUTFILE "L$LOCID[$x]\n";		
}

print OUTFILE "POP\n";
for(my $y = 0; $y < $sampleSize; $y++) {
	
	if(($y == 21) || ($y == 41) || ($y == 61) || ($y == 81) || ($y == 101) || ($y == 121) || ($y == 141) || ($y == 161) || ($y == 181) || ($y == 201) || ($y == 221) || ($y == 241) || ($y == 261)) {
		print OUTFILE "POP\n";
	}
	print OUTFILE "V$lab[$y],\t";
	for(my $x = 0; $x < $locCount; $x++) {
		print OUTFILE "$genArray[$x][$y]\t";
	}
	print OUTFILE "\n";
}

print "DONE!\n";

