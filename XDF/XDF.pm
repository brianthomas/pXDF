
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
#    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
#    Astronomical Data Center <http://adc.gsfc.nasa.gov>
#    NASA/Goddard Space Flight Center
# */


# /** DESCRIPTION
# XDF is the eXtensible Data XDF, which is an XML format
# designed to contain n-dimensional scientific/mathematical data.
# For more background information on XDF see the XDF homepage at 
# http://xml.gsfc.nasa.gov/XDF/XDF_home.html.
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

use Carp;

use XDF::Structure;
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

#/** toXMLFileHandle
# Write this structure and all the objects it owns to the supplied filehandle 
# in XML (XDF) format. The first argument is the name of the filehandle and is required. 
#@
# The second, optional, argument indicates whether/how to write out the XML declaration
# and DOCTYPE statement at the beginning of the file stream. This second argument may 
# either be a string or hash table. As a string is means simply to write the XML declaration 
# and DOCTYPE. As a hash table, the attributes of the XML declaration are arranged 
# in attribute/value pairs, e.g.
# 
#  %XMLDeclAttribs = ( 'version' => "1.0",
#                      'standalone => 'no',
#                    );
#
#*/
sub toXMLFileHandle {
  my ($self, $fileHandle, $XMLDeclAttribs, $indent, $dontCloseNode, $newNodeNameString, $noChildObjectNodeName, $isRootNode  ) = @_;

  if(!defined $fileHandle) {
    carp "Can't write out object, filehandle not defined.\n";
    return;
  }

  my $spec = XDF::Specification->getInstance();

  if (defined $XMLDeclAttribs) {
     $indent = "";
     # write the XML && DOCTYPE decl
     $self->_write_XML_decl_to_file_handle($fileHandle, $XMLDeclAttribs, $spec);
  }

  $self->SUPER::toXMLFileHandle($fileHandle, $XMLDeclAttribs, $indent, $dontCloseNode, $newNodeNameString, $noChildObjectNodeName, $isRootNode);

}


#
# Private Methods 
#

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

sub _write_XML_decl_to_file_handle {
  my ($self, $fileHandle, $XMLDeclAttribs, $spec) = @_;

# write the XML && DOCTYPE decl
  if (defined $XMLDeclAttribs) {
    print $fileHandle "<?xml ";
    if (ref $XMLDeclAttribs) {

      while (my ($attrib, $value) = each (%{$XMLDeclAttribs}) ) {
        print $fileHandle " $attrib=\"",$value,"\"";
      }
      #foreach my $attrib (keys %{$XMLDeclAttribs}) {
      #  print $fileHandle " $attrib=\"",%{$XMLDeclAttribs}->{$attrib},"\"";
      #}
    } else {
      print $fileHandle "version =\"".$spec->getXMLSpecVersion."\"";
    }
    print $fileHandle "?>\n";
    my $root_name = $spec->getXDFRootNodeName;
    my $dtd_name = $spec->getXDFDTDName;
    print $fileHandle "<!DOCTYPE $root_name SYSTEM \"$dtd_name\"";

    # find all XML Href entities
    my @HrefList = @{$self->_find_All_child_Href_Objects()};
    my $entityString;
    for (@HrefList) {
       $entityString .= "  <!ENTITY " . $_->getName();
       $entityString .= " BASE \"" . $_->getBase() . "\"" if defined $_->getBase();
       $entityString .= " PUBLIC \"" . $_->getPubId() . "\"" if defined $_->getPubId();
       $entityString .= " SYSTEM \"" . $_->getSysId() . "\"" if defined $_->getSysId();
       $entityString .= " NDATA " . $_->getNdata() if defined $_->getNdata();
       $entityString .= ">\n";
    }

    # find all XML notation
    my $notationString;
    while (my ($name, $notHashRef) = each (%{$spec->getXMLNotationHash})) {
       my %notationHash = %{$notHashRef};
       $notationString .= "  <!NOTATION $name";
       $notationString .= " BASE \"" . $notationHash{'base'} . "\"" if defined $notationHash{'base'};
       $notationString .= " PUBLIC \"" . $notationHash{'pubid'}. "\"" if defined $notationHash{'pubid'};
       $notationString .= " SYSTEM \"" . $notationHash{'sysid'}. "\"" if defined $notationHash{'sysid'};
       $notationString .= ">\n";
    }

    if (defined $entityString or defined $notationString) {
      print $fileHandle " [\n";
      print $fileHandle "$entityString" if (defined $entityString);
      print $fileHandle "$notationString" if (defined $notationString);
      print $fileHandle "]";
    }
    print $fileHandle ">\n";

  }

}


# Modification History
#
# $Log$
# Revision 1.6  2001/08/13 20:56:37  thomas
# updated documentation via utils/makeDoc.pl for the release.
#
# Revision 1.5  2001/08/13 19:54:43  thomas
# bug fix: use only local XML attributes for appendAttribs in _init
#
# Revision 1.4  2001/08/10 16:29:28  thomas
# Fixed inheritance bug, was repeating Structure attribs 2X.
#
# Revision 1.3  2001/07/23 15:58:07  thomas
# added ability to add arbitary XML attribute to class.
# getXMLattributes now an instance method, we
# have old class method now called getClassXMLAttributes.
#
# Revision 1.2  2001/07/17 17:39:45  thomas
# fine tuning to loadFromXDFFile method. Improved
# documentation on toXMLFileHandle method.
#
# Revision 1.1  2001/07/13 21:39:44  thomas
# Initial version
#
#
#

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

 XDF is the eXtensible Data XDF, which is an XML format designed to contain n-dimensional scientific/mathematical data.  For more background information on XDF see the XDF homepage at  http://xml.gsfc.nasa.gov/XDF/XDF_home.html.     
    
 The XDF can hold both tagged and untagged data and may serve as a wrapper around many kinds of legacy data.     
    
 XDF::XDF inherits from XDF::Structure, and is itself the top level structure in any XDF object. 

XDF::XDF inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>, L<XDF::BaseObjectWithXMLElements>, L<XDF::Structure>.


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

=item getType (EMPTY)

 

=item setType ($value)

 

=item loadFromXDFFile ($file, $optionsHashRef)

Read in an XML file into this XDF object. The current XDF object, if it has any components, is overrided and lost.  

=item toXMLFileHandle ($fileHandle, $XMLDeclAttribs, $indent, $dontCloseNode, $newNodeNameString, $noChildObjectNodeName, $isRootNode)

Write this structure and all the objects it owns to the supplied filehandle in XML (XDF) format. The first argument is the name of the filehandle and is required. @The second, optional, argument indicates whether/how to write out the XML declarationand DOCTYPE statement at the beginning of the file stream. This second argument may either be a string or hash table. As a string is means simply to write the XML declaration and DOCTYPE. As a hash table, the attributes of the XML declaration are arranged in attribute/value pairs, e.g. %XMLDeclAttribs = ( 'version' => "1.0",'standalone => 'no',); 

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::XDF inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::XDF inherits the following instance (object) methods of L<XDF::BaseObject>:
B<getXMLAttributes>, B<setXMLAttributes>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLString>, B<toXMLFile>.

=back



=over 4

XDF::XDF inherits the following instance (object) methods of L<XDF::BaseObjectWithXMLElements>:
B<addXMLElement>, B<removeXMLElement>, B<getXMLElementList>, B<setXMLElementList>.

=back



=over 4

XDF::XDF inherits the following instance (object) methods of L<XDF::Structure>:
B<getName>, B<setName>, B<getDescription>, B<setDescription>, B<getArrayList>, B<setArrayList>, B<getStructList>, B<setStructList>, B<getParamList>, B<setParamList>, B<getNoteList>, B<setNoteList>, B<addNote>, B<removeNote>, B<addParameter>, B<removeParameter>, B<addStructure>, B<removeStructure>, B<addArray>, B<removeArray>, B<addParamGroup>, B<removeParamGroup>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::Structure>, L<XDF::Reader>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut
