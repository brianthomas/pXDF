
# $Id$

package XDF::FormattedIOCmd;

# Generally speaking, Perl Objects could give less than 2 flips about 
# whether an interface exists or not. Well, we created this object
# to be consistent with Java API

# /** COPYRIGHT
#    FormattedIOCmd.pm Copyright (C) 2000 Brian Thomas,
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

# /** DESCRIPTION
# This is an abstract class that describes the interface for
# formatted IO commands in the XDF::FormattedDataIOStyle.
# */

use XDF::BaseObject;
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

# CLASS DATA
my @Class_Attributes = qw (
                          );

# add in super class attributes
push @Class_Attributes, @{&XDF::BaseObject::classAttributes};

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

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

sub bytes {
  my ($self, $dataFormatListRef ) = @_;
  warn "You are calling the bytes method of an abstract class from $self.\n";
}

# Protected method
sub _templateNotation {
  my ($self, $dataFormatListRef, $endian, $encoding, $input ) = @_;
  warn "You are calling the _templateNotation method of an abstract class from $self.\n";
}

# Protected method
sub _regexNotation {
  my ($self, $dataFormatListRef) = @_;
  warn "You are calling the _regexNotation method of an abstract class from $self.\n";
}

# Protected method
sub _sprintfNotation {
  my ($self, $listRef) = @_;
  warn "You are calling the _sprintfNotation method of an abstract class from $self.\n";
}

# Modification History
#
# $Log$
# Revision 1.2  2000/10/16 17:37:20  thomas
# Changed over to BaseObject Class from Object Class.
# Added in History Modification section.
#
#
#

1;


__END__

=head1 NAME

XDF::FormattedIOCmd - Perl Class for FormattedIOCmd

=head1 SYNOPSIS

...

=head1 DESCRIPTION

 This is an abstract class that describes the interface for formatted IO commands in the XDF::FormattedDataIOStyle. 

XDF::FormattedIOCmd inherits class and attribute methods of L<XDF::BaseObject>, L<XDF::GenericObject>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::FormattedIOCmd.

=over 4

=item classAttributes (EMPTY)

 

=back

=head2 OTHER Methods

=over 4

=item bytes ($dataFormatListRef)



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

XDF::FormattedIOCmd inherits the following instance methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLFile>.

=back



=over 4

XDF::FormattedIOCmd inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>, B<setObjRef>.

=back

=back

=head1 SEE ALSO

L<XDF::BaseObject>

=back

=head1 AUTHOR



=cut
