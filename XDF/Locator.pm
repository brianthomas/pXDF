
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
                             _hasNext
                             _locationList
                             _parentArray
                          );

# add in super class attributes
push @Class_Attributes, @{&XDF::GenericObject::classAttributes};

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

#
# Constructor
#

# only allow Array objects to create locators
sub new { 
  my ($proto, $parentArray) = @_;

  unless (caller eq 'XDF::Array') {
    croak "Error: $proto is not meant to be instanciated standalone. Use XDF::Array method to create instance.\n";
  }

  my $class = ref ($proto) || $proto;
  my $self = bless( { }, $class);

  $self->_init($parentArray); # init of class specific stuff

  return $self;
}

#
# Get/Set Methods
#

#/** setAxisIndex
# */
sub setAxisIndex {
  my ($self, $axisObjOrAxisId, $index) = @_;

  return unless defined $axisObjOrAxisId and defined $index;

  for (@{$self->{_locationList}}) {
     if (%{$_}->{'axis'} eq $axisObjOrAxisId) {
       %{$_}->{'index'} = $index;
       last;
     }
  }
  return undef;
}

# /** getAxisIndex
# */
sub getAxisIndex {
  my ($self, $axisObj ) = @_;

  return undef unless defined $axisObj;

  for (@{$self->{_locationList}}) {
     if (%{$_}->{'axis'} eq $axisObj) {
       return %{$_}->{'index'};
     }
  }
  return undef;
}

# /** getAxisValue
# Returns the current axis value if successful, null if no such 
# Axis exists in this locator.
# */
sub getAxisValue {
  my ($self, $axisObj ) = @_;

  return undef unless defined $axisObj;

  for (@{$self->{_locationList}}) {
     if (%{$_}->{'axis'} eq $axisObj) {
       return $axisObj->getValueList->[%{$_}->{'index'}];
     }
  }
  return undef;
}

#/** getAxisIndices
# Returns a list of the current indices (present locator position in the 
# dataCube) arranged in the axis iteration order.
#*/
sub getAxisIndices {
  my ($self) = @_;

  my @list = ();
  for(@{$self->{_locationList}}) {
    push @list, %{$_}->{'index'};
  }
  return \@list;
}

#/** getIterationOrder
# */
sub getIterationOrder {
  my ($self) = @_;

  my @axisList = ();
  for(@{$self->{_locationList}}) {
    push @axisList, %{$_}->{'axis'};
  }
  return \@axisList;
}

#/** setIterationOrder
#  This will also result in a resetting the current (axis) indices to the origin
#  location. 
#  The first axis is considered the 'fastest' axis in the traversal.
# */
sub setIterationOrder {
  my ($self, $axisOrderListRef ) = @_;

  # we should check here that the number of entries matches the
  # dimension of the parent array

  $self->{_locationList} = [];
  foreach my $axisObj (@{$axisOrderListRef}) {
     my %location = (
                       'axis'  => $axisObj,
                       'index' => 0,
                    );

     push @{$self->{_locationList}}, \%location;
  }
}

# /** setAxisIndexByAxisValue
# Set the index of an axis to the index of a value
# along that axis
# */ 
sub setAxisIndexByAxisValue {
  my ($self, $axisObj, $axisValueOrValueObj) = @_;

  return unless defined $axisObj && ref($axisObj) eq 'XDF::Axis'
                 and defined $axisValueOrValueObj;

  $self->setAxisIndex($axisObj, $axisObj->getIndexFromAxisValue($axisValueOrValueObj));
}

#
# Other Public Methods
#

# Are we at the end of the array ?
# Note that this ISNT very performance oriented. I can
# see this really slowing down a while loop that uses it.
sub hasNext {
  my ($self) = @_;

  return $self->{_hasNext};
#  my $outOfDataCells = 1;
#
#  for (@{$self->{_locationList}}) {
#    if (%{$_}->{'index'} < (%{$_}->{'axis'}->getLength()-1) ) {
#      $outOfDataCells = 0;
#      last;
#    }
#  }
#  return $outOfDataCells ? 0 : 1;
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

  $self->{_hasNext} = 1;

  my @axisOrderList = @{$self->{_locationList}};
  my $size = $#axisOrderList;
  for (my $i = 0; $i <= $size ; $i++) {

      my $axis = $axisOrderList[$i]->{'axis'};
      my $index = $axisOrderList[$i]->{'index'};

      # are we still within the axis?
      if ($index < ($axis->getLength()-1)) 
      {
        $outOfDataCells = 0;
        # advance current index by one 
        #$index++;
        $axisOrderList[$i]->{'index'}++;
        last;  # get out of the for loop
      }

      # reset index back to the origin of this axis 
      $axisOrderList[$i]->{'index'} = 0; 

  }

  # we cycled back to the origin. Set the global
  # to let us know
  $self->{_hasNext} = 0 if ($outOfDataCells);

  return !$outOfDataCells;

#  for (reverse @{$self->{_locationList}}) {
#  #for (@{$self->{_locationList}}) {
#    if (%{$_}->{'index'} < (%{$_}->{'axis'}->getLength()-1) ) {
#      %{$_}->{'index'} += 1;
#      $outOfDataCells = 0;
#      last;
#    }
#    $_->{'index'} = 0;
#  }
#
#  return $outOfDataCells ? 0 : 1;
}

