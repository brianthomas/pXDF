
package XDF::TaggedXMLDataIOStyle;

# /** COPYRIGHT
#    TaggedXMLDataIOStyle.pm Copyright (C) 2000 Brian Thomas,
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


# $Id$

# /** AUTHOR 
#    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
#    Astronomical Data Center <http://adc.gsfc.nasa.gov>
#    NASA/Goddard Space Flight Center
# */


# /** DESCRIPTION
# This class indicates how records are to be read/written 
# back out into XDF formatted XML files with tagged data sections.
# */

# /** SYNOPSIS
# 
# */


use XDF::XMLDataIOStyle;
use XDF::Constants;
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::XMLDataIOStyle");

# private
my %XDF_node_name = &XDF::Constants::XDF_NODE_NAMES;
my $Tag_To_Axis_Node_Name = $XDF_node_name{'tagToAxis'};

# CLASS DATA
my $Class_XML_Node_Name = "tagged";
my @Local_Class_XML_Attributes = ();
my @Local_Class_Attributes = qw (
                             _tagHash
                             _parentArray
                             _HAS_INIT_AXIS_TAGS
                          );
my @Class_Attributes;
my @Class_XML_Attributes;

# add in local class XML attributes
push @Local_Class_Attributes, @Local_Class_XML_Attributes;

# get super class attributes
push @Class_XML_Attributes, @{&XDF::Group::getClassXMLAttributes};
push @Class_Attributes, @{&XDF::Group::getClassAttributes};

# add in local to overall class
push @Class_XML_Attributes, @Local_Class_XML_Attributes;
push @Class_Attributes, @Class_XML_Attributes;

# Initalization - set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

sub classXMLNodeName {
  $Class_XML_Node_Name;
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
# Get/Set Methods
#

# /** setAxisTag
# Set an association between an XDF data tag and axis reference.
# One day we will hopefully be able to support user defined tags, but for the 
# time being you will have to stick to those specified by the XDF DTD
# (e.g. "d0","d1", ... "d8"). Note that choosing the wrong tag name will break 
# the current XDF DTD, so go with the defaults (e.g. DONT use this method) 
# if you dont know what you are doing here.
# */
sub setAxisTag {
  my ($self, $tag, $axisId ) = @_;

  unless (defined $tag  && defined $axisId ) {
    warn "Missing information: need tag AND axisId for addAxisTag. Ignoring request.\n";
    return;
  }

  $self->_initAxisTags();

  # insert in hash table, return tag value
  return %{$self->{_tagHash}}->{$axisId} = $tag;

}

sub getAxisTag {
  my ($self, $axisId ) = @_;
  $self->_initAxisTags();
  return %{$self->{_tagHash}}->{$axisId};
}

# /** getXMLDataIOStyleTags
# Return an axis ordered list (ARRAY REF) of tags to be used to write tagged data.
# */
sub getAxisTags {
  my ($self) = @_;

  $self->_initAxisTags();

  my @tags;
  foreach my $axisObj (@{$self->{_parentArray}->getAxisList()}) {
    my $axisId = $axisObj->getAxisId();
    push @tags, %{$self->{_tagHash}}->{$axisId};
  }
  return @tags;

}

#
# Private/Protected Methods
#

# Write this object out to a filehandle in XDF formatted XML.
sub _basicXMLWriter {
  my ($self, $fileHandle, $indent) = @_;

  my $spec = XDF::Specification->getInstance();
  my $niceOutput = $spec->isPrettyXDFOutput;

  $indent = "" unless defined $indent;
  my $more_indent = $spec->getPrettyXDFOutputIndentation;
  my $next_indent = $indent . $more_indent; 
  my $next_indent2 = $next_indent . $more_indent; 

  # open the read block
  print $fileHandle $indent if $niceOutput;
  print $fileHandle "<" . $self->SUPER::classXMLNodeName;

  # get attribute info
  my ($attribListRef) = $self->_getXMLInfo();
  # print attributes
  $self->_printAttributes($fileHandle,$attribListRef); 

  print $fileHandle ">";
  print $fileHandle "\n" if $niceOutput;

  print $fileHandle $next_indent if $niceOutput;
  print $fileHandle "<" . $self->classXMLNodeName . ">";
  print $fileHandle "\n" if $niceOutput;

  my @tags = $self->getAxisTags;
  #foreach my $axisObj ( @{$self->{_parentArray}->getAxisList()} ) {
  foreach my $axisObj ( @{$self->getWriteAxisOrderList()} ) {
    my $axisId = $axisObj->getAxisId();
    my $tag = shift @tags;
    print $fileHandle $next_indent2 if $niceOutput;
    # next 5 lines: have to break up printing of '"' or toXMLString will behave badly
    print $fileHandle "<$Tag_To_Axis_Node_Name axisIdRef=\"";
    print $fileHandle $axisId . "\"";
    print $fileHandle " tag=\"";
    print $fileHandle $tag;
    print $fileHandle "\"/>";
    print $fileHandle "\n" if $niceOutput;
  }

  # close the read block
  print $fileHandle $next_indent if $niceOutput;
  print $fileHandle "</" . $self->classXMLNodeName . ">";
  print $fileHandle "\n" if $niceOutput;
  
  print $fileHandle $indent if $niceOutput;
  print $fileHandle "</" . $self->SUPER::classXMLNodeName . ">";

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

  $self->{_tagHash} = {};

  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

  return $self;

}

sub _initAxisTags {
  my ($self) = @_;

   return if $self->{_HAS_INIT_AXIS_TAGS};
   return unless defined $self->{_parentArray};

   my $counter = $#{$self->{_parentArray}->getAxisList()};
   foreach my $axisObj (@{$self->{_parentArray}->getAxisList()}) {
     my $axisId = $axisObj->getAxisId();
     my $tag = 'd' . $counter--; # the default 
     %{$self->{_tagHash}}->{$axisId} = $tag;
   }

   $self->{_HAS_INIT_AXIS_TAGS} = 1;
}

# /** _removeAxisTag
# Remove an axis tag from the tag hash. This should be PROTECTED
# and occur only when axis is being removed (ie available to array obj only).
# */
sub _removeAxisTag {
  my ($self, $axisId) = @_;
  delete %{$self->{_tagHash}}->{"$axisId"};
}

1;


