
use Test;

BEGIN { plan tests => 11 }

END { ok(0) unless $loaded }

use XDF::DOM::Parser;
its_ok(1); # loaded the parser lib 
$loaded = 1;

  # now for separaate tests of loading various files

  chdir ('samples');

  &test_file('XDF_sample1.xml');  # 1 2D plain array - formatted 
  &test_file('XDF_sample2.xml');  # 1 2D field array - formatted 
  &test_file('XDF_sample3.xml');  # 1 2D field array - tagged 
  &test_file('XDF_sample4.xml');  # 3 2D plain array - formatted 
  # delimited test will *fail* because of the whitespace issue in XDF::DOM
  # &test_file('XDF_sample5.xml');  # 1 2D plain array - delimited 
  &test_file('XDF_sample6.xml');  # 1 2D plain array - formatted w/ data in outside file
  &test_file('XDF_sample7.xml');  # 1 2D plain array - formatted w/ data in outside file (Binary) 
  &test_file('XDF_sample8.xml');  # 1 2D plain array - formatted w/ data in outside file
  # this doent work because of trivial whitespace at the end
  # &test_file('document.xml');  # a document with XDF table embedded within it
  &test_file('XDF_sample9.xml');  # 1 2D plain array - formatted w/ data in outside file (Gzip compressed) 
  &test_file('XDF_sample10.xml');  # 1 2D plain array - formatted w/ data in outside file (Bzip2 compressed) 
  &test_file('XDF_sample11.xml');  # 1 2D plain array - formatted w/ data in outside file (zip compressed) 

   exit;

sub test_file {
  my ($file) = @_;

  my $string1 = &parse_file_to_string($file);
  unless ($string1) {
      return its_ok(0);
  }

  my $string2 = &parse_string_to_string($string1);
  &its_ok($string2 && $string1 eq $string2 ? 1 : 0);

  print STDERR " testing : $file";

}

sub its_ok {
    my $ok = shift;
    ok($ok);

#    print STDERR "not " unless $ok;
#    ++$test;
#    print STDERR "ok $test\n";
#    $ok;
}

sub parse_string_to_string {
   my ($string) = @_;

   my $DEBUG = 1;
   my $QUIET = 1;
   
   my %options = ('quiet' => $QUIET, 'debug' => $DEBUG, );
   
   my $parser = new XDF::DOM::Parser(  
                                       validate => 1,
                                       NoExpand => 0,
                                       ParseParamEnt => 0,
                                       ExpandParamEnt => 1,
                                    );
   
   my $XDF_DOM = $parser->parsestring($string);

   # just pick off the first object for now
   my @xdfNodes = @{$XDF_DOM->getXDFElements};
   my $XDF = $xdfNodes[0]->getXDFObject;
   return 0 unless defined $XDF && ref($XDF) eq 'XDF::XDF';

   my $spec = XDF::Specification->getInstance; 
   $spec->setPrettyXDFOutput(1);  # use pretty print 
   $spec->setPrettyXDFOutputIndentation("   ");  # use 3 spaces for indentation

   return $XDF_DOM->toString;

}

sub parse_file_to_string {
   my ($file) = @_;

   my $DEBUG = 1;
   my $QUIET = 1;

   my %options = ('quiet' => $QUIET, 'debug' => $DEBUG, );

   my $parser = new XDF::DOM::Parser(
                                       validate => 1,
                                       NoExpand => 0,
                                       ParseParamEnt => 0,
                                       ExpandParamEnt => 1,
                                    );

   my $XDF_DOM = $parser->parsefile($file);

   # just pick off the first object for now
   my @xdfNodes = @{$XDF_DOM->getXDFElements};
   my $XDF = $xdfNodes[0]->getXDFObject;
   return 0 unless defined $XDF && ref($XDF) eq 'XDF::XDF';

   my $spec = XDF::Specification->getInstance;
   $spec->setPrettyXDFOutput(1);  
   $spec->setPrettyXDFOutputIndentation("   ");  # use 3 spaces for indentation 

   return $XDF_DOM->toString;

}

