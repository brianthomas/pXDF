
# $Id$

package XDF::Structure;

# /** COPYRIGHT
#    Structure.pm Copyright (C) 2000 Brian Thomas,
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
# XDF is the eXtensible Data Structure, which is an XML format
# designed to contain n-dimensional scientific/mathematical data.
#@   
#@   
# The XDF can hold both tagged and untagged data and may serve as
# a wrapper around many kinds of legacy data.
#@   
#@   
# XDF::Structure is a means of grouping/associating XDF::Parameter objects, which hold 
# scientific content of the data, and XDF::Array objects which hold the mathematical content 
# of the data. If an XDF::Structure holds a parameter with several XDF::Array objects then the 
# parameter is assumed to be applicable to all of the array child nodes. Sub-structure (e.g. other 
# XDF::Structure objects) may be held within a structure to create more fine-grained associations
# between parameters and arrays.
# */

#/** SYNOPSIS
#
#    use XDF::Structure;
#  
#    my %attributes = ( 
#                       'name' => 'A default name',
#                       'paramList' => @paramObjRefList,
#                       'arrayList' => @arrayRefList,
#                     );
#
#    # initialize new object w/ attribute hash
#    my $structObj = XDF::Structure->new(%attributes);
#
#    # overwrite the name attribute w/ new value, set the description 
#    $structObj->setName("My Structure");
#    $structObj->setDescription("This data was found under under a cabinet. It looks important.");
#
#    # add an XDF::Array object to the structure
#    $structObj->addArray($arrayObj);
#
#    ...
#
#    # for another filled in structure..
#
#    # print out all it parameters names 
#    foreach my $paramObj (@{$structObj2->getParamList()}) {
#       print STDOUT "parameter name: ",$paramObj->getName(),"\n"; 
#    }
#    
#    # replace the list of arrays owned by this structure with
#    # a new one.
#
#    $structObj2->setArrayList(\@newArrayRefList);
#
#   ...
#
#    # create a structure from a file
#
#    my $XDFStructObj = new XDF::Structure();
#
#    # read method makes a call to XDF::Reader. %options
#    # has same meaning here as for createXDFObjectfromFile 
#    # method in XDF::Reader.
#
#    $XDFStructObj = $XDFStructObj->loadFromXDFFile($file, \%options);
#
#    # create a structure from a file (alternative method) 
#
#    my $reader = new XDF::Reader();
#    my $XDFStructObj2 = $reader->parseFile($file, \%options);
#
# */

use Carp;

use XDF::BaseObjectWithXMLElements;
use XDF::Array;
use XDF::Reader;
use XDF::Parameter;
use XDF::ParameterGroup;

use strict;
use integer;

use vars qw ($AUTOLOAD @ISA %field);

# inherits from XDF::BaseObjectWithXMLElements 
@ISA = ("XDF::BaseObjectWithXMLElements");

# CLASS DATA
my $Class_XML_Node_Name = "structure";
# NOTE: if you ADD/Change an attribute here, make sure it is
# properly re-inited in the _init method or you will be sorry!!!
my @Class_XML_Attributes = qw (
                                 name
                                 description
                                 paramList
                                 structList
                                 arrayList
                                 noteList
                              ); 
my @Class_Attributes = qw (
                             _paramGroupOwnedHash
                          ); 

# Description of class attributes: 
# /** name
# A scalar string containing the name of this XDF::Structure. 
# */
# /** description
# A scalar string containing the description (long name) of this XDF::Structure. 
# */
# /** paramList
# A scalar list reference to the XDF::Parameter objects held by this XDF::Structure.
# */
# /** structList
# A scalar list reference to the XDF::Structure objects held by this XDF::Structure.
# */
# /** arrayList
# A scalar list reference to the XDF::Array objects held by this XDF::Structure.
# */

# add in class XML attributes
push @Class_Attributes, @Class_XML_Attributes;

# add in super class attributes
push @Class_Attributes, @{&XDF::BaseObjectWithXMLElements::classAttributes};

