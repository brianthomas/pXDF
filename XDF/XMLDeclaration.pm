
# $Id$

package XDF::XMLDeclaration;

# /** COPYRIGHT
#    XMLDeclaration.pm Copyright (C) 2002 Brian Thomas,
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
# The XMLDeclaration class is nothing more than a simple object that holds information
#  concerning the xml declaration of the XDF (root) object.
# */

#/** SYNOPSIS
#
# */

use Carp;

use XDF::BaseObject;
use XDF::Utility;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

@ISA = ("XDF::BaseObject");

# CLASS DATA
my $Class_XML_Node_Name = '?xml'; 
my $XML_VERSION = '1.0';
my @Local_Class_Attributes = qw (
                          );

my @Local_Class_XML_Attributes = qw (
                             standalone
                             version
                          );

my @Class_Attributes;
my @Class_XML_Attributes;

# add in local class XML attributes
push @Local_Class_Attributes, @Local_Class_XML_Attributes;

# get super class attributes
#push @Class_XML_Attributes, @{&XDF::GenericObject::getClassXMLAttributes};
push @Class_Attributes, @{&XDF::GenericObject::getClassAttributes};

# add in local to overall class
push @Class_XML_Attributes, @Local_Class_XML_Attributes;
push @Class_Attributes, @Class_XML_Attributes;

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

sub classXMLNodeName {
  $Class_XML_Node_Name;
}

# /** getClassAttributes
#  This method returns a list reference containing the names
#  of the class attributes of XDF::FloatDataFormat. 
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

# This is called when we cant find any defined method
# exists already. Used to handle general purpose set/get
# methods for our attributes (object fields).
sub AUTOLOAD {
  my ($self,$val) = @_;
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}

# 
# Get/Set Methods
#

# /** getVersion
# get the version of XML we are planning to use.
# */
sub getVersion {
   my ($self) = @_;
   return $XML_VERSION;
}

# /** getStandalone
#  */
sub getStandalone {
   my ($self) = @_;
   return $self->{standalone};
}

# /** setStandalone
#     Set the standalone attribute. 
#  */
sub setStandalone {
   my ($self, $value) = @_;
   if (&XDF::Utility::isValidXMLStandalone($value)) {
     $self->{standalone} = $value;
   } else {
     warn "Value:$value is not a valid XMLDeclaration standalone value. Ignoring set request.\n";
   }
}

#
# Private
# 

sub _init {
  my ($self) = @_;
  
  $self->SUPER::_init();
    
  # set defaults
  $self->{version} = $self->getVersion();
  
  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

}

sub _basicXMLWriter {
  my ($self, $fileHandle, $indent, $dontCloseNode,
      $newNodeNameString, $noChildObjectNodeName) = @_;

  if(!defined $fileHandle) {
    carp "Can't write out object, filehandle not defined.\n";
    return;
  }

  $indent = "" unless defined $indent;

  my $spec = XDF::Specification->getInstance();
  my $niceOutput = $spec->isPrettyXDFOutput;
  my $more_indent = $spec->getPrettyXDFOutputIndentation;

  print $fileHandle $indent if $niceOutput;

  my $version = $self->getVersion();
  my $standalone = $self->getStandalone();

  print $fileHandle "<". $self->classXMLNodeName;

  print $fileHandle " version=\"$version\"" if (defined $version);
  print $fileHandle " standalone=\"$standalone\"" if (defined $standalone);

  print $fileHandle "?>";

  return $self->classXMLNodeName;

}

1;

