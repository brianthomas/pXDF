
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
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::XMLDataIOStyle");

# CLASS DATA
my $Tag_To_Axis_Node_Name = "tagToAxis";
my @Class_Attributes = qw (
                             _tagHash
                          );

# add in super class attributes
push @Class_Attributes, @{&XDF::XMLDataIOStyle::classAttributes};

# Initalization - set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classAttributes
#  This method returns a list reference containing the names
#  of the class attributes of this class.
#  This method takes no arguments may not be changed. 
# */
sub classAttributes {
  \@Class_Attributes;
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

  $self->SUPER::_init(@_);
  $self->_tagHash({}); 

  return $self;

}

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

  # insert in hash table, return tag value
  return %{$self->_tagHash}->{"$axisId"} = $tag;

}

# /** _removeAxisTag
# Remove an axis tag from the tag hash. This should be PROTECTED
# and occur only when axis is being removed (ie available to array obj only).
# */
sub _removeAxisTag {
  my ($self, $axisId) = @_;
  delete %{$self->_tagHash}->{"$axisId"};
}

# /** getXMLDataIOStyleTags
# Return an axis ordered list (ARRAY REF) of tags to be used to write tagged data.
# */
sub getAxisTags {
  my ($self) = @_;

  my @tags;
  my $counter = $#{$self->_parentArray->axisList};
  foreach my $axisObj (@{$self->_parentArray->axisList}) {
    my $axisId = $axisObj->axisId;
    my $tag = 'd' . $counter--; # the default 
    # should it exist, we use whats in the tag hash.
    # otherwize we go w/ the default (as assigned above)
    $tag = %{$self->_tagHash}->{$axisId} if exists %{$self->_tagHash}->{$axisId};
    push @tags, $tag;
  }
  return @tags;

}

# /** toXMLFileHandle
# Write this object out to a filehandle in XDF formatted XML.
# */
sub toXMLFileHandle {
  my ($self, $fileHandle, $junk, $indent) = @_;

  my $niceOutput = $self->Pretty_XDF_Output;

  $indent = "" unless defined $indent;
  my $more_indent = $indent . $self->Pretty_XDF_Output_Indentation;

  print $fileHandle "$indent" if $niceOutput;

  # open the read block
  print $fileHandle "<" . $self->classXMLNodeName;

  # get attribute info
  my ($attribHashRef) = $self->_getXMLInfo();
  my %attribHash = %{$attribHashRef};

  # print out attributes
  foreach my $attrib (keys %attribHash) {
    my $val = $attribHash{$attrib};
    print $fileHandle " $attrib=\"",$val,"\"";
  }

  print $fileHandle ">";
  print $fileHandle "\n" if $niceOutput;

  my @tags = $self->getAxisTags;
  foreach my $axisObj ( @{$self->_parentArray->axisList} ) {
    my $axisId = $axisObj->axisId;
    my $tag = shift @tags;
    print $fileHandle "$more_indent" if $niceOutput;
    print $fileHandle "<$Tag_To_Axis_Node_Name axisIdRef=\"$axisId\" tag=\"" . $tag . "\" />";
    print $fileHandle "\n" if $niceOutput;
  }

  # close the read block
  print $fileHandle "$indent" if $niceOutput;
  print $fileHandle "</" . $self->classXMLNodeName . ">";
  print $fileHandle "\n" if $niceOutput;

}

# Modification History
#
# $Log$
# Revision 1.2  2000/10/16 17:37:21  thomas
# Changed over to BaseObject Class from Object Class.
# Added in History Modification section.
#
#
#

1;


__END__

=head1 NAME

XDF::TaggedXMLDataIOStyle - Perl Class for TaggedXMLDataIOStyle

=head1 SYNOPSIS

 


...

=head1 DESCRIPTION

 This class indicates how records are to be read/written  back out into XDF formatted XML files with tagged data sections. 

XDF::TaggedXMLDataIOStyle inherits class and attribute methods of L<XDF::BaseObject>, L<XDF::GenericObject>, L<XDF::XMLDataIOStyle>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::TaggedXMLDataIOStyle.

=over 4

=item classAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes of this class. This method takes no arguments may not be changed.  

=back

=head2 OTHER Methods

=over 4

=item setAxisTag ($axisId, $tag)

Set an association between an XDF data tag and axis reference. One day we will hopefully be able to support user defined tags, but for the time being you will have to stick to those specified by the XDF DTD(e.g. "d0","d1", ... "d8"). Note that choosing the wrong tag name will break the current XDF DTD, so go with the defaults (e.g. DONT use this method) if you dont know what you are doing here. 

=item getAxisTags (EMPTY)



=item toXMLFileHandle ($indent, $junk, $fileHandle)

Write this object out to a filehandle in XDF formatted XML. 

=back

=over 4

=head2 INHERITED Class Methods

A change in the value of these attributes will change the functioning of ALL instances of these objects that inherit from the indicated super class.


=over 4

The following class attribute methods are inherited from L<XDF::BaseObject>:
B<Pretty_XDF_Output>, B<Pretty_XDF_Output_Indentation>, B<DefaultDataArraySize>.

=back

=back

=over 4

=head2 INHERITED Other Methods



=over 4

XDF::TaggedXMLDataIOStyle inherits the following instance methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFile>.

=back



=over 4

XDF::TaggedXMLDataIOStyle inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>, B<setObjRef>.

=back

=back

=head1 SEE ALSO

L<XDF::XMLDataIOStyle>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center


=cut