# /** prev
# Change the locator coordinates to the previous datacell as
# determined from the locator iteration order.
# Returns '0' if it must cycle to the last datacell. 
# */
sub prev {
  my ($self) = @_;

  my $outOfDataCells = 1;

  for (reverse @{$self->{_locationList}}) {
  #for (@{$self->{_locationList}}) {
    %{$_}->{'index'} -= 1;
    if (%{$_}->{'index'} < 0) {
      %{$_}->{'index'} = %{$_}->{'axis'}->getLength();
    } else {
      last;
    } 
  }
  
  # we flipped over if first member of the list is 
  # set to the length of its axis
  $outOfDataCells = 1 if ( @{$self->{_locationList}}->[0]->{'index'} == 
                           @{$self->{_locationList}}->[0]->{'axis'}->getLength() );

  return $outOfDataCells ? 0 : 1;
}

# /** reset
# Reset the locator to the origin.
# */
sub reset {
  my ($self) = @_;

  for(@{$self->{_locationList}}) { $_->{'index'} = 0; }
}

sub toXMLFileHandle {
  my ($self) = @_;
  warn "You made a silly error, this $self is not meant to be printed to XML.\n";
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

# private method called from XDF::GenericObject->new
sub _init {
  my ($self, $parentArray) = @_;
  $self->SUPER::_init();
  $self->{_parentArray} = $parentArray;
  $self->setIterationOrder($parentArray->getAxisList());
  $self->{_hasNext} = 1;
}
 

# Modification History
#
# $Log$
# Revision 1.13  2001/04/17 18:54:43  thomas
# Properly calling superclass init now
#
# Revision 1.12  2001/03/26 18:11:43  thomas
# Documentation was wrong (!). Fixed.
#
# Revision 1.11  2001/03/16 19:54:57  thomas
# Documentation updated and improved, re-ran makeDoc on file.
#
# Revision 1.10  2001/03/14 21:32:34  thomas
# Updated perldoc section using new version of
# makeDoc.pl.
#
# Revision 1.9  2001/03/14 16:12:04  thomas
# re-enabled setAxisIndexByAxisValue. added the java
# method getAxisValue.
#
# Revision 1.8  2001/03/01 21:11:31  thomas
# Fixed HasNext. Fixed next method.
#
# Revision 1.7  2001/02/23 17:08:54  thomas
# Undid prior change (!) was correct.
#
# Revision 1.6  2001/02/22 19:39:10  thomas
# changed *AxisLocation method names to *AxisIndex methods.
# un-reversed axis traversal in next, prev methods. I cant imagine
# how that ever worked.
#
# Revision 1.5  2000/12/14 22:11:26  thomas
# Big changes to the API. get/set methods, added Href/Entity stuff, deep cloning,
# added Href, Notes, NotesLocationOrder nodes/classes. Ripped out _enlarge_array
# from DataCube (not needed) and fixed problems outputing delimited/formatted
# read nodes. -b.t.
#
# Revision 1.4  2000/12/01 20:03:38  thomas
# Brought Pod docmentation up to date. Bumped up version
# number. -b.t.
#
# Revision 1.3  2000/11/28 19:54:19  thomas
# Added hasNext method. Its not very performance
# oriented. Need better implementation. -b.t.
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

XDF::Locator - Perl Class for Locator

=head1 SYNOPSIS




...

=head1 DESCRIPTION

 The LOCATOR object is nothing more than an array of the indices for the requested datacell.  Indices are always non-negative integers, and ordering within the LOCATOR indicates axis.  For example, declaring: 
  my @locator = (1,2,2);  
  my $data = $dataCubeObject->getData(\@locator);
 
 indicates that the user wishes to retrieve the data from datacell at axis1 index = 1,  axis2 index = 2, axis 3 index = 2. XDF::DataCubes use zero-indexing, so a request to  location (0,0) (for example) is valid. 

XDF::Locator inherits class and attribute methods of L<XDF::GenericObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::Locator.

=over 4

=item new ($parentArray)

 

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::Locator.

=over 4

=item setAxisIndex ($index, $axisObjOrAxisId)

 

=item getAxisIndex ($axisObj)

 

=item getAxisValue ($axisObj)

Returns the current axis value if successful, null if no such Axis exists in this locator.  

=item getAxisIndices (EMPTY)

Returns a list of the current indices (present locator position in the dataCube) arranged in the axis iteration order.  

=item getIterationOrder (EMPTY)

 

=item setIterationOrder ($axisOrderListRef)

This will also result in a resetting the current (axis) indices to the originlocation. The first axis is considered the 'fastest' axis in the traversal.  

=item setAxisIndexByAxisValue ($axisValueOrValueObj, $axisObj)

Set the index of an axis to the index of a valuealong that axis 

=item hasNext (EMPTY)

 

=item next (EMPTY)

Change the locator coordinates to the next datacell asdetermined from the locator iteration order. Returns '0' if it must cycle back to the first datacellto set a new 'next' location.  

=item prev (EMPTY)

Change the locator coordinates to the previous datacell asdetermined from the locator iteration order. Returns '0' if it must cycle to the last datacell.  

=item reset (EMPTY)

Reset the locator to the origin.  

=item toXMLFileHandle (EMPTY)

 

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::Locator inherits the following instance (object) methods of L<XDF::GenericObject>:
B<clone>, B<update>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::GenericObject>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut
