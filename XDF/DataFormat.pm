
# $Id$

package XDF::DataFormat;

# /** COPYRIGHT
#    DataFormat.pm Copyright (C) 2000 Brian Thomas,
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
#    Brian Thomas  (brian.thomas@gsfc.nasa.gov)
#    XML Group <http://xml.gsfc.nasa.gov>
#    NASA/Goddard Space Flight Center
# */

# /** DESCRIPTION
# XDF::DataFormat is an abstract class used to describe the data format of 
# information held in datacells.
# */

# /** SYNOPSIS
#  
# */

# /** SEE ALSO
# XDF::ArrayRefDataFormat
# XDF::NumberDataFormat
# XDF::StringDataFormat
# */

use XDF::BaseObject;
#use XDF::Log;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

# CLASS DATA

my $Class_XML_Node_Name = ""; # will be filled in by concrete class 
my $DataFormat_Class_XML_Node_Name = "dataFormat";
my @Local_Class_XML_Attributes = qw (
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

# /** numOfBytes
# This returns the number of bytes this object describes.
# Undef is returned if not successfull.
# */
sub numOfBytes {
  my ($self) = @_;
  undef;
}

#
# Private/Protected Methods
#

sub _basicXMLWriter {
   my ($self, $fileHandle, $indent, $dontCloseNode,
      $newNodeNameString, $noChildObjectNodeName ) = @_;

   # get XDF spec
   my $spec = XDF::Specification->getInstance();

   # capture output setting
   my $output = $spec->isPrettyXDFOutput;

   # start printing wrapper node
   print $fileHandle $indent if $output;
   print $fileHandle "<$DataFormat_Class_XML_Node_Name>";

   # turn off pretty output to collapse node info to one line 
   $spec->setPrettyXDFOutput(0);

   # now print core stuff
   $self->SUPER::_basicXMLWriter($fileHandle, $indent, $dontCloseNode,
      $newNodeNameString, $noChildObjectNodeName);

   # reset output setting
   $spec->setPrettyXDFOutput($output);
   print $fileHandle "</$DataFormat_Class_XML_Node_Name>";

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

XDF::DataFormat - Perl Class for DataFormat

=head1 SYNOPSIS

  


...

=head1 DESCRIPTION

 XDF::DataFormat is an abstract class used to describe the data format of  information held in datacells. 

XDF::DataFormat inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::DataFormat.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name for this class. This method takes no arguments may not be changed.  

=item getClassAttributes (EMPTY)

This method takes no arguments may not be changed. This method returns a list reference containing the namesof the class attributes of XDF::BinaryFloatField.  

=item getClassXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::DataFormat.

=over 4

=item numOfBytes (EMPTY)

This returns the number of bytes this object describes. Undef is returned if not successfull.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::DataFormat inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::DataFormat inherits the following instance (object) methods of L<XDF::BaseObject>:
B<getXMLAttributes>, B<setXMLAttributes>, B<getXMLAttribute>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L< XDF::ArrayRefDataFormat>, L< XDF::NumberDataFormat>, L< XDF::StringDataFormat>, L<XDF::BaseObject>

=back

=head1 AUTHOR

    Brian Thomas  (brian.thomas@gsfc.nasa.gov)
    XML Group <http://xml.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut
