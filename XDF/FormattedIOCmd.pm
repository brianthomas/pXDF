
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

use XDF::Object;
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::Object
@ISA = ("XDF::Object");

# CLASS DATA
my @Class_Attributes = qw (
                          );

# add in super class attributes
push @Class_Attributes, @{&XDF::Object::classAttributes};

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

1;


__END__

=head1 NAME

XDF::FormattedIOCmd - Perl Class for FormattedIOCmd

=head1 SYNOPSIS

...

=head1 DESCRIPTION

 This is an abstract class that describes the interface for formatted IO commands in the XDF::FormattedDataIOStyle. 

XDF::FormattedIOCmd inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::Object>.


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

The following class attribute methods are inherited from L<XDF::Object>:
B<Pretty_XDF_Output>, B<Pretty_XDF_Output_Indentation>, B<DefaultDataArraySize>.

=back

=back

=over 4

=head2 INHERITED Other Methods



=over 4

XDF::FormattedIOCmd inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>, B<setObjRef>.

=back



=over 4

XDF::FormattedIOCmd inherits the following instance methods of L<XDF::Object>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLFile>.

=back

=back

=head1 SEE ALSO

L<XDF::Object>

=back

=head1 AUTHOR



=cut
