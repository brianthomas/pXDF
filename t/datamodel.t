
BEGIN {print "1..3\n";}
END {print "not ok 1\n" unless $loaded;}
use XDF::Structure;
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
    my $paramObj = $XDF->addParameter({ 'name' => $param_name[$param] });
    my $valueObj = new XDF::Value(); #$param_value[$param]);
    $paramObj->addValue($valueObj);
  }

  foreach my $obj (@{$XDF->paramList()}) {
    push @ret_param_name, $obj->name();
    push @ret_param_value, $obj->value();
  }

  &datamodel_ok($ret_param_name[1] eq $param_name[1]);


  # Test 2. Add an axis, add some tickmarks, then remove one tickmark 
  my $axisObj = $XDF->addAxis({ 'name' => $axis[0], 
                                 'description' => 'the first axis'}
                              );
  my $remove_tickmark;
  foreach my $val (@starting_tickmark_values) {
    $remove_tickmark = $axisObj->addTickMark($val); 
  }
  &datamodel_ok (   defined $axisObj->remove_tickmark($remove_tickmark) &&
                    $ending_tickmark_values[$#ending_tickmark_values] eq 
                    $starting_tickmark_values[1]
                 );


  # Test 3. Add some notes to the structure, then remove one 
  $XDF->addNote({'mark' => '1', 'value' => "one way to add a note"}) || die "Cant add note\n";
  my $remove_obj = $XDF->addNote("A note that I will remove.");
  &datamodel_ok (defined $XDF->remove_note($remove_obj));

sub datamodel_ok {
    my $ok = shift;
    print "not " unless $ok;
    ++$test;
    print "ok $test\n";
    $ok;
}

