
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

my $Def_Encoding           = 'ISO-8859-1';
my $Def_Endian             = 'BigEndian'; 

my $Untagged_Instruction_Node_Name = "for";

my $Class_XML_Node_Name = "read";
my @Class_Attributes = qw (
                             readId
                             readIdRef
                             encoding
                             endian
                             _parentArray
                          );

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

# This is called when we cant find any defined method
# exists already. Used to handle general purpose set/get
# methods for our attributes (object fields).
sub AUTOLOAD {
  my ($self,$val) = @_;
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}

sub _init { 
  my ($self) = @_; 

  $self->encoding($Def_Encoding);
  $self->endian($Def_Endian);

  return $self;

}

# this is for untagged styles. Is overridden by 
# local method in TaggedXMLDataIOStyleObject.
#sub _write_untagged_read {
sub toXMLFileHandle {
  my ($self, $fileHandle, $junk, $indent) = @_;

  my $niceOutput = $self->Pretty_XDF_Output;

  $indent = "" unless defined $indent;
  my $more_indent = $self->Pretty_XDF_Output_Indentation;

  print $fileHandle "$indent" if $niceOutput;

  # open the read block
  print $fileHandle "<" . $self->classXMLNodeName . ">";
  print $fileHandle "\n" if $niceOutput;

  my @indent;
  my $next_indent = $indent . $more_indent;
  foreach my $axisObj (@{$self->_parentArray->axisList}) {
    my $axisId = $axisObj->axisId;
    push @indent, $next_indent;
    print $fileHandle "$next_indent" if $niceOutput;
    print $fileHandle "<$Untagged_Instruction_Node_Name axisIdRef=\"$axisId\" >";
    print $fileHandle "\n" if $niceOutput;
    $next_indent .= $more_indent;
  }

  # now dump ourselves here using the trusty generic method
  $self->SUPER::toXMLFileHandle($fileHandle, undef, $next_indent);

  #close the instructions
  for (reverse @indent) {
    print $fileHandle "$_" if $niceOutput;
    print $fileHandle "</$Untagged_Instruction_Node_Name>";
    print $fileHandle "\n" if $niceOutput;
  }

  # close the read block
  print $fileHandle "$indent" if $niceOutput;
  print $fileHandle "</" . $self->classXMLNodeName . ">";
  print $fileHandle "\n" if $niceOutput;

}

# /** getReadAxisOrder
# Retrieve the order in which the axis will be read in/written out.
# from the data cube.
# Returns a scalar ARRAY reference of axisId values.
# */
#sub getReadAxisOrder { 
#  my ($self) = @_; 
#  my @readList;
#  foreach my $axisObj (@{$self->_parentArray->axisList}) {
#    push @readList, $axisObj->axisId;
#  }
#  return \@readList;
#}

# Modification History
#
# $Log$
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


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::XMLDataIOStyle.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name of this class. This method takes no arguments may not be changed.  

=item classAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes of this class. This method takes no arguments may not be changed.  

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item readId

 

=item readIdRef

 

=item encoding

What encoding to use when writing out XML data.  

=item endian

What endian to use when writing out binary data.  

=back

=head2 OTHER Methods

=over 4

=item toXMLFileHandle ($indent, $junk, $fileHandle)



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

XDF::XMLDataIOStyle inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>, B<setObjRef>.

=back



=over 4

XDF::XMLDataIOStyle inherits the following instance methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFile>.

=back

=back

=head1 SEE ALSO

L< XDF::TaggedXMLDataIOStyle>, L< XDF::FormattedXMLDataIOStyle>, L< XDF::DelimitedXMLDataIOStyle>, L<XDF::BaseObject>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center


=cut
