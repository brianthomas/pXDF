
package XDF::XMLDataIOStyle;

# $Id$

# /** COPYRIGHT
#    XMLDataIOStyle.pm Copyright (C) 2000 Brian Thomas,
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
# This abstract class indicates how records are to be read/written 
# back out into XDF formatted XML files.
# */

# /** SYNOPSIS
# 
# */

# /** SEE ALSO
# XDF::TaggedXMLDataIOStyle
# XDF::FormattedXMLDataIOStyle
# XDF::DelimitedXMLDataIOStyle
# */

# _parentArray is private so that they dont get 
# written out when we use toXML* methods on this class.

use XDF::BaseObject;
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

# CLASS DATA
# /** readId
# 
# */
# /** readIdRef 
# 
# */
# /** encoding
# What encoding to use when writing out XML data.
# */
# /** endian
# What endian to use when writing out binary data.
# */

my $Big_Endian             = 'BigEndian'; 
my $Little_Endian             = 'LittleEndian'; 

my $Def_Encoding           = 'ISO-8859-1';
my $Def_Endian             = $Big_Endian;

my $Untagged_Instruction_Node_Name = "for";

my $Class_XML_Node_Name = "read";
my @Class_XML_Attributes = qw (
                             readId
                             readIdRef
                             encoding
                             endian
                          );
my @Class_Attributes = qw (
                             _writeAxisOrderList
                             _parentArray
                          );

# add in class XML attributes
push @Class_Attributes, @Class_XML_Attributes;

# add in super class attributes
push @Class_Attributes, @{&XDF::BaseObject::classAttributes};

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classXMLNodeName
# This method returns the class node name of this class.
# This method takes no arguments may not be changed. 
# */
sub classXMLNodeName {
  $Class_XML_Node_Name;
}

# /** classAttributes
#  This method returns a list reference containing the names
#  of the class attributes of this class.
#  This method takes no arguments may not be changed. 
# */
sub classAttributes {
  \@Class_Attributes;
}

sub untaggedInstructionNodeName { 
  return $Untagged_Instruction_Node_Name; 
}

#
# GET/SET Methods
#

# /** getReadId
# */
sub getReadId{
   my ($self) = @_;
   return $self->{ReadId};
}

# /** setReadId
#     Set the readId attribute. 
# */
sub setReadId {
   my ($self, $value) = @_;
   $self->{ReadId} = $value;
}

# /** getReadIdRef 
# */
sub getReadIdRef {
   my ($self) = @_;
   return $self->{ReadIdRef};
}

# /** setReadIdRef 
#     Set the readIdRef attribute. 
# */
sub setReadIdRef {
   my ($self, $value) = @_;
   $self->{ReadIdRef} = $value;
}

# /** getEncoding
# */
sub getEncoding{
   my ($self) = @_;
   return $self->{Encoding};
}

# /** setEncoding
#     Set the encoding attribute. 
# */
sub setEncoding {
   my ($self, $value) = @_;

   carp "Cant set encoding to $value, not allowed \n"
      unless (&XDF::Utility::isValidIOEncoding($value));

   $self->{Encoding} = $value;
}

# /** getEndian
# */
sub getEndian{
   my ($self) = @_;
   return $self->{Endian};
}

# /** setEndian
#     Set the endian attribute. 
# */
sub setEndian {
   my ($self, $value) = @_;

   carp "Cant set endian to $value, not allowed \n"
      unless (&XDF::Utility::isValidEndian($value));

   $self->{Endian} = $value;
}

#/** getWriteAxisOrderList 
# This method sets the ordering of the fastest to slowest axis for
# writing out data. The default is to use the parent array
# axisList ordering (field axis first, if it exists, followed by all
# other axes in the order in which they were declared).
# */
sub getWriteAxisOrderList {
  my ($self) =@_;

  my $list_ref = $self->{_writeAxisOrderList};
  $list_ref = $self->{_parentArray}->getAxisList() unless
      defined $list_ref || !defined $self->{_parentArray};
  return $list_ref;
}

#/** setWriteAxisOrderList 
# This method sets the ordering of the fastest to slowest axis for
# writing out formatted data. The fastest axis is the last in
# the array. Setting the writeAxisOrderList will effect how the document
# is written out. For the Formatted and Delimited styles, this means how
# the 'for' nodes will appear. There is no effect on Tagged data (at this
# time) for setting the axis order list in any different way.
#*/
sub setWriteAxisOrderList {
  my ($self, $arrayRefValue) = @_;

  if (ref($self) eq 'XDF::TaggedXMLDataIOStyle') {
    warn "setWriteAxisOrderList has no effect currently for TaggedXMLDataIOStyle, Ignoring\n";
    return;
  }

  # you must do it this way, or when the arrayRef changes it changes us here!
  my @list = @{$arrayRefValue};
  $self->{_writeAxisOrderList} = \@list;
}


# /** getXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
sub getXMLAttributes {
  return \@Class_XML_Attributes;
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

  $self->{Encoding} = $Def_Encoding;
  $self->{Endian} = $Def_Endian;

  return $self;

}

# Modification History
#
# $Log$
# Revision 1.12  2001/03/26 22:26:03  thomas
# changed name of writeAxisOrderList to be 'private'
#
# Revision 1.11  2001/03/26 18:17:09  thomas
# dont allow setWriteAxisOrderList to proceed if the object
# is the tagged style.
#
# Revision 1.10  2001/03/26 18:12:57  thomas
# moved setWriteAxisORder list and getWriteAxisOrderList
# up to here from FormattedXMLDataIOStyle and DelimitedXMLDataIOStyle.
#
# Revision 1.9  2001/03/16 19:54:57  thomas
# Documentation updated and improved, re-ran makeDoc on file.
#
# Revision 1.8  2001/03/14 21:32:35  thomas
# Updated perldoc section using new version of
# makeDoc.pl.
#
# Revision 1.7  2001/03/09 21:44:57  thomas
# removed getBigEndian, getLittleEndian methods.
# Right way to do it is via Constants class, as it
# now is done. Added in new utility class checks
# for encoding and endian attributes.
#
# Revision 1.6  2001/03/07 23:14:25  thomas
# added class methods of "getLittleEndian" and "getBigEndian" so
# the values could be determined with/out DTD.
#
# Revision 1.5  2000/12/15 22:11:59  thomas
# Regenerated perlDoc section in files. -b.t.
#
# Revision 1.4  2000/12/14 22:11:27  thomas
# Big changes to the API. get/set methods, added Href/Entity stuff, deep cloning,
# added Href, Notes, NotesLocationOrder nodes/classes. Ripped out _enlarge_array
# from DataCube (not needed) and fixed problems outputing delimited/formatted
# read nodes. -b.t.
#
# Revision 1.3  2000/12/01 20:03:38  thomas
# Brought Pod docmentation up to date. Bumped up version
# number. -b.t.
#
# Revision 1.2  2000/10/16 17:37:21  thomas
# Changed over to BaseObject Class from Object Class.
# Added in History Modification section.
#
#
#

1;


__END__

=head1 NAME

XDF::XMLDataIOStyle - Perl Class for XMLDataIOStyle

=head1 SYNOPSIS

 


...

=head1 DESCRIPTION

 This abstract class indicates how records are to be read/written  back out into XDF formatted XML files. 

XDF::XMLDataIOStyle inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::XMLDataIOStyle.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name of this class. This method takes no arguments may not be changed.  

=item classAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes of this class. This method takes no arguments may not be changed.  

=item untaggedInstructionNodeName (EMPTY)

 

=item getXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::XMLDataIOStyle.

=over 4

=item getReadId{ (EMPTY)

 

=item setReadId ($value)

Set the readId attribute.  

=item getReadIdRef (EMPTY)

 

=item setReadIdRef ($value)

Set the readIdRef attribute.  

=item getEncoding{ (EMPTY)

 

=item setEncoding ($value)

Set the encoding attribute.  

=item getEndian{ (EMPTY)

 

=item setEndian ($value)

Set the endian attribute.  

=item getWriteAxisOrderList (EMPTY)

This method sets the ordering of the fastest to slowest axis forwriting out data. The default is to use the parent arrayaxisList ordering (field axis first, if it exists, followed by allother axes in the order in which they were declared).  

=item setWriteAxisOrderList ($arrayRefValue)

This method sets the ordering of the fastest to slowest axis forwriting out formatted data. The fastest axis is the last inthe array. Setting the writeAxisOrderList will effect how the documentis written out. For the Formatted and Delimited styles, this means howthe 'for' nodes will appear. There is no effect on Tagged data (at thistime) for setting the axis order list in any different way.  

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

XDF::XMLDataIOStyle inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::XMLDataIOStyle inherits the following instance (object) methods of L<XDF::BaseObject>:
B<addXMLElement>, B<removeXMLElement>, B<getXMLElementList>, B<setXMLElementList>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLAttributes>, B<setXMLNotationHash>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L< XDF::TaggedXMLDataIOStyle>, L< XDF::FormattedXMLDataIOStyle>, L< XDF::DelimitedXMLDataIOStyle>, L<XDF::BaseObject>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut
