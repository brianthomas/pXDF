
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
my @Class_XML_Attributes = qw (
                             count
                             output
                          );
my @Class_Attributes = ();

# add in class XML attributes
push @Class_Attributes, @Class_XML_Attributes;

# add in super class attributes
push @Class_Attributes, @{&XDF::FormattedIOCmd::classAttributes};
push @Class_XML_Attributes, @{&XDF::FormattedIOCmd::getXMLAttributes};

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

# /** getCount
# */
sub getCount {
   my ($self) = @_;
   return $self->{Count};
}

# /** setCount
#     Set the count attribute. 
# */
sub setCount {
   my ($self, $value) = @_;
   $self->{Count} = $value;
}

# /** getOutput
# */
sub getOutput {
   my ($self) = @_;
   return $self->{Output};
}

# /** setOutput
#     Set the output attribute. 
# */
sub setOutput {
   my ($self, $value) = @_;
   $self->{Output} = $value;
}

sub numOfBytes { 
  my ($self) = @_;  
  return $self->{Count}; 
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
  $self->{Count} = $Def_Count;
  $self->{Output} = $Def_Output_Char;
}

sub _templateNotation { 
  my ($self, $endian, $encoding, $input) = @_; 
  return "x" . $self->numOfBytes() if $input; 
  return "A" . length($self->{Output});
}

sub _regexNotation {
  my ($self) = @_;

  my $notation = "\.{". $self->{Count}. "}";
  return $notation;
}


sub _sprintfNotation {
  my ($self) = @_;

  my $char = $self->{Output};
  my $notation = "$char" x $self->{Count};

  return $notation;

}

# Modification History
#
# $Log$
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

A change in the value of these class attributes will change the value for ALL instances of XDF::SkipCharFormattedIOCmd.

=over 4

=item classXMLNodeName (EMPTY)

 

=item classAttributes (EMPTY)

 

=back

=head2 INSTANCE Methods

The following instance methods are defined for XDF::SkipCharFormattedIOCmd.
=over 4

=item getCount (EMPTY)

 

=item setCount ($value)

Set the count attribute.  

=item getOutput (EMPTY)

 

=item setOutput ($value)

Set the output attribute.  

=item numOfBytes (EMPTY)

 

=item getXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

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

=head2 INHERITED INSTANCE Methods



=over 4

XDF::SkipCharFormattedIOCmd inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>. 

=back



=over 4

XDF::SkipCharFormattedIOCmd inherits the following instance methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLAttributes>, B<setXMLNotationHash>, B<toXMLFileHandle>, B<toXMLFile>. 

=back

=head1 SEE ALSO

L<XDF::FormattedIOCmd> 

=back

=head1 AUTHOR

 

=cut
