
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
   my ($self, $arrayRefValue) = @_;
   # you must do it this way, or when the arrayRef changes it changes us here!
   my @list = @{$arrayRefValue};
   $self->{LocationOrderList} = \@list;
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
     $self->_write_XML_decl_to_file_handle($fileHandle, $XMLDeclAttribs);
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
    # next 3 lines: have to break up printing of '"' or toXMLString will behave badly
     print $fileHandle "<index axisIdRef=\"";
     print $fileHandle $indexNodeAxisIdRef;
     print $fileHandle "\">";
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
# Revision 1.5  2001/03/23 20:38:40  thomas
# broke up printing of attributes in toXMLFileHandle
# so that toXMLString will work properly.
#
# Revision 1.4  2001/03/16 19:54:57  thomas
# Documentation updated and improved, re-ran makeDoc on file.
#
# Revision 1.3  2001/03/14 21:32:34  thomas
# Updated perldoc section using new version of
# makeDoc.pl.
#
# Revision 1.2  2000/12/15 22:11:59  thomas
# Regenerated perlDoc section in files. -b.t.
#
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


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::NotesLocationOrder.

=over 4

=item classXMLNodeName (EMPTY)

 

=item classAttributes (EMPTY)

 

=item getXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=item toXMLFileHandle (EMPTY)

Special overloaded method inthis class to allow proper printing.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::NotesLocationOrder.

=over 4

=item getLocationOrderList (EMPTY)

 

=item setLocationOrderList ($arrayRefValue)

Set the locationOrderList attribute.  

=item addAxisIdToLocatorOrder ($axisId)

 

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

XDF::NotesLocationOrder inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::NotesLocationOrder inherits the following instance (object) methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLAttributes>, B<setXMLNotationHash>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::BaseObject>

=back

=head1 AUTHOR

 

=cut
