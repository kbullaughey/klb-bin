#!/usr/bin/perl -w
use strict;

my %sample = ();
my $i = 0;
while (my $line = <STDIN>) {
   $sample{$i++} = $line;
}

while (scalar(keys(%sample)) > 0) {
   $i = int(rand(scalar(keys(%sample))));  
   $i = (keys(%sample))[$i];
   print $sample{$i};
   delete($sample{$i});
}
