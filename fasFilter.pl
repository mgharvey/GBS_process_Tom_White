use warnings;

my $infile = $ARGV[0];

my $filename = $ARGV[1];
open(OUTFILE, ">$filename");

my $filename1 = $ARGV[2];
open(OUTFILE1, ">$filename1");


open(IN,$infile); # or die "ERROR, no input file\n";


my @dataArray = ();
$i = 0;

while($entry=<IN>) {
	chomp($entry);
	$entry =~ s/TGCA+\Z/TGCA/g;
	$dataArray[$i] = $entry;
	$i++;
}

print OUTFILE "QUERY\tHIT\n";
for($j = 0; $j < scalar @dataArray; $j++) {

	if(($j) % 2 == 0) {
		if(($j) % 4 == 0) {
			print OUTFILE1 "$dataArray[$j]\n";
		} else {
			#print OUTFILE1 "$dataArray[$j]\n";
		}
	}
	if(($j+1) % 2 == 0) {
		print OUTFILE "$dataArray[$j]";
		if(($j+1) % 4 == 0) {
			print OUTFILE "\n";
		} else {
			print OUTFILE1 "$dataArray[$j]\n";
			print OUTFILE "\t";
		}
	} 
	
}


