
# $Id$

package XDF::Locator;

# /** COPYRIGHT
#    Locator.pm Copyright (C) 2000 Brian Thomas,
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
# The LOCATOR object is nothing more than an array of the indices for the requested datacell. 
# Indices are always non-negative integers, and ordering within the LOCATOR indicates axis.
# For example, declaring:
#@
#@ my @locator = (1,2,2);  
#@ my $data = $dataCubeObject->getData(\@locator);
#@
# indicates that the user wishes to retrieve the data from datacell at axis1 index = 1, 
# axis2 index = 2, axis 3 index = 2. XDF::DataCubes use zero-indexing, so a request to 
# location (0,0) (for example) is valid.
# */

#/** SYNOPSIS
#
# */

use Carp;

use XDF::GenericObject;

use strict;
use integer;

# TODO: need to sync this object up with changes made
# to the parentArray. For example, what should we do
# when a new axis is added to the parent (?)

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::GenericObject
# Technically, this is MORE than we want
# we dont need the toXMLFile and related stuff at all.
# Hopefully in the future we can split these objects appart.
@ISA = ("XDF::GenericObject");

# CLASS DATA
my @Class_Attributes = qw (
                             _locationList
                             _parentArray
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

# only allow Array objects to create locators
sub new { 
  my ($proto, $attribHashRef) = @_;

  unless (caller eq 'XDF::Array') {
    croak "Error: $proto is not meant to be instanciated standalone. Use XDF::Array method to create instance.\n";
  }

  my $class = ref ($proto) || $proto;
  my $self = bless( { }, $class);

  $self->_init(); # init of class specific stuff

  # init of instance specific stuff 
  $self->update($attribHashRef) if defined $attribHashRef;

  # now, since we KNOW _parentArray is defined
  # (has to be intanciated via XDF::Array ONLY)
  # we can proceed to initialize the axis, index positions
  # to the origin (ie index 0 for each axis).
  # We choose the parent Array axisList ordering for our
  # default location ordering.
  foreach my $axisObj (@{$self->_parentArray->axisList}) {
     my %location = (
                       'axis'  => $axisObj,
                       'index' => 0,
                    );
     push @{$self->_locationList}, \%location;
  }

  return $self;
}

# private method called from XDF::GenericObject->new
sub _init {
  my ($self) = @_;
  $self->_locationList([]); 
}

sub setAxisLocation {
  my ($self, $axisObjOrAxisId, $index) = @_;

  return unless defined $axisObjOrAxisId and defined $index;

  for (@{$self->_locationList}) { 
     if (%{$_}->{'axis'} eq $axisObjOrAxisId) {
       %{$_}->{'index'} = $index;
       last;
     } 
  }

  return $index;
} 

# /** getAxisLocation
# Only axisObj ref supported right now (need to change Reader)
# */
sub getAxisLocation {
  my ($self, $axisObjOrAxisId ) = @_;

  return unless defined $axisObjOrAxisId;

  for (@{$self->_locationList}) { 
     if (%{$_}->{'axis'} eq $axisObjOrAxisId) {
       return %{$_}->{'index'};
     } 
  }

}

# note that the ordering is *still* that of 
# the axisList in Array
sub getAxisLocations {
  my ($self) = @_;

  my @list = ();
  for(@{$self->_locationList}) { 
    push @list, %{$_}->{'index'};
  }
  return @list;

}

# /** setAxisLocationByAxisValue
#  
# */ 
sub setAxisLocationByAxisValue {
  my ($self, $axisObj, $axisValueOrValueObj) = @_;
  
  return unless defined $axisObj && ref($axisObj) eq 'XDF::Axis'
                 and defined $axisValueOrValueObj;
  
  $self->setLocation($axisObj, $axisObj->getIndexFromAxisValue($axisValueOrValueObj));
} 

# /** next
# Change the locator coordinates to the next datacell as
# determined from the locator iteration order.
# Returns '0' if it must cycle back to the first datacell
# to set a new 'next' location.
# */
sub next {
  my ($self) = @_;

  my $outOfDataCells = 1;

  for (@{$self->_locationList}) {
    if (%{$_}->{'index'} < (%{$_}->{'axis'}->length()-1) ) {
      %{$_}->{'index'} += 1;
      $outOfDataCells = 0;
      last;
    }
    $_->{'index'} = 0;
  }

  return $outOfDataCells ? 0 : 1;
}

# /** prev
# Change the locator coordinates to the previous datacell as
# determined from the locator iteration order.
# Returns '0' if it must cycle to the last datacell. 
# */
sub prev {
  my ($self) = @_;

  my $outOfDataCells = 1;

  for (reverse @{$self->_locationList}) {
    %{$_}->{'index'} -= 1;
    if (%{$_}->{'index'} < 0) {
      %{$_}->{'index'} = %{$_}->{'axis'}->length();
    } else {
      last;
    } 
  }
  
  # we flipped over if first member of the list is 
  # set to the length of its axis
  $outOfDataCells = 1 if ( @{$self->_locationList}->[0]->{'index'} == 
                           @{$self->_locationList}->[0]->{'axis'}->length() );

  return $outOfDataCells ? 0 : 1;
}

sub setIterationOrder {
  my ($self, $axisOrderListRef ) = @_;

  croak "Locator can't setIterationOrder, axisOrderList arg missing or not a list."
    unless (defined $axisOrderListRef && ref($axisOrderListRef) eq 'ARRAY'); 

  my $oldList = $self->_locationList;
  $self->_locationList([]);

  foreach my $axisObj (@{$axisOrderListRef}) {
     my $index = 0; 

     for(@{$oldList}) {
       if(%{$_}->{'axis'} eq $axisObj) {
         $index = %{$_}->{'index'};
         last;
       }
     }

     my %location = (
                       'axis'  => $axisObj,
                       'index' => $index,
                    );

     push @{$self->_locationList}, \%location;

  }

}

# /** reset
# Reset the locator to the origin.
# */
sub reset {
  my ($self) = @_;

  for(@{$self->_locationList}) { $_->{'index'} = 0; }
}

sub getIterationOrder {
  my ($self) = @_;

  my @axisList = ();
  for(@{$self->_locationList}) {
    push @axisList, %{$_}->{'axis'};
  }
  return @axisList;
}

sub toXMLFileHandle {
  my ($self) = @_;
  warn "You made a silly error, this $self is not meant to be printed to XML.\n";
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

XDF::Locator - Perl Class for Locator

=head1 SYNOPSIS




...

=head1 DESCRIPTION

 The LOCATOR object is nothing more than an array of the indices for the requested datacell.  Indices are always non-negative integers, and ordering within the LOCATOR indicates axis.  For example, declaring: 
  my @locator = (1,2,2);  
  my $data = $dataCubeObject->getData(\@locator);
 
 indicates that the user wishes to retrieve the data from datacell at axis1 index = 1,  axis2 index = 2, axis 3 index = 2. XDF::DataCubes use zero-indexing, so a request to  location (0,0) (for example) is valid. 

XDF::Locator inherits class and attribute methods of L<XDF::GenericObject>.


=over 4

=head2 OTHER Methods

=over 4

=item new ($attribHashRef)



=item setAxisLocation ($index, $axisObjOrAxisId)



=item getAxisLocation ($axisObjOrAxisId)

Only axisObj ref supported right now (need to change Reader)

=item getAxisLocations (EMPTY)



=item setAxisLocationByAxisValue ($axisValueOrValueObj, $axisObj)



=item next (EMPTY)

Change the locator coordinates to the next datacell asdetermined from the locator iteration order. Returns '0' if it must cycle back to the first datacellto set a new 'next' location. 

=item prev (EMPTY)

Change the locator coordinates to the previous datacell asdetermined from the locator iteration order. Returns '0' if it must cycle to the last datacell. 

=item setIterationOrder ($axisOrderListRef)



=item reset (EMPTY)

Reset the locator to the origin. 

=item getIterationOrder (EMPTY)



=item toXMLFileHandle (EMPTY)



=back

=over 4

=head2 INHERITED Class Methods

A change in the value of these attributes will change the functioning of ALL instances of these objects that inherit from the indicated super class.
=back

=over 4

=head2 INHERITED Other Methods



=over 4

XDF::Locator inherits the following instance methods of L<XDF::GenericObject>:
B<clone>, B<update>, B<setObjRef>.

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
