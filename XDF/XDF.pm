
# $Id$

package XDF::XDF;

# /** COPYRIGHT
#    XDF.pm Copyright (C) 2001 Brian Thomas,
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
# XDF is the eXtensible Data XDF, which is an XML format
# designed to contain n-dimensional scientific/mathematical data.
# For more background information on XDF see the XDF homepage at 
# http://xml.gsfc.nasa.gov/XDF/XDF_home.html .
#@   
#@   
# The XDF can hold both tagged and untagged data and may serve as
# a wrapper around many kinds of legacy data.
#@   
#@   
# XDF::XDF inherits from XDF::Structure, and is itself the top level structure
# in any XDF object.
# */

#/** SYNOPSIS
#
#    use XDF::XDF;
#  
#    my %attributes = ( 
#                       'name' => 'A default name',
#                       'paramList' => @paramObjRefList,
#                       'arrayList' => @arrayRefList,
#                     );
#
#    # initialize new object w/ attribute hash
#    my $xdfObj = XDF::XDF->new(%attributes);
#
#    # overwrite the name attribute w/ new value, set the description 
#    $xdfObj->setName("My XDF");
#    $xdfObj->setDescription("This data was found under under a cabinet. It looks important.");
#
#    # add an XDF::Array object to the XDF structure
#    $xdfObj->addArray($arrayObj);
#
#    ...
#
#    # several ways to create an XDF from a file
#
#    my $XDFObj = new XDF::XDF();
#
#    # read method makes a call to XDF::Reader. %options
#    # has same meaning here as for createXDFObjectfromFile 
#    # method in XDF::Reader.
#
#    my $newXDFObj = $XDFObj->loadFromXDFFile($file, \%options);
#
#    # create a structure from a file (alternative method) 
#
#    my $reader = new XDF::Reader();
#    my $XDFObj2 = $reader->parseFile($file, \%options);
#
# */

use XDF::Structure;
use XDF::Log;
use XDF::Reader;

use strict;
use integer;

use vars qw ($AUTOLOAD @ISA %field);

# inherits from XDF::Structure
@ISA = ("XDF::Structure");

# CLASS DATA
my $Class_XML_Node_Name = "XDF";
# NOTE: if you ADD/Change an attribute here, make sure it is
# properly re-inited in the _init method or you will be sorry!!!
my @Local_Class_XML_Attributes = qw (
                                      type
                                    ); 
my @Local_Class_Attributes = qw (
                                   xmlDeclaration
                                   documentType
                                ); 
my @Class_Attributes;
my @Class_XML_Attributes;

# add in local class XML attributes
push @Local_Class_Attributes, @Local_Class_XML_Attributes;

# get super class attributes
push @Class_XML_Attributes, @{&XDF::Structure::getClassXMLAttributes};
push @Class_Attributes, @{&XDF::Structure::getClassAttributes};

# add in local to overall class
push @Class_XML_Attributes, @Local_Class_XML_Attributes;
push @Class_Attributes, @Class_XML_Attributes;

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classXMLNodeName
# This method takes no arguments may not be changed. 
# This method returns the class node name for XDF::XDF; 
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

# /** getDocumentType
# */
sub getDocumentType {
   my ($self) = @_;
   return $self->{documentType};
}

# /** setDocumentType
# */
sub setDocumentType {
   my ($self, $docType) = @_;
   if (!defined $docType or ref $docType eq 'XDF::DocumentType') {
      $self->{documentType} = $docType;
   } else {
      error("Cant setDocumentType(), object:$docType is wrong class! Ignoring request.\n"); 
   }
}

# /** getType
# */
sub getType {
   my ($self) = @_;
   return $self->{type};
}

# /** setType
# */
sub setType {
   my ($self, $value) = @_;
   $self->{type} = $value;
}

# /** getXMLDeclaration
# */
sub getXMLDeclaration {
   my ($self) = @_;
   return $self->{xmlDeclaration};
}

# /** setXMLDeclaration
# */
sub setXMLDeclaration {
   my ($self, $xmlDecl) = @_;
   if (!defined $xmlDecl or ref $xmlDecl eq 'XDF::XMLDeclaration') {
      $self->{xmlDeclaration} = $xmlDecl;
   } else {
      error("Cant setXMLDeclaration(), object:$xmlDecl is wrong class! Ignoring request.\n");
   }
}

#
# Other Public Methods 
#

# /** loadFromXDFFile
# Read in an XML file into this XDF object. The current XDF object, 
# if it has any components, is overrided and lost. 
# */
sub loadFromXDFFile {
  my ($self, $file, $optionsHashRef) = @_;

  my $reader = new XDF::Reader($optionsHashRef);
  $self->_init(); # clear out old structure
  $reader->setReaderXDFObject($self);
  $self = $reader->parseFile($file);
  return $self;

}

#
# Protected/Private Methods 
#

# Write this Top-level structure and all the objects it owns to the supplied filehandle 
# in XML (XDF) format. The first argument is the name of the filehandle and is required. 
#
sub _basicXMLWriter {
  my ($self, $fileHandle, $indent, $dontCloseNode, $newNodeNameString, $noChildObjectNodeName) = @_;


  if(!defined $fileHandle) {
    error("Can't write out object, filehandle not defined.\n");
    return;
  }

  # To be valid XML, we always start an XML block with an
  # XML declaration (e.g. somehting like "<?xml standalone="no"?>").
  # Here we deal with  printing out XML Declaration && its attributes
  $self->_writeXMLHeader($fileHandle, $indent);

  $self->SUPER::_basicXMLWriter($fileHandle, $indent, $dontCloseNode, $newNodeNameString, $noChildObjectNodeName);

}

# /** Write the XML Declaration/Doctype to the indicated OutputStream.
#   */
sub _writeXMLHeader {
  my ($self, $fileHandle, $indent) = @_;

  my $xmlDecl = $self->getXMLDeclaration();
  my $docType = $self->getDocumentType();

  if (defined $xmlDecl) {
     $xmlDecl->toXMLFileHandle($fileHandle, $indent);
  }

  if (defined $docType) {
     $docType->toXMLFileHandle($fileHandle, $indent);
  }

}


# This is called when we cant find any defined method
# exists already. Used to handle general purpose set/get
# methods for our attributes (object fields).
sub AUTOLOAD {
  my ($self,$val) = @_;
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}

sub _init {
  my ($self) = @_;
  
  $self->SUPER::_init(); 

  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

}

1;


__END__

=head1 NAME

XDF::XDF - Perl Class for XDF

=head1 SYNOPSIS


    use XDF::XDF;
  
    my %attributes = ( 
                       'name' => 'A default name',
                       'paramList' => @paramObjRefList,
                       'arrayList' => @arrayRefList,
                     );

    # initialize new object w/ attribute hash
    my $xdfObj = XDF::XDF->new(%attributes);

    # overwrite the name attribute w/ new value, set the description 
    $xdfObj->setName("My XDF");
    $xdfObj->setDescription("This data was found under under a cabinet. It looks important.");

    # add an XDF::Array object to the XDF structure
    $xdfObj->addArray($arrayObj);

    ...

    # several ways to create an XDF from a file

    my $XDFObj = new XDF::XDF();

    # read method makes a call to XDF::Reader. %options
    # has same meaning here as for createXDFObjectfromFile 
    # method in XDF::Reader.

    my $newXDFObj = $XDFObj->loadFromXDFFile($file, \%options);

    # create a structure from a file (alternative method) 

    my $reader = new XDF::Reader();
    my $XDFObj2 = $reader->parseFile($file, \%options);



...

=head1 DESCRIPTION

 XDF is the eXtensible Data XDF, which is an XML format designed to contain n-dimensional scientific/mathematical data.  For more background information on XDF see the XDF homepage at  http://xml.gsfc.nasa.gov/XDF/XDF_home.html .     
    
 The XDF can hold both tagged and untagged data and may serve as a wrapper around many kinds of legacy data.     
    
 XDF::XDF inherits from XDF::Structure, and is itself the top level structure in any XDF object. 

XDF::XDF inherits class and attribute methods of L<XDF::BaseObjectWithXMLElements>, L<XDF::GenericObject>, L<XDF::BaseObject>, L<XDF::Structure>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::XDF.

=over 4

=item classXMLNodeName (EMPTY)

This method takes no arguments may not be changed. This method returns the class node name for XDF::XDF;  

=item getClassAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes for this class. This method takes no arguments may not be changed.  

=item getClassXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::XDF.

=over 4

=item getDocumentType (EMPTY)

 

=item setDocumentType ($docType)

 

=item getType (EMPTY)

 

=item setType ($value)

 

=item getXMLDeclaration (EMPTY)

 

=item setXMLDeclaration ($xmlDecl)

 

=item loadFromXDFFile ($file, $optionsHashRef)

Read in an XML file into this XDF object. The current XDF object, if it has any components, is overrided and lost.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::XDF inherits the following instance (object) methods of L<XDF::BaseObjectWithXMLElements>:
B<addXMLElement>, B<removeXMLElement>, B<getXMLElementList>, B<setXMLElementList>.

=back



=over 4

XDF::XDF inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::XDF inherits the following instance (object) methods of L<XDF::BaseObject>:
B<getXMLAttributes>, B<setXMLAttributes>, B<getXMLAttribute>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back



=over 4

XDF::XDF inherits the following instance (object) methods of L<XDF::Structure>:
B<getName>, B<setName>, B<getDescription>, B<setDescription>, B<getArrayList>, B<setArrayList>, B<getStructList>, B<setStructList>, B<getParamList>, B<setParamList>, B<getNoteList>, B<setNoteList>, B<addNote>, B<removeNote>, B<addParameter>, B<removeParameter>, B<addStructure>, B<removeStructure>, B<addArray>, B<removeArray>, B<addParamGroup>, B<removeParamGroup>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::Structure>, L<XDF::Log>, L<XDF::Reader>

=back

=head1 AUTHOR

    Brian Thomas  (brian.thomas@gsfc.nasa.gov)
    XML Group <http://xml.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut
