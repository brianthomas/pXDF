
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
my @Class_Attributes = qw (
                             count
                             output
                          );

# add in super class attributes
push @Class_Attributes, @{&XDF::FormattedIOCmd::classAttributes};

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

sub classXMLNodeName { 
  $Class_XML_Node_Name; 
}

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
  $self->count($Def_Count);
  $self->output($Def_Output_Char);
}

sub bytes { my ($self) = @_; return $self->count; }

sub _templateNotation { 
  my ($self, $endian, $encoding, $input) = @_; 
  return "x" . $self->bytes if $input; 
  return "A" . length($self->output);
}

sub _regexNotation {
  my ($self) = @_;

  my $notation = "\.{". $self->count. "}";
  return $notation;
}


sub _sprintfNotation {
  my ($self) = @_;

  my $char = $self->output;
  my $notation = "$char" x $self->count;

  return $notation;

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

XDF::SkipCharFormattedIOCmd - Perl Class for SkipCharFormattedIOCmd

=head1 SYNOPSIS

...

=head1 DESCRIPTION

XDF::SkipCharFormattedIOCmd inherits class and attribute methods of L<XDF::BaseObject>, L<XDF::FormattedIOCmd>, L<XDF::GenericObject>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::SkipCharFormattedIOCmd.

=over 4

=item classXMLNodeName (EMPTY)

 

=item classAttributes (EMPTY)

 

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item count

 

=item output

 

=back

=head2 OTHER Methods

=over 4

=item bytes (EMPTY)



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

XDF::SkipCharFormattedIOCmd inherits the following instance methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLFile>.

=back



=over 4

XDF::SkipCharFormattedIOCmd inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>, B<setObjRef>.

=back

=back

=head1 SEE ALSO

L<XDF::FormattedIOCmd>

=back

=head1 AUTHOR



=cut
