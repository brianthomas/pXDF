
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

use XDF::GenericObject;
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::GenericObject
@ISA = ("XDF::GenericObject");

# CLASS DATA
my $Class_XML_Node_Name = "valueList";
my @Class_XML_Attributes = qw (
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
my @Class_Attributes = qw ( 
                             values
                          );

# add in class XML attributes
push @Class_Attributes, @Class_XML_Attributes;

# add in super class attributes
push @Class_Attributes, @{&XDF::GenericObject::getClassAttributes};

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

   print $fileHandle "<valueList delimiter=\"",$self->{Delimiter},"\" repeatable=\"no\"";
   print $fileHandle " valueListId=\"",$self->{valueListId},"\"" if (defined $self->{valueListId});
   print $fileHandle " valueListIdRef=\"",$self->{valueListIdRef},"\"" if (defined $self->{valueListIdRef});
   print $fileHandle " noDataValue=\"",$self->{NoData},"\"" if (defined $self->{NoData});
   print $fileHandle " infiniteValue=\"",$self->{Infinite},"\"" if (defined $self->{Infinite});
   print $fileHandle " infiniteNegativeValue=\"",$self->{InfiniteNegative},"\"" 
                       if (defined $self->{InfiniteNegative});
   print $fileHandle " notANumberValue=\"",$self->{NotANumber},"\"" if (defined $self->{NotANumber});
   print $fileHandle " overflowValue=\"",$self->{Overflow},"\"" if (defined $self->{Overflow});
   print $fileHandle " underflowValue=\"",$self->{Underflow},"\"" if (defined $self->{Underflow});
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

