# $Id$

# /** COPYRIGHT
#    BaseObjectWithValueList.pm Copyright (C) 2000 Brian Thomas,
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
#    Brian Thomas  (brian.thomas@gsfc.nasa.gov)
#    XML Group <http://xml.gsfc.nasa.gov>
#    NASA/Goddard Space Flight Center
# */

# /** DESCRIPTION
# A 'super base object' for objects which can take valueList children.
# */

# /** SYNOPSIS
# 
# */

# /** SEE ALSO
# XDF::Parameter
# XDF::ValueListAlgorithm
# XDF::ValueListDelimitedList
# */

package XDF::BaseObjectWithValueList;

use XDF::BaseObject;
use XDF::Log;

use strict;
use integer;

use vars qw {@ISA %field};

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

# CLASS DATA
my @Local_Class_Attributes = qw (
                             _hasValueListCompactDescription
                             _valueListGetMethodName
                          );

my @Local_Class_XML_Attributes = qw (
                             valueListObjects
                              );

my @Class_Attributes;
my @Class_XML_Attributes;

# add in local class XML attributes
push @Local_Class_Attributes, @Local_Class_XML_Attributes;

# get super class attributes
push @Class_XML_Attributes, @{&XDF::BaseObject::getClassXMLAttributes};
push @Class_Attributes, @{&XDF::BaseObject::getClassAttributes};

# add in local to overall class
push @Class_XML_Attributes, @Local_Class_XML_Attributes;
push @Class_Attributes, @Local_Class_Attributes;


# Initalization - set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

#
# CLASS DATA
#

my $PCDATA_ATTRIBUTE = &XDF::Constants::getPCDATAAttribute;

#
# CLASS (Static) METHODS
#

# /** getClassAttributes
#  This method returns a list reference containing the names
#  of the class attributes for this object;
#  This method takes no arguments may not be changed. 
# */
sub getClassAttributes {
  return \@Class_Attributes;
}

sub getClassXMLAttributes {
  return \@Class_XML_Attributes;
}

# /** getValueListObjects
# Get a list of ValueList objects held by this object. 
# */
sub getValueListObjects {
  my ($self) = @_;
  return $self->{valueListObjects};
}

# /** _setValueListObj
# 
# */
sub _setValueListObj {
  my ($self, $valueListObj) = @_;
  $self->_resetBaseValueListObjects();
  $self->_addValueListObj($valueListObj);
}

# /** _addValueListObj
# 
# */
sub _addValueListObj {
  my ($self, $valueListObj) = @_;

  return 0 unless defined $valueListObj && ref $valueListObj;
  push @{$self->{valueListObjects}}, $valueListObj;

  $self->{_hasValueListCompactDescription} = 1;

  return 1;

}

# reset the list of valueList objects held within this object.
sub _resetBaseValueListObjects {
  my ($self, $force) = @_;

  if ($force || $self->{_hasValueListCompactDescription}) 
  {
     $self->{_hasValueListCompactDescription} = 0;
     $self->{valueListObjects} = []; 
  }

}

sub hasValues {
  my ($self) = @_;
  return 0;
}

#
# Private/Protected methods
#

#/** toXMLFileHandle
#
#*/
sub _basicXMLWriter_not_needed {
  my ($self, $fileHandle, $indent, $dontCloseNode, $newNodeNameString, $noChildObjectNodeName) = @_;

  if(!defined $fileHandle) {
    error("Can't write out object, filehandle not defined.\n");
    return;
  }

  $indent = "" unless defined $indent;

  my $spec = XDF::Specification->getInstance();
  my $Pretty_XDF_Output = $spec->isPrettyXDFOutput;
  my $Pretty_XDF_Output_Indentation = $spec->getPrettyXDFOutputIndentation;

  # We need to invoke a little bit of Voodoo to keep the DTD happy; 
  # the first structure node is always called by the root node name
  # also, we may have nodes (w/o attributes) that just hold other nodes.
  my $nodename = $self->classXMLNodeName;
  $nodename = $newNodeNameString if defined $newNodeNameString;

  # open this node, print its attributes
  if ($nodename) {
      print $fileHandle $indent if $Pretty_XDF_Output;
      print $fileHandle "<" . $nodename;
  }

  my ($attribListRef, $objListRef, $objPCDATA) = $self->_getXMLInfo();
  my @objList = @{$objListRef};

  # print out attributes
  $self->_printAttributes($fileHandle, $attribListRef);

  # now, does this object own others? if so print them
  if ( $#objList > -1
       or defined $objPCDATA
       or defined $noChildObjectNodeName)
  {

    # close the opening node
    print $fileHandle ">";
    print $fileHandle "\n" if $Pretty_XDF_Output && !defined $objPCDATA;

    # these are objects owned by this one, print them out too 
    for (@objList) {

      if (ref($_) =~ m/ARRAY/ ) { # if its a list..
 
           $indent = $self->_doObjectListtoXMLFileHandle($_, $fileHandle, $indent, $Pretty_XDF_Output, $Pretty_XDF_Output_Indentation);

      } elsif (ref($_) =~ m/XDF::/) { # if its an XDF object

         $indent = $self->_deal_with_closing_group_nodes($_, $fileHandle, $indent, $Pretty_XDF_Output, $Pretty_XDF_Output_Indentation);
         $indent = $self->_deal_with_opening_group_nodes($_, $fileHandle, $indent, $Pretty_XDF_Output_Indentation);
         $_->toXMLFileHandle($fileHandle, $indent . $Pretty_XDF_Output_Indentation);

      } else {

        die "BaseObject.pm got weird reference: $_\n";

      }

    }

    # print out the PCDATA
    if(defined $objPCDATA) {
      print $fileHandle $objPCDATA;
    }

    # if their are no children, then we print out the noChildObjectNodeName
    if ( $#objList < 0 and !defined $objPCDATA and
         defined $noChildObjectNodeName )
    {
       print $fileHandle "$indent$Pretty_XDF_Output_Indentation" if $Pretty_XDF_Output;
       print $fileHandle "<$noChildObjectNodeName/>";
       print $fileHandle "\n" if $Pretty_XDF_Output;
    }

    # Ok, no deal with closing this node
    $indent = $self->_deal_with_closing_group_nodes($self, $fileHandle, $indent, $Pretty_XDF_Output, $Pretty_XDF_Output_Indentation);
    print $fileHandle $indent if $Pretty_XDF_Output && !defined $objPCDATA;
    if(!$dontCloseNode) {
       print $fileHandle "</". $nodename . ">";
    }

  } else {

    if ($dontCloseNode) {
      # It may not have sub-objects, but we dont want to close it
      # (this happens for group objects).
      print $fileHandle ">";
    } else {
      # no sub-objects, just close this node
      print $fileHandle "/>";
    }

  }

}

sub _init {
  my ($self) = @_;

  $self->SUPER::_init();

  $self->{_hasValueListCompactDescription} = 0;
  $self->{valueListObjects} = [];

  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

}

sub _doObjectListtoXMLFileHandle {
   my ($self, $objListRef, $fileHandle, $indent, $Pretty_XDF_Output, $Pretty_XDF_Output_Indentation) = @_;

   my $valueListGetMethod = $self->{_valueListGetMethodName};
   if ( $self->{_hasValueListCompactDescription} &&
        defined $valueListGetMethod &&
        $objListRef eq $self->$valueListGetMethod )
   {

      foreach my $valueListObj (@{$self->{valueListObjects}}) 
      {
         # Grouping *may* differ between the values held in each ValueLists. To check we
         # if all valueListObjects are 'kosher' we use the first value in the values 
         # list of each ValueListObj as a reference object and compare it to all other
         # values in that list (but not the lists of values in other ValueListObj). Yes, 
         # this can be slow for large lists of values but is the correct thing to do.
         my @values = @{$valueListObj->getValues()};
         my $valueObj = $values[0];

         # *sigh* Yes, we have to check that all values belong to 
         # the same groups, or problems will arise in the output. Do that here. 
         my $canUseCompactValueDescription = 1;
         my $firstValueGroups = $valueObj->{_groupMemberHash};

         foreach my $valIndex (1 .. $#values) {
            my $thisValue = $values[$valIndex];
            if (defined $thisValue) {
               my $thisValuesGroups = $thisValue->{_groupMemberHash};
               # are these hashes equivalent? No means differing group membership
               if (&_hashesAreEquivalent($firstValueGroups,$thisValuesGroups)) {
                  warn ("Cant use short description for values because some values have differing groups! Using long description instead.");
                  $canUseCompactValueDescription = 0;
                  last;
               }
            }
         }

         if ($canUseCompactValueDescription) {
            # use compact description
            $indent = $self->_deal_with_closing_group_nodes($valueObj, $fileHandle, $indent, $Pretty_XDF_Output, $Pretty_XDF_Output_Indentation);
            $indent = $self->_deal_with_opening_group_nodes($valueObj, $fileHandle, $indent, $Pretty_XDF_Output_Indentation);
            $valueListObj->toXMLFileHandle($fileHandle, $indent . $Pretty_XDF_Output_Indentation);

         } else {
            # use long description
            $indent = $self->_objectToXMLFileHandle($fileHandle, \@values, $indent, $Pretty_XDF_Output,
                                                             $Pretty_XDF_Output_Indentation);
         }
      }

   } else { 

         # use long description
         $indent = $self->_objectToXMLFileHandle($fileHandle, $objListRef, $indent, $Pretty_XDF_Output,
                                                          $Pretty_XDF_Output_Indentation);
   }

   return $indent;

}

# checking to see that all the members of each hash
# are the same
sub _hashesAreEquivalent {
   my ($hashRef1, $hashRef2) = @_;

   my @key_values1 = keys %{$hashRef1};
   my @key_values2 = keys %{$hashRef2};

   # differing membership in groups?? Easy to return
   return 1 if ($#key_values1 != $#key_values2); 

   # ok same number, now plug thru and make sure they
   # all match up
   foreach my $key1 (@key_values1) { 
      my $arentSame = 1;
      foreach my $key2 (@key_values2) { 
         if ($key1 eq $key2) {
            $arentSame = 0;
            last;
         } 
      }
      return 1 if ($arentSame);
   }

   return 0;
}

1;


__END__

=head1 NAME

XDF::BaseObjectWithValueList - Perl Class for BaseObjectWithValueList

=head1 SYNOPSIS

 


...

=head1 DESCRIPTION

 A 'super base object' for objects which can take valueList children. 

XDF::BaseObjectWithValueList inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::BaseObjectWithValueList.

=over 4

=item getClassAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes for this object;This method takes no arguments may not be changed.  

=item getClassXMLAttributes (EMPTY)

 

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::BaseObjectWithValueList.

=over 4

=item getValueListObjects (EMPTY)

Get a list of ValueList objects held by this object.  

=item hasValues (EMPTY)

 

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::BaseObjectWithValueList inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::BaseObjectWithValueList inherits the following instance (object) methods of L<XDF::BaseObject>:
B<getXMLAttributes>, B<setXMLAttributes>, B<getXMLAttribute>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L< XDF::Parameter>, L< XDF::ValueListAlgorithm>, L< XDF::ValueListDelimitedList>, L<XDF::BaseObject>, L<XDF::Log>

=back

=head1 AUTHOR

    Brian Thomas  (brian.thomas@gsfc.nasa.gov)
    XML Group <http://xml.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut
