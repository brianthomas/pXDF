
# $Id$

# /** COPYRIGHT
#    FieldRelation.pm Copyright (C) 2000 Brian Thomas,
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

# /** Description
# Denotes a relationship between one XDF::Field object (the parent of
# the XDF::FieldRelation object) and one or more other XDF::Field objects.
# */ 

package XDF::FieldRelation;

use XDF::Object;
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::Object
@ISA = ("XDF::Object");

# CLASS DATA
my $Class_XML_Node_Name = "relation";
my @Class_Attributes = qw (
                             fieldIdRefs
                             role
                          );

# add in super class attributes
push @Class_Attributes, @{&XDF::Object::classAttributes};

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

# /** getRelatedFieldIdRefs
# Returns an array of related fieldIdRefs.    
# */
sub getRelatedFieldIdRefs {
  my ($self) = @_;
  return split / /, $self->fieldIdRefs;
}

1;


__END__

=head1 NAME

XDF::FieldRelation - Perl Class for FieldRelation

=head1 SYNOPSIS

...

=head1 DESCRIPTION

XDF::FieldRelation inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::Object>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::FieldRelation.

=over 4

=item classXMLNodeName (EMPTY)

 

=item classAttributes (EMPTY)

 

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item fieldIdRefs

 

=item role

 

=back

=head2 OTHER Methods

=over 4

=item getRelatedFieldIdRefs (EMPTY)

Returns an array of related fieldIdRefs.    

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

XDF::FieldRelation inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>, B<setObjRef>.

=back



=over 4

XDF::FieldRelation inherits the following instance methods of L<XDF::Object>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLFile>.

=back

=back

=head1 SEE ALSO

L<XDF::Object>

=back

=head1 AUTHOR



=cut
