
use Test;
use vars qw ($VALIDATE);

BEGIN { 

    if (eval { require XML::Checker::Parser; }) { $VALIDATE = 1; }

    my $test_number = 11;
    $test_number *= 2 if $VALIDATE;
    $test_number += 1;
    plan tests => $test_number

}

END { ok(0) unless $loaded }

use XDF::XDF;
use XDF::Reader;
its_ok(1); # loaded the parser lib 
$loaded = 1;

# runtime params
my $DEBUG = 0;
my $QUIET = 1;
#my $VALIDATE = 0;

  # now for separaate tests of loading various files

  chdir ('samples');

  if ($VALIDATE) {
    # do both validating and non-validating parser tests
    &run_tests(1);
    &run_tests(0);
  } else {
    print STDERR "Skipping validating parser tests\n";
    &run_tests(0);
  }

   exit;

sub run_tests {
  my ($validate) = @_;

  $validate = 0 unless defined $validate;
  &test_file('XDF_sample1.xml', $validate);  # 1 2D plain array - formatted 
  &test_file('XDF_sample2.xml', $validate);  # 1 2D field array - formatted 
  &test_file('XDF_sample3.xml', $validate);  # 1 2D field array - tagged 
  &test_file('XDF_sample4.xml', $validate);  # 3 2D plain array - formatted 
  &test_file('XDF_sample5.xml', $validate);  # 1 2D plain array - delimited 
  &test_file('XDF_sample6.xml', $validate);  # 1 2D plain array - formatted w/ data in outside file
  &test_file('XDF_sample7.xml', $validate);  # 1 2D plain array - formatted w/ data in outside file (Binary) 
  &test_file('XDF_sample8.xml', $validate);  # 1 2D plain array - formatted w/ data in outside file
  &test_file('XDF_sample9.xml', $validate);  # 1 2D plain array - formatted w/ data in outside file (Gzip compressed) 
  &test_file('XDF_sample10.xml', $validate);  # 1 2D plain array - formatted w/ data in outside file (Bzip2 compressed) 
  &test_file('XDF_sample11.xml', $validate);  # 1 2D plain array - formatted w/ data in outside file (zip compressed) 

}

sub test_file {
  my ($file, $validate) = @_;

  my $string1 = &parse_file_to_string($file, $validate);
  unless ($string1) {
      return its_ok(0);
  }

  my $string2 = &parse_string_to_string($string1, $validate);
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
   my ($string, $validate) = @_;

   my %options = ( 'quiet' => $QUIET, 
                   'debug' => $DEBUG, 
                   'validate' => $validate,
                   NoExpand => 0,
                   ParseParamEnt => 0,
                   ExpandParamEnt => 1,
                 );


   my $XDFparser = new XDF::Reader(\%options);
   my $XDFObject = $XDFparser->parseString($string);

   my $spec = XDF::Specification->getInstance; 
   $spec->setPrettyXDFOutput(1);  # use pretty print 
   $spec->setPrettyXDFOutputIndentation("   ");  # use 3 spaces for indentation

   return $XDFObject->toXMLString(1);

}

sub parse_file_to_string {
   my ($file, $validate) = @_;

   my %options = ( 'quiet' => $QUIET,
                   'debug' => $DEBUG,
                   'validate' => $validate,
                   NoExpand => 0,
                   ParseParamEnt => 0,
                   ExpandParamEnt => 1,
                 );

   my $XDF = new XDF::XDF();
   $XDF->loadFromXDFFile($file, \%options);

   my $spec = XDF::Specification->getInstance;
   $spec->setPrettyXDFOutput(1);  
   $spec->setPrettyXDFOutputIndentation("   ");  # use 3 spaces for indentation 

   return $XDF->toXMLString(1);

}

