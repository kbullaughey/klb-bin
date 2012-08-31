#!/usr/bin/perl -w
use strict;

# interactive program for creating a table

# global variables
my $db;
my $table;
my $num_cols;
my $build_dir;
my @col_names;
my @col_types;
my @col_extra;
my @col_indexed;
my $make_link = 0;
my $use_header = 0;
my $data_file;
my @data_a;

# fetch a line of user input
sub get {
   my $line = <STDIN>;
   if (!defined($line)) {
      $line = "";
   } else {
      chomp $line;
   }
   return $line;
}

sub instructions {
   print "\n". 
      "(iN) toggle index on N  (eN) edit N\n".
      "(nN) edit name on N     (tN) edit type on N   (xN) edit extra on N\n".
      "(d) done\n";
}

# return a string with the create table statements
sub print_create {
   my $mode = shift @_;
   my $str = "";
   $str .= "CREATE TABLE $table (\n";
   if ($col_names[0] ne "row_id") {
      $str .= "   row_id INTEGER AUTO_INCREMENT NOT NULL,\n";
   }
   
   for (my $i = 0; $i < $num_cols; $i++) {
      my $lead;
      if (defined($mode) && $mode eq "write") {
         $lead = "   ";
      } else {
         $lead = sprintf "%02d ", $i;
         $lead =~ s/^0/ /;
      }

      $str .= $lead . $col_names[$i] . " " . $col_types[$i];
      if (defined($col_extra[$i])) {
         $str .= " " . $col_extra[$i];
      }
      $str .= ",\n";
   }
   $str .= "   PRIMARY KEY(row_id)\n";
   $str .= ") DEFAULT CHARSET=utf8;\n\n";
   for (my $i = 0; $i < $num_cols; $i++) {
      my $name = $col_names[$i];
      if ($col_indexed[$i] == 1) {
         $str .= "CREATE INDEX index_$name ON $table ($name);\n";
      }
   }
   $str .= "\nLOAD DATA LOCAL INFILE\n".
           "   '$data_file'\n".
           "INTO TABLE $table\n".
           "FIELDS TERMINATED BY '\\t' LINES TERMINATED BY '\\n'\n";
   if ($use_header) {
      $str .= "IGNORE 1 LINES\n";
   }
   $str .= "(\n";
   my $sep = "";
   for (my $i = 0; $i < $num_cols; $i++) {
      $str .= $sep.$col_names[$i];
      $sep = ", ";
   }
   $sep =~ s/, $//;
   $str .= "\n);\n";
           
   
   $str .= "\n";

   if (!defined($mode)) {
      my @data_a_trunc = @data_a;
      for (my $i = 0; $i < scalar(@data_a_trunc); $i++) {
         if (length($data_a_trunc[$i]) > 100) {
            $data_a_trunc[$i] = substr($data_a_trunc[$i], 0, 100)."...";
         }
      }
      $str .= "line 1:\n";
      $str .= join("\t", @data_a_trunc)."\n";
   }
   return $str;
}

sub edit_column {
   my $c = shift @_;
   print "name: ";
      $col_names[$c] = get();
   print "type: ";
      $col_types[$c] = get();
   print "extra: ";
      $col_extra[$c] = get();
}

sub edit_name {
   my $c = shift @_;
   print "name: ";
      $col_names[$c] = get();
}

sub edit_type {
   my $c = shift @_;
   print "type: ";
      $col_types[$c] = get();
}

sub edit_extra {
   my $c = shift @_;
   print "extra: ";
      $col_extra[$c] = get();
}

sub toggle_index {
   my $c = shift @_;
   $col_indexed[$c] = ($col_indexed[$c]+1) % 2;
}

# perhaps the table name was passed on the command line
$table = shift @ARGV;

# ask about the database
while (1) {
   print "(1) chinese2\n";
   print "chose a database: ";
   $db  = get();
   if ($db eq "1") {
      $db = "chinese2"; last;
   } else {
      print "Invalid choice\n";
      exit 1;
   }
}

