
# $Id$

# /** COPYRIGHT
#    Value.pm Copyright (C) 2000 Brian Thomas,
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
# An XDF::Value holds mathematical values. XDF::ErroredValue inherits
# from this object; this object is also used
# at every indice on an XDF::Axis object to denote the coordinate
# value of a given index. The XDF::Value can holds a scalar value. To hold a vector 
# (unit direction) value use XDF::UnitDirection instead.
# */

# /** SYNOPSIS
# 
# */

# /** SEE ALSO
# XDF::Axis
# XDF::ErroredValue
# XDF::UnitDirection
# */

package XDF::Value;

use XDF::BaseObject;
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

# CLASS DATA
my $Class_XML_Node_Name = "value";
my @Class_XML_Attributes = qw (
                             valueId
                             valueIdRef
                             special
                             inequality
                             value
                          );
my @Class_Attributes = ();

# add in class XML attributes
push @Class_Attributes, @Class_XML_Attributes;

# add in super class attributes
push @Class_Attributes, @{&XDF::BaseObject::getClassAttributes};

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classXMLNodeName
# This method takes no arguments may not be changed. 
# This method returns the class node name of XDF::Value.
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
# SET/GET Methods
#

# /** getValueId
# */
sub getValueId{
   my ($self) = @_;
   return $self->{valueId};
}

# /** setValueId
#     Set the valueId attribute. 
# */
sub setValueId {
   my ($self, $value) = @_;
   $self->{valueId} = $value;
}

# /** getValueIdRef 
# */
sub getValueIdRef {
   my ($self) = @_;
   return $self->{valueIdRef};
}

# /** setValueIdRef 
#     Set the valueIdRef attribute. 
# */
sub setValueIdRef {
   my ($self, $value) = @_;
   $self->{valueIdRef} = $value;
}

# /** getSpecial
# */
sub getSpecial{
   my ($self) = @_;
   return $self->{special};
}

# /** setSpecial
#     Set the special attribute. 
# */
sub setSpecial {
   my ($self, $value) = @_;

   carp "Cant set special to $value, not allowed \n"
      unless (&XDF::Utility::isValidValueSpecial($value));

   $self->{special} = $value;
}

# /** getInequality
# */
sub getInequality {
   my ($self) = @_;
   return $self->{inequality};
}

# /** setInequality
#     Set the inequality attribute. 
# */
sub setInequality {
   my ($self, $value) = @_;

   carp "Cant set special to $value, not allowed \n"
      unless (&XDF::Utility::isValidValueInequality($value));

   $self->{inequality} = $value;
}

# /** getValue
# */
sub getValue {
   my ($self) = @_;
   return $self->{value};
}

# /** setValue
#     Set the value attribute. 
# */
sub setValue {
   my ($self, $value) = @_;
   $self->{value} = $value;
}

#
# Other Public Methods
#

# special new method for Value objects.
# /** setXMLAttributes
# XDF::ErrorValue has a special setXMLAttributes method. 
# These objects are so simple they seem to merit 
# special handling. This new setXMLAttributes method takes either
# and attribute Hash reference or a STRING.
# If the input value is a HASH reference, we 
# construct an object from it, else, we 
# just set its upperErrorValue AND lowerErrorValue attributes to the 
# contents of the passed STRING. 
# */
sub setXMLAttributes {
  my ($self, $info) = @_;

  # these objects are so simple they seem to merit 
  # special handling. If $info is a reference, we assume
  # it is an attribute hash (as per other objects). Else,
  # we assume its a string, and the value of the errorValue.
  if (defined $info) {
    if (ref($info) ) {
      $self->SUPER::setXMLAttributes($info);
    } else {
      $self->{value} = $info;
    }
  }
}

#
# Private methods 
#

sub _init {
  my ($self) = @_;
  
  $self->SUPER::_init();

  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Class_XML_Attributes);

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
# Revision 1.11  2001/07/23 15:58:07  thomas
# added ability to add arbitary XML attribute to class.
# getXMLattributes now an instance method, we
# have old class method now called getClassXMLAttributes.
#
# Revision 1.10  2001/07/03 17:56:40  thomas
# trivial typeset change.
#
# Revision 1.9  2001/04/25 16:01:31  thomas
# updated documentation
#
# Revision 1.8  2001/03/16 19:54:57  thomas
# Documentation updated and improved, re-ran makeDoc on file.
#
# Revision 1.7  2001/03/14 21:32:35  thomas
# Updated perldoc section using new version of
# makeDoc.pl.
#
# Revision 1.6  2001/03/09 21:51:09  thomas
# Updated perldocumentation. added Utility check
# for seting inequality and special attributes.
#
# Revision 1.5  2000/12/15 22:11:58  thomas
# Regenerated perlDoc section in files. -b.t.
#
# Revision 1.4  2000/12/14 22:11:26  thomas
# Big changes to the API. get/set methods, added Href/Entity stuff, deep cloning,
# added Href, Notes, NotesLocationOrder nodes/classes. Ripped out _enlarge_array
# from DataCube (not needed) and fixed problems outputing delimited/formatted
# read nodes. -b.t.
#
# Revision 1.3  2000/12/01 20:03:38  thomas
# Brought Pod docmentation up to date. Bumped up version
# number. -b.t.
#
# Revision 1.2  2000/10/16 17:37:21  thomas
# Changed over to BaseObject Class from Object Class.
# Added in History Modification section.
#
#
#

1;


__END__

=head1 NAME

XDF::Value - Perl Class for Value

=head1 SYNOPSIS

 


...

=head1 DESCRIPTION

 An XDF::Value holds mathematical values. XDF::ErroredValue inherits from this object; this object is also used at every indice on an XDF::Axis object to denote the coordinate value of a given index. The XDF::Value can holds a scalar value. To hold a vector  (unit direction) value use XDF::UnitDirection instead. 

XDF::Value inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::Value.

=over 4

=item classXMLNodeName (EMPTY)

This method takes no arguments may not be changed. This method returns the class node name of XDF::Value.  

=item classAttributes (EMPTY)

This method takes no arguments may not be changed. This method returns a list reference containing the namesof the class attributes of XDF::Value.  

=item getXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::Value.

=over 4

=item getValueId{ (EMPTY)

 

=item setValueId ($value)

Set the valueId attribute.  

=item getValueIdRef (EMPTY)

 

=item setValueIdRef ($value)

Set the valueIdRef attribute.  

=item getSpecial{ (EMPTY)

 

=item setSpecial ($value)

Set the special attribute.  

=item getInequality{ (EMPTY)

 

=item setInequality ($value)

Set the inequality attribute.  

=item getValue{ (EMPTY)

 

=item setValue ($value)

Set the value attribute.  

=item setXMLAttributes ($info)

XDF::ErrorValue has a special setXMLAttributes method. These objects are so simple they seem to merit special handling. This new setXMLAttributes method takes eitherand attribute Hash reference or a STRING. If the input value is a HASH reference, we construct an object from it, else, we just set its upperErrorValue AND lowerErrorValue attributes to the contents of the passed STRING.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::Value inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::Value inherits the following instance (object) methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L< XDF::Axis>, L< XDF::ErroredValue>, L< XDF::UnitDirection>, L<XDF::BaseObject>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut
