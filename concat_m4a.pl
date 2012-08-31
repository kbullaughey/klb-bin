#!/usr/bin/perl -w
use strict;

my $outname = shift @ARGV;
if (!defined($outname)) {
  print STDERR "Error: must speicfy output file name parameter\n";
  exit 1;
}
if (-f "$outname") {
  unlink "$outname";
}

if (!defined(open(RAWOUT, "| ffmpeg -f s16be -ar 44100 -ac 2 -i - -acodec libfaac -ab 128k '$outname'"))) {
  print STDERR "Error: Failed to open ffmpeg pipe\n";
  exit 1;
}
binmode RAWOUT;

my $buffer;
while (my $song = <STDIN>) {
  chomp $song;
  if (!defined(open(SONGDATA, "ffmpeg -i \"$song\" -f s16be -ar 44100 -ac 2 - |"))) {
    print STDERR "Error: Failed to open ffmpeg for reading from $song...skipping\n";
    next;
  }
  binmode SONGDATA;
  while (my $bytes = read(SONGDATA, $buffer, 65536)) {
    print RAWOUT $buffer;
  }
  close SONGDATA;
}

close RAWOUT;

# END



