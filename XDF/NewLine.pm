
# $Id$

package XDF::NewLine;

# /** COPYRIGHT
#    NewLine.pm Copyright (C) 2002 Brian Thomas,
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
# This class handles the outputting of newline character data for some cases. 
# Normally, "new line" character data will be converted to whitespace upon output by 
# XML parsers. This presents XDF with a problem in appropriately describing and 
# perserving the output format of some formatted and delimited text data (e.g within
# the &lt;read> block). 
#@
# In order to work around this, both this and the Chars classes were formulated. This class
# will  will insure that a tag, "&lt;newLine/>" (or some such) will be output so that the
# XDF parser will be able to recognize where newLines ought to be when the XML file
# is re-read.
# */

# /** SYNOPSIS
#  
# */

# /** SEE ALSO
# */

use XDF::BaseObject;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

# CLASS DATA

my $Class_XML_Node_Name = "newLine";
my @Local_Class_XML_Attributes = ();
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

# /** getValue
# */
sub getValue {
   my ($self) = @_;
   return "\n";
}

#
# Private/Protected Methods
#

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

XDF::NewLine - Perl Class for NewLine

=head1 SYNOPSIS

  


...

=head1 DESCRIPTION

 This class handles the outputting of newline character data for some cases.  Normally, "new line" character data will be converted to whitespace upon output by  XML parsers. This presents XDF with a problem in appropriately describing and  perserving the output format of some formatted and delimited text data (e.g within the &lt;read> block).  
 In order to work around this, both this and the Chars classes were formulated. This class will  will insure that a tag, "&lt;newLine/>" (or some such) will be output so that the XDF parser will be able to recognize where newLines ought to be when the XML file is re-read. 

XDF::NewLine inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::NewLine.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name for this class. This method takes no arguments may not be changed.  

=item getClassAttributes (EMPTY)

This method takes no arguments may not be changed. This method returns a list reference containing the namesof the class attributes of XDF::BinaryFloatField.  

=item getClassXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::NewLine.

=over 4

=item getValue (EMPTY)

 

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::NewLine inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::NewLine inherits the following instance (object) methods of L<XDF::BaseObject>:
B<getXMLAttributes>, B<setXMLAttributes>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::BaseObject>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut
