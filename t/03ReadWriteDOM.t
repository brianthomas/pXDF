
use Test;
use vars qw ($VALIDATE @test_file);

BEGIN {

    if (eval { require XML::Checker::Parser; }) { $VALIDATE = 0; }

    @test_file = qw ( XDF_sample1.xml XDF_sample2.xml XDF_sample3.xml XDF_sample4.xml
                     XDF_sample5.xml XDF_sample6.xml XDF_sample7.xml XDF_sample8.xml
                     XDF_sample9.xml XDF_sample10.xml XDF_sample11.xml XDF_sample12.xml
                     XDF_sample13.xml XDF_sample14.xml XDF_sample15.xml XDF_sample16.xml
	 	     XDF_sample17.xml XDF_sample18.xml XDF_sample19.xml XDF_sample20.xml 
	 	     XDF_sample21.xml XDF_sample22.xml XDF_sample23.xml XDF_sample24.xml 
                     document.xml
                   );

    my $test_number = $#test_file + 1;
    plan tests => $test_number

}

#END { ok(0) unless $loaded }

use XDF::DOM::Parser;
#$loaded = 1;
#test_status(1); # loaded the parser lib 

# runtime params
my $DEBUG = 0;
my $QUIET = 1;

  # now for separaate tests of loading various files

  chdir ('samples');

  &run_tests($VALIDATE);

  exit;

sub run_tests {
   my ($val) = @_;
   $val = 0 unless defined $val;
   foreach my $file (@test_file) {
        &test_file($file, $val);
   }
}

sub test_file {
  my ($file, $validate) = @_;

  print STDERR " testing : $file (validation: $validate)";

  my $string1 = &parse_file_to_string($file, $validate);
  unless ($string1) {
      return test_status(0);
  }

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
}

sub parse_string_to_string {
   my ($string, $validate) = @_;

   my $DEBUG = 1;
   my $QUIET = 1;
   
   my %options = ('quiet' => $QUIET, 'debug' => $DEBUG, 'loadDataOnDemand' => 0,);
   
   my $parser = new XDF::DOM::Parser(  
                                       validate => $validate,
                                       NoExpand => 0,
                                       ParseParamEnt => 0,
                                       ExpandParamEnt => 1,
                                       'loadDataOnDemand' => 0,
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
   my ($file, $validate) = @_;

   my $DEBUG = 1;
   my $QUIET = 1;

   my %options = ('quiet' => $QUIET, 'debug' => $DEBUG, 'loadDataOnDemand' => 0,);

   my $parser = new XDF::DOM::Parser(
                                       validate => $validate,
                                       NoExpand => 0,
                                       ParseParamEnt => 0,
                                       ExpandParamEnt => 1,
                                       'loadDataOnDemand' => 0,
                                    );

   my $XDF_DOM = $parser->parsefile($file);

   # just pick off the first object for now
   my @xdfNodes = @{$XDF_DOM->getXDFElements};
   my $XDF = $xdfNodes[0]->getXDFObject;
   return 0 unless defined $XDF && ref($XDF) eq 'XDF::XDF';

   my $spec = XDF::Specification->getInstance;
   $spec->setPrettyXDFOutput(1);  
   $spec->setPrettyXDFOutputIndentation("   ");  # use 3 spaces for indentation 

   # make this safe for writting, change the external
   # Href Entities files to write out to (should it exist)
   my $index = 0;
   foreach my $XDFNode (@xdfNodes) {
     my $XDFObject = $XDFNode->getXDFObject;
     foreach my $arrayObj (@{$XDFObject->getArrayList}) {
        if (defined $arrayObj->getDataCube()->getHref()) {
           $arrayObj->getDataCube()->getHref()->setSystemId('table'.$index.'.dat');
        }
        $index++;
     }
   }

   return $XDF_DOM->toString();

}

