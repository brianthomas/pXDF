
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

use strict;
use integer;

use vars qw ($AUTOLOAD @ISA %field);

# inherits from XDF::Structure
@ISA = ("XDF::Structure");

# CLASS DATA
my $Class_XML_Node_Name = "XDF";
# NOTE: if you ADD/Change an attribute here, make sure it is
# properly re-inited in the _init method or you will be sorry!!!
my @Class_XML_Attributes = qw (
                              ); 
my @Class_Attributes = qw (
                          ); 

# add in class XML attributes
push @Class_Attributes, @Class_XML_Attributes;

# add in super class attributes
push @Class_Attributes, @{&XDF::Structure::classAttributes};

# add in super class XML attributes to our list 
push @Class_XML_Attributes, @{&XDF::Structure::getXMLAttributes};

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

# /** classAttributes
#  This method takes no arguments may not be changed. 
#  This method returns a list reference containing the names
#  of the class attributes for XDF::XDF; 
# */
sub classAttributes { 
  return \@Class_Attributes; 
}

# 
# SET/GET Methods
#

# /** getXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
sub getXMLAttributes { 
  return \@Class_XML_Attributes; 
}
  
#
# Other Public Methods 
#

# /** loadFromXDFFile
# Read in an XML file into this structure. The current structure, 
# if it has any components, is overrided and lost. 
# */
sub loadFromXDFFile {
  my ($self, $file, $optionsHashRef) = @_;

  my $reader = new XDF::Reader($optionsHashRef);
  $self->_init(); # clear out old structure
  $reader->setReaderXDFObject($self);
  $self = $reader->parseFile($file);
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

}

# Modification History
#
# $Log$
# Revision 1.1  2001/07/13 21:39:44  thomas
# Initial version
#
#
#

1;

