
# $Id$

package XDF::DataCube;

# /** COPYRIGHT
#    DataCube.pm Copyright (C) 2000 Brian Thomas,
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

# /** AUTHOR 
#    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
#    Astronomical Data Center <http://adc.gsfc.nasa.gov>
#    NASA/Goddard Space Flight Center
# */

# /** DESCRIPTION
# Holds the data for a given L<XDF::Array>. It is designed to flexibly expand as data 
# is added/appended onto it. It doesnt treat swaping of large array data out to file currently.
# */

# /** SYNOPSIS
#    my $dataObj = XDF::DataCube->new();
# */

# /** SEE ALSO
# XDF::Array
# */

use Carp;
use XDF::Object;

# fields pragma requires Perl 5.005 support. what does this do exactly?? 
# It does the following:
# 1- Informats Perl compiler that these are only valid fields
#    in the class
# 2- Creates a package hash named %FIELDS with an entry for each named field.
#
# 3- Causes the Perl compiler to trnslate any pseudo-hash accesses into
#    direct array accesses. 
# Upshot: faster class 
# use fields @Class_Attributes;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::Object
@ISA = ("XDF::Object");

# CLASS DATA
my $Class_XML_Node_Name = "data";
my @Class_Attributes = qw (
                             compression
                             dimension
                             maxDimensionIndex
                             _currentLocator
                             _parentArray
                             _data
                          );

# /** dimension
# The number of dimensions within this dataCube.
# */
# this shouldnt be publicly possible to set!
# /** maxDimensionIndex
# The maximum index value along each dimension (Axis). Returns an ARRAY of SCALARS (non-negative INTEGERS).
# */
# /** compression
# The STRING value which stores the type of compression algoritm used
# to compress the data.
# */


# add in super class attributes
push @Class_Attributes, @{&XDF::Object::classAttributes};

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# CLASS stuff..

# /** classXMLNodeName
# This method takes no arguments may not be changed. This method returns the class node name of XDF::DataCube.
# */
sub classXMLNodeName { 
  $Class_XML_Node_Name; 
}

# /** classAttributes
#  This method returns a list reference containing the names
#  of the class attributes of XDF::DataCube; 
#  This method takes no arguments may not be changed. 
# */
sub classAttributes { 
  \@Class_Attributes; 
}

# This is called when we cant find any defined method
# exists already. Used to handle general purpose set/get
# methods for our attributes (object fields).
sub AUTOLOAD {
  my ($self,$val) = @_;
  #&XDF::Object::AUTOLOAD($self, $val, $AUTOLOAD, \%{$XDF::DataCube::FIELDS} );
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}

sub _init {
  my ($self) = @_;

  # declare the _data attribute as an array 
  # as we add data (below) it may grow in
  # dimensionality, but defaults to 0 at start. 
  $self->dimension(0);
  $self->_data([]);
 
  # set the minimum array size (essentially the size of the axis)
  $#{$self->_data} = $self->DefaultDataArraySize();

  # a list of what the maximum index is along each dimension
  $self->maxDimensionIndex([]);

  my @locator = (); # zero dimensions, empty array
  $self->_currentLocator(\@locator);

}

# /** clone
# special method for dataCube. B<NOT IMPLEMENTED YET>.
# */
# a place holder. Obviously not correct
sub clone {
  my ($self, $_parentArray) = @_;
  carp "Warning DataCube cloning NOT implemented fully\n";
  my $clone = ref($self)->new;
  $clone->_parentArray($_parentArray) if defined $_parentArray;
  return $clone;
}

# /** toXMLFileHandle
# We overwrite the toXMLFileHandle method supplied by L<XDF::Object> to 
# have some special handling for the XDF::DataCube. The interface for this
# method remains the same however. 
# */
# we dont want to write back out all the attributes, the data
# needs special handling to write out, etc...
sub toXMLFileHandle {
  my ($self, $fileHandle, $junk, $indent) = @_;

  my $readObj = $self->_parentArray->XmlDataIOStyle();

  croak "DataCube can't write out. No format reference object defined.\n"
     unless defined $readObj;

  my $niceOutput = $self->Pretty_XDF_Output();
  $indent = "" unless defined $indent;

  my $nodeName = $self->classXMLNodeName;

  # open the tagged data section
  print $fileHandle $indent if $niceOutput;
  print $fileHandle "<" . $nodeName . ">";

  my @size = @{$self->maxDimensionIndex()};

  if (ref($readObj) eq 'XDF::TaggedXMLDataIOStyle' ) {

     print $fileHandle "\n" if $niceOutput;
     &_write_tagged_data($self, $fileHandle, $readObj, $indent, $niceOutput);

  } elsif (ref($readObj) eq 'XDF::DelimitedXMLDataIOStyle' or
           ref($readObj) eq 'XDF::FormattedXMLDataIOStyle' )
  {

    print $fileHandle "<![CDATA[";
    &_write_untagged_data($self, $fileHandle, $readObj, $indent, $niceOutput);
    print $fileHandle "]]>";
    print $fileHandle "\n" if $niceOutput;

  } else {

     warn "Unknown read object: $readObj. $self cannot write itself out.\n";

  } 

  # close the tagged data section
  print $fileHandle $indent if $niceOutput;
  print $fileHandle "</" . $nodeName . ">";
  print $fileHandle "\n" if $niceOutput;


}

# Yes, this is crappy. I plan to come back and do it 'right' one day.
#
# Note: we need to consider the case where the user *DIDNT* supply 
# tag names for the axes. In this case, we use 'd0','d1' ...'d8' tag 
# notation.
sub _write_tagged_data {
  my ($self, $fileHandle, $readObj, $indent, $niceOutput) = @_;

  my @size = @{$self->maxDimensionIndex()};

#print "MAX DIMENSION SIZES: ",join ',', @size,"\n";

  # now we populate the data , if there are any
  if ($#size > -1) {

    # gather info. Find out what tags go w/ which axii
    my @AXIS_TAG = reverse $readObj->getAxisTags(); 

    # now build the formatting stuff. 
    my $data_indent = $indent . $self->Pretty_XDF_Output_Indentation;
    my $startDataRecordTag = $data_indent;
    my $endDataRecordTag = "";
    foreach my $axis (0 .. ($#size-1)) {
      $startDataRecordTag .= "<" . $AXIS_TAG[$axis] . ">";
    }
    foreach my $axis (reverse 0 .. ($#size-1)) {
      $endDataRecordTag .= "</" . $AXIS_TAG[$axis] . ">";
    }
    $endDataRecordTag .= "\n";
    my $startDataTag = "<" . $AXIS_TAG[$#size] . ">";
    my $endDataTag = "</" . $AXIS_TAG[$#size] . ">";
    my $emptyDataTag = "<" . $AXIS_TAG[$#size] . "/>";
 
    # ok, time to build the eval block that will write out the tagged data
    my $eval_block;
    my $locator = $self->_parentArray->createLocator;

    my $more_data = 1;
    my $fast_axis_length = @{$self->_parentArray->axisList}->[0]->length; 
    my $dataNumb = 0; 
    while ($more_data) {
       print $fileHandle $startDataRecordTag if ($dataNumb == 0);
       $self->_print_data($fileHandle, $locator, $startDataTag, $endDataTag, $emptyDataTag);
       $dataNumb++;
       if( $dataNumb >= $fast_axis_length ) {
         print $fileHandle $endDataRecordTag;
         $dataNumb = 0;
       }
       $more_data = $locator->next();
    }
  }

}

sub _write_untagged_data {
  my ($self, $fileHandle, $readObj, $indent) = @_;

  my @size = @{$self->maxDimensionIndex()};

  # now we populate the data , if there are any
  if ($#size > -1) {

    # gather info. Find out what formating to use w/ which data
    my $formatObj = $self->_parentArray->XmlDataIOStyle;

    # a little safety
    croak "$self lacks formatobj! Cannot write XML data out.\n"
       unless defined $formatObj;

    my $sprintfFormat;
    my $terminator;
    my $fast_axis_length;
    my $template;
    my @outArray;

    if (ref($formatObj) eq 'XDF::DelimitedXMLDataIOStyle') {
      # tis a shame that we dont use the outArray/template system here.
      $sprintfFormat = $formatObj->_sprintfNotation();
      $terminator = $formatObj->recordTerminator;
      $fast_axis_length = @{$self->_parentArray->axisList}->[0]->length; 
    } elsif (ref($formatObj) eq 'XDF::FormattedXMLDataIOStyle') {
      $template = $formatObj->_templateNotation(0);
      @outArray = $formatObj->_outputSkipCharArray;
    } else {
      die "$self got weird formatobj for untagged output of DataCube: $formatObj\n";
    }

    my $locator = $self->_parentArray->createLocator(); 

    if (ref($formatObj) eq 'XDF::DelimitedXMLDataIOStyle') { 

      my $there_is_more_data = 1;
      my $dataNumb = 0;

      while ($there_is_more_data) {
        my $this_data = $self->getData($locator);
        $dataNumb++;
        if( $dataNumb >= $fast_axis_length ) {
          print $fileHandle $this_data . $terminator;
          $dataNumb = 0;
        } else {
          print $fileHandle sprintf($sprintfFormat, $this_data);
        } 
        $there_is_more_data = $locator->next();
      }

    } elsif (ref($formatObj) eq 'XDF::FormattedXMLDataIOStyle') { 

      my @outData = ();
      my $outArrayNumb = 0;
      my $there_is_more_data = 1;

      while ($there_is_more_data) {
        push @outData, $self->getData($locator) if !defined $outArray[$outArrayNumb];
        $outArrayNumb++;
        while (defined $outArray[$outArrayNumb]) { 
          push @outData, $outArray[$outArrayNumb++];
        }
        if( $outArrayNumb >= $#outArray ) {
          print $fileHandle pack($template, @outData);
          $outArrayNumb = 0;
          @outData = ();
        }
        $there_is_more_data = $locator->next();
      }

    } else {

      die "$self got wierd XMLDataIOStyle object : $formatObj\n";

    }

  }

}

sub _print_data {
  my ($self, $fileHandle, $locator, $startTag, $endTag, $emptyTag) = @_;

  my $datum = $self->getData($locator);
  if (defined $datum) {
     print $fileHandle $startTag . $datum . $endTag;
  } else {
     print $fileHandle $emptyTag;
  }
}

# private method
sub _check_datacube_dimension {
  my ($self, $locator, $check_string, $dontCheckBounds) = @_;

  # does this location (dimensionally) exist? if not, we add it 
  #if ($#{$locator_ref} > $#{$self->maxDimensionIndex()} ) { 

  if ($#{$locator->_locationList} > $#{$self->maxDimensionIndex()} ) { 
     # if array exists, we will enlarge it
     &_enlarge_array($self, $locator) if (defined $self->_data()->[0] &&
       !defined $dontCheckBounds);
     # bump up max index for each axis
  } 
  &_increase_max_dimension_index($self, $locator);

}

# private method
sub _build_locator_string {
  my ($locator) = @_;

  my $string = '$self->_data()';
  foreach my $axisObj ($locator->getIterationOrder) {
    #$string = $string . "->[" . @{$locator_ref}->[$loc] . "]";
    $string = $string . "->[" . $locator->getAxisLocation($axisObj) . "]";
  }
  return $string;
} 

# private method
# adds 1 dimension to the array
sub _enlarge_array {
  my ($self, $locator_ref) = @_;

  print STDERR "ENLARGING ARRAY to encompass (",join ',', @{$locator_ref},")\n";

  #my @max_size = @{$locator_ref};
  my @max_size = $locator_ref->getAxisLocations;

  my @size = @{$self->maxDimensionIndex()};
  print STDERR "SIZES FOR EVAL : ",join ',', @size,"\n";

  my $locator; 
  my $eval_block;
  my $newdatanumber = 1;
  foreach my $axis (0 .. $#size) { 
     $locator .= "\$axis$axis" . "_index,"; 
     $eval_block .= "foreach my \$axis$axis" . "_index (0 .. \$size[$axis]) { \n";
     $newdatanumber *= ($size[$axis]+1);
  }

  my @new_array_refs;
  for (0 .. $newdatanumber) {
    my @array = ();
    # set the minimum array size (essentially the size of the axis)
    $#array = $self->DefaultDataArraySize();
    push @new_array_refs, \@array;
  }

  # print "LOCATOR: $locator\n";

  $eval_block .= "my $locator = new XDF::Locator(); \n";
#  for (@locator) {
#    $eval_block .= "$locator = ($locator); \n";
#  }

  $eval_block .= "my \$oldData = \$self->getData(\\\@locator); \n";
  $eval_block .= "\$self->setData(\\\@locator, pop \@new_array_refs); \n";
  $eval_block .= "push \@locator, 0; \n";
  $eval_block .= "\$self->setData(\\\@locator, \$oldData, 1) if defined \$oldData; \n";

  $eval_block .= "}" x $#size;
  $eval_block .= "}\n";


  #print "SIZES: (", join ',', @size, ")\n";
    print STDERR "EVAL BLOCK: \n$eval_block\n"; 
exit 0;
  eval " $eval_block ";

}

sub _increase_max_dimension_index {
  my ($self, $locatorObj) = @_;

  my @max_size = $locatorObj->getAxisLocations;

  foreach my $dim (0 ... $#max_size) {
     @{$self->maxDimensionIndex()}->[$dim] = $max_size[$dim]
        unless defined @{$self->maxDimensionIndex()}->[$dim] &&
               @{$self->maxDimensionIndex()}->[$dim] > $max_size[$dim]; 
  }
 # print "MAXSIZES are now: (",join ',', @{$self->maxDimensionIndex()},")\n";

}

# /** addData
# This routine will append data to a cell unless directed to do otherwise.
# */
# the self evaluation part will make this SLOW for large arrays. :P
sub addData {
  my ($self, $locator, $data, $no_append, $dontCheckBounds ) = @_;

  # safety
  unless (defined $locator && defined $data) {
    carp "Please specify location and data value, e.g. \$obj->addData(\$locator,\$value). Ignoring request.";
    return;
  }

  unless (ref($locator) eq 'XDF::Locator') {
    warn "addData method not passed a valid XDF::Locator object, ignoring request\n";
    return;
  }

  # add the data to the right array in the $self->_data list

  # We first check that the location exists! 
  # fix the array if it doesnt
  my $eval_string = &_build_locator_string($locator);
  &_check_datacube_dimension($self, $locator, $eval_string, $dontCheckBounds);

  if($no_append) {
    $eval_string = $eval_string . " = \"$data\"";
  } else {
    $eval_string = $eval_string . " .= \"$data\"";
  }

#  print "ADD EVAL STRING($locator): $eval_string\n";
  eval " $eval_string; ";

}

# /** removeData
# Data held within the requested datacell is removed. The value of the datacell is set to undef.
# B<NOT CURRENTLY IMPLEMENTED>.
# */
sub removeData {
  carp "Remove_data not currently implemented.\n";
}

# /** setData
# Set the SCALAR value of the requested datacell at indicated location (see LOCATOR REF section).
# Overwrites existing datacell value if any.
# */
sub setData {
  my ($self, $locator, $datum , $dontCheckBounds) = @_;
  $self->addData($locator, $datum, 1, $dontCheckBounds);
}

# /** getData
# Retrieve the SCALAR value of the requested datacell.
# */
# do we need to do some bounds checking here??
sub getData {
  my ($self, $locator) = @_;
 
  unless (defined $locator and ref($locator) eq 'XDF::Locator') {
    warn "getData method not passed a valid XDF::Locator object, ignoring request\n";
    return;
  }

  my $get_string = "\$self->_data()";
  foreach my $loc ($locator->getAxisLocations) {
     $get_string = $get_string . "->[$loc]";
  }

  return eval "$get_string";
  
}

1;


__END__

=head1 NAME

XDF::DataCube - Perl Class for DataCube

=head1 SYNOPSIS

    my $dataObj = XDF::DataCube->new();


...

=head1 DESCRIPTION

 Holds the data for a given L<XDF::Array>. It is designed to flexibly expand as data  is added/appended onto it. It doesnt treat swaping of large array data out to file currently. 

XDF::DataCube inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::Object>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::DataCube.

=over 4

=item classXMLNodeName (EMPTY)

This method takes no arguments may not be changed. This method returns the class node name of XDF::DataCube.  

=item classAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes of XDF::DataCube; This method takes no arguments may not be changed.  

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item compression

The STRING value which stores the type of compression algoritm usedto compress the data.  

=item dimension

The number of dimensions within this dataCube.  

=item maxDimensionIndex

The maximum index value along each dimension (Axis). Returns an ARRAY of SCALARS (non-negative INTEGERS).  

=back

=head2 OTHER Methods

=over 4

=item clone ($_parentArray)

special method for dataCube. B<NOT IMPLEMENTED YET>. 

=item toXMLFileHandle ($indent, $junk, $fileHandle)

We overwrite the toXMLFileHandle method supplied by L<XDF::Object> to have some special handling for the XDF::DataCube. The interface for thismethod remains the same however. 

=item addData ($dontCheckBounds, $no_append, $data, $locator)

This routine will append data to a cell unless directed to do otherwise. 

=item removeData (EMPTY)

Data held within the requested datacell is removed. The value of the datacell is set to undef. B<NOT CURRENTLY IMPLEMENTED>. 

=item setData ($dontCheckBounds, $datum, $locator)

Set the SCALAR value of the requested datacell at indicated location (see LOCATOR REF section). Overwrites existing datacell value if any. 

=item getData ($locator)

Retrieve the SCALAR value of the requested datacell. 

=back

=over 4

=head2 INHERITED Class Methods

A change in the value of these attributes will change the functioning of ALL instances of these objects that inherit from the indicated super class.


=over 4

The following class attribute methods are inherited from L<XDF::Object>:
B<Pretty_XDF_Output>, B<Pretty_XDF_Output_Indentation>, B<DefaultDataArraySize>.

=back

=back

=over 4

=head2 INHERITED Other Methods



=over 4

XDF::DataCube inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<update>, B<setObjRef>.

=back



=over 4

XDF::DataCube inherits the following instance methods of L<XDF::Object>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFile>.

=back

=back

=head1 SEE ALSO

L< XDF::Array>, L<XDF::Object>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center


=cut
