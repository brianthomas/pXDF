
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

use strict;
use integer;

use XDF::Log;

# class attribs
use fields qw ( _hasNext 
                _iterationOrderList 
                _locationHash 
                _parentArray 
                _nrofAxes 
                _axisLookupIndexArray
                _longArrayIndex
              );

#
# Constructor
#

# only allow Array objects to create locators
sub new { 
  my ($proto, $parentArray) = @_;

  unless (caller eq 'XDF::Array') {
    error("Error: $proto is not meant to be instanciated standalone. Use XDF::Array method to create instance.\n");
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
  my ($self, $axisObj, $index) = @_;

#my @parentAxisList = @{%{$self->{_parentArray}}->{axisList}};
#print STDERR "setAxisIndex $axisObj, $index (parent:",$self->{_parentArray},"| ",join ' ',@parentAxisList,")called\n";

  unless (ref $axisObj and defined $index) {
    warn ("Cannot setAxisIndex missing information\n");
    return; 
  }

  #unless (defined %{$self->{_locationHash}}->{$axisObj}) {
  unless (defined $self->{_locationHash}->{$axisObj}) {
    warn ("Cannot setAxisIndex...passed axis not valid\n");
    return;
  }

  #%{$self->{_locationHash}}->{$axisObj} = $index;
  $self->{_locationHash}->{$axisObj} = $index;

  # needs to be done
  $self->_calculateLongArrayIndex();

#print STDERR "LONG INDEX IS NOW:",$self->{_longArrayIndex},"\n";

}

# /** getAxisIndex
# */
sub getAxisIndex {
  my ($self, $axisObj ) = @_;
  return undef unless defined $axisObj;
  #return %{$self->{_locationHash}}->{$axisObj};
  return $self->{_locationHash}->{$axisObj};
}

# /** getAxisValue
# Returns the current axis value if successful, null if no such 
# Axis exists in this locator.
# */
sub getAxisValue {
  my ($self, $axisObj ) = @_;

  return undef unless defined $axisObj;
  #my $index = %{$self->{_locationHash}}->{$axisObj};
  my $index = $self->{_locationHash}->{$axisObj};
  return $axisObj->getValueList()->[$index];

}

#/** getAxisIndices
# Returns a list of the current indices (present locator position in the 
# dataCube) arranged in the axis iteration order.
#*/
sub getAxisIndices {
  my ($self) = @_;

  my @list = ();
  foreach my $axisObj (@{$self->{_iterationOrderList}}) {
    #push @list, %{$self->{_locationHash}}->{$axisObj};
    push @list, $self->{_locationHash}->{$axisObj};
  }

  return \@list;
}

#/** getIterationOrder
# returns an array reference.
# */
sub getIterationOrder {
  my ($self) = @_;
  return $self->{_iterationOrderList};
}

#/** setIterationOrder
#  This will also result in a resetting the current (axis) indices to the origin
#  location. 
#  The first axis is considered the 'fastest' axis in the traversal.
# */
sub setIterationOrder {
  my ($self, $axisOrderListRef ) = @_;

  my @newAxesOrder = @{$axisOrderListRef};

  # a different number of axes? we need to re-calculate coeficients
  $self->_updateInternalLookupIndices() if ($self->{_nrofAxes} != $#newAxesOrder); 

  # we should check here that the number of entries matches the
  # dimension of the parent array

  $self->{_iterationOrderList} = [];

  my @parentAxes = @{$self->{_parentArray}->getAxisList()};

  my $hasSameAxisAsParentArray = 1;
  my $i = 0;
  foreach my $axisObj (@newAxesOrder) {
     $hasSameAxisAsParentArray = 0 unless ($axisObj eq $parentAxes[$i]);
     push @{$self->{_iterationOrderList}}, $axisObj;
     $i++;
  }

  $self->{_hasDefaultAxesIOOrder} = $hasSameAxisAsParentArray;

  $self->reset();

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

  foreach my $axisObj (@{$self->{_iterationOrderList}}) {

      my $axisSize = $axisObj->getLength()-1;
      #my $index = %{$self->{_locationHash}}->{$axisObj}; 
      my $index = $self->{_locationHash}->{$axisObj}; 

      # are we still within the axis?
      if ($index < $axisSize)
      {
        $outOfDataCells = 0;
        # advance current index by one 
        #%{$self->{_locationHash}}->{$axisObj}++;
        $self->{_locationHash}->{$axisObj}++;
        last;  # get out of the for loop
      }

      # reset index back to the origin of this axis 
      #%{$self->{_locationHash}}->{$axisObj} = 0;
      $self->{_locationHash}->{$axisObj} = 0;

  }

  # we cycled back to the origin. Set the global
  # to let us know
  $self->{_hasNext} = 0 if ($outOfDataCells);

  $self->_calculateLongArrayIndex();

  return !$outOfDataCells;

}

# /** prev
# Change the locator coordinates to the previous datacell as
# determined from the locator iteration order. If the request
# takes it past the origin (e.g. you *were* there to start), 
# it cycles the locator back around to the last datacell.
# In this case the method returns false ('0'), otherwise it returns
# true.
# */

# Works? very different from 'next'. hmm.
sub prev {
  my ($self) = @_;

  my $outOfDataCells = 0;

  my $atOrigin = 1;
  foreach my $axisObj (reverse @{$self->{_iterationOrderList}}) {
    #%{$self->{_locationHash}}->{$axisObj} -= 1;
    $self->{_locationHash}->{$axisObj} -= 1;
   # if (%{$self->{_locationHash}}->{$axisObj} < 0) {
    if ($self->{_locationHash}->{$axisObj} < 0) {
       # Crap. We went below 0 on that index, means we flipped to next
       # axis. IF this is the last axis we are testing, then we went
       # out of axes and should set to the origin.
       #%{$self->{_locationHash}}->{$axisObj} = $axisObj->getLength()-1; # set to the max index then
       $self->{_locationHash}->{$axisObj} = $axisObj->getLength()-1; # set to the max index then
    } else {
       $atOrigin = 0;
       last;
    }
  }

  $outOfDataCells = 1 if $atOrigin;

  $self->_calculateLongArrayIndex();

  return $outOfDataCells;

}

#/** backward
# Move the locator backward by $nrofDataCells data cells. 
# Locator traverses the data cube in the iteration order.
# This method returns false if the request would take it past
# the origin of the data Cube (the location is still changed to the 
# origin).
#*/
sub backward {
  my ($self, $nrofDataCells) = @_;

  my @needAxis;
  my $outOfDataCells = 0;
  # determine how many axes are needed to satisfy our request
  foreach my $axisObj (@{$self->{_iterationOrderList}}) {

     # gather and record info
     my $maxIndex = $axisObj->getLength();
     #my $currentIndex = %{$self->{_locationHash}}->{$axisObj};
     my $currentIndex = $self->{_locationHash}->{$axisObj};

     # calc the value of nrofDataCells gained by changing index by 1
     my $worthCells = 1;
     for (@needAxis)
     {
        #$worthCells *= %{$_}->{maxIndex};
        $worthCells *= $_->{maxIndex};
     }

     # the test
     last if ($worthCells > $nrofDataCells);

     # ok, this axis *will* be needed
     # add to the array

     my %info = ( 'maxIndex' => $maxIndex,
                  'worthCells' => $worthCells,
                  'index' => $currentIndex,
                  'axis' => $axisObj,
                );

     push @needAxis, \%info;
  }

  # now determine the change to each indice
  my @changeIndex = ();
  my $remainingCells = $nrofDataCells;
  foreach my $axis (reverse @needAxis) {

     if ($remainingCells == 0) {
        push @changeIndex, 0;
        next;
     }

     #my $worthCells = %{$axis}->{worthCells};
     #my $maxIndex = %{$axis}->{maxIndex};
     my $worthCells = $axis->{worthCells};
     my $maxIndex = $axis->{maxIndex};
     my $changeAxisIndex = int ($remainingCells/$worthCells);

     if ($changeAxisIndex > $maxIndex) {
        $changeAxisIndex = $maxIndex;
     }

     push @changeIndex, $changeAxisIndex;
     $remainingCells -= ($changeAxisIndex * $worthCells);

  }

  # now actually change it
  @changeIndex = reverse @changeIndex;

  my $moreChange = 0;
  foreach my $which (0 .. $#needAxis) {

    next unless $changeIndex[$which] > 0;

    my %axisInfo = %{$needAxis[$which]};
    my $newIndex = $axisInfo{'index'} - $changeIndex[$which] - $moreChange;

    my $axisObj = $axisInfo{'axis'};

    if ($newIndex < 0) {
       $newIndex = $axisInfo{'maxIndex'} - $changeIndex[$which];
       $moreChange = 1;
       if ($which == $#needAxis) {
         # oops, this is the last axis, we *can't* subtract more
         # the whole cube should be set to the orign
         $self->reset();
         $outOfDataCells = 1;
         last;
       }
    } else {
       $moreChange = 0;
    } 

    $self->setAxisIndex($axisObj, $newIndex);

  }

  # info we need to cache or pass on back
  $self->{_hasNext} = 1; #always at least one more cell? an array with 1 dataCell *will* goof this :P 

  return !$outOfDataCells;

}

#/** forward
# Move the locator forward by $nrofDataCells data cells. 
# The Locator traverses the data cube in the iteration order.
# This method returns false if the request would take it past
# the number of allocated data cells (the location is set to the 
# final dataCell however).
#*/
sub forward {
  my ($self, $nrofDataCells) = @_;

  return unless (defined $nrofDataCells && $nrofDataCells > 0);

  my @needAxis;
  my $outOfDataCells = 0;
  # determine how many axes are needed to satisfy our request
  foreach my $axisObj (@{$self->{_iterationOrderList}}) {

     # gather and record info
     my $maxIndex = $axisObj->getLength();
     #my $currentIndex = %{$self->{_locationHash}}->{$axisObj};
     my $currentIndex = $self->{_locationHash}->{$axisObj};

     # calc the value of nrofDataCells gained by changing index by 1
     my $worthCells = 1;
     for (@needAxis) 
     {
        #$worthCells *= %{$_}->{maxIndex};
        $worthCells *= $_->{maxIndex};
     }

     # the test
     last if ($worthCells > $nrofDataCells);

     # ok, this axis *will* be needed
     # add to the array

     my %info = ( 'maxIndex' => $maxIndex,
                  'worthCells' => $worthCells,
                  'index' => $currentIndex, 
                  'axis' => $axisObj,
                );
     
     push @needAxis, \%info;
  } 

  my @changeIndex = ();
  my $remainingCells = $nrofDataCells;
  foreach my $axis (reverse @needAxis) {

     if ($remainingCells == 0) {
        push @changeIndex, 0;
        next;
     }

     #my $worthCells = %{$axis}->{worthCells};
     #my $maxIndex = %{$axis}->{maxIndex};
     my $worthCells = $axis->{worthCells};
     my $maxIndex = $axis->{maxIndex};
     my $changeAxisIndex = int ($remainingCells/$worthCells);

     if ($changeAxisIndex > $maxIndex) {
       $changeAxisIndex = $maxIndex;
     }

     push @changeIndex, $changeAxisIndex;
     $remainingCells -= ($changeAxisIndex * $worthCells);

  }

  @changeIndex = reverse @changeIndex;
  my $maxedPosition = 1;
  foreach my $which (0 .. $#needAxis) {

    next unless $changeIndex[$which] > 0; 

    my %axisInfo = %{$needAxis[$which]};
    my $newIndex = $changeIndex[$which] + $axisInfo{'index'};
    my $axisObj = $axisInfo{'axis'};
    my $maxIndex = $axisInfo{'maxIndex'};

    $self->setAxisIndex($axisObj, $newIndex);

    $maxedPosition = 0 unless ($newIndex == $maxIndex);

  } 

  if ($remainingCells > 0) {
     # oops! we have exceeded the maximum, set to max indices
     $outOfDataCells = 1; 
     for (@needAxis) {
       #$self->setAxisIndex(%{$_}->{'axis'}, (%{$_}->{'maxIndex'}-1));
       $self->setAxisIndex($_->{'axis'}, ($_->{'maxIndex'}-1));
     }
  }

  # info we need to cache or pass on back
  $self->{_hasNext} = ($remainingCells > 0 || $maxedPosition) ? 0 : 1;

  return !$outOfDataCells;
}

# /** reset
# Reset the locator to the origin.
# */
sub reset {
  my ($self) = @_;

  # Yo! this is crucial.. not to change this without considering
  # how it changes the initialization of the Locator..
  foreach my $axisObj (@{$self->{_iterationOrderList}}) { 
    # %{$self->{_locationHash}}->{$axisObj} = 0; 
     $self->{_locationHash}->{$axisObj} = 0; 
  }

  $self->_calculateLongArrayIndex();
}

#
# Private Methods 
#

# private method called from XDF::GenericObject->new
sub _init {
  my ($self, $parentArray) = @_;

  my $axesList_ref = $parentArray->getAxisList();

  $self->{_axisLookupIndexArray} = [];
  $self->{_parentArray} = $parentArray;
  $self->{_nrofAxes} = $#{$axesList_ref};
  $self->{_locationHash} = {};
  $self->{_hasNext} = 1;

  # this stuff should be done later

  # make sure all coeff-cients are correct 
  # presumably, if the number of axes changed in the locator
  # then this would have to be called again
  $self->_updateInternalLookupIndices();

  my $writeOrderList = $parentArray->getXMLDataIOStyle()->getWriteAxisOrderList();

  $self->setIterationOrder($writeOrderList);

  # do this last
#  $self->reset(); # inits _locationHash too

}

sub _hasDefaultAxesIOOrder {
  my ($self) = @_;
  return $self->{_hasDefaultAxesIOOrder};
}
 
# having this here isnt quite right... it means that 
# the dataCube could have an additional axis added, and
# then the locator wouldnt know about it.
sub _updateInternalLookupIndices {
   my ($self) = @_;

   $self->{_axisLookupIndexArray} = [];
   push @{$self->{_axisLookupIndexArray}}, 0; # first axis is always 0

   my @axisList = @{$self->{_parentArray}->{axisList}};
   my $mult = 1;
   foreach my $axisNum (1 .. $#axisList) {
      $mult *= $axisList[$axisNum-1]->getLength();
      push @{$self->{_axisLookupIndexArray}}, $mult;
   }

}

sub _getLongArrayIndex { my $self = shift; return $self->{_longArrayIndex}; }

# Note that because of complications in storing values from fieldAxis
# which is always the at the 0 index position (if it exists)
# we can't simply treat index0 as the short axis. Instead, we
# have to use the axis at index1 (if it exists).
sub _calculateLongArrayIndex 
{
   my ($self) = @_;
   
   my $longIndex = 0;
  # my @axisList = @{%{$self->{_parentArray}}->{axisList}};
   my @axisList = @{$self->{_parentArray}->{axisList}};
   my $numOfAxes = $self->{_nrofAxes}+1;

   if ($numOfAxes > 0) {

      my $axisObj = $axisList[0];
     # $longIndex = %{$self->{_locationHash}}->{$axisObj};
      $longIndex = $self->{_locationHash}->{$axisObj};

      for (my $i = 1; $i < $numOfAxes; $i++) {
         $axisObj = $axisList[$i];
         my $coefficient = $self->{_axisLookupIndexArray}->[$i];
         #$longIndex += %{$self->{_locationHash}}->{$axisObj} * $coefficient;
         $longIndex += $self->{_locationHash}->{$axisObj} * $coefficient;
      }

   }

   $self->{_longArrayIndex} = $longIndex;
}

sub DESTROY 
{
   my $self = shift;
   $self->{_parentArray}->_removeLocator($self) if $self->{_parentArray};
}

sub _dumpLocation {
   my ($self) = @_;

   my $string = "Present Location :"; 
   while (my ($axisObj, $index) = each %{$self->{_locationHash}}) {
       my $id = $axisObj; #->getAxisId();
       $string .= "($id,$index)"; 
   }

   return $string;
}

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

=item setAxisIndex ($axisObj, $index)

 

=item getAxisIndex ($axisObj)

 

=item getAxisValue ($axisObj)

Returns the current axis value if successful, null if no such Axis exists in this locator.  

=item getAxisIndices (EMPTY)

Returns a list of the current indices (present locator position in the dataCube) arranged in the axis iteration order.  

=item getIterationOrder (EMPTY)

returns an array reference.  

=item setIterationOrder ($axisOrderListRef)

This will also result in a resetting the current (axis) indices to the originlocation. The first axis is considered the 'fastest' axis in the traversal.  

=item setAxisIndexByAxisValue ($axisObj, $axisValueOrValueObj)

Set the index of an axis to the index of a valuealong that axis 

=item hasNext (EMPTY)

 

=item next (EMPTY)

Change the locator coordinates to the next datacell asdetermined from the locator iteration order. Returns '0' if it must cycle back to the first datacellto set a new 'next' location.  

=item prev (EMPTY)

Change the locator coordinates to the previous datacell asdetermined from the locator iteration order. If the requesttakes it past the origin (e.g. you *were* there to start), it cycles the locator back around to the last datacell. In this case the method returns false ('0'), otherwise it returnstrue.  

=item backward ($nrofDataCells)

Move the locator backward by $nrofDataCells data cells. Locator traverses the data cube in the iteration order. This method returns false if the request would take it pastthe origin of the data Cube (the location is still changed to the origin).  

=item forward ($nrofDataCells)

Move the locator forward by $nrofDataCells data cells. The Locator traverses the data cube in the iteration order. This method returns false if the request would take it pastthe number of allocated data cells (the location is set to the final dataCell however).  

=item reset (EMPTY)

Reset the locator to the origin.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4

=back

=back

=head1 SEE ALSO



=over 4



=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut
