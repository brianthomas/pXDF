
# $Id$

package XDF::RecordTerminator;

# /** COPYRIGHT
#    RecordTerminator.pm Copyright (C) 2002 Brian Thomas,
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
# This class handles the recordTerminator information for delimited IO 
# */

# /** SYNOPSIS
#  
# */

# /** SEE ALSO
# */

use XDF::BaseObject;
use XDF::Chars;
use XDF::Log;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

# CLASS DATA
my $Class_XML_Node_Name = "recordTerminator";
my @Local_Class_XML_Attributes = qw (
                                       valueObj
                                    );
my @Local_Class_Attributes = (); 

my @Class_Attributes;
my @Class_XML_Attributes;

# add in local class XML attributes
push @Local_Class_Attributes, @Local_Class_XML_Attributes;

# get super class attributes
push @Class_XML_Attributes, @{&XDF::BaseObject::getClassXMLAttributes};
push @Class_Attributes, @{&XDF::BaseObject::getClassAttributes};

# add in local to overall class
push @Class_XML_Attributes, @Local_Class_XML_Attributes;
push @Class_Attributes, @Local_Class_Attributes;

# Initalization -- set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }


# /** classXMLNodeName
# This method returns the class node name for this class.
# This method takes no arguments may not be changed. 
# */
sub classXMLNodeName { 
  $Class_XML_Node_Name;
}

# /** getClassAttributes
#  This method takes no arguments may not be changed. 
#  This method returns a list reference containing the names
#  of the class attributes of XDF::BinaryFloatField. 
# */
sub getClassAttributes {
  \@Class_Attributes;
}

# /** getClassXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
sub getClassXMLAttributes {
  return \@Class_XML_Attributes;
}

# 
# SET/GET Methods
#

# /** setValue
#     Set the value (with either Chars or NewLine object) of this delimiter.
# */
sub setValue {
   my ($self, $valueObj) = @_;

   if (&XDF::Utility::isValidCharOutput($valueObj)) {
      $self->{valueObj} = $valueObj;
   } else {
      error("Cant set $valueObj as value of XDF::RecordTerminator class, ignoring request\n");
   }
}

# /** getValue
# */
sub getValue {
   my ($self) = @_;
   return $self->{valueObj};
}

# /** getStringValue
#     return the string representation of the recordterminator characters for this object. 
# */
sub getStringValue {
   my ($self) = @_;
   return $self->getValue()->getValue();
}

#
# Private/Protected Methods
#

sub _init {
  my ($self) = @_;

  $self->SUPER::_init();

  $self->setValue(new XDF::Chars());

  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

}

# This is called when we cant find any defined method
# exists already. Used to handle general purpose set/get
# methods for our attributes (object fields).
sub AUTOLOAD {
  my ($self,$val) = @_;
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}

1;


__END__

=head1 NAME

XDF::RecordTerminator - Perl Class for RecordTerminator

=head1 SYNOPSIS

  


...

=head1 DESCRIPTION

 This class handles the recordTerminator information for delimited IO 

XDF::RecordTerminator inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::RecordTerminator.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name for this class. This method takes no arguments may not be changed.  

=item getClassAttributes (EMPTY)

This method takes no arguments may not be changed. This method returns a list reference containing the namesof the class attributes of XDF::BinaryFloatField.  

=item getClassXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::RecordTerminator.

=over 4

=item setValue ($valueObj)

Set the value (with either Chars or NewLine object) of this delimiter.  

=item getValue (EMPTY)

 

=item getStringValue (EMPTY)

return the string representation of the recordterminator characters for this object.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::RecordTerminator inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::RecordTerminator inherits the following instance (object) methods of L<XDF::BaseObject>:
B<getXMLAttributes>, B<setXMLAttributes>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::BaseObject>, L<XDF::Chars>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut
