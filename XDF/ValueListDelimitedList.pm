
# $Id$

# /** COPYRIGHT
#    ValueListDelimitedList.pm Copyright (C) 2000 Brian Thomas,
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
# ValueListDelimitedList will create a concise description of a list of 
# values from a passed list of value objects.
# The ValueList object may be then passed on and used by other objects
# to populate the list of values they hold.
# A desirable feature of using the ValueList object is that it result in
# a more compact format for describing the values so added to other objects
# when they are written out using the toXMLFileHandle method.
# */

# /** SYNOPSIS
# 
# */

# /** SEE ALSO
# XDF::Axis
# XDF::Parameter
# XDF::ValueListAlgorithm
# */

package XDF::ValueListDelimitedList;

use XDF::BaseObject;
use XDF::Log;
use XDF::Value;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

# CLASS DATA
my $Class_XML_Node_Name = "valueList";
my @Local_Class_XML_Attributes = qw (
                             valueListId
                             valueListIdRef
                             delimiter
                             repeatable
                           );
                           #  noDataValue 
                           #  infiniteValue 
                           #  infiniteNegativeValue 
                           #  notANumberValue 
                            # overflowValue 
                            # underflowValue
my @Local_Class_Attributes = qw ( 
                             values
                          );
my @Class_Attributes;
my @Class_XML_Attributes;

# add in local class XML attributes
push @Local_Class_Attributes, @Local_Class_XML_Attributes;

# get super class attributes
push @Class_Attributes, @{&XDF::BaseObject::getClassAttributes};

# add in local to overall class
push @Class_XML_Attributes, @Local_Class_XML_Attributes;
push @Class_Attributes, @Class_XML_Attributes;

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classXMLNodeName
# This method takes no arguments may not be changed. 
# This method returns the class node name of XDF::ValueListDelimitedList.
# */
sub classXMLNodeName { 
  return $Class_XML_Node_Name; 
}

# /** getClassAttributes
#  This method returns a list reference containing the names
#  of the class attributes for this class.
#  This method takes no arguments may not be changed. 
# */
sub getClassAttributes {
  return \@Class_Attributes;
}

# /** getClassXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
sub getClassXMLAttributes {
  return \@Class_XML_Attributes;
}

# 
# Constructors
# 

# /** new
# Constructs a delimited valueList object with ValueObjs in passed List.
# Care should be taken that none of the Value objects are set
# to the same sequence of characters as the passed delimiter (or 
# the default delimiter if no delimiter attribute is passed).
# */
sub new { 
  my ($proto, $attrib_hash_ref, $valueListRef) = @_;

  unless (defined $valueListRef && ref($valueListRef)) {
    warn("Error: $proto missing list of valueObjs, please remember to init later).\n");
  }

  my $class = ref ($proto) || $proto;
  my $self = bless( { }, $class);

  $self->_init($attrib_hash_ref, $valueListRef);

  return $self;
}

# /** clone
# Clone a deep copy from this object. 
# */
# this is needed in order to treat the values appropriately
sub clone {
  my ($self, $_parentArray) = @_;

  my @list_clone_values = ();
  foreach my $value (@{$self->getValues}) {
     push @list_clone_values, $value->clone();
  }

  my $clone = (ref $self)->new(\@list_clone_values);

  # IF this object is an array, then we will use it now as the
  # parent array of all sub-objects that it owns.
  $_parentArray = $clone if ref($clone) eq 'XDF::Array';

  foreach my $attrib ( @{$self->getClassAttributes} ) {
    next if $attrib eq 'values';
    if ($attrib !~ m/_parentArray/) {
      my $val = $self->_clone_attribute($attrib, $_parentArray);
      $clone->$attrib($val);
    } else {
      # _parentArray is set as new cloned array (should it exist)
      $clone->$attrib($_parentArray) if defined $_parentArray;
    }
  }

  return $clone;
}

# 
# SET/GET Methods
#

# /** getValueListId
# */
sub getValueListId {
   my ($self) = @_;
   return $self->{valueListId};
}

# /** setValueListId
#     Set the valueListId attribute. 
# */
sub setValueListId {
   my ($self, $value) = @_;
   $self->{valueListId} = $value;
}

# /** getValueListIdRef 
# */
sub getValueListIdRef {
   my ($self) = @_;
   return $self->{valueListIdRef};
}

# /** setValueListIdRef 
#     Set the valueListIdRef attribute. 
# */
sub setValueListIdRef {
   my ($self, $value) = @_;
   $self->{valueListIdRef} = $value;
}

# /** getValues
# Return the list of valueObjs held in this object.
# */
sub getValues {
   my ($self) = @_;
   return $self->{values};
}

# /** setValues
# Set the list of valueObjs held by this object.
# */
sub setValues {
  my ($self, $valueListRef) = @_;

  # you must do it this way, or when the arrayRef changes it changes us here!
  # however we DO want to preserve the valueObj ref tho.
  foreach my $valueObj (@{$valueListRef}) {
      push @{$self->{values}}, $valueObj;
  }

}

# /** getDelimiter
# Return the delimiter string between values.  
# */
sub getDelimiter {
  my ($self) = @_;
  return $self->{delimiter};
}

# /** setDelimiter
# Set the delimiter string between values.  
# */
sub setDelimiter {
  my ($self, $value) = @_;
  $self->{delimiter} = $value;
}

# /** getRepeatable
# Get the repeatable attribute. Repeatable will tell 
# whether or not the delimiting string between values may repeat.
# */
sub getRepeatable {
  my ($self) = @_;
  return $self->{repeatable};
}

# /** setRepeatable
# Set whether or not the delimiting string between values may repeat.
# */
sub setRepeatable {
  my ($self, $value) = @_;
  $self->{repeatable} = $value;
}

# /* getNoDataValue
# Return the particular value in the list that indicates a 'noData' value.
# */
#sub getNoDataValue {
#  my ($self) = @_;
#  return $self->{noDataValue};
#}

# /* setNoDataValue
# Set the particular value in the list that indicates a 'noData' value.
# */
#sub setNoDataValue {
#  my ($self, $value) = @_;
#$  $self->{noDataValue} = $value;
#}

# /* getInfiniteValue 
# Return the particular value in the list that indicates an 'infinite' value.
# */
#sub getInfiniteValue {
#  my ($self) = @_;
#  return $self->{infiniteValue};
#}

# /* setInfiniteValue
# Set the particular value in the list that indicates an 'infinite' value.
# */
#sub setInfiniteValue {
#  my ($self, $value) = @_;
#  $self->{infiniteValue} = $value;
#}

# /* getInfiniteNegativeValue 
# Return the particular value in the list that indicates an 'infiniteNegative' value.
# */
#sub getInfiniteNegativeValue {
#  my ($self) = @_;
#  return $self->{infiniteNegativeValue};
#}

# /* setInfiniteNegativeValue
# Set the particular value in the list that indicates an 'infiniteNegative' value.
# */
#sub setInfiniteNegativeValue {
#  my ($self, $value) = @_;
#  $self->{infiniteNegativeValue} = $value;
#}

# /* getNotANumberValue
# Return the particular value in the list that indicates an 'notANumber' value.
# */
#sub getNotANumberValue {
#  my ($self) = @_;
#  return $self->{notANumberValue};
#}

# /* setNotANumberValue
# Set the particular value in the list that indicates an 'notANumber' value.
# */
#sub setNotANumberValue {
#  my ($self, $value) = @_;
#  $self->{notANumberValue} = $value;
#}

# /* getUnderflowValue
# Return the particular value in the list that indicates an 'underflow' value.
# */
#sub getUnderflowValue {
#  my ($self) = @_;
#  return $self->{underflowValue};
#}

# /* setUnderflowValue
# Set the particular value in the list that indicates an 'underflow' value.
# */
#sub setUnderflowValue {
#  my ($self, $value) = @_;
#  $self->{underflowValue} = $value;
#}

# /* getOverflowValue
# Return the particular value in the list that indicates an 'overflow' value.
# */
#sub getOverflowValue {
#  my ($self) = @_;
#  return $self->{overflowValue};
#}

# /* setOverflowValue
# Set the particular value in the list that indicates an 'overflow' value.
# */
#sub setOverflowValue {
#  my ($self, $value) = @_;
#  $self->{overflowValue} = $value;
#}

#
# Protected/Private Methods
#

sub _basicXMLWriter {
   my ($self, $fileHandle, $indent ) = @_;

   if(!defined $fileHandle) {
      error("Can't write out object, filehandle not defined.\n");
      return;
   }

   $indent = "" unless defined $indent;

   my $spec = XDF::Specification->getInstance();
   my $isPrettyXDFOutput = $spec->isPrettyXDFOutput;

   print $fileHandle $indent if $isPrettyXDFOutput;

   print $fileHandle "<$Class_XML_Node_Name";
   print $fileHandle " delimiter=\"".$self->{delimiter}."\" repeatable=\"".$self->{repeatable}."\"";
   print $fileHandle " valueListId=\"".$self->{valueListId}."\"" if (defined $self->{valueListId});
   print $fileHandle " valueListIdRef=\"".$self->{valueListIdRef}."\"" if (defined $self->{valueListIdRef});
   print $fileHandle " noDataValue=\"".$self->{noDataValue}."\"" if (defined $self->{noDataValue});
   print $fileHandle " infiniteValue=\"".$self->{infinite}."\"" if (defined $self->{infinite});
   print $fileHandle " infiniteNegativeValue=\"".$self->{infiniteNegative}."\"" 
                       if (defined $self->{infiniteNegative});
   print $fileHandle " notANumberValue=\"".$self->{notANumberValue}."\"" if (defined $self->{notANumberValue});
   print $fileHandle " overflowValue=\"".$self->{overflowValue}."\"" if (defined $self->{overflowValue});
   print $fileHandle " underflowValue=\"".$self->{underflowValue}."\"" if (defined $self->{underflowValue});
   print $fileHandle ">";

   my @values = @{$self->{values}};
   foreach my $valIndex (0 .. $#values) {

      my $thisValue = $values[$valIndex];

      my $specialValue = $thisValue->getSpecial();
      if(defined $specialValue) {
         if($specialValue eq &XDF::Constants::VALUE_SPECIAL_INFINITE) {
            &_doValuePrint($fileHandle, $specialValue, $self->{infiniteValue});
         } elsif($specialValue eq &XDF::Constants::VALUE_SPECIAL_INFINITE_NEGATIVE) {
            &_doValuePrint($fileHandle, $specialValue, $self->{infiniteNegativeValue});
         } elsif($specialValue eq &XDF::Constants::VALUE_SPECIAL_NODATA) {
             &_doValuePrint($fileHandle, $specialValue, $self->{noDataValue});
         } elsif($specialValue eq &XDF::Constants::VALUE_SPECIAL_NOTANUMBER) {
             &_doValuePrint($fileHandle, $specialValue, $self->{notANumberValue});
         } elsif($specialValue eq &XDF::Constants::VALUE_SPECIAL_UNDERFLOW) {
             &_doValuePrint($fileHandle, $specialValue, $self->{underflowValue});
         } elsif($specialValue eq &XDF::Constants::VALUE_SPECIAL_OVERFLOW) {
             &_doValuePrint($fileHandle, $specialValue, $self->{overflowValue});
         } 

      } else {
         print $fileHandle $thisValue->getValue();
      }

      # print delimiter except on last index.
      print $fileHandle $self->{delimiter} unless $valIndex eq $#values;
   }

   print $fileHandle "</valueList>";

}

sub _init {
   my ($self, $attribHashRef, $valueListRef) = @_;

   # adds to ordered list of XML attributes
   $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

   $self->setXMLAttributes($attribHashRef) if defined $attribHashRef;

   $self->{delimiter} = &XDF::Constants::DEFAULT_VALUELIST_DELIMITER
       unless defined $self->{delimiter};

   $self->{repeatable} = &XDF::Constants::DEFAULT_VALUELIST_REPEATABLE
       unless defined $self->{repeatable};

   # init values
   $self->{values} = [];
   # you must do it this way, or when the arrayRef changes it changes us here!
   # however we DO want to preserve the valueObj ref tho.
   foreach my $valueObj (@{$valueListRef}) {
      push @{$self->{values}}, $valueObj;
   }

}

sub _doValuePrint {
   my ($fileHandle, $specialValue, $value) = @_;

   if (defined $value) {
      print $fileHandle $value;
   } else {
      error("Error: valueList doesnt have ",$specialValue," defined but value does. Ignoring.");
   }
}

# This is called when we cant find any defined method
# exists already. Used to handle general purpose set/get
# methods for our attributes (object fields).
sub AUTOLOAD {
  my ($self, $val) = @_;
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}


1;


__END__

=head1 NAME

XDF::ValueListDelimitedList - Perl Class for ValueListDelimitedList

=head1 SYNOPSIS

 


...

=head1 DESCRIPTION

 ValueListDelimitedList will create a concise description of a list of  values from a passed list of value objects.  The ValueList object may be then passed on and used by other objects to populate the list of values they hold.  A desirable feature of using the ValueList object is that it result in a more compact format for describing the values so added to other objects when they are written out using the toXMLFileHandle method. 

XDF::ValueListDelimitedList inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::ValueListDelimitedList.

=over 4

=item classXMLNodeName (EMPTY)

This method takes no arguments may not be changed. This method returns the class node name of XDF::ValueListDelimitedList.  

=item getClassAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes for this class. This method takes no arguments may not be changed.  

=item getClassXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=item new ($valueListRef, $delimiter, $noDataValue, $infiniteValue, $infiniteNegativeValue, $notANumberValue, $overflowValue, $underflowValue)

Constructs a valueList object with Values in passed List. Care should be taken that none of the Value objects are setto the same sequence of characters as the passed delimiter (or the default delimiter if no delimiter variable is passed).  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::ValueListDelimitedList.

=over 4

=item clone ($_parentArray)

Clone a deep copy from this object.  

=item getValueListId (EMPTY)

 

=item setValueListId ($value)

Set the valueListId attribute.  

=item getValueListIdRef (EMPTY)

 

=item setValueListIdRef ($value)

Set the valueListIdRef attribute.  

=item getValues (EMPTY)

Return the list of values held in this object.  

=item getNoDataValue (EMPTY)

Return the particular value in the list that indicates a 'noData' value.  

=item setNoDataValue ($value)

Set the particular value in the list that indicates a 'noData' value.  

=item getInfiniteValue (EMPTY)

Return the particular value in the list that indicates an 'infinite' value.  

=item setInfiniteValue ($value)

Set the particular value in the list that indicates an 'infinite' value.  

=item getNotANumberValue (EMPTY)

Return the particular value in the list that indicates an 'notANumber' value.  

=item setNotANumberValue ($value)

Set the particular value in the list that indicates an 'notANumber' value.  

=item getUnderflowValue (EMPTY)

Return the particular value in the list that indicates an 'underflow' value.  

=item setUnderflowValue ($value)

Set the particular value in the list that indicates an 'underflow' value.  

=item getOverflowValue (EMPTY)

Return the particular value in the list that indicates an 'overflow' value.  

=item setOverflowValue ($value)

Set the particular value in the list that indicates an 'overflow' value.  

=item toXMLFileHandle ($fileHandle, $XMLDeclAttribs, $indent)

 

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::ValueListDelimitedList inherits the following instance (object) methods of L<XDF::GenericObject>:
B<update>.

=back



=over 4

XDF::ValueListDelimitedList inherits the following instance (object) methods of L<XDF::BaseObject>:
B<getXMLAttributes>, B<setXMLAttributes>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L< XDF::Axis>, L< XDF::Parameter>, L< XDF::ValueListAlgorithm>, L<XDF::BaseObject>, L<XDF::Value>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut
