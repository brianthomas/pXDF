
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
my @Local_Class_XML_Attributes = qw (
                             locationOrderList
                          );
my @Local_Class_Attributes = ( );

my @Class_Attributes;
my @Class_XML_Attributes;

# add in local class XML attributes
push @Local_Class_Attributes, @Local_Class_XML_Attributes;

# get super class attributes
push @Class_XML_Attributes, @{&XDF::BaseObject::getClassXMLAttributes};
push @Class_Attributes, @{&XDF::BaseObject::getClassAttributes};

# add in local to overall class
push @Class_XML_Attributes, @Local_Class_XML_Attributes;
push @Class_Attributes, @Local_Class_Attributes;

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

sub classXMLNodeName { 
  return $Class_XML_Node_Name; 
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

#
# Get/Set Methods
#

# /** getLocationOrderList
# */
sub getLocationOrderList {
   my ($self) = @_;
   return $self->{locationOrderList};
}

# /** setLocationOrderList
#     Set the locationOrderList attribute. 
# */
sub setLocationOrderList {
   my ($self, $arrayRefValue) = @_;
   # you must do it this way, or when the arrayRef changes it changes us here!
   my @list = @{$arrayRefValue};
   $self->{locationOrderList} = \@list;
}

# /** getXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
#sub getXMLAttributes {
#  return \@Class_XML_Attributes;
#}

#
# Other Public Methods
#

# /** addAxisIdToLocatorOrder
# Add this axisId (a string) to the location order of the Notes.
# Returns 1 on success, 0 on failure.
# */
sub addAxisIdToLocatorOrder {
   my ($self, $axisId) = @_;

   return 0 unless defined $axisId && !ref $axisId;

   push @{$self->{locationOrderList}}, $axisId;

   return 1;
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

  my $spec = XDF::Specification->getInstance();
  my $Pretty_XDF_Output = $spec->isPrettyXDFOutput;

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
  my $indexIndent = $indent . $spec->getPrettyXDFOutputIndentation;
  foreach my $indexNodeAxisIdRef (@{$self->{locationOrderList}}) {
     print $fileHandle $indexIndent if $Pretty_XDF_Output;
    # next 3 lines: have to break up printing of '"' or toXMLString will behave badly
     print $fileHandle "<index axisIdRef=\"";
     print $fileHandle $indexNodeAxisIdRef;
     print $fileHandle "\"/>";
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

  $self->SUPER::_init();

  $self->{locationOrderList} = [];

  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

}

# Modification History
#
# $Log$
# Revision 1.12  2001/08/13 20:56:37  thomas
# updated documentation via utils/makeDoc.pl for the release.
#
# Revision 1.11  2001/08/13 19:49:15  thomas
# bug fix: use only local XML attributes for appendAttribs in _init
#
# Revision 1.10  2001/07/23 15:58:07  thomas
# added ability to add arbitary XML attribute to class.
# getXMLattributes now an instance method, we
# have old class method now called getClassXMLAttributes.
#
# Revision 1.9  2001/06/29 21:07:12  thomas
# changed public add (and remove) methods to
# conform to Java API standard: e.g. return boolean
# rather than an object. Also, these methods only
# accept an object (in general) as input (instead of an attribute hash).
#
# Revision 1.8  2001/04/25 16:01:31  thomas
# updated documentation
#
# Revision 1.7  2001/04/17 19:00:10  thomas
# Using Specification class now.
# Properly calling superclass init now.
#
# Revision 1.6  2001/03/26 16:07:29  thomas
# bug fix to toXMLFileHandle, node not closed properly.
#
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

 

=item getClassAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes of XDF::FloatDataFormat. This method takes no arguments may not be changed.  

=item getClassXMLAttributes (EMPTY)

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

Add this axisId (a string) to the location order of the Notes. Returns 1 on success, 0 on failure.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::NotesLocationOrder inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::NotesLocationOrder inherits the following instance (object) methods of L<XDF::BaseObject>:
B<getXMLAttributes>, B<setXMLAttributes>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::BaseObject>

=back

=head1 AUTHOR

 

=cut