# add in super class XML attributes to our list 
push @Class_XML_Attributes, @{&XDF::BaseObjectWithXMLElements::getXMLAttributes};

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classXMLNodeName
# This method takes no arguments may not be changed. 
# This method returns the class node name for XDF::Structure; 
# */
sub classXMLNodeName { 
  return $Class_XML_Node_Name; 
}

# /** classAttributes
#  This method takes no arguments may not be changed. 
#  This method returns a list reference containing the names
#  of the class attributes for XDF::Structure; 
# */
sub classAttributes { 
  return \@Class_Attributes; 
}

# 
# SET/GET Methods
#

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

# /** getDescription
#  */
sub getDescription { 
   my ($self) = @_; 
   return $self->{Description}; 
}

# /** setDescription
#  */
sub setDescription { 
   my ($self, $value) = @_; 
   $self->{Description} = $value; 
}

# /** getArrayList
#  */
sub getArrayList { 
   my ($self) = @_; 
   return $self->{ArrayList}; 
}

# /** setArrayList
#  */
sub setArrayList { 
   my ($self, $arrayRefValue) = @_;
   # you must do it this way, or when the arrayRef changes it changes us here!
   my @list = @{$arrayRefValue};
   $self->{ArrayList} = \@list; 
}

# /** getStructList
#  */
sub getStructList { 
   my ($self) = @_; 
   return $self->{StructList}; 
}

# /** setStructList
#  */
sub setStructList { 
   my ($self, $arrayRefValue) = @_;
   # you must do it this way, or when the arrayRef changes it changes us here!
   my @list = @{$arrayRefValue};
   $self->{StructList} = \@list; 
}

# /** getParamList
#  */
sub getParamList { 
   my ($self) = @_; 
   return $self->{ParamList}; 
}

# /** setParamList
#  */
sub setParamList { 
   my ($self, $arrayRefValue) = @_;
   # you must do it this way, or when the arrayRef changes it changes us here!
   my @list = @{$arrayRefValue};
   $self->{ParamList} = \@list; 
}

# /** getNoteList
#  */
sub getNoteList { 
   my ($self) = @_; 
   return $self->{NoteList}; 
}

# /** setNoteList
#  */
sub setNoteList { 
   my ($self, $arrayRefValue) = @_;
   # you must do it this way, or when the arrayRef changes it changes us here!
   my @list = @{$arrayRefValue};
   $self->{NoteList} = \@list; 
}

# /** getXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
sub getXMLAttributes { 
  return \@Class_XML_Attributes; 
}
  
#
# Other Public Methods 
#

# /** addNote
# Insert an XDF::Note object into the XDF::Notes object held by this object.
# RETURNS : 1 on success, 0 on failure.
# */
sub addNote {
  my ($self, $noteObj) = @_;

  return 0 unless defined $noteObj && ref $noteObj;

  # add the parameter to the list
  push @{$self->{NoteList}}, $noteObj;

  return 1;
}

# /** removeNote
# Removes an XDF::Note object from the list of XDF::Note objects
# held within the XDF::Notes object of this object. This method takes 
# either the list index number or an object reference as its argument.
# RETURNS : 1 on success, 0 on failure.
# */
sub removeNote {
  my ($self, $what) = @_;
  return $self->_remove_from_list($what, $self->{NoteList}, 'noteList');
}

# /** addParameter 
# Insert an XDF::Parameter object into this object.
# RETURNS : 1 on success, 0 on failure.
# */
sub addParameter {
  my ($self, $paramObj) = @_;

  return 0 unless defined $paramObj && ref $paramObj;

  # add the parameter to the list
  push @{$self->{ParamList}}, $paramObj;

  return 1;
}

# /** removeParameter 
# Remove an XDF::Parameter object from the list of XDF::Parameters
# held within this object. This method takes either the list index 
# number or an object reference as its argument.
# RETURNS : 1 on success, 0 on failure.
# */
sub removeParameter {
  my ($self, $indexOrObjectRef) = @_;
  return $self->_remove_from_list($indexOrObjectRef, $self->{ParamList}, 'paramList');
}

# /** addStructure
# Insert an XDF::Structure object into this object.
# RETURNS :  1 on success, 0 on failure.
# */
sub addStructure {
   my ($self, $structObj) = @_;

   return 0 unless defined $structObj && ref $structObj;

   # add the new structure to the list
   push @{$self->{StructList}}, $structObj;

   return 1;
}

# /** removeStructure
# Remove an XDF::Structure object from the list of XDF::Structures
# held within this object. This method takes either the list index 
# number or an object reference as its argument.
# RETURNS : 1 on success, 0 on failure.
# */
sub removeStructure {
  my ($self, $indexOrObjectRef) = @_; 
  return $self->_remove_from_list($indexOrObjectRef, $self->{StructList}, 'structList');
}

# /** addArray
# Insert an XDF::Array object into this object.
# RETURNS : 1 on success, 0 on failure.
# */
sub addArray {
   my ($self, $arrayObj) = @_;

   return 0 unless defined $arrayObj && ref $arrayObj;

   # add the parameter to the list
   push @{$self->{ArrayList}}, $arrayObj;

   return 1;
}

# /** removeArray
# Remove an XDF::Array object from the list of XDF::Arrays
# held within this object. This method takes either the list index 
# number or an object reference as its argument.
# RETURNS : 1 on success, 0 on failure.
# */
sub removeArray {
  my ($self, $indexOrObjectRef) = @_; 
  return $self->_remove_from_list($indexOrObjectRef, $self->{ArrayList}, 'arrayList');
}

# /** addParamGroup
# Insert an XDF::ParameterGroup object into this object.
# RETURNS : 1 on success, 0 on failure.
# */
sub addParamGroup {
  my ($self, $groupObj) = @_;

  return 0 unless defined $groupObj && ref $groupObj;

  # add the group to the groupOwnedHash
  %{$self->{_paramGroupOwnedHash}}->{$groupObj} = $groupObj;

  return 1;
}

# /** removeParamGroup
# Remove an XDF::ParameterGroup object from the hash table of XDF::ParameterGroups 
# held within this object. This method takes the hash key 
# its argument. RETURNS : 1 on success, 0 on failure.
# */
sub removeParamGroup { 
   my ($self, $hashKey) = @_; 
   if (exists %{$self->{_paramGroupOwnedHash}}->{$hashKey}) {
      delete %{$self->{_paramGroupOwnedHash}}->{$hashKey}; 
      return 1;
   }
   return 0;
}

# /** loadFromXDFFile
# Read in an XML file into this structure. The current structure, 
# if it has any components, is overrided and lost. 
# */
sub loadFromXDFFile {
  my ($self, $file, $optionsHashRef) = @_;

  my $reader = new XDF::Reader($optionsHashRef);
  $self->_init(); # clear out old structure
  $reader->setReaderStructureObject($self);
  $self = $reader->parseFile($file);
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

sub _init {
  my ($self) = @_;
  
  $self->SUPER::_init(); 

  # re-initialize attribs
  # this is only needed for Structure and not other XDF objects because
  # of the needs of its loadXDFFromFile method 
  $self->{Name} = undef; 
  $self->{Description} = undef; 

  # initialize lists
  $self->{StructList} = [];
  $self->{ParamList} = [];
  $self->{ArrayList} = [];
  $self->{NoteList} = [];

  $self->{_paramGroupOwnedHash} = {};

}

# Modification History
#
# $Log$
# Revision 1.12  2001/06/29 21:07:12  thomas
# changed public add (and remove) methods to
# conform to Java API standard: e.g. return boolean
# rather than an object. Also, these methods only
# accept an object (in general) as input (instead of an attribute hash).
#
# Revision 1.11  2001/04/25 16:01:31  thomas
# updated documentation
#
# Revision 1.10  2001/04/17 19:00:41  thomas
# Using Specification class now.
# Properly calling superclass init now.
# Now using BaseObjectWithXMLElements as base class.
#
# Revision 1.9  2001/03/21 20:19:23  thomas
# Fixed documentation to show addXMLElement, etc. methods in perldoc
#
# Revision 1.8  2001/03/16 19:52:25  thomas
# changes to read method now Java name:
# loadFromXDFFile. Changes to that method
# to accomodate new Reader code. Now can
# load a file and it overwrites existing structure.
# Improved documentation.
#
# Revision 1.7  2001/03/14 21:32:35  thomas
# Updated perldoc section using new version of
# makeDoc.pl.
#
# Revision 1.6  2001/03/14 16:13:06  thomas
# Fixed addArray method. Wasnt treating passing an
# already allocated arrayobject correctly.
#
# Revision 1.5  2000/12/15 22:12:00  thomas
# Regenerated perlDoc section in files. -b.t.
#
# Revision 1.4  2000/12/14 22:11:26  thomas
# Big changes to the API. get/set methods, added Href/Entity stuff, deep cloning,
# added Href, Notes, NotesLocationOrder nodes/classes. Ripped out _enlarge_array
# from DataCube (not needed) and fixed problems outputing delimited/formatted
# read nodes. -b.t.
#
# Revision 1.3  2000/12/01 20:03:38  thomas
# Brought Pod docmentation up to date. Bumped up version
# number. -b.t.
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

XDF::Structure - Perl Class for Structure

=head1 SYNOPSIS


    use XDF::Structure;
  
    my %attributes = ( 
                       'name' => 'A default name',
                       'paramList' => @paramObjRefList,
                       'arrayList' => @arrayRefList,
                     );

    # initialize new object w/ attribute hash
    my $structObj = XDF::Structure->new(%attributes);

    # overwrite the name attribute w/ new value, set the description 
    $structObj->setName("My Structure");
    $structObj->setDescription("This data was found under under a cabinet. It looks important.");

    # add an XDF::Array object to the structure
    $structObj->addArray($arrayObj);

    ...

    # for another filled in structure..

    # print out all it parameters names 
    foreach my $paramObj (@{$structObj2->getParamList()}) {
       print STDOUT "parameter name: ",$paramObj->getName(),"\n"; 
    }
    
    # replace the list of arrays owned by this structure with
    # a new one.

    $structObj2->setArrayList(\@newArrayRefList);

   ...

    # create a structure from a file

    my $XDFStructObj = new XDF::Structure();

    # read method makes a call to XDF::Reader. %options
    # has same meaning here as for createXDFObjectfromFile 
    # method in XDF::Reader.

    $XDFStructObj = $XDFStructObj->loadFromXDFFile($file, \%options);

    # create a structure from a file (alternative method) 

    my $reader = new XDF::Reader();
    my $XDFStructObj2 = $reader->parseFile($file, \%options);



...

=head1 DESCRIPTION

 XDF is the eXtensible Data Structure, which is an XML format designed to contain n-dimensional scientific/mathematical data.     
    
 The XDF can hold both tagged and untagged data and may serve as a wrapper around many kinds of legacy data.     
    
 XDF::Structure is a means of grouping/associating XDF::Parameter objects, which hold  scientific content of the data, and XDF::Array objects which hold the mathematical content  of the data. If an XDF::Structure holds a parameter with several XDF::Array objects then the  parameter is assumed to be applicable to all of the array child nodes. Sub-structure (e.g. other  XDF::Structure objects) may be held within a structure to create more fine-grained associations between parameters and arrays. 

XDF::Structure inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>, L<XDF::BaseObjectWithXMLElements>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::Structure.

=over 4

=item classXMLNodeName (EMPTY)

This method takes no arguments may not be changed. This method returns the class node name for XDF::Structure;  

=item classAttributes (EMPTY)

This method takes no arguments may not be changed. This method returns a list reference containing the namesof the class attributes for XDF::Structure;  

=item getXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::Structure.

=over 4

=item getName (EMPTY)

 

=item setName ($value)

Set the name attribute.  

=item getDescription (EMPTY)

 

=item setDescription ($value)

 

=item getArrayList (EMPTY)

 

=item setArrayList ($arrayRefValue)

 

=item getStructList (EMPTY)

 

=item setStructList ($arrayRefValue)

 

=item getParamList (EMPTY)

 

=item setParamList ($arrayRefValue)

 

=item getNoteList (EMPTY)

 

=item setNoteList ($arrayRefValue)

 

=item addNote ($info)

Insert an XDF::Note object into the XDF::Notes object held by this object. This method may optionally take a reference to an attribute hash asits argument. Attributes in the attribute hash shouldcorrespond to attributes of the L<XDF::Note> object. The attribute/value pairs in the attribute hash reference areused to initialize the new XDF::Note object. RETURNS : an XDF::Note object reference on success, undef on failure.  

=item removeNote ($what)

Removes an XDF::Note object from the list of XDF::Note objectsheld within the XDF::Notes object of this object. This method takes either the list index number or an object reference as its argument. RETURNS : 1 on success, undef on failure.  

=item addParameter ($attribHashReference)

Insert an XDF::Parameter object into this object. This method may optionally take a reference to an attribute hash asits argument. Attributes in the attribute hash shouldcorrespond to attributes of the L<XDF::Parameter> object. The attribute/value pairs in the attribute hash reference areused to initialize the new XDF::Parameter object. RETURNS : an XDF::Parameter object reference on success, undef on failure.  

=item removeParameter ($indexOrObjectRef)

Remove an XDF::Parameter object from the list of XDF::Parametersheld within this object. This method takes either the list index number or an object reference as its argument. RETURNS : 1 on success, undef on failure.  

=item addStructure ($attribHashReference)

Insert an XDF::Structure object into this object. This method may optionally take a reference to an attribute hash asits argument. Attributes in the attribute hash shouldcorrespond to attributes of the L<XDF::Structure> object. The attribute/value pairs in the attribute hash reference areused to initialize the new XDF::Structure object. RETURNS : an XDF::Structure object reference on success, undef on failure.  

=item removeStructure ($indexOrObjectRef)

Remove an XDF::Structure object from the list of XDF::Structuresheld within this object. This method takes either the list index number or an object reference as its argument. RETURNS : 1 on success, undef on failure.  

=item addArray ($attribHashOrObjectReference)

Insert an XDF::Array object into this object. This method may optionally take a reference to an attribute hash asits argument. Attributes in the attribute hash shouldcorrespond to attributes of the L<XDF::Array> object. The attribute/value pairs in the attribute hash reference areused to initialize the new XDF::Array object. RETURNS : an XDF::Array object reference on success, undef on failure.  

=item removeArray ($indexOrObjectRef)

Remove an XDF::Array object from the list of XDF::Arraysheld within this object. This method takes either the list index number or an object reference as its argument. RETURNS : 1 on success, undef on failure.  

=item addParamGroup ($objectRefOrAttribHashRef)

Insert an XDF::ParameterGroup object into this object. This method takes either a reference to an attribute hash ORobject reference to an existing XDF::ParameterGroup asits argument. Attributes in the attribute hash reference shouldcorrespond to attributes of the L<XDF::ParameterGroup> object. The attribute/value pairs in the attribute hash reference areused to initialize the new XDF::ParameterGroup object. RETURNS : an XDF::ParameterGroup object reference on success, undef on failure.  

=item removeParamGroup ($hashKey)

Remove an XDF::ParameterGroup object from the hash table of XDF::ParameterGroups held within this object. This method takes the hash key its argument. RETURNS : 1 on success, undef on failure.  

=item loadFromXDFFile ($file, $optionsHashRef)

Read in an XML file into this structure. The current structure, if it has any components, is overrided and lost.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::Structure inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::Structure inherits the following instance (object) methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLAttributes>, B<toXMLString>, B<toXMLFile>.

=back



=over 4

XDF::Structure inherits the following instance (object) methods of L<XDF::BaseObjectWithXMLElements>:
B<addXMLElement>, B<removeXMLElement>, B<getXMLElementList>, B<setXMLElementList>, B<toXMLFileHandle>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::BaseObjectWithXMLElements>, L<XDF::Array>, L<XDF::Reader>, L<XDF::Parameter>, L<XDF::ParameterGroup>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut
