#!/usr/bin/perl -w
use strict;

my $split_on = shift @ARGV;
my $num_fields = shift @ARGV;
if (!defined($split_on)) {
   print STDERR "Error: must specify what to split on: space or tab\n";
   exit 1;
}
if (!defined($num_fields)) {
   print STDERR "Error: must specify number of fileds\n";
   exit 1;
}
if ($split_on ne "space" && $split_on ne "tab") {
   print STDERR "Error: what to split on must be space or tab\n";
   exit 1;
}

my $split_regexp;
if ($split_on eq "space") {
   $split_regexp = " ";
} else {
   $split_regexp = "\t";
}
   
my $linenum = 0;
while (my $line = <STDIN>) {
   chomp $line; $linenum++;
   my @res = split($split_regexp, $line);
   if (scalar(@res) != $num_fields) {
      print STDERR "skipping row $linenum\n";
      next;
   }
   print "$line\n";
}

# END


