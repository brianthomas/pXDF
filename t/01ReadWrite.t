
use Test;
use vars qw (@test_file);

BEGIN { 

    @test_file = qw (
                       XDF_sample1.xml XDF_sample2.xml XDF_sample3.xml XDF_sample4.xml
                       XDF_sample5.xml XDF_sample6.xml XDF_sample7.xml XDF_sample8.xml
                       XDF_sample9.xml XDF_sample10.xml XDF_sample11.xml XDF_sample12.xml
                       XDF_sample13.xml XDF_sample14.xml XDF_sample15.xml XDF_sample16.xml
                       XDF_sample17.xml XDF_sample18.xml XDF_sample19.xml XDF_sample20.xml
                       XDF_sample21.xml XDF_sample22.xml XDF_sample23.xml XDF_sample24.xml
                    );

#Note: you can use 'SKIP_TEST' in place of filename (above) to skip running on it 

    my $test_number = $#test_file + 1;
    plan tests => $test_number

}

use XDF::XDF;
use XDF::Reader;

# runtime params
my $DEBUG = 0;
my $QUIET = 1;

  # now for separaate tests of loading various files

  chdir ('samples');

  &run_tests(0);

  # remove temp dat
  unlink ("table0.dat");
  unlink ("table1.dat");
#  unlink ("table2.dat");
#  unlink ("table3.dat");

  exit;

sub run_tests {
  my ($val) = @_;

   $val = 0 unless defined $val;
   foreach my $file (@test_file) {
#print STDERR "LOADING:$file\n";
      &test_file($file, $val); 
   }
}

sub test_file {
  my ($file, $validate) = @_;

  return test_status(1) if ($file eq 'SKIP_TEST');

  my $string1 = &parse_file_to_string($file, $validate);
  unless ($string1) {
      return test_status(0);
  }

  print STDERR " testing : $file (validation: $validate)";

  my $string2;

  if (!eval { $string2 = &parse_string_to_string($string1, $validate) }) {
     return test_status(0);
  }

  if ($string2 && $string1 eq $string2) {
     return test_status(1);
  } else {
     return test_status(0);
  }

}

sub test_status {
    my $ok = shift;
    ok($ok);
    return $ok;
}

sub parse_string_to_string {
   my ($string, $validate) = @_;

   # Important! loadDataOnDemand should be OFF in order to do the tests of
   # external data files
   my %options = ( 'quiet' => $QUIET, 
                   'debug' => $DEBUG, 
                   'validate' => $validate,
                   'loadDataOnDemand' => 0, 
                   NoExpand => 0,
                   ParseParamEnt => 0,
                   ExpandParamEnt => 1,
                 );


   my $XDFparser = new XDF::Reader(\%options);
   my $XDFObject = $XDFparser->parseString($string);

   my $spec = XDF::Specification->getInstance; 
   $spec->setPrettyXDFOutput(1);  # use pretty print 
   $spec->setPrettyXDFOutputIndentation("   ");  # use 3 spaces for indentation

   return $XDFObject->toXMLString();

}

sub parse_file_to_string {
   my ($file, $validate) = @_;

   # Important! loadDataOnDemand should be OFF in order to do the tests of
   # external data files
   my %options = ( 'quiet' => $QUIET,
                   'debug' => $DEBUG,
                   'validate' => $validate,
                   'loadDataOnDemand' => 0, 
                   NoExpand => 0,
                   ParseParamEnt => 0,
                   ExpandParamEnt => 1,
                 );

   my $XDF = new XDF::XDF();
   $XDF->loadFromXDFFile($file, \%options);

   my $spec = XDF::Specification->getInstance;
   $spec->setPrettyXDFOutput(1);  
   $spec->setPrettyXDFOutputIndentation("   ");  # use 3 spaces for indentation 

   # make this safe for writting, change the external
   # file name to write out to (should it exist)
   my $index = 0;
   foreach my $arrayObj (@{$XDF->getArrayList}) {
     if (defined $arrayObj->getDataCube()->getHref()) {
       $arrayObj->getDataCube()->getHref()->setSystemId('table'.$index.'.dat');
     }
     $index++;
   }

   return $XDF->toXMLString();

}

