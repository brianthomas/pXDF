#!/usr/bin/perl -w

# /** COPYRIGHT
#    makeHtmlDoc.pl Copyright (C) 2000 Brian Thomas,
#    ADC/GSFC-NASA, Code 631, Greenbelt MD, 20771
#@ 
#    This program is free software; it is licensed under the same terms
#    as Perl itself is. Please refer to the file LICENSE which is contained
#    in the distribution that this file came in.
#@ 
#   This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
# */

# CVS $Id$

my $man2HTML = "/usr/bin/man2html";
my $depositDir = "../html";
my $manpageDir = "../blib/man3"; 

# B E G I N  P R O G R A M

  # grab our manpage file list
  opendir (DIR, $manpageDir); my @manFiles = readdir(DIR); closedir DIR;

  mkdir($depositDir,0755) unless -e $depositDir;

  foreach $manfile (@manFiles) {

    next unless $manfile =~ m/^XDF::/;
    my $outname = $manfile;  
    $outname =~ s/3$/html/;

    push @htmlPages, $outname;

    # convert the file to HTML
    print STDERR "$man2HTML $manpageDir/$manfile >! $depositDir/$outname \n"; 
    system("/usr/bin/man2html $manpageDir/$manfile > $depositDir/$outname");

    my $fileContents = &get_document_chunk("$depositDir/$outname");
    $fileContents =~ s/manpage//sg;
    $fileContents =~ s/<A HREF="http:\/\/localhost\/cgi-bin\/man\/man2html">Return to Main Contents<\/A><HR>//sg;
    $fileContents =~ s/Content-type: text\/html//;
    $fileContents =~ s/<A HREF="http:\/\/localhost\/cgi-bin\/man\/man2html">man2html<\/A>,\s+using the manual pages/<I>man2html<\/I>/sg;
    $fileContents =~ s/(<DT>)([^<].*?)(<DD>)/<br>$1<B>$2<\/B>$3/g;
    $fileContents =~ s/<PRE>//sg;
    $fileContents =~ s/<\/PRE>//sg;
    $fileContents =~ s/<FONT.*?>//sg;
    $fileContents =~ s/<\/FONT>//sg;
    $fileContents =~ s/<I><\/I>//sg;
    $fileContents =~ s/<[iI]>(XDF.*?)<\/[iI]><[iI]>(\w*?)<\/[iI]>/<a href="$1$2.html">$1$2<\/a>/g;
    $fileContents =~ s/the <I>(XDF::\w*?)<\/I>/<a href="$1.html">$1<\/a>/g;
    $fileContents =~ s/the\s+?<[aA] href="(XDF.*?)<\/[iI]> \.\n/<a href="$1.html">$1<\/a>./sg; 

    $fileContents =~ s/^(.*?)(<A HREF="#index">Index<\/A>)(.*?)(<A NAME="index">&nbsp;<\/A><H2>Index<\/H2>\s<DL>\s<DT>.*)(.*?)$/$1<HR>$4<HR>$3$2$5/sg;

    open(FILE, "> $depositDir/$outname"); print FILE $fileContents; close FILE;

  }
  
  # create the index document
  open(FILE, ">$depositDir/index.html");
  print FILE '<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">'; 
  print FILE '<HTML><HEAD><TITLE>eXtensible Data Format API: Perl Version</TITLE>'; 
  print FILE '<BASE TARGET="class">'; 
  print FILE '<FRAMESET COLS="25%,72%">';
  print FILE '<NOFRAMES>'; 
  print FILE '<p> Your browser is not capable of working with frames.';  
  print FILE '<a href="classes.html"> Use the no-frames version.</a>'; 
  print FILE '</NOFRAMES>'; 
  print FILE '<FRAME SRC="classes.html" NAME="classes">'; 
  print FILE '<FRAME SRC="XDF::Object.html" NAME="class">'; 
  print FILE '</FRAMESET>'; 
  print FILE '</HEAD></HTML>';
  close FILE;

  # create the classes.html document
  open(FILE, ">$depositDir/classes.html");
  print FILE '<html><head><title>XDF Perl Documentation</title>' . "\n"; 
  print FILE '<base target="class"></head><body>' . "\n"; 
  print FILE '<H1>XDF Perl Module Documentation</H1>' . "\n"; 
  print FILE '<H2>Classes:</H2><UL>'; 

  foreach my $page (sort @htmlPages) {
    my $displayName = $page;
    $displayName =~ s/\.html//;
    print FILE '<LI><A HREF="'. $page . '"> ' . $displayName . "</A>\n";
  } 
  print FILE '</UL></body></html>'; 

  close FILE;

print STDERR "Finished making HTML docs. Look in $depositDir for HTML files.\n";
  exit 0;

sub get_document_chunk {
  my ($file) = @_;
  my $text;
#  my $old_input_rec_sep = $/;

  if ($file && -e $file) {
    undef $/; #input rec separator, once newline, now nothing.
            # will cause whole file to be read in one whack 

    open (TXT, "<$file" ); $text = <TXT>; close TXT;
  }

#  $/ = $old_input_rec_sep;
  return $text;
}
