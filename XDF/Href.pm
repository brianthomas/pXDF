
# $Id$

package XDF::Href;

# /** COPYRIGHT
#    Href.pm Copyright (C) 2000 Brian Thomas,
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

# /** AUTHOR 
#    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
#    Astronomical Data Center <http://adc.gsfc.nasa.gov>
#    NASA/Goddard Space Flight Center
# */

# /** DESCRIPTION
#
# The HREF object is nothing more than a simple hash that holds the name of the
# href and its associated ENTITY reference.
# */

#/** SYNOPSIS
#
# */

use Carp;

use XDF::GenericObject;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

@ISA = ("XDF::GenericObject");

# CLASS DATA
my @Class_Attributes = qw (
                             name
                             base
                             sysId
                             pubId
                             ndata
                          );

# add in super class attributes
push @Class_Attributes, @{&XDF::GenericObject::classAttributes};

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# This is called when we cant find any defined method
# exists already. Used to handle general purpose set/get
# methods for our attributes (object fields).
sub AUTOLOAD {
  my ($self,$val) = @_;
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}

# 
# Get/Set Methods
#

# /** getBase
# */
sub getBase {
   my ($self) = @_;
   return $self->{Base};
}

# /** setBase
#     Set the entity base attribute. 
# */
sub setBase {
   my ($self, $value) = @_;
   $self->{Base} = $value;
}

# /** getName
# */
sub getName {
   my ($self) = @_;
   return $self->{Name};
}

# /** setName
#     Set the name attribute. 
# */
sub setName {
   my ($self, $value) = @_;
   $self->{Name} = $value;
}

# /** getNdata
# */
sub getNdata {
   my ($self) = @_;
   return $self->{Ndata};
}

# /** setNdata
#     Set the ndata attribute. 
# */
sub setNdata {
   my ($self, $value) = @_;
   $self->{Ndata} = $value;
}


# /** getPubId
#  */
sub getPubId {
   my ($self) = @_;
   return $self->{PubId};
}

# /** setPubId
#     Set the pubId attribute. 
#  */
sub setPubId {
   my ($self, $value) = @_;
   $self->{PubId} = $value;
}

# /** getSysId
#  */
sub getSysId {
   my ($self) = @_;
   return $self->{SysId};
}

# /** setSysId
#     Set the sysId attribute. 
#  */
sub setSysId {
   my ($self, $value) = @_;
   $self->{SysId} = $value;
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

XDF::Href - Perl Class for Href

=head1 SYNOPSIS




...

=head1 DESCRIPTION

 The HREF object is nothing more than a simple hash that holds the name of the href and its associated ENTITY reference. 

XDF::Href inherits class and attribute methods of L<XDF::GenericObject>.


=over 4

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item name

 

=item base

 

=item sysId

 

=item pubId

 

=item ndata

 

=back

=head2 OTHER Methods

=over 4

=item getBase (EMPTY)



=item setBase ($value)

Set the entity base attribute. 

=item getName (EMPTY)



=item setName ($value)

Set the name attribute. 

=item getNdata (EMPTY)



=item setNdata ($value)

Set the ndata attribute. 

=item getPubId (EMPTY)



=item setPubId ($value)

Set the pubId attribute. 

=item getSysId (EMPTY)



=item setSysId ($value)

Set the sysId attribute. 

=back

=over 4

=head2 INHERITED Class Methods

A change in the value of these attributes will change the functioning of ALL instances of these objects that inherit from the indicated super class.
=back

=over 4

=head2 INHERITED Other Methods



=over 4

XDF::Href inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back

=back

=head1 SEE ALSO

L<XDF::GenericObject>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center


=cut
