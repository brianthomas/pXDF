
BEGIN {print "1..4\n";}
END {print "not ok 1\n" unless $loaded;}
use XDF::Array;
use XDF::Structure;
use XDF::Parameter;
$loaded = 1;
print "ok 1\n";

my $test = 1;

# another test to check if can add/remove parameters, axisValues, and notes 

  my $XDF = new XDF::Structure();

  my @axis = qw ( axis1 axis2 );
  my @param_name = qw ( param1 param2 param3 );
  my @param_value = qw ( 1 2 3 );
  my @starting_tickmark_values = qw ( 8 9 10 );
  my @ending_tickmark_values = qw ( 8 9 );

  my @ret_param_name = ();
  my @ret_param_value = ();

  # Test 1. add/get some parameters in the XDF structure
  foreach my $param (0 ... $#param_name) {
    my $paramObj = new XDF::Parameter({ 'name' => $param_name[$param] }); 
    $XDF->addParameter($paramObj);
    my $valueObj = new XDF::Value(); 
    $paramObj->addValue($valueObj);
  }

  foreach my $obj (@{$XDF->getParamList()}) {
    push @ret_param_name, $obj->getName();
    push @ret_param_value, @{$obj->getValueList()}[0];
  }

  &its_ok($ret_param_name[1] eq $param_name[1]);


  # Test 2. Add an axis to an array, add some tickmarks, then remove one tickmark 
  my $arrayObj = new XDF::Array(); 
  my $axisObj = new XDF::Axis ({ 'name' => $axis[0], 
                                     'description' => 'the first axis', 
                                     'axisId' => 'firstAxis' }
                                  );
  $arrayObj->addAxis($axisObj);

  my $remove_tickmark;
  foreach my $val (@starting_tickmark_values) {
    $remove_tickmark = $axisObj->addAxisValue($val); 
  }
  &its_ok (   defined $axisObj->removeAxisValue($remove_tickmark) &&
                    $ending_tickmark_values[$#ending_tickmark_values] eq 
                    $starting_tickmark_values[1]
                 );


  # Test 3. Add some notes to the structure, then remove one 
  my $firstNoteObj = $XDF->addNote({'mark' => '1', 'value' => "one way to add a note"}); 
  my $remove_obj = $XDF->addNote("A note that I will remove.");
  &its_ok (defined $XDF->removeNote($remove_obj));

sub its_ok {
    my $ok = shift;
    print "not " unless $ok;
    ++$test;
    print "ok $test\n";
    $ok;
}