if ($db eq "chinese2") {
   $build_dir = "/Users/kevin/chinese/db";
}

print "build directory: $build_dir\n";

if (!defined($table)) {
   # ask about the table name
   print "\ntable name: ";
   $table  = get();
}

# ask about the data file
while (1) {
   
   # if a file exists here with the same name as the table, use it
   if (-f "$build_dir/data/$table.table") {
      $data_file = "$build_dir/data/$table.table";
      print "\nassuming $data_file\n";
   } else {
      if (-f $table) {
         $data_file = $table;
      } else {
         print "\ndata file: ";
         $data_file = get();
      }
      
      # test if we're dealing with a relative path
      if (!($data_file =~ /[~\/]/)) {
         my $path = `pwd`;
         chomp $path;
         $data_file = "$path/$data_file";
      }
      if (!(-f "$data_file")) {
         print "Failed to find file: $data_file.\n";
         next;
      }
      $make_link = 1;
   }

   if (!defined(open DATA, "<$data_file")) {
      print "Failed to open $data_file\n";
      next;
   } 
   last;
}

# ask about the header
while (1) {
   print "\ndoes the file have a header line? ";
   my $has_header = get();
   if ($has_header =~ /^[yY]/) {
      $use_header = 1; last;
   } elsif ($has_header =~ /^[nN]/) {
      $use_header = 0; last;
   } else {
      print "Invalid answer\n";
   }
}

my $header;
if ($use_header) {
   $header = <DATA>;
   chomp $header;
   $header =~ s/^#//;
}

my $first = <DATA>;
chomp $first;

my @header_a;
@data_a = split /\t/, $first;
if ($use_header) {
   @header_a = split /\t/, $header;
}

$num_cols = scalar(@data_a);
print "there appears to be $num_cols fields.\n";

if (-f "$build_dir/sql/create_table.$table.sql") {
   while (1) {
      print "\nare you sure you want to replace create_table.$table.sql? ";
      my $answer = get();
      if ($answer =~ /^[yY]/) {
         last;
      } elsif ($answer =~ /^[nN]/) {
         print "not proceeding. exiting...\n";
         exit 0;
      } else {
         print "Invalid answer\n";
      }
   }
}

# make guesses for each field
for (my $i = 0; $i < $num_cols; $i++) {
   if ($use_header) {
      $col_names[$i] = $header_a[$i];
      $col_names[$i] =~ s/[^A-Za-z0-9_]//g;
   } else {
      $col_names[$i] = "field$i";
   }
   if ($data_a[$i] =~ /^[-+]?[.0-9]+(e-?[0-9][0-9]+)?$/) {
      if ($data_a[$i] =~ /\./) {
         $col_types[$i] = "FLOAT";
      } else {
         $col_types[$i] = "INTEGER";
      }
   } else {
      $col_types[$i] = "VARCHAR(20)";
   }
   $col_extra[$i] = "NOT NULL";
   $col_indexed[$i] = 0;
}

my $done = 0;
while (!$done) {

   print "\n";
   print print_create();
   instructions();
   while (1) {
      print "\nwhat would you like to change? ";
      my $answer = get();
      if ($answer =~ /^e([0-9]+)$/) {
         edit_column($1);
      } elsif ($answer =~ /^t([0-9]+)$/) {
         edit_type($1)
      } elsif ($answer =~ /^n([0-9]+)$/) {
         edit_name($1)
      } elsif ($answer =~ /^x([0-9]+)$/) {
         edit_extra($1)
      } elsif ($answer =~ /^i([0-9]+)$/) {
         toggle_index($1);
      } elsif ($answer =~ /^d$/) {
         $done = 1;
      } else {
         print "Invalid answer\n";
         next;
      }
      last;
   }
}

sleep(1);
open CREATE, ">$build_dir/sql/create_table.$table.sql" or 
   die "Failed to open create_table.$table.sql\n";
print CREATE print_create("write");
close CREATE;
print print_create("write");

if ($make_link) {
   `ln -s $data_file $build_dir/data/$table.table`;
}

print "\ncreating table complete.\n";

# END





