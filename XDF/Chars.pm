
# $Id$

# /** COPYRIGHT
#    Chars.pm Copyright (C) 2002 Brian Thomas,
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
# An XDF::Chars holds character data. It does not guarantee that 
# various whitespace characters will NOT be converted to regular space
# characters (which is the XML way). If you want to specify a newLine
# character, DON'T use Chars objects, use NewLine objects instead. 
# */

# /** SYNOPSIS
# 
# */

# /** SEE ALSO
# XDF::NewLine
# */

package XDF::Chars;

use XDF::BaseObject;
use XDF::Log;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

# CLASS DATA
my $Class_XML_Node_Name = "chars";
my $Default_Char_Data = " "; # single space
my @Local_Class_XML_Attributes = qw (
                                       value
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

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classXMLNodeName
# This method takes no arguments may not be changed. 
# This method returns the class node name of XDF::Chars.
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

# /** getValue
# */
sub getValue {
   my ($self) = @_;
   return $self->{value};
}

# /** setValue
#     Set the character string this object will hold.
# */
sub setValue {
   my ($self, $value) = @_;
   $self->{value} = $value;
}

#
# Protected/Private methods 
#

# special method needed as normally "value" is converted to PCDATA
sub _basicXMLWriter {
  my ($self, $fileHandle, $indent, $dontCloseNode, $newNodeNameString, $noChildObjectNodeName) = @_;

  my $niceOutput = XDF::Specification->getInstance->isPrettyXDFOutput();

  if(!defined $fileHandle) {
    error("Can't write out object, filehandle not defined.\n");
    return;
  }

  $indent = "" unless defined $indent;

  print $fileHandle $indent if $niceOutput;

  print $fileHandle "<" . $Class_XML_Node_Name;

  #writeOutAttributes
  my $value = $self->getValue();
  if (defined $value)
  {
     print $fileHandle " value=\"$value\"";
  }

  print $fileHandle "/>";

  return $Class_XML_Node_Name;

}

sub _init {
  my ($self) = @_;
  
  $self->SUPER::_init();

  $self->setValue($Default_Char_Data);

  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

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

XDF::Chars - Perl Class for Chars

=head1 SYNOPSIS

 


...

=head1 DESCRIPTION

 An XDF::Chars holds character data. It does not guarantee that  various whitespace characters will NOT be converted to regular space characters (which is the XML way). If you want to specify a newLine character, DON'T use Chars objects, use NewLine objects instead. 

XDF::Chars inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::Chars.

=over 4

=item classXMLNodeName (EMPTY)

This method takes no arguments may not be changed. This method returns the class node name of XDF::Chars.  

=item getClassAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes for this class. This method takes no arguments may not be changed.  

=item getClassXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::Chars.

=over 4

=item getValue (EMPTY)

 

=item setValue ($value)

Set the character string this object will hold.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::Chars inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::Chars inherits the following instance (object) methods of L<XDF::BaseObject>:
B<getXMLAttributes>, B<setXMLAttributes>, B<getXMLAttribute>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L< XDF::NewLine>, L<XDF::BaseObject>, L<XDF::Log>

=back

=head1 AUTHOR

    Brian Thomas  (brian.thomas@gsfc.nasa.gov)
    XML Group <http://xml.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut
