
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
use XDF::Value;
use Carp;

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
                             noData
                             infinite
                             infiniteNegative
                             notANumber
                             overflow
                             underflow
                           );
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
# Constructs a valueList object with Values in passed List.
# Care should be taken that none of the Value objects are set
# to the same sequence of characters as the passed delimiter (or 
# the default delimiter if no delimiter variable is passed).
# */
sub new { 
  my ($proto, $valueListRef, $delimiter, $noDataValue, $infiniteValue, $infiniteNegativeValue, $notANumberValue, $overflowValue, $underflowValue ) = @_;

  unless (defined $valueListRef && ref($valueListRef)) {
    croak "Error: $proto got insufficient information to create self (missing value list).\n";
  }

  my $class = ref ($proto) || $proto;
  my $self = bless( { }, $class);

  $self->_init($valueListRef, $delimiter, $noDataValue, $infiniteValue, $infiniteNegativeValue, $notANumberValue, $overflowValue, $underflowValue); # init of class specific stuff

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
# Return the list of values held in this object.
# */
sub getValues {
   my ($self) = @_;
   return $self->{values};
}

#
# Other Public Methods
#

sub toXMLFileHandle {
   my ($self, $fileHandle, $XMLDeclAttribs, $indent ) = @_;

   if(!defined $fileHandle) {
      carp "Can't write out object, filehandle not defined.\n";
      return;
   }

   $indent = "" unless defined $indent;

   my $spec = XDF::Specification->getInstance();
   my $isPrettyXDFOutput = $spec->isPrettyXDFOutput;

   print $fileHandle $indent if $isPrettyXDFOutput;

   print $fileHandle "<valueList delimiter=\"".$self->{Delimiter}."\" repeatable=\"no\"";
   print $fileHandle " valueListId=\"".$self->{valueListId}."\"" if (defined $self->{valueListId});
   print $fileHandle " valueListIdRef=\"".$self->{valueListIdRef}."\"" if (defined $self->{valueListIdRef});
   print $fileHandle " noDataValue=\"".$self->{NoData}."\"" if (defined $self->{NoData});
   print $fileHandle " infiniteValue=\"".$self->{Infinite}."\"" if (defined $self->{Infinite});
   print $fileHandle " infiniteNegativeValue=\"".$self->{InfiniteNegative}."\"" 
                       if (defined $self->{InfiniteNegative});
   print $fileHandle " notANumberValue=\"".$self->{NotANumber}."\"" if (defined $self->{NotANumber});
   print $fileHandle " overflowValue=\"".$self->{Overflow}."\"" if (defined $self->{Overflow});
   print $fileHandle " underflowValue=\"".$self->{Underflow}."\"" if (defined $self->{Underflow});
   print $fileHandle ">";

   my @values = @{$self->{values}};
   foreach my $valIndex (0 .. $#values) {

      my $thisValue = $values[$valIndex];

      my $specialValue = $thisValue->getSpecial();
      if(defined $specialValue) {
         if($specialValue eq &XDF::Constants::VALUE_SPECIAL_INFINITE) {
            &_doValuePrint($fileHandle, $specialValue, $self->{Infinite});
         } elsif($specialValue eq &XDF::Constants::VALUE_SPECIAL_INFINITE_NEGATIVE) {
            &_doValuePrint($fileHandle, $specialValue, $self->{InfiniteNegative});
         } elsif($specialValue eq &XDF::Constants::VALUE_SPECIAL_NODATA) {
             &_doValuePrint($fileHandle, $specialValue, $self->{NoData});
         } elsif($specialValue eq &XDF::Constants::VALUE_SPECIAL_NOTANUMBER) {
             &_doValuePrint($fileHandle, $specialValue, $self->{NotANumber});
         } elsif($specialValue eq &XDF::Constants::VALUE_SPECIAL_UNDERFLOW) {
             &_doValuePrint($fileHandle, $specialValue, $self->{Underflow});
         } elsif($specialValue eq &XDF::Constants::VALUE_SPECIAL_OVERFLOW) {
             &_doValuePrint($fileHandle, $specialValue, $self->{Overflow});
         } 

      } else {
         print $fileHandle $thisValue->getValue();
      }

      # print delimiter except on last index.
      print $fileHandle $self->{Delimiter} unless $valIndex eq $#values;
   }

   print $fileHandle "</valueList>";

   print $fileHandle "\n" if $isPrettyXDFOutput;

}

#
# Private methods 
#

sub _init {
   my ($self, $valueListRef, $delimiter, $noDataValue, $infiniteValue, $infiniteNegativeValue, $notANumberValue, $overflowValue, $underflowValue) = @_;

   $self->{Delimiter} = defined $delimiter ? $delimiter : &XDF::Constants::DEFAULT_VALUELIST_DELIMITER;

   $self->{NoData} = $noDataValue;
   $self->{Infinite} = $infiniteValue;
   $self->{InfiniteNegative} = $infiniteNegativeValue;
   $self->{NotANumber} = $notANumberValue;
   $self->{Overflow} = $overflowValue;
   $self->{Underflow} = $underflowValue;

   # init values
   $self->{values} = [];
   # you must do it this way, or when the arrayRef changes it changes us here!
   # however we DO want to preserve the valueObj ref tho.
   foreach my $valueObj (@{$valueListRef}) {
      push @{$self->{values}}, $valueObj;
   }

   # adds to ordered list of XML attributes
   $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

}

sub _doValuePrint {
   my ($fileHandle, $specialValue, $value) = @_;

   if (defined $value) {
      print $fileHandle $value;
   } else {
      carp("Error: valueList doesnt have ",$specialValue," defined but value does. Ignoring.");
   }
}

# This is called when we cant find any defined method
# exists already. Used to handle general purpose set/get
# methods for our attributes (object fields).
sub AUTOLOAD {
  my ($self, $val) = @_;
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}

# Modification History
#
# $Log$
# Revision 1.5  2001/08/13 20:56:37  thomas
# updated documentation via utils/makeDoc.pl for the release.
#
# Revision 1.4  2001/08/13 19:56:29  thomas
# bug fix: use only local XML attributes for appendAttribs in _init
#
# Revision 1.3  2001/08/10 16:28:24  thomas
# added local clone method (so work properly).
# fixed toXMLFileHandle method to print properly.
#
# Revision 1.2  2001/07/23 15:58:07  thomas
# added ability to add arbitary XML attribute to class.
# getXMLattributes now an instance method, we
# have old class method now called getClassXMLAttributes.
#
# Revision 1.1  2001/07/13 21:38:25  thomas
# Initial Version
#
#
#

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
B<getXMLAttributes>, B<setXMLAttributes>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L< XDF::Axis>, L< XDF::Parameter>, L< XDF::ValueListAlgorithm>, L< XDF::Value>, L<XDF::BaseObject>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut
