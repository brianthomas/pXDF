
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
                             # _objRef
my @Class_Attributes = ();

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
  
  # subst. to rip off leading class name
  $attr =~ s/.*:://; 
  return unless $attr =~ m/[^A-Z]/; # skip all-cap methods (e.g. DESTROY)
  
  # safety check
  croak "invalid attribute method: $self->$attr()" unless defined %{$field_ref}->{$attr};
  
  # We use the local value, if it exists, otherwise we go to 
  # the reference object, if it exists
#  if (!defined $self->{ucfirst $attr} && $attr ne '_objRef' && $self->_objRef() ) {

#    return $self->_objRef->$attr(); # may only get, NOT set object Refs 

#  } else {

   # this should only be used by a clone operation. 
   if (1) {
     my $event = &_getEventStack();
     # dont print if from clone
     print STDERR "Compatablity method ",ref($self),"->$attr() called from :$event\n\n" 
        unless $event =~ m/clone/;
    }

    # now the general purpose set/get method part
    # set attribute to $val, if it exists 
    $self->{ucfirst $attr} = $val if defined $val;
    return $self->{ucfirst $attr}; # always return our current value 

#  }

}

sub _getEventStack {
   my ($package, $filename, $line, $subroutine);
   my $outputLine = caller(1);
   my $i = 2;
   while (($package, $filename, $line, $subroutine) = caller($i++)) {
     $outputLine .= '->' . $subroutine;
   }
   return $outputLine;
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

  $self->{_openGroupNodeHash} = {}; # used only by toXMLFileHandle
  $self->{_groupMemberHash} = {}; # init of groupMember Hash (all objects have) 

  $self->_init(); # init of class specific stuff

  # init of instance specific stuff 
  $self->setXMLAttributes($attribHashRef) if defined $attribHashRef;

  return $self;

}

# /** clone
# Clone a deep copy from this object. 
# */
sub clone {
  my ($self, $_parentArray) = @_;

  my $clone = (ref $self)->new();

  # IF this object is an array, then we will use it now as the
  # parent array of all sub-objects that it owns.
  $_parentArray = $clone if ref($clone) eq 'XDF::Array';
   
  foreach my $attrib ( @{$self->classAttributes} ) { 
    if ($attrib !~ m/_parentArray/) {
      my $val = $self->_clone_attribute($attrib, $_parentArray);
      $clone->$attrib($val);
    } else {
      # _parentArray is set as new cloned array (should it exist)
      $clone->$attrib($_parentArray) if defined $_parentArray;
    } 
  }

  return $clone;
}

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
# This method is depreciated.
# */
sub update {
   my ($self) = @_;
   print STDERR "Error: ".ref($self)."->update is a deprecated method. Use setXMLAttributes instead.\n";
}

# Private Method. Default is empty
sub _init { my ($self) = @_; return $self; }

#sub setObjRef {
#  my ($self, $value) = @_;
#  $self->_objRef($value) if defined $value && ref $value;
#}

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

# Modification History
#
# $Log$
# Revision 1.3  2000/12/14 22:11:26  thomas
# Big changes to the API. get/set methods, added Href/Entity stuff, deep cloning,
# added Href, Notes, NotesLocationOrder nodes/classes. Ripped out _enlarge_array
# from DataCube (not needed) and fixed problems outputing delimited/formatted
# read nodes. -b.t.
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

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item # Initalization

 

=item # set up object attributes.

 

=item for my $attr ( @Class_Attributes ) { $field{$attr}++; }

 

=item # /** classAttributes

 

=item #  This method returns a list reference containing the names

 

=item #  of the class attributes for this class.

 

=item #  This method takes no arguments may not be changed. 

 

=item # */

 

=item sub classAttributes { 

 

=item }

 

=item #

 

=item # Methods ..

 

=item #

 

=item sub AUTOLOAD {

 

=item my ($self, $val, $attr, $field_ref) = @_;

 

=item # subst. to rip off leading class name

 

=item $attr =~ s/.*:://; 

 

=item return unless $attr =~ m/[^A-Z]/; # skip all-cap methods (e.g. DESTROY)

 

=item # safety check

 

=item croak "invalid attribute method: $self->$attr()" unless defined %{$field_ref}->{$attr};

 

=item # We use the local value, if it exists, otherwise we go to 

 

=item # the reference object, if it exists

 

=item #  if (!defined $self->{ucfirst $attr} && $attr ne '_objRef' && $self->_objRef() ) {

 

=back

=head2 OTHER Methods

=over 4

=item new ($attribHashRef)

Create a new object. Returns the new object if successfull. It takes an optional argument of an attribute HASH Referenceto initialize the object.  

=item clone ($_parentArray)

Clone a deep copy from this object. 

=item update (EMPTY)

Update the attributes of this object from the passed attribute HASH Reference. This method is depreciated. 

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
