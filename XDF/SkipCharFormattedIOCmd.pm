
# $Id$

package XDF::SkipCharFormattedIOCmd;

# /** COPYRIGHT
#    SkipCharFormatedIOCmd.pm Copyright (C) 2000 Brian Thomas,
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

use XDF::FormattedIOCmd;
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::FormattedIOCmd");

# CLASS DATA
my $Def_Count = 1;
my $Def_Output_Char = " ";
my $Class_XML_Node_Name = "skipChars";
my @Local_Class_XML_Attributes = qw (
                             count
                             output
                          );
my @Local_Class_Attributes = ();
my @Class_Attributes;
my @Class_XML_Attributes;

# add in local class XML attributes
push @Local_Class_Attributes, @Local_Class_XML_Attributes;

# get super class attributes
push @Class_XML_Attributes, @{&XDF::FormattedIOCmd::getClassXMLAttributes};
push @Class_Attributes, @{&XDF::FormattedIOCmd::getClassAttributes};

# add in local to overall class
push @Class_XML_Attributes, @Local_Class_XML_Attributes;
push @Class_Attributes, @Class_XML_Attributes;


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

# /** getCount
# */
sub getCount {
   my ($self) = @_;
   return $self->{count};
}

# /** setCount
#     Set the count attribute. 
# */
sub setCount {
   my ($self, $value) = @_;
   $self->{count} = $value;
}

# /** getOutput
# */
sub getOutput {
   my ($self) = @_;
   return $self->{output};
}

# /** setOutput
#     Set the output attribute. 
# */
sub setOutput {
   my ($self, $value) = @_;
   $self->{output} = $value;
}

sub numOfBytes { 
  my ($self) = @_;  
  return $self->{count}; 
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

  $self->{count} = $Def_Count;
  $self->{output} = $Def_Output_Char;
  
  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

}

sub _templateNotation { 
  my ($self, $endian, $encoding, $input) = @_; 
  return "x" . $self->numOfBytes() if $input; 
  return "A" . length($self->{output});
}

sub _regexNotation {
  my ($self) = @_;

  my $notation = "\.{". $self->{count}. "}";
  return $notation;
}


sub _sprintfNotation {
  my ($self) = @_;

  my $char = $self->{output};
  my $notation = "$char" x $self->{count};

  return $notation;

}

# Modification History
#
# $Log$
# Revision 1.12  2001/08/13 19:50:16  thomas
# bug fix: use only local XML attributes for appendAttribs in _init
#
# Revision 1.11  2001/07/23 15:58:07  thomas
# added ability to add arbitary XML attribute to class.
# getXMLattributes now an instance method, we
# have old class method now called getClassXMLAttributes.
#
# Revision 1.10  2001/04/25 16:01:31  thomas
# updated documentation
#
# Revision 1.9  2001/04/17 18:55:20  thomas
# Properly calling superclass init now
#
# Revision 1.8  2001/03/16 19:54:57  thomas
# Documentation updated and improved, re-ran makeDoc on file.
#
# Revision 1.7  2001/03/14 21:32:35  thomas
# Updated perldoc section using new version of
# makeDoc.pl.
#
# Revision 1.6  2001/02/15 17:50:30  thomas
# changed getBytes to numOfBytes method as per
# java API.
#
# Revision 1.5  2000/12/15 22:11:59  thomas
# Regenerated perlDoc section in files. -b.t.
#
# Revision 1.4  2000/12/14 22:11:26  thomas
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

XDF::SkipCharFormattedIOCmd - Perl Class for SkipCharFormattedIOCmd

=head1 SYNOPSIS

...

=head1 DESCRIPTION

XDF::SkipCharFormattedIOCmd inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::FormattedIOCmd>, L<XDF::BaseObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::SkipCharFormattedIOCmd.

=over 4

=item classXMLNodeName (EMPTY)

 

=item classAttributes (EMPTY)

 

=item getXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::SkipCharFormattedIOCmd.

=over 4

=item getCount (EMPTY)

 

=item setCount ($value)

Set the count attribute.  

=item getOutput (EMPTY)

 

=item setOutput ($value)

Set the output attribute.  

=item numOfBytes (EMPTY)

 

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::SkipCharFormattedIOCmd inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::SkipCharFormattedIOCmd inherits the following instance (object) methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLAttributes>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::FormattedIOCmd>

=back

=head1 AUTHOR

 

=cut
