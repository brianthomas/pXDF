
# $Id$

# /** COPYRIGHT
#    XMLElement.pm Copyright (C) 2000 Brian Thomas,
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
# An XDF::XMLElement object holds generic (non-XDF) node information. 
# This class allows the XDF to capture non-XDF information within it so 
# that it may be written back out by the XDF object as needed.
# */

# /** SYNOPSIS
# 
# */

# /** SEE ALSO
# */

package XDF::XMLElement;

use XDF::BaseObject;
use XDF::XMLAttribute;
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

# CLASS DATA
my $Class_XML_Node_Name = ""; # will be overwritten by nodeName 
my @Class_XML_Attributes = ();
my @Class_Attributes = qw (
                          nodeName
                          attribList
                          value
                       );

# add in class XML attributes
push @Class_Attributes, @Class_XML_Attributes;

# add in super class attributes
push @Class_Attributes, @{&XDF::BaseObject::classAttributes};

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classXMLNodeName
# This method takes no arguments may not be changed. 
# This method returns the class node name of XDF::XMLElement.
# */
sub classXMLNodeName { 
  $Class_XML_Node_Name; 
}

# /** classAttributes
#  This method takes no arguments may not be changed. 
#  This method returns a list reference containing the names
#  of the class attributes of XDF::XMLElement.
# */
sub classAttributes { 
  \@Class_Attributes; 
}

# 
# SET/GET Methods
#

# /** getNodeName
# */
sub getNodeName {
   my ($self) = @_;
   return $self->{NodeName};
}

# /** setNodeName
#     Set the nodeName attribute. 
# */
sub setNodeName {
   my ($self, $value) = @_;
   $self->{NodeName} = $value;
}

# /** getCData {
# */
sub getCData {
   my ($self) = @_;
   return $self->{Value};
}

# /** setCData
#     Set the character data for this node.
# */
sub setCData {
   my ($self, $value) = @_;
   $self->{Value} = $value;
}

# /** getAttribList
# */
sub getAttribList {
   my ($self) = @_;
   return $self->{AttribList};
}

# /** setAttribList
#     Set the attribute list. 
# */
sub setAttribList {
   my ($self, $attribListRef) = @_;
   $self->{AttribList} = $attribListRef;
}

# /** getXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
sub getXMLAttributes {
  die "getXMLAttributes not implemented yet for XMLElement\n";
  #return \@Class_XML_Attributes;
}

#
# Other Public Methods
#

#/** addAttribute 
# 
#*/
sub addAttribute {
   my ($self, $attributeObjRef) = @_;
   return unless defined $attributeObjRef;
   push @{$self->{AttribList}}, $attributeObjRef;
}

#/** removeAttribute
# 
#*/
sub removeAttribute {
   my ($self, $attribObjRef) = @_;
   die "removeAttribute not implemented yet for XMLElement\n";
}

#/** toXMLFileHandle
# Special local method. 
#*/
sub toXMLFileHandle {
   my ($self, $fileHandle, $indent) = @_;

   $indent = "" unless defined $indent;
   my $Pretty_XDF_Output = $self->Pretty_XDF_Output;
   my $Pretty_XDF_Output_Indent = $self->Pretty_XDF_Output_Indentation;

   # open the node
   print $fileHandle $indent if $Pretty_XDF_Output;
   print $fileHandle "<" . $self->{NodeName};

   # print attribs
   for (@{$self->getAttribList}) { 
      $_->toXMLFileHandle($fileHandle);
   }

   # print child nodes OR CDATA 
   my @childXMLElements; # generic XML nodes we need to print 
   @childXMLElements = @{$self->{_ChildXMLElementList}} if defined $self->{_ChildXMLElementList};
   if (defined $self->{Value} 
        || $#childXMLElements > -1
     )
   {

     # close the opening node decl 
     print $fileHandle ">";

     # print the CData (or child nodes)
     if (defined $self->{Value}) {
        print $fileHandle $self->{Value};
     }

     for (@childXMLElements) { 
        print $fileHandle "\n" if $Pretty_XDF_Output;
        $_->toXMLFileHandle($fileHandle, $indent . $Pretty_XDF_Output_Indent); 
        print $fileHandle $indent if $Pretty_XDF_Output;
     } 

     # closing node decl 
     print $fileHandle "<". $self->{NodeName} ."/>";

   } else { 
      # just close the node
      print $fileHandle "/>";
   }

   print $fileHandle "\n" if $Pretty_XDF_Output;

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

  $self->{NodeName} = $Class_XML_Node_Name;
  $self->{AttribList} = [];

}

# Modification History
#
# $Log$
# Revision 1.1  2001/03/23 21:53:41  thomas
# Class needed to treat 'anonymous' nodes that the DTD
# allows to exist in several spots within the XDF. Holds
# generic XMLElement information.
#
#
#

1;


__END__

=head1 NAME

XDF::XMLElement - Perl Class for XMLElement

=head1 SYNOPSIS

 


...

=head1 DESCRIPTION

 An XDF::XMLElement object holds generic (non-XDF) node information.  This class allows the XDF to capture non-XDF information within it so  that it may be written back out by the XDF object as needed. 

XDF::XMLElement inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::XMLElement.

=over 4

=item classXMLNodeName (EMPTY)

This method takes no arguments may not be changed. This method returns the class node name of XDF::XMLElement.  

=item classAttributes (EMPTY)

This method takes no arguments may not be changed. This method returns a list reference containing the namesof the class attributes of XDF::XMLElement.  

=item getXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::XMLElement.

=over 4

=item getNodeName (EMPTY)

 

=item setNodeName ($value)

Set the nodeName attribute.  

=item getCData (EMPTY)

 

=item setCData ($value)

Set the character data for this node.  

=item getAttribList (EMPTY)

 

=item setAttribList ($attribListRef)

Set the attribute list.  

=item addAttribute ($attributeObjRef)

 

=item removeAttribute ($attribObjRef)

 

=item toXMLFileHandle ($indent, $fileHandle)

Special local method.  

=back



=head2 INHERITED Class Methods

=over 4



=over 4

The following class methods are inherited from L<XDF::BaseObject>:
B<Pretty_XDF_Output>, B<Pretty_XDF_Output_Indentation>, B<DefaultDataArraySize>. 

=back

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::XMLElement inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::XMLElement inherits the following instance (object) methods of L<XDF::BaseObject>:
B<addXMLElement>, B<removeXMLElement>, B<getXMLElementList>, B<setXMLElementList>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLAttributes>, B<setXMLNotationHash>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::BaseObject>, L<XDF::XMLAttribute>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut
