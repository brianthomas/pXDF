
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
#    Brian Thomas  (brian.thomas@gsfc.nasa.gov)
#    XML Group <http://xml.gsfc.nasa.gov>
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
use XDF::Log;

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
my @Local_Class_XML_Attributes = ( );
my @Local_Class_Attributes = qw (
                             outputStyle
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

#/** getOutputStyle
#   Get the type of tagged output which is desired
#*/
sub getOutputStyle {
  my ($self) = @_;
  return $self->{outputStyle};
}

# /** setOutputType
#   Get the type of tagged output which is desired. Certain options are
#   only posssible in correct combination with certain axes types. 
# */
sub setOutputStyle {
  my ($self, $value) = @_;

   unless (&XDF::Utility::isValidTaggedOutputStyle($value, $self->{_parentArray})) {
     error("Cant set tagged datastyle to $value, not allowed as object and parent array are currently configured, ignoring \n");
     return;
   }

   $self->{outputStyle} = $value;
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

  $self->_initAxisTags();

  # insert in hash table
 # %{$self->{_tagHash}}->{$axisId} = $tag;
  $self->{_tagHash}->{$axisId} = $tag;

   foreach my $axisObj (@{$self->{_parentArray}->getAxisList()}) {
     my $axisId = $axisObj->getAxisId();
    # my $value = %{$self->{_tagHash}}->{$axisId};
     my $value = $self->{_tagHash}->{$axisId};
   }


  my $axisObj = &_find_axis_in_array($self->{_parentArray}, $axisId);
  #%{$self->{_axisHash}}->{$tag} = $axisObj;
  $self->{_axisHash}->{$tag} = $axisObj;

  # update writeAxis Order List;
  $self->_updateWriteAxisOrder();

}

sub getAxisTag {
  my ($self, $axisId ) = @_;
  $self->_initAxisTags();
  #return %{$self->{_tagHash}}->{$axisId};
  return $self->{_tagHash}->{$axisId};

}

# /** getAxisTags
# Return an axis ordered list (ARRAY REF) of tags to be used to write tagged data.
# */
sub getAxisTags {
  my ($self) = @_;

  $self->_initAxisTags();

  $self->_updateWriteAxisOrder();

  my @tags;
 # foreach my $axisObj (@{$self->{_parentArray}->getAxisList()}) {
  foreach my $axisObj (@{$self->{writeAxisOrderList}}) {
    my $axisId = $axisObj->getAxisId();
    #push @tags, %{$self->{_tagHash}}->{$axisId};
    push @tags, $self->{_tagHash}->{$axisId};
  }
  return \@tags;

}

#
# Private/Protected Methods
#

sub _updateWriteAxisOrder 
{
  my ($self) = @_;

  my @axesOrder;
  my %tagHash = %{$self->{_axisHash}}; 
  foreach my $tag (reverse sort keys %tagHash) 
  {
     push @axesOrder, $tagHash{$tag};
  }

  $self->{writeAxisOrderList} = \@axesOrder;

}

# Write this object out to a filehandle in XDF formatted XML.
sub _basicXMLWriter {
  my ($self, $fileHandle, $indent) = @_;

  # first order of business: is this the simple style? -- then dont print node! 
  my $parentArray =$self->{_parentArray};
  if (ref $parentArray) {
     return if ($parentArray->_isSimpleDataIOStyle);
  }

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

  #foreach my $axisObj ( @{$self->{_parentArray}->getAxisList()} ) {
  foreach my $axisObj ( @{$self->getWriteAxisOrderList()} ) {
    my $axisId = $axisObj->getAxisId();
    my $tag = $self->getAxisTag($axisId);
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

sub _find_axis_in_array { # STATIC
  my ($arrayObj, $axisId) = @_;
  foreach my $axisObj (@{$arrayObj->getAxisList()}) 
  {
     if ($axisObj->getAxisId eq $axisId) {
         return $axisObj;
     }
  }
}

sub _init {
  my ($self) = @_;

  $self->SUPER::_init();

  $self->{outputStyle} = &XDF::Constants::TAGGED_DEFAULT_OUTPUTSTYLE;
  $self->{_tagHash} = {};
  $self->{_axisHash} = {};

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
     #%{$self->{_tagHash}}->{$axisId} = $tag;
     #%{$self->{_axisHash}}->{$tag} = $axisObj;
     $self->{_tagHash}->{$axisId} = $tag;
     $self->{_axisHash}->{$tag} = $axisObj;
   }

   $self->{_HAS_INIT_AXIS_TAGS} = 1;
}

# /** _removeAxisTag
# Remove an axis tag from the tag hash. This should be PROTECTED
# and occur only when axis is being removed (ie available to array obj only).
# */
sub _removeAxisTag {
  my ($self, $axisId) = @_;
  #delete %{$self->{_tagHash}}->{"$axisId"};
  delete $self->{_tagHash}->{"$axisId"};
}


1;


__END__

=head1 NAME

XDF::TaggedXMLDataIOStyle - Perl Class for TaggedXMLDataIOStyle

=head1 SYNOPSIS

 


...

=head1 DESCRIPTION

 This class indicates how records are to be read/written  back out into XDF formatted XML files with tagged data sections. 

XDF::TaggedXMLDataIOStyle inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>, L<XDF::XMLDataIOStyle>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::TaggedXMLDataIOStyle.

=over 4

=item classXMLNodeName (EMPTY)

 

=item getClassAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes for this class. This method takes no arguments may not be changed.  

=item getClassXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::TaggedXMLDataIOStyle.

=over 4

=item getOutputStyle (EMPTY)

Get the type of tagged output which is desired 

=item setOutputStyle ($value)

 

=item setAxisTag ($tag, $axisId)

Set an association between an XDF data tag and axis reference. One day we will hopefully be able to support user defined tags, but for the time being you will have to stick to those specified by the XDF DTD(e.g. "d0","d1", ... "d8"). Note that choosing the wrong tag name will break the current XDF DTD, so go with the defaults (e.g. DONT use this method) if you dont know what you are doing here.  

=item getAxisTag ($axisId)

 

=item getAxisTags (EMPTY)

Return an axis ordered list (ARRAY REF) of tags to be used to write tagged data.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::TaggedXMLDataIOStyle inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::TaggedXMLDataIOStyle inherits the following instance (object) methods of L<XDF::BaseObject>:
B<getXMLAttributes>, B<setXMLAttributes>, B<getXMLAttribute>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLString>, B<toXMLFile>.

=back



=over 4

XDF::TaggedXMLDataIOStyle inherits the following instance (object) methods of L<XDF::XMLDataIOStyle>:
B<untaggedInstructionNodeName>, B<getDataStyleId{>, B<setDataStyleId>, B<getDataStyleIdRef>, B<setDataStyleIdRef>, B<getEncoding>, B<setEncoding>, B<getEndian{>, B<setEndian>, B<getWriteAxisOrderList>, B<setWriteAxisOrderList>, B<setParentArray>, B<toXMLFileHandle>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::XMLDataIOStyle>, L<XDF::Constants>, L<XDF::Log>

=back

=head1 AUTHOR

    Brian Thomas  (brian.thomas@gsfc.nasa.gov)
    XML Group <http://xml.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut
