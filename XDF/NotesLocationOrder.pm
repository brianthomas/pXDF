
# $Id$

package XDF::NotesLocationOrder;

# /** COPYRIGHT
#    NotesLocationOrder.pm Copyright (C) 2000 Brian Thomas,
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


use XDF::BaseObject;
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

# CLASS DATA
my $Class_XML_Node_Name = "locationOrder";
my @Class_XML_Attributes = qw (
                             locationOrderList
                          );
my @Class_Attributes = ( );

# push in XML attributes to class attributes
push @Class_Attributes, @Class_XML_Attributes;

# add in super class attributes
push @Class_Attributes, @{&XDF::BaseObject::classAttributes};

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

sub classXMLNodeName { 
  $Class_XML_Node_Name; 
}

sub classAttributes { 
  \@Class_Attributes; 
}

#
# Get/Set Methods
#

# /** getLocationOrderList
# */
sub getLocationOrderList {
   my ($self) = @_;
   return $self->{LocationOrderList};
}

# /** setLocationOrderList
#     Set the locationOrderList attribute. 
# */
sub setLocationOrderList {
   my ($self, $value) = @_;
   $self->{LocationOrderList} = $value;
}

# /** getXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
sub getXMLAttributes {
  return \@Class_XML_Attributes;
}

#
# Other Public Methods
#

# /** addAxisIdToLocatorOrder
# */
sub addAxisIdToLocatorOrder {
   my ($self, $axisId) = @_;
   push @{$self->{LocationOrderList}}, $axisId;
}

#/** toXMLFileHandle
#    Special overloaded method inthis class to allow proper printing.
# */
sub toXMLFileHandle {
  my ($self, $fileHandle, $XMLDeclAttribs, $indent, $dontCloseNode,
      $newNodeNameString, $noChildObjectNodeName ) = @_;

  if(!defined $fileHandle) {
    carp "Can't write out object, filehandle not defined.\n";
    return;
  }

  my $Pretty_XDF_Output = $self->Pretty_XDF_Output;

  if (defined $XMLDeclAttribs) {
     $indent = ""; #$Pretty_XDF_Output_Indentation;
     # write the XML && DOCTYPE decl
     &_write_XML_decl_to_file_handle($fileHandle, $XMLDeclAttribs);
  }

  my $nodeNameString = $self->classXMLNodeName;
  $nodeNameString = $newNodeNameString if defined $newNodeNameString;

   my $nodename = $nodeNameString;
   # open this node, print its attributes
   if ($nodename) {
      print $fileHandle $indent if $Pretty_XDF_Output;
      print $fileHandle "<" . $nodename . ">";
      print $fileHandle "\n" if $Pretty_XDF_Output;
   }

  # print out index sub-nodes
  my $indexIndent = $indent . $self->Pretty_XDF_Output_Indentation;
  foreach my $indexNodeAxisIdRef (@{$self->{LocationOrderList}}) {
     print $fileHandle $indexIndent if $Pretty_XDF_Output;
     print $fileHandle "<index axisIdRef=\"",$indexNodeAxisIdRef,"\"/>";
     print $fileHandle "\n" if $Pretty_XDF_Output;
  }

  # close this node
  print $fileHandle "$indent" if $Pretty_XDF_Output;
  print $fileHandle "</". $nodename . ">";
  print $fileHandle "\n" if $Pretty_XDF_Output;

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

  $self->{LocationOrderList} = [];

}

# Modification History
#
# $Log$
# Revision 1.1  2000/12/14 22:12:15  thomas
# First version. -b.t.
#
#
#

1;


__END__

=head1 NAME

XDF::NotesLocationOrder - Perl Class for NotesLocationOrder

=head1 SYNOPSIS

...

=head1 DESCRIPTION

XDF::NotesLocationOrder inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::NotesLocationOrder.

=over 4

=item classXMLNodeName (EMPTY)

 

=item classAttributes (EMPTY)

 

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item # push in XML attributes to class attributes

 

=item push @Class_Attributes, @Class_XML_Attributes;

 

=item # add in super class attributes

 

=item push @Class_Attributes, @{&XDF::BaseObject::classAttributes};

 

=item # Initalization

 

=item # set up object attributes.

 

=item for my $attr ( @Class_Attributes ) { $field{$attr}++; }

 

=item sub classXMLNodeName { 

 

=item }

 

=item sub classAttributes { 

 

=item }

 

=item #

 

=item # Get/Set Methods

 

=item #

 

=item # /** getLocationOrderList

 

=item # */

 

=item sub getLocationOrderList {

 

=item return $self->{LocationOrderList};

 

=item }

 

=item # /** setLocationOrderList

 

=item #     Set the locationOrderList attribute. 

 

=item # */

 

=item sub setLocationOrderList {

 

=item $self->{LocationOrderList} = $value;

 

=item }

 

=item # /** getXMLAttributes

 

=item #      This method returns the XMLAttributes of this class. 

 

=item #  */

 

=item sub getXMLAttributes {

 

=item }

 

=item #

 

=item # Other Public Methods

 

=item #

 

=item # /** addAxisIdToLocatorOrder

 

=item # */

 

=item sub addAxisIdToLocatorOrder {

 

=item push @{$self->{LocationOrderList}}, $axisId;

 

=item }

 

=item #/** toXMLFileHandle

 

=item #    Special overloaded method inthis class to allow proper printing.

 

=item # */

 

=item sub toXMLFileHandle {

 

=item $newNodeNameString, $noChildObjectNodeName ) = @_;

 

=item if(!defined $fileHandle) {

 

=item carp "Can't write out object, filehandle not defined.\n";

 

=item return;

 

=item }

 

=item my $Pretty_XDF_Output = $self->Pretty_XDF_Output;

 

=item if (defined $XMLDeclAttribs) {

 

=item $indent = ""; #$Pretty_XDF_Output_Indentation;

 

=item # write the XML && DOCTYPE decl

 

=back

=head2 OTHER Methods

=over 4

=item getLocationOrderList (EMPTY)



=item setLocationOrderList ($value)

Set the locationOrderList attribute. 

=item getXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class. 

=item addAxisIdToLocatorOrder ($axisId)



=item toXMLFileHandle (EMPTY)

Special overloaded method inthis class to allow proper printing. 

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

XDF::NotesLocationOrder inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::NotesLocationOrder inherits the following instance methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLAttributes>, B<toXMLFile>.

=back

=back

=head1 SEE ALSO

L<XDF::BaseObject>

=back

=head1 AUTHOR



=cut
