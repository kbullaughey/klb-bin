#!/usr/bin/perl -w
use strict;

my $seed = time ^ $$ ^ unpack("%L*", `ps aux | gzip`);

my $bound = shift @ARGV;
if (defined($bound)) {
   $seed = $seed % $bound;
}
print "$seed\n";
