
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
use XDF::Chars;
use XDF::Log;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::FormattedIOCmd");

# CLASS DATA
my $Def_Count = 1;
my $Def_Output_Char = " ";
my $Class_XML_Node_Name = "skip";
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
   my ($self, $object) = @_;

   if (&XDF::Utility::isValidCharOutput($object)) {
      $self->{output} = $object;
   } else {
      error("Cant set $object as output for XDF::Char class, ignoring request\n"); 
   }
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
  $self->{output} = new XDF::Chars();
  
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

 

=item getClassAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes of XDF::FloatDataFormat. This method takes no arguments may not be changed.  

=item getClassXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::SkipCharFormattedIOCmd.

=over 4

=item getCount (EMPTY)

 

=item setCount ($value)

Set the count attribute.  

=item getOutput (EMPTY)

 

=item setOutput ($object)

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
B<getXMLAttributes>, B<setXMLAttributes>, B<getXMLAttribute>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::FormattedIOCmd>, L<XDF::Chars>, L<XDF::Log>

=back

=head1 AUTHOR

 

=cut
