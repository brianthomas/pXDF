
# $Id$

# /** COPYRIGHT
#    XMLAttribute.pm Copyright (C) 2000 Brian Thomas,
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
# An XDF::XMLAttribute object holds attribute information for XMLElement objects.
# Programmers note: unlike the Java XDF package, XMLAttribute objects are NOT used
# to hold the attributes of most XDF objects. In fact, that this time only the
# L<XDF::XMLElement> objects use XDF::XMLAttribute objects to hold their attribute
# data at this time.
# */

# /** SYNOPSIS
# 
# */

# /** SEE ALSO
# XDF::XMLElement
# */

package XDF::XMLAttribute;

use XDF::BaseObject;
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::GenericObject");

# CLASS DATA
my $Class_XML_Node_Name = ""; # doesnt have one!! 
my @Class_XML_Attributes = ();
my @Class_Attributes = qw (
                            key
                            value
                          );

# add in class XML attributes
push @Class_Attributes, @Class_XML_Attributes;

# add in super class attributes
push @Class_Attributes, @{&XDF::GenericObject::classAttributes};

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classAttributes
#  This method takes no arguments may not be changed. 
#  This method returns a list reference containing the names
#  of the class attributes of XDF::XMLAttribute.
# */
sub classAttributes { 
  \@Class_Attributes; 
}

# 
# SET/GET Methods
#

# /** getKey
# */
sub getKey {
   my ($self) = @_;
   return $self->{Key};
}

# /** setKey
#     Set the name of the key of this XML attribute. 
# */
sub setKey {
   my ($self, $value) = @_;
   $self->{Key} = $value;
}

# /** getValue {
# */
sub getValue {
   my ($self) = @_;
   return $self->{Value};
}

# /** setValue
#     Set the attibute value for this node.
# */
sub setValue {
   my ($self, $value) = @_;
   $self->{Value} = $value;
}

#
# Other Public Methods
#

#/** toXMLFileHandle
# Special local method. 
#*/
sub toXMLFileHandle {
   my ($self, $fileHandle) = @_;

   # print attribs
    # next 2 lines: have to break up printing of '"' or toXMLString will behave badly
    print $fileHandle " " . $self->{Key} . "=\"";
    print $fileHandle $self->{Value} . "\"";

}

#
# Private methods 
#

# This is called when we cant find any defined method
# exists already. Used to handle general purpose set/get
# methods for our attributes (object fields).
sub AUTOLOAD {
  my ($self, $val) = @_;
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}

sub _init {
  my ($self) = @_;

}

# Modification History
#
# $Log$
# Revision 1.1  2001/03/23 21:54:19  thomas
# Holds XML attributes for XMLElement. Not
# as widely used as in Java package. should be
# rectified.
#
#
#

1;


__END__

=head1 NAME

XDF::XMLAttribute - Perl Class for XMLAttribute

=head1 SYNOPSIS

 


...

=head1 DESCRIPTION

 An XDF::XMLAttribute object holds attribute information for XMLElement objects.  Programmers note: unlike the Java XDF package, XMLAttribute objects are NOT used to hold the attributes of most XDF objects. In fact, that this time only the L<XDF::XMLElement> objects use XDF::XMLAttribute objects to hold their attribute data at this time. 

XDF::XMLAttribute inherits class and attribute methods of L<XDF::GenericObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::XMLAttribute.

=over 4

=item classAttributes (EMPTY)

This method takes no arguments may not be changed. This method returns a list reference containing the namesof the class attributes of XDF::XMLAttribute.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::XMLAttribute.

=over 4

=item getKey (EMPTY)

 

=item setKey ($value)

Set the name of the key of this XML attribute.  

=item getValue (EMPTY)

 

=item setValue ($value)

Set the attibute value for this node.  

=item toXMLFileHandle ($fileHandle)

Special local method.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::XMLAttribute inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L< XDF::XMLElement>, L<XDF::BaseObject>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut
