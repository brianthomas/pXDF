#!/usr/bin/perl -w



my $file = $ARGV[0];
my $new_file = $file . ".new";

my $author = "# /** AUTHOR
#    Brian Thomas  (brian.thomas\@gsfc.nasa.gov)
#    XML Group <http://xml.gsfc.nasa.gov>
#    NASA/Goddard Space Flight Center
# */

"; 

my $header_start = ' AUTHOR';
my $header_end = '^\s*$';

open (FILE, "$file");
open (NEWFILE, ">$new_file");

my $in_header = 0;
while (<FILE>) {

   if ($_ =~ m/$header_start/) {
       print NEWFILE $author;
       $in_header = 1;
   }

   if (!$in_header) {
       print NEWFILE $_;
   }

   if ($_ =~ m/$header_end/) {
       $in_header = 0;
   }

}

close FILE;
close NEWFILE;

system "mv $new_file $file";

