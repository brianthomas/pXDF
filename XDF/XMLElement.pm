
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
# An XDF::XMLElement object contains node information for XML element nodes which are
# held inside the an XDF structure or array.
# */

# /** SYNOPSIS
# 
# */

# /** SEE ALSO
# XDF::Array
# XDF::Structure
# */

package XDF::XMLElement;

use XML::DOM;
use XDF::Constants;
use XDF::Specification;
use Carp;

use strict;
use integer;

#use vars qw ($AUTOLOAD @ISA);
use vars qw { $AUTOLOAD @ISA };

# inherits from XML::DOM::Attr
@ISA = ("XML::DOM::Element"); #, "XDF::BaseObject");

# CLASS DATA
my $Class_XML_Node_Name = ""; # doesnt have one!! 
my @Class_Attributes = (); # none!, we should probably fix this 

# /** classAttributes
# This method returns a list reference containing the names
# of the class attributes of XDF::XMLElement.
# Note that for XDF::XMLElement this is an empty list. Any attributes
# that this class has are inherited from XML::DOM::Element, a class
# outside of the XDF package.
# */
sub classAttributes { 
  \@Class_Attributes; 
}

#/** new
# Creates a new XMLElement. $tagName variable must be specified, 
# but $ownerDoc is not needed.
#*/
sub new {
   my ($proto, $tagName, $ownerDoc) = @_;

   die "XDF::XMLElement::new requires you define the value of tagName.\n"
       unless defined $tagName and $tagName ne "";

   my $class = ref ($proto) || $proto;

   # Well we have to declare a document. feh. Its not 
   # good that we have to use FULL DOM Document, too bad DocumentFragment 
   # wont do, as its more lightweight. Still, we can just reference a single
   # declared document from the constants class as a memory saver.
   #$ownerDoc = new XML::DOM::Document() unless defined $ownerDoc;
   $ownerDoc = &XDF::Constants::getInternalDOMDocument unless defined $ownerDoc;
   my $self = XML::DOM::Document::createElement($ownerDoc, $tagName); 
   bless ($self, $class); # re-bless into this class 

   return $self;
}

# need to override this method in BaseObject (via GenericObject)
sub AUTOLOAD { # PRIVATE 
  # do nothing
}

# /** getXMLElementList 
# Similar to the getChildNodes method except that it only returns
# the children which are of type XMLElement. 
# */
sub getXMLElementList {
  my ($self) = @_;
 
  my @list;
  foreach my $child ($self->getChildNodes()) {
     next unless ref($child) eq 'XDF::XMLElement'; 
     push @list, $child;
  }

  return \@list;
}

# /** addXMLElement
# Aliased to the appendChild method. 
# */
sub addXMLElement {
  my ($self, $xmlElementObjRef) = @_;

  # change owner document to that of this one
  $xmlElementObjRef->setOwnerDocument($self->getOwnerDocument);
  $self->appendChild($xmlElementObjRef);
}

# /** removeXMLElement
# Aliased to the removeChild method. Will only remove child
# XMLElement nodes. 
# */
sub removeXMLElement {
   my ($self, $xmlElementObjRef) = @_;
   return unless defined $xmlElementObjRef && ref($xmlElementObjRef) eq 'XDF::XMLElement';
   $self->removeChild($xmlElementObjRef);
}

# /** setXMLElementList 
# May reset the childNode list to that passed. 
# This method will reject any $listRef which is undefined. 
# This method will not append any non-XDF::XMLElement objects 
# in the list.
# */
sub setXMLElementList {
  my ($self, $listRef) = @_;

  return unless defined $listRef;

  # remove old nodes
  foreach my $child ($self->getChildNodes) {
    $self->removeChild($child);
  }

  # add in new list
  foreach my $newchild (@{$listRef}) {
     next unless ref($newchild) eq 'XDF::XMLElement';
     $self->appendChild($newchild);
  }

}

# 
# SET/GET Methods
# 

# /** getCData {
# A short cut method. Finds all of the child TEXT_NODEs and returns
# concatenated value of all as a string.
# */
sub getCData {
   my ($self) = @_;
   # concat all child Text Nodes together

   my $CDATA_string; 
   foreach my $childNode ($self->getChildNodes) {
      if ($childNode->getNodeTypeName eq 'TEXT_NODE') {
          $CDATA_string .= $childNode->getNodeValue;
      }
   }

   return $CDATA_string;
}

# /** appendCData
#     Append character data into this node. This is a short cut method,
#   it actually creates a child TEXT_NODE to hold the CDATA and then 
#   appends it as a child of the XMLElement.
# */
sub appendCData {
   my ($self, $text) = @_;

   return unless defined $text;

   my $textNode = $self->getOwnerDocument->createTextNode($text);
   $self->appendChild($textNode);
}

#
# Other Public Methods
#

#/** toXMLFileHandle
#*/
sub toXMLFileHandle {
   my ($self, $fileHandle, $indent) = @_;

   $indent = "" unless defined $indent;
   my $spec = XDF::Specification->getInstance();

   my $Pretty_XDF_Output = $spec->isPrettyXDFOutput;
   my $Pretty_XDF_Output_Indent = $spec->getPrettyXDFOutputIndentation;

   # open the node
   print $fileHandle $indent if $Pretty_XDF_Output;
   print $fileHandle "<" . $self->getTagName();


   # print attribs
   #for ($self->{parentElement}->getAttributes->getValues) {
   for ($self->getAttributes->getValues) {
      print $fileHandle " ".$_->getName."=\"".$_->getValue."\"";
   }

   # print child nodes OR CDATA 
   my @childXMLElements; # generic XML nodes we need to print 
   @childXMLElements = @{$self->getXMLElementList}; # if defined $self->getXMLElementList;
   if (defined $self->getCData
        || $#childXMLElements > -1
     )
   {

     # close the opening node decl 
     print $fileHandle ">";

     # print the CData (or child nodes)
     if (defined $self->getCData) {
        print $fileHandle $self->getCData;
     }

     for (@childXMLElements) {
        print $fileHandle "\n" if $Pretty_XDF_Output;
        $_->toXMLFileHandle($fileHandle, $indent . $Pretty_XDF_Output_Indent);
        print $fileHandle $indent if $Pretty_XDF_Output;
     }

     # closing node decl 
     print $fileHandle "</". $self->getTagName .">";

   } else {
      # just close the node
      print $fileHandle "/>";
   }

   print $fileHandle "\n" if $Pretty_XDF_Output;

}

#
# Private methods 
#

# Modification History
#
# $Log$
# Revision 1.3  2001/04/17 18:47:26  thomas
# Completely redone. This class is now derived from XML::DOM::Element
# (as it should be) with added methods to make that class
# interoperate with XDF package classes (like toXMLFilehandle method).
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

 An XDF::XMLElement object contains node information for XML element nodes which are held inside the an XDF structure or array. 

XDF::XMLElement inherits class and attribute methods of L<XML::DOM::Element>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::XMLElement.

=over 4

=item classAttributes (EMPTY)

This method takes no arguments may not be changed. This method returns a list reference containing the namesof the class attributes of XDF::XMLElement.  

=item new ($name, $value, $ownerDoc)

 

=item Pretty_XDF_Output (EMPTY)

 

=item Pretty_XDF_Output_Indentation (EMPTY)

 

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::XMLElement.

=over 4

=item getXMLElementList (EMPTY)

Similar to the getChildNodes method except that it only returnsthe children which are of type XMLElement.  

=item addXMLElement ($xmlElementObjRef)

Aliased to the appendChild method.  

=item removeXMLElement ($xmlElementObjRef)

Aliased to the removeChild method. Will only remove childXMLElement nodes.  

=item setXMLElementList ($listRef)

May reset the childNode list to that passed. This method will reject any $listRef which is undefined. This method will not append any non-XDF::XMLElement objects in the list.  

=item getCData (EMPTY)

 

=item appendCData ($text)

Append character data into this node. This is a short cut method,it actually creates a child TEXT_NODE to hold the CDATA and then appends it as a child of the XMLElement.  

=item toXMLFileHandle ($fileHandle, $indent)

 

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4

=back

=back

=head1 SEE ALSO



=over 4

L< XDF::Array>, L< XDF::Structure>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut
