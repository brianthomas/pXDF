
# $Id$

package XDF::GenericObject;

# /** COPYRIGHT
#    GenericObject.pm Copyright (C) 2000 Brian Thomas,
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
# XDF::GenericObject is a base class that provides all of the 
# methods that XDF objects will need, but arent provided 
# generically by Perl as they are in Java
# (e.g. the java.lang.Object class). 
#@
#@
# In principle, none of the methods in this class
# are XDF specific at all and may be easily reused in other 
# Perl OO code. 
# */

# /** SYNOPSIS
# 
# */

# /** SEE ALSO
# */

# /** AUTHOR 
#    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
#    Astronomical Data Center <http://adc.gsfc.nasa.gov>
#    NASA/Goddard Space Flight Center
# */

use Carp;

use strict;
use integer;

use vars qw (%field);

# Public Data

# CLASS DATA
my @Class_Attributes = qw (
                             _objRef
                          );

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classAttributes
#  This method returns a list reference containing the names
#  of the class attributes for this class.
#  This method takes no arguments may not be changed. 
# */
sub classAttributes { 
  return \@Class_Attributes; 
}

#
# Methods ..
#

sub AUTOLOAD {
  my ($self, $val, $attr, $field_ref) = @_;
  
  # my $attr = $AUTOLOAD;
  
  # subst. to rip off leading class name
  $attr =~ s/.*:://; 
  return unless $attr =~ m/[^A-Z]/; # skip all-cap methods (e.g. DESTROY)
  
  # safety check
  croak "invalid attribute method: $self->$attr()" unless defined %{$field_ref}->{$attr};
  
  # We use the local value, if it exists, otherwise we go to 
  # the reference object, if it exists
  if (!defined $self->{uc $attr} && $attr ne '_objRef' && $self->_objRef() ) {

    return $self->_objRef->$attr(); # may only get, NOT set object Refs 

  } else {

    # now the general purpose set/get method part
    # set attribute to $val, if it exists 
    $self->{uc $attr} = $val if defined $val;
    return $self->{uc $attr}; # always return our current value 

  }

}

# /** new
# Create a new object. Returns the new object if successfull.
# It takes an optional argument of an attribute HASH Reference
# to initialize the object.  
# */
sub new {
  my ($proto, $attribHashRef) = @_;

  my $class = ref ($proto) || $proto;
  my $self = bless( { }, $class);

  $self->_openGroupNodeHash({}); # used only by toXMLFileHandle
  $self->_groupMemberHash({}); # init of groupMember Hash (all objects have) 

  $self->_init(); # init of class specific stuff

  # init of instance specific stuff 
  $self->update($attribHashRef) if defined $attribHashRef;

  return $self;

}

# /** clone
# Clone an exact copy object from this object. B<CURRENTLY BROKEN>. 
# */
sub clone {
  my ($self, $_parentArray) = @_;

  my $clone = (ref $self)->new();

  $_parentArray = $clone if !defined $_parentArray && $clone =~ m/XDF::Array/;
   
  foreach my $attrib ( @{$self->classAttributes} ) { 
    if ($attrib !~ m/(_objRef|_parentArray)/) {
      my $val = $self->_clone_attribute($attrib, $_parentArray);
      $clone->$attrib($val) if defined $val; 
    } elsif ($attrib =~ m/_objRef/) {
      # objRef is retained as orign reference
      # This is not really desireable, what we would like is to copy the
      # reference object + local attribs and make it the new node. But
      # watch out for ID attribute values, which will be wrong...
      $clone->$attrib($self->$attrib()) if defined $self->$attrib();
    } else {
      # _parentArray is set as new cloned array (should it exist)
      $clone->$attrib($_parentArray) if defined $_parentArray;
    } 
  }

  return $clone;
}

# preliminary routine
sub _clone_attribute {
  my ($self, $attrib, $parentArray) = @_;
  
   my $val = $self->$attrib();

   # check if value is object ref, if so clone it 
    if( defined $val && ref $val ) { 

        if( $val =~ m/XDF::/) {
          $val = $val->clone($parentArray);
        } elsif ($val =~ m/HASH/) {
          my %list;
          while (my ($key, $value) = each (%{$val}) ) { 
            if (defined $value) {
              if(ref $value) { 
                if( $value =~ m/XDF::/) {
                  $list{$key} = $value->clone($parentArray); 
                } else {
                  die "Dont know how to add hash value ref $value to hash yet.\n";
                }
              } else {
                $list{$key} = $value; 
              }
            }
          }
          $val = \%list;
        } elsif ($val =~ m/ARRAY/) {
          my @list;
          for (@$val) { 
             if (defined $_) {
               if(ref $_) { 
                 if( $_ =~ m/XDF::/) {
                   push @list, $_->clone($parentArray);
                 } else {
                   die "Dont know how to add list value ref $_ to list yet.\n";
                 }
               } else {
                 push @list, $_;
               }
             } else {
               # push @list, $_;
             } 
          }
          $val = \@list;
        } else {
          carp "Error in cloning, dont undertand reference $val\n";
        }
   }

   return $val;
}

# /** update
# Update the attributes of this object from the passed attribute HASH Reference.
# */
sub update {
  my ($self, $attribHashRef) = @_;
  while (my ($attrib, $value) = each (%{$attribHashRef}) ) { $self->$attrib($value); }
}

# Private Method. Default is empty
sub _init { my ($self) = @_; return $self; }

sub setObjRef {
  my ($self, $value) = @_;
  $self->_objRef($value) if defined $value && ref $value;
}

# Protected Method. 
sub _remove_from_list { 
  my ($self, $what, $list_ref, $listName) = @_;

  return unless defined $what;

  my $index = -1;

  # if ref, then we are trying to remove an object
  if (ref $what) {

    my $remove_obj = $what;

    # find the index of this object
    foreach my $obj (@{$list_ref}) {
      $index++;
      next unless defined $obj;
      last if ($obj eq $remove_obj);
      if ($index == $#{$list_ref}) { 
        carp "Could not find $remove_obj in $self $listName, ignoring remove request.\n";
        return;
      }
    }
  } else { # if NOT ref, then we are giving an index number we want to remove

    return unless ($what >= 0); # make sure its reasonable index
    $index = $what;

  }

  if ($index >= 0) {
    # if we found it, remove it from the list
    # this should cause the obj to go out of scope
    # and destroy itself.
    splice @{$list_ref}, $index, 1;
    return 1; # success 
  } else {
    carp "$self $listName empty! No objects to remove.\n";
  }

}

1;


__END__

=head1 NAME

XDF::GenericObject - Perl Class for GenericObject

=head1 SYNOPSIS

 


...

=head1 DESCRIPTION

 XDF::GenericObject is a base class that provides all of the  methods that XDF objects will need, but arent provided  generically by Perl as they are in Java (e.g. the java.lang.Object class).  
 
 In principle, none of the methods in this class are XDF specific at all and may be easily reused in other  Perl OO code. 



=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::GenericObject.

=over 4

=item classAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes for this class. This method takes no arguments may not be changed.  

=back

=head2 OTHER Methods

=over 4

=item new ($attribHashRef)

Create a new object. Returns the new object if successfull. It takes an optional argument of an attribute HASH Referenceto initialize the object.  

=item clone ($_parentArray)

Clone an exact copy object from this object. B<CURRENTLY BROKEN>. 

=item update ($attribHashRef)

Update the attributes of this object from the passed attribute HASH Reference. 

=item setObjRef ($value)



=back

=over 4

=head2 INHERITED Class Methods

A change in the value of these attributes will change the functioning of ALL instances of these objects that inherit from the indicated super class.
=back

=over 4

=head2 INHERITED Other Methods

=back

=head1 SEE ALSO



=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center


=cut
