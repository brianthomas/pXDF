
package XDF::Reader;

# a module to read in XDF files, both in 
# tagged and untagged formats.

# $Id$

# /** COPYRIGHT
#    Reader.pm Copyright (C) 2000 Brian Thomas,
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


# TODO
# - We also need to allow options to 
#     1 - use parser other than Expat (?)
#

# /** DESCRIPTION
# This class allows the user to create XDF objects from XDF files. 
# XDF::Reader will read in both Binary and ASCII data and tagged/delimited/
# and formatted XDF data styles are supported.
# */

# /** AUTHOR
#    Brian Thomas  (brian.thomas@gsfc.nasa.gov)
#    XML Group <http://xml.gsfc.nasa.gov>
#    NASA/Goddard Space Flight Center
# */

# /** SYNOPSIS
#
#    my $DEBUG = 1;
#
#    # test file for reading in XDF files.
#
#    my $file = $ARGV[0];
#    my %options = ( 'quiet' => $DEBUG, 
#                    'validate' => 0, 
#                    'loadDataOnDemand' => 1
#                    'cacheDataOnDisk' => 1
#                   );
#
#    my $XDFReader = new XDF::Reader(\%options);
#    my $XDFObject = $XDFReader->parseFile($file);
#
# */

use XML::DOM;

use XDF::Add;
use XDF::Array;
use XDF::ArrayRefDataFormat;
use XDF::BinaryFloatDataFormat;
use XDF::BinaryIntegerDataFormat;
use XDF::ColAxis;
use XDF::Conversion;
use XDF::Constants;
use XDF::DelimitedXMLDataIOStyle;
use XDF::Delimiter;
use XDF::DocumentType;
use XDF::Entity;
use XDF::Exponent;
use XDF::ExponentOn;
use XDF::Field;
use XDF::FloatDataFormat;
use XDF::FormattedXMLDataIOStyle;
use XDF::TaggedXMLDataIOStyle;
use XDF::LogarithmBase;
use XDF::Log;
use XDF::Multiply;
use XDF::NaturalLogarithm;
use XDF::NewLine;
use XDF::NotationNode;
use XDF::IntegerDataFormat;
use XDF::Parameter;
use XDF::Polynomial;
use XDF::Reader::ValueList;
use XDF::RecordTerminator;
use XDF::Relation;
use XDF::RepeatFormattedIOCmd;
use XDF::ReadCellFormattedIOCmd;
use XDF::RowAxis;
use XDF::SkipCharFormattedIOCmd;
use XDF::StringDataFormat;
use XDF::Structure;
use XDF::ValueListAlgorithm;
use XDF::ValueListDelimitedList;
use XDF::XMLDataIOStyle;
use XDF::XMLElementNode;
use XDF::XMLDeclaration;
use XDF::XDF;

use vars qw ($VERSION %field);

# look for the checker, if its installed use it
# otherwise, fall back to the (regular) non-validating
# version of the parser
BEGIN {
  unless (eval "use XML::Checker::Parser" ) {
     use XML::Parser;
  }
} 

use strict;
use integer;

                              #lastFieldGroupParentObject
                              #tagCount
                              #lastUnitsObject
my @Class_Attributes = qw (
                              Options
                              startElementHandler
                              endElementHandler
                              charDataHandler
                              defaultHandler
                              XDF
                              currentStructure
                              currentArray
                              currentDataTagLevel
                              currentFieldGroupList
                              currentFormatObjectList
                              currentArrayAxes
                              currentNodePath
                              currentParamGroupList
                              currentCol
                              gotACellread
                              currentRow
                              currentValueList
                              currentValueGroupList
                              dataTagLevel
                              DoctypeObjectAttributes
                              Notation
                              UnParsedEntity
                              Entity
                              taggedLocatorObject
                              dataFormatAttribRef
                              dataIOStyleAttribRef
                              ForceSetXMLHeaderStuff
                              nrofWarnings
                              ArrayObj
                              AxisObj
                              FieldObj
                              NoteObj
                              XMLDataIOStyleObj
                              dataBlock
                              dataNodeLevel
                              readAxisOrderList
                              readAxisOrderHash
                              noteLocatorOrder
                              psuedoSimpleReadObj
                              lastObjList
                              lastNoteObject
                              lastUnitObject
                              lastParamObject
                              lastNotesParentObject
                              lastParamGroupParentObject
                              lastValueGroupParentObject
                              lastValueObjAttribRef
                          );

#
# CLASS DATA
#

$VERSION = "0.18"; # the version of this module, what version of XDF
                   # it will read in.

my %XDF_node_name = &XDF::Constants::XDF_NODE_NAMES;

# this is a BAD thing. I have been having troubles distinguishing between
# important whitespace (e.g. char data within a data node) and text nodes
# that are purely for the layout of the XML document. Right now I use the 
# CRUDE distinquishing characteristic that fluff (eg. only there for the sake
# of formatting the output doc) text nodes are all whitespace.
# Used by TAGGED data arrays
my $IGNORE_WHITESPACE_ONLY_DATA = 1;

# OPTIONS for running the parser
my $MAX_WARNINGS = 10; # how many warnings we can have before termination. 
                       # Set to 0 for unlimited warnings 
my $DEBUG = 0; # for printing out debug information from class methods 
my $QUIET = 1; # if enabled it suppresses warnings from class methods 
my $DONT_LOAD_DATA_YET = 1; # if enabled, then no data will be loaded by reader.
                            # until it is demanded by user request
my $STORE_DATA_ON_DISK = 0; # if enabled, then data will be stored on disk rather
                            # than in memory. Usefull for large data files, but performance is generally slower.
my $PARSER_MSG_THRESHOLD = 200; # we print all messages equal to and below this threshold

my %Default_Handler = ( 'start' => sub { &_default_start_handler(@_); }, 
                        'end' => sub { &_null_cmd(); },
                        'cdata' => sub { &_default_cdata_handler(@_); },
                      );

# dispatch table for the start node handler of the parser
#                       $XDF_node_name{'axisUnits'}    => sub { &_axisUnits_node_start(@_); },
my %Start_Handler = (
                       $XDF_node_name{'add'}          => sub { &_component_node_start(new XDF::Add(), @_); },
                       $XDF_node_name{'array'}        => sub { &_array_node_start(@_); },
                       $XDF_node_name{'arrayRef'}     => sub { &_arrayRefField_node_start(@_); },
                       $XDF_node_name{'axis'}         => sub { &_axis_node_start(@_); },
                       $XDF_node_name{'binaryFloat'}  => sub { &_binaryFloatField_node_start(@_); },
                       $XDF_node_name{'binaryInteger'} => sub { &_binaryIntegerField_node_start(@_); },
                       $XDF_node_name{'cell' }        => sub { &_cell_node_start(@_); },
                       $XDF_node_name{'chars'}        => sub { &_chars_node_start(@_); },
                       $XDF_node_name{'colAxis'}      => sub { &_colaxis_node_start(@_); },
                       $XDF_node_name{'column' }      => sub { &_column_node_start(@_); },
                       $XDF_node_name{'conversion' }  => sub { &_conversion_node_start(@_); },
                       $XDF_node_name{'data'}         => sub { &_data_node_start(@_); },
                       $XDF_node_name{'dataFormat'}   => sub { &_dataFormat_node_start(@_); },
                       $XDF_node_name{'dataStyle'}         => sub { &_read_node_start(@_);},
                       $XDF_node_name{'doInstruction'} => sub { &_null_cmd(@_);},
                       $XDF_node_name{'delimiter'}    => sub { &_delimiter_node_start(@_); },
                       $XDF_node_name{'delimitedStyle'} => sub { &_asciiDelimiter_node_start(@_); },
                       $XDF_node_name{'delimitedReadInstructions'} => sub { &_null_cmd(@_); },
                       $XDF_node_name{'exponent'}     => sub { &_component_node_start(new XDF::Exponent(), @_); },
                       $XDF_node_name{'exponentOn'}   => sub { &_component_node_start(new XDF::ExponentOn(), @_); },
                       $XDF_node_name{'field'}        => sub { &_field_node_start(@_); },
                       $XDF_node_name{'fieldAxis'}    => sub { &_fieldAxis_node_start(@_); },
                       $XDF_node_name{'formattedStyle'} => sub { &_formattedStyle_node_start(@_); },
                       $XDF_node_name{'formattedReadInstructions'} => sub { &_null_cmd(@_); },
                       $XDF_node_name{'float'}        => sub { &_floatField_node_start(@_); },
                       $XDF_node_name{'for'}          => sub { &_for_node_start(@_); },
                       $XDF_node_name{'fieldGroup'}   => sub { &_fieldGroup_node_start(@_); },
                       $XDF_node_name{'index'}        => sub { &_note_index_node_start(@_); },
                       $XDF_node_name{'integer'}      => sub { &_integerField_node_start(@_); },
                       $XDF_node_name{'locationOrder'}=> sub { &_null_cmd(@_); },
                       $XDF_node_name{'logarithmBase'}=> sub { &_component_node_start(new XDF::LogarithmBase(), @_); },
                       $XDF_node_name{'multiply'}     => sub { &_component_node_start(new XDF::Multiply(), @_); },
                       $XDF_node_name{'naturalLogarithm'}=> sub { &_component_node_start(new XDF::NaturalLogarithm(), @_); },
                       $XDF_node_name{'newline'}      => sub { &_newLine_node_start(@_); },
                       $XDF_node_name{'note'}         => sub { &_note_node_start(@_); },
                       $XDF_node_name{'notes'}        => sub { &_notes_node_start(@_); },
                       $XDF_node_name{'parameter'}    => sub { &_parameter_node_start(@_); },
                       $XDF_node_name{'parameterGroup'} => sub { &_parameterGroup_node_start(@_); },
                       $XDF_node_name{'polynomial'}    => sub { &_polynomial_node_start(@_); },
                       $XDF_node_name{'readCell'}     => sub { &_readCell_node_start(@_);},
                       $XDF_node_name{'recordTerminator'} => sub { &_recordTerminator_node_start(@_); },
                       $XDF_node_name{'repeat'}       => sub { &_repeat_node_start(@_); },
                       $XDF_node_name{'relationship'} => sub { &_relationship_node_start(@_); },
                       $XDF_node_name{'root'}         => sub { &_root_node_start(@_); },
                       $XDF_node_name{'rowAxis'}      => sub { &_rowaxis_node_start(@_); },
                       $XDF_node_name{'row'}          => sub { &_row_node_start(@_);},
                       $XDF_node_name{'skipChar'}     => sub { &_skipChar_node_start(@_); },
                       $XDF_node_name{'string'}       => sub { &_stringField_node_start(@_); },
                       $XDF_node_name{'structure'}    => sub { &_structure_node_start(@_); },
                       $XDF_node_name{'taggedStyle'}  => sub { &_taggedStyle_node_start(@_); },
                       $XDF_node_name{'tagToAxis'}    => sub { &_tagToAxis_node_start(@_);},
                       $XDF_node_name{'td0'}          => sub { &_dataTag_node_start(@_);},
                       $XDF_node_name{'td1'}          => sub { &_dataTag_node_start(@_);},
                       $XDF_node_name{'td2'}          => sub { &_dataTag_node_start(@_);},
                       $XDF_node_name{'td3'}          => sub { &_dataTag_node_start(@_);},
                       $XDF_node_name{'td4'}          => sub { &_dataTag_node_start(@_);},
                       $XDF_node_name{'td5'}          => sub { &_dataTag_node_start(@_);},
                       $XDF_node_name{'td6'}          => sub { &_dataTag_node_start(@_);},
                       $XDF_node_name{'td7'}          => sub { &_dataTag_node_start(@_);},
                       $XDF_node_name{'td8'}          => sub { &_dataTag_node_start(@_);},
                       $XDF_node_name{'unit'}         => sub { &_unit_node_start(@_); },
                       $XDF_node_name{'units'}        => sub { &_units_node_start(@_); },
                       $XDF_node_name{'unitless'}     => sub { &_unitless_node_start(@_); },
                       $XDF_node_name{'value'}        => sub { &_null_cmd(@_); },
                       $XDF_node_name{'valueGroup'}   => sub { &_valueGroup_node_start(@_); },
                       $XDF_node_name{'valueList'}    => sub { &_valueList_delimited_node_start(@_); },
                       $XDF_node_name{'valueListAlgorithm'}    => sub { &_valueList_algorithm_node_start(@_); },
                       $XDF_node_name{'value'}        => sub { &_value_node_start(@_); },
                       $XDF_node_name{'vector'}       => sub { &_vector_node_start(@_); } ,
                    );

# dispatch table for the end element handler of the parser
my %End_Handler = (
                       $XDF_node_name{'array'}        => sub { &_array_node_end(@_); },
                       $XDF_node_name{'cell' }        => sub { &_cell_node_end(@_); },
                       $XDF_node_name{'column'}       => sub { &_column_node_end(@_); },
                       $XDF_node_name{'data'}         => sub { &_data_node_end(@_); },
                       $XDF_node_name{'fieldGroup'}   => sub { &_fieldGroup_node_end(@_); },
                       $XDF_node_name{'notes'}        => sub { &_notes_node_end(@_); },
                       $XDF_node_name{'parameterGroup'} => sub { &_parameterGroup_node_end(@_); },
                       $XDF_node_name{'repeat'}       => sub { &_repeat_node_end(@_); },
                       $XDF_node_name{'row'}          => sub { &_row_node_end(@_); },
                       $XDF_node_name{'td0'}          => sub { &_dataTag_node_end(0, @_);},
                       $XDF_node_name{'td1'}          => sub { &_dataTag_node_end(1, @_);},
                       $XDF_node_name{'td2'}          => sub { &_dataTag_node_end(2, @_);},
                       $XDF_node_name{'td3'}          => sub { &_dataTag_node_end(3, @_);},
                       $XDF_node_name{'td4'}          => sub { &_dataTag_node_end(4, @_);},
                       $XDF_node_name{'td5'}          => sub { &_dataTag_node_end(5, @_);},
                       $XDF_node_name{'td6'}          => sub { &_dataTag_node_end(6, @_);},
                       $XDF_node_name{'td7'}          => sub { &_dataTag_node_end(7, @_);},
                       $XDF_node_name{'td8'}          => sub { &_dataTag_node_end(8, @_);},
                       $XDF_node_name{'valueGroup'}   => sub { &_valueGroup_node_end(@_); },
                       $XDF_node_name{'value'}        => sub { &_value_node_end(@_); },
                       $XDF_node_name{'valueList'}    => sub { &_valueList_node_end(@_); },
                       $XDF_node_name{'valueListAlgorithm'}    => sub { &_valueList_node_end(@_); },
                  );

# dispatch table for the chardata handler of the parser
my %CharData_Handler = (

                          $XDF_node_name{'add'}        => sub { &_component_node_charData(@_); },
                          $XDF_node_name{'data'}       => sub { &_data_node_charData(@_); },
                          $XDF_node_name{'cell'}       => sub { &_cell_node_charData(@_); },
                          $XDF_node_name{'column'}     => sub { &_simpleDelimited_node_charData(@_); },
                          $XDF_node_name{'exponent'}   => sub { &_component_node_charData(@_); },
                          $XDF_node_name{'exponentOn'} => sub { &_component_node_charData(@_); },
                          $XDF_node_name{'logarithmBase'} => sub { &_component_node_charData(@_); },
                          $XDF_node_name{'multiply'}   => sub { &_component_node_charData(@_); },
                          $XDF_node_name{'note'}       => sub { &_note_node_charData(@_); },
                          $XDF_node_name{'polynomial'} => sub { &_polynomial_node_charData(@_); },
                          $XDF_node_name{'row'}        => sub { &_simpleDelimited_node_charData(@_); },
                          $XDF_node_name{'td0'}        => sub { &_taggedData_node_charData(@_); },
                          $XDF_node_name{'td1'}        => sub { &_taggedData_node_charData(@_); },
                          $XDF_node_name{'td2'}        => sub { &_taggedData_node_charData(@_); },
                          $XDF_node_name{'td3'}        => sub { &_taggedData_node_charData(@_); },
                          $XDF_node_name{'td4'}        => sub { &_taggedData_node_charData(@_); },
                          $XDF_node_name{'td5'}        => sub { &_taggedData_node_charData(@_); },
                          $XDF_node_name{'td6'}        => sub { &_taggedData_node_charData(@_); },
                          $XDF_node_name{'td7'}        => sub { &_taggedData_node_charData(@_); },
                          $XDF_node_name{'td8'}        => sub { &_taggedData_node_charData(@_); },
                          $XDF_node_name{'unit'}       => sub { &_unit_node_charData(@_); },
                          $XDF_node_name{'valueList'}  => sub { &_valueList_node_charData(@_); },
                          $XDF_node_name{'value'}      => sub { &_value_node_charData(@_); },
                    );

#
# Class Attribute Initalization
#

for my $attr ( @Class_Attributes ) { $field{$attr}++; }

#
# Class methods
#

#/** getReaderXDFObject
# returns the XDF object that the reader parses into.
#*/
sub getReaderXDFObject {
  my ($self) = @_;
  return $self->{XDF};
}

#/** setReaderXDFObject 
# Sets the XDF object that the reader parses into.
#*/
sub setReaderXDFObject {
  my ($self, $XDF) = @_;
  $self->{XDF} = $XDF;
}

# /** If true it tells this DocumentHandler that it should go ahead and insert XMLHeader
#  stuff even if the current parser doesnt support DTD events using reasonable
#  values.
#     */
sub setForceSetXMLHeaderStuffOnXDFObject {
   my ($self, $value) = @_;
   $self->{ForceSetXMLHeaderStuff} = $value;
}

#/** getVersion
# returns the version of the XDF DTD supported by this parser.
#*/
sub getVersion {
  return $VERSION;
}

# /** parseFile
# Reads in the given file and returns a full XDF Perl object (an L<XDF::Structure>
#  with at least one L<XDF::Array>). A second HASH argument may be supplied to 
# specify runtime options for the XDF::Reader.
# */
sub parseFile {
   my ($self, $file, $optionsHashRef) = @_;

   open (FILE, $file) or die "$0 cant open $file\n";
   $self->parseFileHandle(\*FILE, $optionsHashRef);
   close FILE;

   return $self->{XDF};
}

# /** parseFileHandle
# Similar to parseFile but takes an open filehandle as an 
# argument (so you can parse ANY open fileHandle, e.g. files, sockets, etc.
# Whatever Perl supports.).
# */
sub parseFileHandle {
  my ($self, $handle, $optionsHashRef) = @_;

  if (defined $optionsHashRef && ref($optionsHashRef)) {
     while (my ($option, $value) = each %{$optionsHashRef}) {
        $self->{Options}->{$option} = $value;
     }
  }

  if ($self->{Options}->{validate} && ! eval { new XML::Checker::Parser } ) {
    $self->_printWarning("Validating parser module (XML::Checker::Parser) not available on this system, using default non-validating parser XML::Parser.\n");
    $self->{Options}->{validate} = 0;
  }

  unless ($self->{Options}->{validate} ) {

    my $parser = $self->_create_parser();
    $parser->parse($handle);

  } else {

    my $parser = &_create_validating_parser($optionsHashRef);

    eval {
       local $XML::Checker::FAIL = sub { $self->_my_fail(@_); };
       $parser->parse($handle);
    };

    # Either XML::Parser (expat) threw an exception or my_fail() died.
    if ($@) {
       my ($msg, $loc) = split "\n", $@;
       error("MSG: $msg\n"); # the error message 
       error("$loc\n"); # print location 
    }

  } 

  return $self->{XDF};
}

# /** parseString
# Reads in the given string and returns a full XDF Perl object (an L<XDF::Structure>
# with at least one L<XDF::Array>). A second HASH argument may be supplied to 
# specify runtime options for the XDF::Reader.
# */
sub parseString {
  my ($self, $string, $optionsHashRef) = @_;

  $self->{Options} = $optionsHashRef if defined $optionsHashRef && ref($optionsHashRef);
  if (defined $optionsHashRef && ref($optionsHashRef)) {
     while (my ($option, $value) = each %{$optionsHashRef}) {
        $self->{Options}->{$option} = $value;
     }
  }


  if ($self->{Options}->{validate} && ! eval { new XML::Checker::Parser } ) {
    $self->_printWarning("Validating parser module (XML::Checker::Parser) not available on this system, using default non-validating parser XML::Parser.\n");
    $self->{Options}->{validate} = 0;
  }

  unless ($self->{Options}->{validate} ) {

    my $parser = $self->_create_parser();
    $parser->parse($string);

  } else {

    my $parser = &_create_validating_parser($optionsHashRef);
    
    eval {
       local $XML::Checker::FAIL = sub { $self->_my_fail(@_); };
       $parser->parse($string);
    };
    
    # Either XML::Parser (expat) threw an exception or my_fail() died.
    if ($@) {
       my ($msg, $loc) = split "\n", $@;
       print "MSG: $msg\n"; # the error message 
       print "$loc\n"; # print location 
    }

  }

  return $self->{XDF};
 
}

#
# Object M E T H O D S 
#

#
# PUBLIC Methods
#

# /** new
# Create a new reader object. Returns the reader object if successfull.
# It takes an optional argument of an option HASH Reference  
# to initialize the object options.  
# */
sub new {
  my ($proto, $optionsHashRef) = @_;

  my $class = ref ($proto) || $proto;
  my $self = bless( { }, $class);

  $self->_init($optionsHashRef);

  return $self;

}

#/** addStartElementHandlers
# Add new handlers to the internal XDF::Parser start element handler. The form of  
# the entries in the passed hash should be 'nodename' => sub { &handler_for_nodename(@_); }; 
# If a 'nodename' for a handler already exists in the XDF start handler table,  
# this method will override it with the new handler. 
# Returns 1 on success, 0 on failure.
#*/
sub addStartElementHandlers {
  my ($self, %newHandlers) = @_;

  return 0 unless %newHandlers;

  # merge into existing XDF handlers
  while ( my ($k, $v) = each (%newHandlers)) {
     $self->{startElementHandler}->{$k} = $v;
  }

  return 1;
}

#/** addEndElementHandlers
# Add new handlers to the internal XDF::Parser end element handler. The form of  
# the entries in the passed hash should be 'nodename' => sub { &handler_for_nodename(@_); }; 
# If a 'nodename' for a handler already exists in the XDF end handler table,  
# this method will override it with the new handler. 
# Returns 1 on success, 0 on failure.
#*/
sub addEndElementHandlers {
  my ($self, %newHandlers) = @_;

  return 0 unless %newHandlers;

  # merge into existing XDF handlers
  while ( my ($k, $v) = each (%newHandlers)) {
     $self->{endElementHandler}->{$k} = $v;
  }
  return 1;

}

#/** addCharDataHandlers
# Add new handlers to the internal XDF::Parser CDATA element handler. The form of  
# the entries in the passed hash should be 'nodename' => sub { &handler_for_nodename(@_); }; 
# If a 'nodename' for a handler already exists in the XDF CDATA handler table,  
# this method will override it with the new handler. 
# returns 1 on success, 0 on failure. 
#*/
sub addCharDataHandlers {
  my ($self, %newHandlers) = @_;

  return 0 unless %newHandlers;

  # merge into existing XDF handlers
  while ( my ($k, $v) = each (%newHandlers)) {
     $self->{charDataHandler}->{$k} = $v;
  }
  
  return 1;

}

#/** setDefaultStartElementHandler
# This sets the subroutine which will handle all nodes which DONT match  
# an entry within the start element handler table. 
#*/
sub setDefaultStartElementHandler {
  my ($self, $codeRef) = @_;
  return unless defined $codeRef;
  $self->{defaultHandler}->{'start'} = $codeRef;
}

#/** setDefaultEndElementHandler
# This sets the subroutine which will handle all nodes which DONT match  
# an entry within the end element handler table. 
#*/
sub setDefaultEndElementHandler {
  my ($self, $codeRef) = @_;
  return unless defined $codeRef;
  $self->{defaultHandler}->{'end'} = $codeRef;
}

#/** setDefaultCharDataHandler
# This sets the subroutine which will handle all nodes which DONT match  
# an entry within the CDATA handler table. 
#*/
sub setDefaultCharDataHandler {
  my ($self, $codeRef) = @_;
  return unless defined $codeRef;
  $self->{defaultHandler}->{'cdata'} = $codeRef;
}

#
# SAX Parser Handlers (Protected) 
#

sub _handle_doctype {
   my ($self, $parser_ref, $name, $systemId, $publicId, $internal) = @_;

   $systemId = "" unless defined $systemId;
   $publicId = "" unless defined $publicId;
   $internal = "" unless defined $internal;
   debug("H_DOCTYPE: $name, $systemId, $publicId, $internal\n");

   my %hashTable;
   $hashTable{"name"} = $name;
   $hashTable{"sysId"} = $systemId;
   $hashTable{"pubId"} = $publicId;
   $self->{DoctypeObjectAttributes} = \%hashTable;
   return;
}

sub _handle_xml_decl {
   my ($self, $parser_ref, @stuff) = @_;
   debug("H_XML_DECL: ");
   foreach my $thing (@stuff) { debug($thing.", ") if defined $thing; }
   debug("\n");
}

# store these in the entity array
sub _handle_unparsed {
  my ($self, $parser_ref, $name, $base, $sysid, $pubid, $notation) = @_;

   my $msgstring = "H_UNPARSED: $name";
   $self->{Entity}{$name} = {}; # add a new entry;

   if (defined $base) {
      $msgstring .= ", BASE:$base";
      ${$self->{Entity}{$name}}{'base'} = $base;
   }

   if (defined $sysid) {
      $msgstring .= ", SYS:$sysid";
      ${$self->{Entity}{$name}}{'sysid'} = $sysid;
   }

   if (defined $pubid) {
      $msgstring .= ", PUB:$pubid";
      ${$self->{Entity}{$name}}{'pubid'} = $pubid;
   }

   if (defined $notation) {
      $msgstring .= " NOTATION:$notation";
      ${$self->{Entity}{$name}}{'ndata'} = $notation;
   }

   $msgstring .= "\n";
   debug($msgstring);

}

sub _handle_notation {
  my ($self, $parser_ref, $notation, $base, $sysid, $pubid) = @_;

   my $msgstring = "H_NOTATION: $notation ";
   $self->{Notation}->{$notation} = {}; # add a new entry

   ${$self->{Notation}->{$notation}}{name} = $notation;

   if (defined $base) {
      $msgstring .= ", Base:$base";
      ${$self->{Notation}->{$notation}}{base} = $base;
   }

   if (defined $sysid) {
      $msgstring .= ", SYS:$sysid";
      ${$self->{Notation}->{$notation}}{systemId} = $sysid;
   }

   if (defined $pubid) {
      $msgstring .= " PUB:$pubid";
      ${$self->{Notation}->{$notation}}{publicId} = $pubid;
   }

   $msgstring .= "\n";
   debug($msgstring);

}

sub _handle_element {
   my ($self, $parser_ref, $name, $model) = @_; 
   debug("H_ELEMENT: $name [$model]\n"); 
}

# do we really need this? attribute list from entity defs 
sub _handle_attlist {
   my ($self, $parser_ref, $elname, $attname, $type, $default, $fixed) = @_; 
   debug("H_ATTLIST: $elname [");
   debug($attname) if defined $attname;
   debug(" | ");
   debug($type) if defined $type;
   debug(" | ");
   debug($default) if defined $default;
   debug(" | ");
   debug($fixed) if defined $fixed;
   debug(" ]\n");
}

sub _handle_start {
   my ($self, $parser_ref, $element, @attribinfo) = @_; 

   debug("H_START: $element \n"); 

   my %attrib_hash = $self->_make_attrib_array_a_hash(\@attribinfo);

   # 1.add this node to the current path
   push @{$self->{currentNodePath}}, $element;

   # 2. run the start handler. All start handlers SHOULD return a corresponding
   # xdf object that they create at this step. 
   my $obj;
   if ( exists $self->{startElementHandler}->{$element}) {

      # run the appropriate start handler
      $obj = $self->{startElementHandler}->{$element}->($self, %attrib_hash);

   } 
   else 
   {
      $obj =  $self->_exec_default_Start_Handler($element, \%attrib_hash);
   }

   # 3. record the object that corresponds to this XML node (remember that we
   # dont always have an object defined, some XML nodes have no coorsponending
   # xdf object so $obj may equal undef.
   push @{$self->{lastObjList}}, $obj;

}

sub _handle_end {
   my ($self, $parser_ref, $element) = @_;

   debug("H_END: $element\n");

   # peel off the last element in the current path
   my $last_element = pop @{$self->{currentNodePath}};

   $self->_printFatalError("error last element not $element!! (was: $last_element) \n")
       unless ($element eq $last_element);

   if (exists $self->{endElementHandler}->{$element} ) {

      $self->{endElementHandler}->{$element}->($self);

   } else {

      $self->_exec_default_End_Handler($element);

   } 

   pop @{$self->{lastObjList}};

}

sub _handle_char {
   my ($self, $parser_ref, $string) = @_;

   unless ($self->{inCdataBlock}) { 
       debug("PCDATA from:[$string]\n");
       # unless we are in CDATASection, then we should change all multi-space
       # and whitespace chars into a single space. Furthermore, we should peel
       # off leading and trailing whitespace as its meaningless in XML spec
       $string =~ s/\s+/ /g; 
       debug("         to:[$string]\n");
   }

   debug("H_CHAR:".join '/', @{$self->{currentNodePath}} ."[$string]\n");

   # we need to know what the current node is in order to 
   # know what to do with this data, however, 
   # early on when reading the DOCTYPE, other nodes we can get 
   # text nodes which are not meaningful to us. Ignore all
   # charcter data until we open the root node.

   my $curr_node = $self->_currentNodeName();

   if (defined $curr_node) { 

     if(exists $self->{charDataHandler}->{$curr_node} ) {
       
        $self->{charDataHandler}->{$curr_node}->($self, $string); 

     } else {

         # run the default handler
         $self->_exec_default_CData_Handler($string);

     }

   } 

}

# ignore comments
sub _handle_comment {
   my ($self, $parser_ref, $data) = @_;
   info("H_COMMENT: $data\n");
}

# the same as endDocument?
sub _handle_final {
   my ($self, $parser_ref) = @_;
   debug("H_FINAL \n");

   if (defined $self->{DoctypeObjectAttributes} || $self->{ForceSetXMLHeaderStuff} ) {

      # bah, this doesnt belong here
      my $xmlDecl = new XDF::XMLDeclaration();
      $xmlDecl->setStandalone("no");

      my $doctype = new XDF::DocumentType($self->{XDF});

      # set the values of the DocumentType object appropriately
      if (!$self->{ForceSetXMLHeaderStuff}) {
         my %hash = %{$self->{DoctypeObjectAttributes}};
         my $sysId = $hash{"sysId"};
         my $pubId = $hash{"pubId"};
         if (defined $sysId) {
            $doctype->setSystemId($sysId);
         }
         if (defined $pubId) {
            $doctype->setPublicId($pubId);
         }
      } else {
         # we have to guess values
         $doctype->setSystemId(&XDF::Constants::XDF_DTD_NAME);
      }

      $self->{XDF}->setXMLDeclaration($xmlDecl);
      $self->{XDF}->setDocumentType($doctype);
   }

   # Now that it exists, lets
   # set the notation hash for the XDF structure
   my $documentType = $self->{XDF}->getDocumentType();
   while ( my ($key, $notationAttribHash) = each %{$self->{Notation}}) {
      # force having document type
      if (!defined $documentType) {
         $documentType = new XDF::DocumentType($self->{XDF});
         $self->{XDF}->setDocumentType($documentType);
      }
      $self->{XDF}->getDocumentType()->addNotation(new XDF::NotationNode($notationAttribHash));
   }

   return $self->{XDF};
}

sub _handle_init {
   my ($self, $parser_ref) = @_;
   debug("H_INIT \n");
}

sub _handle_proc {
   my ($self, $parser_ref, $target, $data) = @_;
   debug("H_PROC: $target [$data] \n");
}

sub _handle_cdata_start {
   my ($self, $parser_ref) = @_;
   debug( "H_CDATA_START \n");
   $self->{inCdataBlock} = 1;
}

sub _handle_cdata_end {
   my ($self, $parser_ref) = @_;
   debug("H_CDATA_END \n");
   $self->{inCdataBlock} = 0;
   # this is important, terminate all following 
   # within this (data) node whitespace data
   $self->{thisDataNodeHasAlreadyAddedData} = 0;
}

# things like entity definitions get passed here
sub _handle_default {
   my ($self, $parser_ref, $string) = @_;
   return unless defined $string;
   debug("H_DEFAULT:[$string]\n");

   # well, i dont know what else can go here, but for now
   # lets assume its entities in the character data ONLY.
   # So we just pass this off to the _handle_character method.
   # (yes, we could specify in the parser decl, but perhaps
   # above assumtion ISNT right, then we will need this ).
#   $self->_handle_char($parser_ref, $string);

}
  
sub _handle_external_ent {
   my ($self, $parser_ref, $base, $sysid, $pubid) = @_;

   my $entityString = "H_EXTERN_ENT: ";
   $entityString .= ", Base:$base" if defined $base;
   $entityString .= ", SYS:$sysid" if defined $sysid;
   $entityString .= " PUB:$pubid" if defined $pubid;
   $entityString .= "\n";
   debug($entityString);

}

sub _handle_entity {
   my ($self, $parser_ref, $name, $val, $sysid, $pubid, $ndata) = @_;

   my $msgstring = "H_ENTITY: $name";
   $self->{Entity}{$name} = {}; # add a new entry;

   if (defined $val) {
      $msgstring .= ", VAL:$val";
      ${$self->{Entity}{$name}}{'value'} = $val;
   }

   if (defined $sysid) {
      $msgstring .= ", SYS:$sysid";
      ${$self->{Entity}{$name}}{'sysid'} = $sysid;
   }
  
   if (defined $pubid) {
      $msgstring .= ", PUB:$pubid";
      ${$self->{Entity}{$name}}{'pubid'} = $pubid;
   }

   if (defined $ndata) {
      $msgstring .= " NDATA:$ndata";
      ${$self->{Entity}{$name}}{'ndata'} = $ndata;
   }

   $msgstring .= "\n";
   debug($msgstring);

}

#
# ------------ END XML PARSER HANDLERS -----------
#

#
# SAX Document HANDLERS (Private? perhaps should be protected, hurmm)  
#

sub _asciiDelimiter_node_end { 
  my ($self) = @_;
  pop @{$self->{currentFormatObjectList}}; 
}

sub _asciiDelimiter_node_start {
  my ($self, %attrib_hash) = @_;

  # if this is still defined, we havent init'd an
  # XMLDataIOStyle object for this array yet, do it now. 
  # set the format object in the current array
  # (other case: we got a format object from a dataStyleIdRef and
  #  already supplied correct stuff)
  my $formatObj;
  if ( defined $self->{dataIOStyleAttribRef}) {

    $formatObj = new XDF::DelimitedXMLDataIOStyle($self->{currentArray},$self->{dataIOStyleAttribRef});
    # shortcut: since the current DTD sez
    # we dont have any attributes on this node 
    # we dont attempt to add anything more in
    # $formatObj->setXMLAttributes(\%attrib_hash);

    # set formatObj as the current Array XMLDataIOStyle
    $self->{currentArray}->setXMLDataIOStyle($formatObj);

    # add this to the current set of dataStyle objects we have cached
    my $dataStyleId = $formatObj->getDataStyleId();
    if (defined $dataStyleId ) {
       $self->_printWarning( "Danger: More than one read node with dataStyleId=\"$dataStyleId\", using latest node.\n" )
           if defined $self->{XMLDataIOStyleObj}{$dataStyleId};
       $self->{XMLDataIOStyleObj}{$dataStyleId} = $formatObj;
    }

    # clear this 
    $self->{dataIOStyleAttribRef} = undef;
    # add to format list
    push @{$self->{currentFormatObjectList}}, $formatObj;

  } else {
    die "Error: no Format Obj could be defined for delimited data (bad file format?)\n";
  }

  return $self->{currentArray}->getXMLDataIOStyle();
}

sub _array_node_end {
  my ($self) = @_;

   # well, well, which array will we deal with here?
   # if an appendto is specified, then we will try to append this array
   # to the specified one, otherwise, the current array is added to 
   # the current structure.
   my $arrayAppendId = $self->{currentArray}->getAppendTo();
   if (defined $arrayAppendId)
   {
      # we just add it to the designated array
      my $arrayToAppendTo = $self->{ArrayObj}->{$arrayAppendId};
      $self->_appendArrayToArray($arrayToAppendTo, $self->{currentArray});
   }
   else
   {
      # add the current array and add this array to current structure 
      my $retarray = $self->{currentStructure}->addArray($self->{currentArray});
   }

   # make this undef so we dont re-use
   $self->{noteLocatorOrder} = undef;
}

sub _array_node_start {
  my ($self, %attrib_hash) = @_;

  # first, a little init of internal variable
  # allows us to store the ordering of the axisIDRef's in 
  # the notes locationOrder tag (so we can cross link it)
  $self->{noteLocatorOrder} = []; # list

  #$self->{currentArray} = $self->{currentStructure}->addArray(\%attrib_hash);
  my $newarray = new XDF::Array(\%attrib_hash);

  # set whether we want to use DB file or in memory treatment for storage of our data
  # in this array
  $newarray->setCacheDataToDisk($self->{Options}->{cacheDataOnDisk});

  # add this array to our list of arrays if it has an ID
  if ($newarray && (my $arrayId = $newarray->getArrayId)) {
     $self->{ArrayObj}->{$arrayId} = $newarray;
  }

  $self->{currentArray} = $newarray;

  $self->{currentArrayAxes} = {};

  return $newarray;
}

sub _arrayRefField_node_start {
  my ($self, %attrib_hash) = @_;

  # this can waste memory, however these should always be quite small. 
  # see perl cookbook on merging hashes
  my %merged_hash = (%{$self->{dataFormatAttribRef}}, %attrib_hash);

  # create the object, add it to the current datatype holder 
  my $dataTypeObj = $self->_currentFormatOwnerObject();

  my $dataFormatObj;
  my $name = ref $dataTypeObj;
  if (ref($dataTypeObj) eq 'XDF::Field' or ref($dataTypeObj) eq 'XDF::Array' or ref($dataTypeObj) eq 'XDF::Parameter' )
  {

     $dataFormatObj = new XDF::ArrayRefDataFormat(\%merged_hash);
     $dataTypeObj->setDataFormat($dataFormatObj);

  } elsif ($name eq 'XDF::Axis' or $name eq 'XDF::ColAxis' or $name eq 'XDF::RowAxis' ) {

# this _shouldnt_ be allowed, but the DTD allows it, so we do too.
     $dataFormatObj = new XDF::ArrayRefDataFormat(\%merged_hash);
     $dataTypeObj->setLabelDataFormat($dataFormatObj);

  } else {

    $self->_printWarning("Unknown parent object, cant set arrayRef dataformat in $name, ignoring\n");

  }

  return $dataFormatObj;
}


sub _axis_node_start {
  my ($self, %attrib_hash) = @_;

  my $axisObj = new XDF::Axis(\%attrib_hash);

  $self->_axis_node_add($axisObj,%attrib_hash);

}

sub _axis_node_add {
  my ($self, $axisObj, %attrib_hash) = @_;

  # record this axis
  $self->{currentArrayAxes}{$axisObj->getAxisId()} = $axisObj if defined $axisObj->getAxisId();

  # add in reference object, if it exists 
  if (exists($attrib_hash{'axisIdRef'})) {

     my $id = $attrib_hash{'axisIdRef'};

     # clone from the reference object
     $axisObj = $self->{AxisObj}->{$id}->clone();

     # override with local values
     $axisObj->setXMLAttributes(\%attrib_hash);
     $axisObj->setAxisId($self->_getUniqueIdName($id, \%{$self->{AxisObj}})); # set ID attribute to unique name 
     $axisObj->setAxisIdRef(undef); # unset IDREF attribute 
     
     # record this axis under its parent id 
     $self->{currentArrayAxes}{$id} = $axisObj;

  }

  # add this object to the lookup table, if it has an ID
  if ((my $axisId = $axisObj->getAxisId()) && !$self->{currentArray}->getAppendTo()) {
     $self->_printWarning( "Danger: More than one axis node with axisId=\"$axisId\", using latest node.\n" )
           if defined $self->{AxisObj}->{$axisId};
     $self->{AxisObj}->{$axisId} = $axisObj;
  }

  if($self->{currentArray}->addAxis($axisObj) ) {
#     push @{$self->{currentFormatOwnerObjectList}}, $axisObj;
     # do nothing right now
  } else {
     $self->_printFatalError("Couldnt add axis to array:".$self->{currentArray}->getName().", aborting\n");
  }

  return $axisObj;
}

#sub _axisUnits_node_start { 
#  my ($self, %attrib_hash) = @_;
#  # do nothing
#  return undef;
#}

sub _binaryFloatField_node_start {
  my ($self, %attrib_hash) = @_;

  # this can waste memory, however these should always be quite small. 
  # see perl cookbook on merging hashes
  my %merged_hash = (%{$self->{dataFormatAttribRef}}, %attrib_hash);

  # create the object, add it to the current datatype holder 
  my $dataTypeObj = $self->_currentFormatOwnerObject();
  
  my $dataFormatObj;
  my $name = ref $dataTypeObj;
  if ($name eq 'XDF::Field' or $name eq 'XDF::Array') {
  
     $dataFormatObj = new XDF::BinaryFloatDataFormat(\%merged_hash);
     $dataTypeObj->setDataFormat($dataFormatObj);
  
  } else {
  
    $self->_printWarning("Unknown parent object, cant set binaryFloatField dataformat in $name, ignoring\n");
  
  }

  return $dataFormatObj;
}

sub _binaryIntegerField_node_start {
  my ($self, %attrib_hash) = @_;

  # this can waste memory, however these should always be quite small. 
  # see perl cookbook on merging hashes
  my %merged_hash = (%{$self->{dataFormatAttribRef}}, %attrib_hash);

  # create the object, add it to the current datatype holder 
  my $dataTypeObj = $self->_currentFormatOwnerObject();
  
  my $dataFormatObj;
  my $name = ref $dataTypeObj;
  if ($name eq 'XDF::Field' or $name eq 'XDF::Array') {
  
     $dataFormatObj = new XDF::BinaryIntegerDataFormat(\%merged_hash);
     $dataTypeObj->setDataFormat($dataFormatObj);
  
  } else {
  
    $self->_printWarning("Unknown parent object, cant set binaryIntegerField dataformat in $name, ignoring\n");
  
  }

  return $dataFormatObj;

}

 
sub _cell_node_charData {
   my ($self, $string) = @_;

   # dont add this data unless it has more than just whitespace
   if (!$IGNORE_WHITESPACE_ONLY_DATA || $string !~ m/^\s*$/) {
#     my $location = $self->{taggedLocatorObject}->_dumpLocation;
#     debug("ADDING DATA to:$location [$string]");
      $self->{currentArray}->addData($self->{taggedLocatorObject}, $string);
   }

}

# for the cell tags in simple table data
sub _cell_node_start {
  my ($self, %attrib_hash) = @_;
  $self->{gotACellread} = 1;
  return undef;
}

sub _cell_node_end {
  my ($self) = @_;
   $self->{taggedLocatorObject}->next();
}

sub _chars_node_start {
  my ($self, %attrib_hash) = @_;

  my $charDataObj = new XDF::Chars(\%attrib_hash);

  my $lastObject = $self->_lastObj();

  $self->_printFatalError("Internal error: cant set chars, last object not defined\n") unless defined $lastObject;

  if ( ref($lastObject) eq 'XDF::SkipCharFormattedIOCmd') {
     $lastObject->setOutput($charDataObj);
     return $charDataObj;
  } elsif ( ref($lastObject) eq 'XDF::Delimiter') {
     $lastObject->setValue($charDataObj);
     return $charDataObj;
  } elsif ( ref($lastObject) eq 'XDF::RecordTerminator') {
     $lastObject->setValue($charDataObj);
     return $charDataObj;
  } else {
     $self->_printWarning(" cant add Chars object to parent:$lastObject not a valid object. Ignoring request\n");
  }

  return undef;

}

# for the tags in tagged data
sub _column_node_start {
  my ($self, %attrib_hash) = @_;

  my $readObj = $self->{currentArray}->getXMLDataIOStyle();
  if (ref ($readObj) ne 'XDF::TaggedXMLDataIOStyle' ) {

          # Finding out that this must be the first time thru because
          # its not Delimited style AND we got a row/col node.. well not robust,
          # but will work. 

          #..ok lets define the necessary stuff..

          # force it to be tagged, remember to add dataStyle to array FIRST, before changing outputstyle
          $readObj = new XDF::TaggedXMLDataIOStyle();
          $self->{currentArray}->setXMLDataIOStyle($readObj);
          $readObj->setOutputStyle(&XDF::Constants::TAGGED_BYCOL_OUTPUTSTYLE);
  
          $self->{psuedoSimpleReadObj} = new XDF::DelimitedXMLDataIOStyle($self->{currentArray});

          # we also need to create this too
          $self->{taggedLocatorObject} = $self->{currentArray}->createLocator;

          # configure axis ordering to be col-oriented
          my @newOrder = ( $self->{currentArray}->getRowAxis(), $self->{currentArray}->getColAxis() );
          $self->{taggedLocatorObject}->setIterationOrder(\@newOrder);

          $self->{currentCol} = 0;
  }
  
  return undef;
}

# for the tags in tagged data
sub _column_node_end {
  my ($self) = @_;

  if ($self->{currentCol} == $self->{taggedLocatorObject}->getAxisIndex($self->{currentArray}->getColAxis()))
  {
     # uh oh, we had a "short" read in the row.. apparently didnt supply all the cells. 
     # lets advance the row marker by 1 in this case and reset the column to "0"
     $self->{taggedLocatorObject}->setAxisIndex($self->{currentArray}->getColAxis(), $self->{currentCol}+1);
     $self->{taggedLocatorObject}->setAxisIndex($self->{currentArray}->getRowAxis(), 0);
  }

  $self->{currentCol}++;

}

sub _colaxis_node_start {
  my ($self, %attrib_hash) = @_;

  my $axisObj = new XDF::ColAxis(\%attrib_hash);

  $self->_axis_node_add($axisObj,%attrib_hash);
   
}

sub _component_node_start {
  my ($componentObj, $self, $string) = @_;

  my $parent = $self->_lastObj();
  my $parenttype = ref $parent;

  if ($parenttype eq 'XDF::Conversion') {

     $parent->addComponent($componentObj);
     return $componentObj;

  } else {

     my $name = ref $componentObj;
     $self->_printWarning("Unknown parent object:$parenttype, cant add component \"$name\", ignoring\n");
     return undef;
  }

}

sub _component_node_charData {
  my ($self, $string) = @_;

  if (!$IGNORE_WHITESPACE_ONLY_DATA || $string !~ m/^\s*$/) {
     my $componentObj = $self->_lastObj;
     $componentObj->setValue($string);
  }

}

sub _conversion_node_start {
  my ($self, %attrib_hash) = @_;

  my $conversionObj;
  my $parent = $self->_lastObj;
  my $parent_type = ref $parent;

  if ( $parent_type eq 'XDF::Field' or $parent_type eq 'XDF::Parameter'
         or $parent_type eq 'XDF::Array' or $parent_type eq 'XDF::Axis' 
         or $parent_type eq 'XDF::RowAxis' or $parent_type eq 'XDF::ColAxis' 
     ) {

     $conversionObj = new XDF::Conversion(%attrib_hash);
     $parent->setConversion($conversionObj);

  } else {

    $self->_printWarning("Unknown parent object:$parent_type, cant set conversion, ignoring\n");

  }

  return $conversionObj;

}

# for the tags in tagged data
sub _dataTag_node_start {
  my ($self, %attrib_hash) = @_;

  $self->{currentDataTagLevel}++;

  return undef;
}

# for the tags in tagged data
sub _dataTag_node_end {
  my ($which, $self) = @_;

  $self->{taggedLocatorObject}->next() 
      if ($self->{currentDataTagLevel} == $self->{dataTagLevel});

#  debug("tag end (".$self->{currentDataTagLevel}.",".$self->{dataTagLevel}."); LOCATION IS NOW:".$self->{taggedLocatorObject}->_dumpLocation."\n");
  $self->{currentDataTagLevel}--;

}
  
# should only be relevant in untagged (delimited/formatted) cases
sub _data_node_charData {
   my ($self, $string) = @_;

   # only do something here IF we are reading in data at the moment
   # is this needed?? 
   if ($self->{dataNodeLevel} > 0) {

     my $readObj = $self->{currentArray}->getXMLDataIOStyle();

     if (ref($readObj) eq 'XDF::DelimitedXMLDataIOStyle' or
         ref($readObj) eq 'XDF::FormattedXMLDataIOStyle' )
     {

         # add it to the datablock if it isnt all whitespace OR its in CDATAsection 
         if ( 
               $self->{inCdataBlock} or $string !~ m/^\s+$/
            )
         {

            # this wasnt done eariler, so we do it here.. 
            # (the above IF statement regex *doesnot* prevent multi-whitespace embedded
            # with letters/numbers from being passed, and should be removed now =b.t.)
#            unless ($self->{inCdataBlock}) { $string =~ s/\s+/ /g; }; # this IS done earlier

            if (defined $self->{whitespaceData} and $self->{thisDataNodeHasAlreadyAddedData}) {
               $string = $self->{whitespaceData} . $string;
            }
            $self->{whitespaceData} = undef;

            debug("ADDING String to DataBlock: [$string]\n");
            $self->{dataBlock} .= $string;

            $self->{thisDataNodeHasAlreadyAddedData} = 1;

         } else {
            # in the case of whitespace outside of CDATA section, but
            # INSIDE of datanode, save the whitespace for later possible addition.
            $self->{whitespaceData} = $string;
#         } elsif ($string =~ m/^\s+$/ and !$self->{inCdataBlock}) {
#            $self->{dataBlock} .= " "; # tack in single whitespace
         }
     }
   }
}

sub _data_node_end {
  my ($self) = @_;

  # we stopped reading datanode, lower count by one
  $self->{dataNodeLevel}--;
  
  my $formatObj = $self->{currentArray}->getXMLDataIOStyle();

  if ($self->{gotACellread}) {
     # set output style appropriately
     if($formatObj->getOutputStyle eq &XDF::Constants::TAGGED_BYROW_OUTPUTSTYLE)
     {
        $formatObj->setOutputStyle(&XDF::Constants::TAGGED_BYROWANDCELL_OUTPUTSTYLE);
     } 
     elsif ($formatObj->getOutputStyle eq &XDF::Constants::TAGGED_BYCOL_OUTPUTSTYLE)
     {
        $formatObj->setOutputStyle(&XDF::Constants::TAGGED_BYCOLANDCELL_OUTPUTSTYLE);
     }
     # zero it out
     $self->{gotACellread} = 0;
  }

  if (defined $self->{whitespaceData} 
        and 
      $self->{thisDataNodeHasAlreadyAddedData}
     ) 
  {
     $self->{dataBlock} .= $self->{whitespaceData};
  }
  $self->{thisDataNodeHasAlreadyAddedData} = 0;
  $self->{whitespaceData} = undef;

  # we might still be nested within a data node
  # if so, return now to accumulate more data within the DATABLOCK
  return unless $self->{dataNodeLevel} == 0;

  # we have already done tagged data so return now
  return if ref($formatObj) eq 'XDF::TaggedXMLDataIOStyle';

  # QUICK CHECK: this prevents us from re-reading Href data again 
  # and re-setting the write/readIO order amonsgt other bad things 
  # we could do.
  # ALSO, it prevents us from reading in tagged data sections (already
  # taken care of earlier)
  #return unless $self->{dataBlock};
  
  # now read in any untagged data (both delimited/formmatted styles) 
  # from the $self->{dataBlock} or external Href resources 

  if ($self->{dataBlock}) {

    my $locator = $self->{currentArray}->createLocator();
    #$locator->setIterationOrder($formatObj->getWriteAxisOrderList());

    my $start = $self->{currentArray}->getDataCube()->getStartByte();
    my $end = $self->{currentArray}->getDataCube()->getEndByte();

    $self->{currentArray}->parseAndLoadDataString($locator, $self->{dataBlock}, $start, $end, $self->{Options}->{loadDataOnDemand});

    # clean up.. start/end byte only needed for reading
    $self->{currentArray}->getDataCube()->setStartByte(0);
    $self->{currentArray}->getDataCube()->setEndByte(undef);

  } else {

    $self->{currentArray}->reloadAllExternalData() unless ($self->{Options}->{loadDataOnDemand});

  }

}

# we have now read in ALL of the axis that will 
# exist, lets now decipher how to read the tags
sub _data_node_start {
  my ($self, %attrib_hash) = @_;

  my $hrefObj;
  my $readObj = $self->{currentArray}->getXMLDataIOStyle();

  # href is special
  if (exists $attrib_hash{'href'}) 
  { 

    my $hrefName = $attrib_hash{'href'};

    # this shouldnt happen, but does for unconsidered cases.
    die "XDF::Reader Internal bug: Href Entity [$hrefName] is not defined. Aborting parse.\n" 
        unless exists $self->{Entity}{$hrefName}; 

    # create the new Href object
    $hrefObj = new XDF::Entity(); 
    $hrefObj->setName($hrefName);
    $hrefObj->setSystemId(${$self->{Entity}{$hrefName}}{'sysid'});
    $hrefObj->setBase(${$self->{Entity}{$hrefName}}{'base'});
    $hrefObj->setNdata(${$self->{Entity}{$hrefName}}{'ndata'});
    $hrefObj->setPublicId(${$self->{Entity}{$hrefName}}{'pubid'});

    delete $attrib_hash{'href'}; # prevent over-writing object with string 

    # tack in this href
    $self->{currentArray}->getDataCube()->addHref($hrefObj);

    # we only set the Href once for the dataCube.
    # now, while we may be able to read from other files
    # and combine, we are not going to be able to write back
    # out to so many files. Throw a warning here for the user.
    if (defined $self->{currentArray}->getDataCube()->getHref()) {

       my $oldHrefName = $self->{currentArray}->getDataCube()->getHref()->getName();
       $self->_printWarning(" There is already one href defined for this Array ($oldHrefName), reading data for $hrefName but ignoring setting new href value in array. Be carefull you dont write a file you dont want on output!\n") unless $self->{Options}->{quiet};

    } else {

       # this section need only be done once..(for the first href).

       # this is done because we read these in the reverse order in which
       # the API demands the axes, e.g. first axis is the 'fast' one, whereas
       # reading the XDF node by node we get the fastest last in the array.
       @{$self->{readAxisOrderList}} = reverse @{$self->{readAxisOrderList}};
  
       # need to store this information to make operate properly
       # when we have read nodes w/ idRef stuff going on.
       my @temparray = @{$self->{readAxisOrderList}};
       $self->{readAxisOrderHash}->{$self->{currentArray}} = \@temparray;
       $readObj->setWriteAxisOrderList(\@temparray);

    }

    # here is a HACK...we need to record start/stopbytes for 
    # href's individually...and note the ultra-crappy "private"
    # accessor use. Ugh. Its days like this I cringe at the code
    # I write. Well, its gonna be done right one day, Ill make a note
    # in the TODO list. -b.t.
    my $startByte = $attrib_hash{'startByte'}; 
    my $endByte = $attrib_hash{'endByte'};
    if ($startByte) 
    {
       $hrefObj->{_startByte} = $startByte;
    }

    if ($endByte) 
    {
       $hrefObj->{_endByte} = $endByte;
    }

    # remove so its not recorded in the dataCube.
    delete $attrib_hash{'startByte'}; 
    delete $attrib_hash{'endByte'}; 

  } 

  # update the array dataCube with XML attributes
  $self->{currentArray}->getDataCube()->setXMLAttributes(\%attrib_hash);


  # these days, this should always be defined.
  if (defined $readObj) {

     if (ref($readObj) eq 'XDF::TaggedXMLDataIOStyle') {
       $self->{taggedLocatorObject} = $self->{currentArray}->createLocator;
     } else {
       # A safety. We clear datablock when this is the first datanode we 
       # have entered DATABLOCK is used in cases where we read in untagged data
       $self->{dataBlock} = "" if $self->{dataNodeLevel} == 0; 
     }
       
     # this declares we are now reading data, 
     $self->{dataNodeLevel}++; # entered a datanode, raise the count 

  } else {
    die "No read object defined in array. Exiting.\n";
  }

  return $self->{currentArray}->getDataCube;
}

#sub _dataFormat_node_end {
#   my ($self) = @_;
   # do nothing
#}

sub _dataFormat_node_start {
  my ($self, %attrib_hash) = @_;
  # save attribs for latter
  $self->{dataFormatAttribRef} = \%attrib_hash;
  return undef;
}

sub _delimiter_node_start {
  my ($self, %attrib_hash) = @_;
   
  # create obj
  my $delimiterObj = new XDF::Delimiter(\%attrib_hash);
     
  # okey, now that that is taken care off, we will go
  # get the current format (read) object, and add the readCell
  # command to it
  my $formatObj = $self->_currentFormatObject();
     
  if ( ref($formatObj) eq 'XDF::DelimitedXMLDataIOStyle') {
     $formatObj->setDelimiter($delimiterObj);
     return $delimiterObj;
  } else {
     $self->_printWarning(" cant add Delimiter object to parent($formatObj)..its not a DelimitedXMLDataIOStyle Object. Ignoring request\n");
  }

  return undef;

}

sub _field_node_start {
  my ($self, %attrib_hash) = @_;

   #my $_parentNodeName = $self->_parentNodeName();

   my $fieldObj = new XDF::Field(\%attrib_hash);
   $self->{currentArray}->getFieldAxis()->addField($fieldObj);

   # add this object to all open groups
   foreach my $groupObj (@{$self->{currentFieldGroupList}}) { $fieldObj->addToGroup($groupObj); }

   #if(defined $fieldObj && exists($attrib_hash{'fieldId'})) {
   if(defined $fieldObj && (my $id = $fieldObj->getFieldId)) {
      #my $id = $attrib_hash{'fieldId'};
      $self->_printWarning("More than one field node with fieldId=\"$id\", using latest node.\n") 
            if defined $self->{FieldObj}->{$id};
       $self->{FieldObj}->{$id} = $fieldObj;
   }

   return $fieldObj;
}

sub _fieldAxis_node_end {
  my ($self) = @_;

  # nothing to do here but check on the correctness of the declared size attrib.
  my $actualFieldAxisSize = $self->_lastAxisObj()->getSize;

  $self->_printWarning(" Meta-data incorrect? Got field Axis actual size:$actualFieldAxisSize vs. predetermined size:".$self->{fieldAxisSize}.". Using actual size.\n") if ($self->{fieldAxisSize} ne $actualFieldAxisSize);

  # now clear out cached size value
  $self->{fieldAxisSize} = undef;
}

sub _fieldAxis_node_start {
  my ($self, %attrib_hash) = @_;

   # size is special, we shouldnt set it from here, but 
   # rather let the number of fields input into the axis
   # tell us what should be the actual size.
   $self->{fieldAxisSize} = $attrib_hash{'size'};
   $attrib_hash{'size'} = undef;

   my $axisObj = new XDF::FieldAxis(\%attrib_hash);

   # record this axis
   my $id = $axisObj->getAxisId();
   $self->{currentArrayAxes}->{$id} = $axisObj if defined $id;

   # add in reference object, if it exists 
   if (exists($attrib_hash{'axisIdRef'})) {
      my $id = $attrib_hash{'axisIdRef'};

      # clone from the reference object
      $axisObj = $self->{AxisObj}->{$id}->clone();

      # override with local values
      $axisObj->setXMLAttributes(\%attrib_hash);
      $axisObj->setAxisId($self->_getUniqueIdName($id, \%{$self->{AxisObj}})); # set ID attribute to unique name 
      $axisObj->setAxisIdRef(undef); # unset IDREF attribute 

      # record this axis under its parent id 
      $self->{currentArrayAxes}{$id} = $axisObj;
   }

   # add this object to the lookup table, if it has an ID
   #if ((my $axisId = $attrib_hash{'axisId'})) {
   if ((my $axisId = $axisObj->getAxisId) && !$self->{currentArray}->getAppendTo()) {
      $self->_printWarning( "More than one axis node with axisId=\"$axisId\", using latest node.\n" )
            if defined $self->{AxisObj}->{$axisId};
      $self->{AxisObj}->{$axisId} = $axisObj;
   }

   # add the axis object to the array
   $self->{currentArray}->setFieldAxis($axisObj);

   return $axisObj;
}

sub _fieldGroup_node_end { 
   my ($self) = @_;
   pop @{$self->{currentFieldGroupList}}; 
}

sub _fieldGroup_node_start {
  my ($self, %attrib_hash) = @_;

  my $_parentNodeName = $self->_parentNodeName();

  my $fieldGroupObj = new XDF::FieldGroup(\%attrib_hash);

  if($_parentNodeName eq $XDF_node_name{'fieldAxis'} ) {

    return unless $self->{currentArray}->getFieldAxis()->addFieldGroup($fieldGroupObj);

  } elsif($_parentNodeName eq $XDF_node_name{'fieldGroup'} ) {

    my $lastGroupObj = $self->{currentFieldGroupList}[$#{$self->{currentFieldGroupList}}];
    return unless $lastGroupObj->addFieldGroup($fieldGroupObj);

  } else {

     die" weird parent node $_parentNodeName for fieldGroup";

  }

  # add this object to all open groups
  foreach my $groupObj (@{$self->{currentFieldGroupList}}) { $fieldGroupObj->addToGroup($groupObj); }

  # add to the list of open fieldGroups
  push @{$self->{currentFieldGroupList}}, $fieldGroupObj;

  return $fieldGroupObj;
}


sub _floatField_node_start {
  my ($self, %attrib_hash) = @_;

  # this can waste memory, however these should always be quite small. 
  # see perl cookbook on merging hashes
  my %merged_hash = (%{$self->{dataFormatAttribRef}}, %attrib_hash);

  # create the object, add it to the current datatype holder 
  my $dataTypeObj = $self->_currentFormatOwnerObject();
  
  my $dataFormatObj;
  my $name = ref $dataTypeObj;
  if ($name eq 'XDF::Field' or $name eq 'XDF::Array' or $name eq 'XDF::Parameter' ) {
  
     $dataFormatObj = new XDF::FloatDataFormat(\%merged_hash);
     $dataTypeObj->setDataFormat($dataFormatObj);
  
  } elsif ($name eq 'XDF::Axis' or $name eq 'XDF::ColAxis' or $name eq 'XDF::RowAxis' ) {

     $dataFormatObj = new XDF::FloatDataFormat(\%merged_hash);
     $dataTypeObj->setLabelDataFormat($dataFormatObj);
  
  } else {

    $self->_printWarning("Unknown parent object, cant set float dataformat in $name, ignoring\n");
  
  }

  return $dataFormatObj;
}

sub _for_node_start {              
  my ($self, %attrib_hash) = @_;

  # for node sets the iteration order for how we will setData
  # in the datacube (important for delimited and formatted reads).
  if (defined (my $id = $attrib_hash{'axisIdRef'})) {
    my $axisObj = $self->{currentArrayAxes}->{$id};
    $axisObj = $self->{AxisObj}->{$id} unless defined $axisObj;
    push @{$self->{readAxisOrderList}}, $axisObj;
  } else {
    $self->_printFatalError("Error: got for node without axisIdRef, aborting read.\n");
  }

  return undef;
}

sub _formattedStyle_node_end {
  my ($self) = @_;
  pop @{$self->{currentFormatObjectList}};
}

sub _formattedStyle_node_start {
  my ($self, %attrib_hash) = @_;

  # if this is still defined, we havent init'd an
  # XMLDataIOStyle object for this array yet, do it now. 
  # set the format object in the current array
  # (other case: we got a format object from a dataStyleIdRef and
  #  already supplied correct stuff)

  my $formatObj;
  if ( defined $self->{dataIOStyleAttribRef}) {
    $formatObj = new XDF::FormattedXMLDataIOStyle($self->{currentArray}, $self->{dataIOStyleAttribRef});
    $formatObj->setXMLAttributes($self->{dataIOStyleAttribRef});
    $self->{currentArray}->setXMLDataIOStyle($formatObj);

    my $dataStyleId = $formatObj->getDataStyleId();
    if (defined $dataStyleId ) {
       $self->_printWarning( "Danger: More than one read node with dataStyleId=\"$dataStyleId\", using latest node.\n" )   
           if defined $self->{XMLDataIOStyleObj}{$dataStyleId};
       $self->{XMLDataIOStyleObj}{$dataStyleId} = $formatObj;
    }

    # undefine so we wont init again.
    $self->{dataIOStyleAttribRef} = undef;

    # add to current format Object List
    push @{$self->{currentFormatObjectList}}, $formatObj;
  }

  return $formatObj;
}


sub _integerField_node_start {
  my ($self, %attrib_hash) = @_;

  # this can waste memory, however these should always be quite small. 
  # see perl cookbook on merging hashes
  my %merged_hash = (%{$self->{dataFormatAttribRef}}, %attrib_hash);

  # create the object, add it to the current datatype holder 
  my $dataTypeObj = $self->_currentFormatOwnerObject();

  my $dataFormatObj;
  my $name = ref $dataTypeObj;
  if (ref($dataTypeObj) eq 'XDF::Field' or ref($dataTypeObj) eq 'XDF::Array' or ref($dataTypeObj) eq 'XDF::Parameter' ) 
  {
  
     $dataFormatObj = new XDF::IntegerDataFormat(\%merged_hash);
     $dataTypeObj->setDataFormat($dataFormatObj);
  
  } elsif ($name eq 'XDF::Axis' or $name eq 'XDF::ColAxis' or $name eq 'XDF::RowAxis' ) {

     $dataFormatObj = new XDF::IntegerDataFormat(\%merged_hash);
     $dataTypeObj->setLabelDataFormat($dataFormatObj);

  } else {
  
    $self->_printWarning("Unknown parent object, cant set integer dataformat in $name, ignoring\n");
  
  }

  return $dataFormatObj;
}

sub _newLine_node_start {
  my ($self, %attrib_hash) = @_;

  my $newLineObj = new XDF::NewLine(\%attrib_hash);

  my $lastObject = $self->_lastObj();

  $self->_printFatalError("Internal error: cant set chars, last object not defined\n")
      unless defined $lastObject;

  if ( ref($lastObject) eq 'XDF::SkipCharFormattedIOCmd') {
     $lastObject->setOutput($newLineObj);
     return $newLineObj;
  } elsif ( ref($lastObject) eq 'XDF::Delimiter') {
     $lastObject->setValue($newLineObj);
     return $newLineObj;
  } elsif ( ref($lastObject) eq 'XDF::RecordTerminator') {
     $lastObject->setValue($newLineObj);
     return $newLineObj;
  } else {
     $self->_printWarning(" cant add NewLine object to parent:$lastObject not a valid object. Ignoring request\n");
  }

  return undef;

}


sub _note_node_charData {
  my ($self, $string) = @_;

  if (defined $self->{lastNoteObject}) {
    # add string as the value of the note
    $self->{lastNoteObject}->addText($string);

  } else {

    # error! did they specify a value on an idRef'd node??
    $self->_printWarning("Weird error: tried to put value on non-existent note!($string)\n"); 

  }

}

# this, along with notes_*, needs to be re-written proper
sub _note_node_start {
  my ($self, %attrib_hash) = @_;

   # note: note nodes sometimes appear within notes node,
   # use $self->{lastNotesParentObject} to determine if this is the case
   # (yes this is crappy)
   my $parent_node = defined $self->{lastNotesParentObject} ? $XDF_node_name{'array'} : undef;
   $parent_node = $self->_parentNodeName() unless defined $parent_node;
  
   my $noteObj = new XDF::Note(\%attrib_hash);

   # does this object have a noteIdRef? If so, we clone a copy
   if (exists($attrib_hash{'noteIdRef'})) {
      my $id = $attrib_hash{'noteIdRef'};

      # clone from the reference object
      $noteObj = $self->{NoteObj}{$id}->clone();


      # override with local values
      $noteObj->setXMLAttributes(\%attrib_hash);
      $noteObj->setNoteId($self->_getUniqueIdName($id, \%{$self->{NoteObj}})); # set ID attribute to unique name 
      $noteObj->setNoteIdRef(undef); # unset IDREF attribute 
   }

   # Does this object have a noteId? if so, add to our roster of notes 
   if ((my $id = $noteObj->getNoteId())) {
         $self->_printWarning("More than one note node with noteId=\"$id\", using latest node.\n")
            if defined $self->{NoteObj}{$id};
         $self->{NoteObj}{$id} = $noteObj;
   }

   my $addNoteObj;
   if ($parent_node eq $XDF_node_name{'array'}) {
         $addNoteObj = $self->{currentArray};
   } elsif ($parent_node eq $XDF_node_name{'field'}) {
         $addNoteObj = $self->_lastFieldObj();
   } elsif ($parent_node eq $XDF_node_name{'parameter'}) {
         $addNoteObj = $self->{lastParamObject};
   } else {
         $self->_printWarning( "Unknown parent node: $parent_node for note. Ignoring\n");
   }

   if (defined $addNoteObj) {
      return unless $addNoteObj->addNote($noteObj);
   }

   $self->{lastNoteObject} = $noteObj;

   return $noteObj;
}

sub _note_index_node_start {
   my ($self, %attrib_hash) = @_;
   push @{$self->{noteLocatorOrder}}, $attrib_hash{'axisIdRef'};
   return undef;
}

sub _notes_node_end {
   my ($self) = @_;

   my $notesParentObj = $self->{lastNotesParentObject};

   if (defined $notesParentObj->getNotes()) { 
      my $notesObj = $notesParentObj->getNotes();
      for (@{$self->{noteLocatorOrder}}) { 
          $notesObj->addAxisIdToLocatorOrder($_); 
      }
   }

   # reset the location order 
   @{$self->{noteLocatorOrder}} = ();
   
   # clear notes object
   $self->{lastNotesParentObject} = undef;
}

sub _notes_node_start {
   my ($self, %attrib_hash) = @_;

   my $_parentNodeName = $self->_parentNodeName();

   my $obj;
   if ($_parentNodeName eq $XDF_node_name{'field'}) {
        $obj = $self->_lastFieldObj();
   } elsif ($_parentNodeName eq $XDF_node_name{'parameter'}) {
        $obj = $self->{lastParamObject};
   } elsif ($_parentNodeName eq $XDF_node_name{'array'}) {
        $obj = $self->{currentArray};
   } else {
        die "Weird parent $_parentNodeName for notes object\n";
   }

   $self->{lastNotesParentObject} = $obj if defined $obj; # ->notes() if defined $obj;

   #special handling: notes object comes 'pre-defined' in parent,
   # so go to the parent to find it.
   my $notesObj = defined $obj ? $obj->getNotes : undef;
   $notesObj->setXMLAttributes(\%attrib_hash);

   return $notesObj;
}

sub _parameter_node_start {
   my ($self, %attrib_hash) = @_;

   my $_parentNodeName = $self->_parentNodeName();

   my $paramObj = new XDF::Parameter(\%attrib_hash);
   if($_parentNodeName eq $XDF_node_name{'array'} ) {

       return unless $self->{currentArray}->addParameter($paramObj);

   } elsif($_parentNodeName eq $XDF_node_name{'root'}
              || $_parentNodeName eq $XDF_node_name{'structure'})
   { 

       return unless $self->{currentStructure}->addParameter($paramObj);

   } elsif($_parentNodeName eq $XDF_node_name{'parameterGroup'} ) {

#        $LAST_GROUP_OBJECT->addObject(new XDF::Parameter(\%attrib_hash));
        # for now, just add as regular parameter 
       return unless $self->{lastParamGroupParentObject}->addParameter($paramObj);

   } else {
       die" weird parent node $_parentNodeName for parameter";
   }

   # add this object to all open groups
   foreach my $groupObj (@{$self->{currentParamGroupList}}) { $paramObj->addToGroup($groupObj); }

   $self->{lastParamObject} = $paramObj;

   return $paramObj;
}

sub _parameterGroup_node_end { 
   my ($self) = @_;
   pop @{$self->{currentParamGroupList}}; 
}

sub _parameterGroup_node_start {
   my ($self, %attrib_hash) = @_;
  
  my $_parentNodeName = $self->_parentNodeName();

  my $paramGroupObj = new XDF::ParameterGroup(\%attrib_hash);

  if($_parentNodeName eq $XDF_node_name{'array'} ) {

    return unless $self->{currentArray}->addParamGroup($paramGroupObj);
    $self->{lastParamGroupParentObject} = $self->{currentArray};

  } elsif($_parentNodeName eq $XDF_node_name{'root'}
              || $_parentNodeName eq $XDF_node_name{'structure'})
  {

    return unless $self->{currentStructure}->addParamGroup($paramGroupObj);
    $self->{lastParamGroupParentObject} = $self->{currentStructure};

  } elsif($_parentNodeName eq $XDF_node_name{'parameterGroup'} ) {

    my $lastGroupObj = $self->{currentParamGroupList}[$#{$self->{currentParamGroupList}}]; 
    return unless $lastGroupObj->addParamGroup($paramGroupObj);

  } else {

     die" weird parent node $_parentNodeName for parameterGroup";

  }

  # add this object to all open groups
  foreach my $groupObj (@{$self->{currentParamGroupList}}) { $paramGroupObj->addToGroup($groupObj); }

  # now add it to the list
  push @{$self->{currentParamGroupList}}, $paramGroupObj;

  return $paramGroupObj;
}

sub _polynomial_node_charData {
  my ($self, $string) = @_;

  # remove leading/trailing whitespace
  $string =~ s/^\s*//;
  $string =~ s/\s*$//;
  my @coeffs = split ' ', $string;
  $self->{lastPolynomialObj}->setCoefficients(\@coeffs);
   
}

sub _polynomial_node_start {
  my ($self, %attrib_hash) = @_;

  my $parentNodeName = $self->_parentNodeName();

  my $polyObj= new XDF::Polynomial(\%attrib_hash);

  if($parentNodeName eq $XDF_node_name{'valueListAlgorithm'} ) {

    $self->{currentValueList}->setAlgorithm($polyObj);

  } else {

    die" weird parent node $parentNodeName for polynomial\n";

  }

  $self->{lastPolynomialObj} = $polyObj;

}

sub _read_node_start { 
   my ($self, %attrib_hash) = @_;

  # zero this out for upcoming read 
  @{$self->{readAxisOrderList}} = ();

  # clear out the format command object array
  # (its used by Formatted reads only, but this is reasonable 
  # spot to do this).
  @{$self->{currentFormatObjectList}} = ();

  # do we have an idREf? if so, copy the object, otherwise we will 
  # save these for later, when we know what kind of dataIOstyle we got
  # use reference object, if refId exists 
  my $dataStyleIdRef = $attrib_hash{'dataStyleIdRef'};
  my $readObj;
  if (defined $dataStyleIdRef) {

     # clone from the reference object
     $readObj = $self->{XMLDataIOStyleObj}{$dataStyleIdRef}->clone();

     # override with local values
     $readObj->setXMLAttributes(\%attrib_hash);

     # set ID attribute to unique name 
     $readObj->setDataStyleId($self->_getUniqueIdName($dataStyleIdRef, \%{$self->{XMLDataIOStyleObj}}));
     $readObj->setDataStyleIdRef(undef); # unset IDREF attribute 

     $self->{currentArray}->setXMLDataIOStyle($readObj);

     push @{$self->{currentFormatObjectList}}, $readObj; #,$self->{currentArray}->getXMLDataIOStyle();

     # populate readorder array. We will have problems if someone specifies
     # dataStyleIdRef AND has child for nodes on the read node. fef.  
     my $oldArrayObj = $self->{XMLDataIOStyleObj}{$dataStyleIdRef}->{_parentArray}; #shouldnt be allowed to do this 
     # note: we *must* run in reverse here to simulate it being read in 
     # by the for nodes, which occur in that reverse ordering.
     foreach my $oldAxisObj (reverse @{$self->{readAxisOrderHash}{$oldArrayObj}}) {
        my $axisObj = $self->{currentArrayAxes}->{$oldAxisObj->getAxisId};
        if (defined $axisObj) {
          push @{$self->{readAxisOrderList}}, $axisObj; 
        } else {
          $self->_printFatalError("Bad code error: axisObj not found in CURRENT_ARRAY_AXES.\n");
        }
     }
   
     # add this object to the lookup array
     my $id = $readObj->getDataStyleId();
     $self->{XMLDataIOStyleObj}{$id} = $readObj;

  } else { 
     $self->{dataIOStyleAttribRef} = \%attrib_hash;
  }

  return $readObj;

}

sub _readCell_node_start { 
   my ($self, %attrib_hash) = @_;

  my $formatObj = $self->_currentFormatObject();
  my $readCellObj = new XDF::ReadCellFormattedIOCmd(\%attrib_hash);
  return unless $formatObj->addFormatCommand($readCellObj);

  return $readCellObj;
}

sub _recordTerminator_node_start {
  my ($self, %attrib_hash) = @_;

  # create obj
  my $recordTerminatorObj = new XDF::RecordTerminator(\%attrib_hash); 

  # okey, now that that is taken care off, we will go 
  # get the current format (read) object, and add the readCell
  # command to it
  my $formatObj = $self->_currentFormatObject();

  if ( ref($formatObj) eq 'XDF::DelimitedXMLDataIOStyle') {
     $formatObj->setRecordTerminator($recordTerminatorObj);
     return $recordTerminatorObj;
  } else {
     $self->_printWarning("Cant add RecordTerminator object to parent($formatObj)..its not a DelimitedXMLDataIOStyle Object. Ignoring request\n");
  }

  return undef;

}
                       
sub _relationship_node_start {
  my ($self, %attrib_hash) = @_;
                       
   my $relObj;         
   my $parent = $self->_lastObj();
   my $name = ref $parent;
   if ($name eq 'XDF::Field' or $name eq 'XDF::Array') {
                       
       $relObj = new XDF::Relation(\%attrib_hash);    
       $parent->setRelation($relObj);
                       
   } else {            

      $self->_printWarning("Unknown parent object, cant set relationship in $name, ignoring\n");
                       
   }
                       
   return $relObj;
}                      

sub _repeat_node_end { 
   my ($self) = @_;
   pop @{$self->{currentFormatObjectList}}; 
}

sub _repeat_node_start {
   my ($self, %attrib_hash) = @_;

  my $formatObj = $self->_currentFormatObject();
  my $repeatObj = new XDF::RepeatFormattedIOCmd(\%attrib_hash);
  return unless $formatObj->addFormatCommand($repeatObj);
 
  push @{$self->{currentFormatObjectList}}, $repeatObj;

  return $repeatObj;
}

sub _root_node_start { 
   my ($self, %attrib_hash) = @_;
  
   if (!defined $self->{XDF}) {
      $self->{XDF} = XDF::XDF->new(\%attrib_hash);
   } else {
      # hmm. already defined? then we must want to load into this object.
      $self->{XDF}->setXMLAttributes(\%attrib_hash);
   }
   $self->{currentStructure} = $self->{XDF};

   my $spec= XDF::Specification->getInstance();
   $spec->setDefaultDataArraySize($self->{Options}->{axisSize})
      if defined $self->{Options}->{axisSize};

   return $self->{XDF};

}

# for the tags in tagged data
sub _row_node_start {
  my ($self, %attrib_hash) = @_;

  my $readObj = $self->{currentArray}->getXMLDataIOStyle();
  if (ref ($readObj) ne 'XDF::TaggedXMLDataIOStyle' ) {

          # Finding out that this must be the first time thru because
          # its not Delimited style AND we got a row/col node.. well not robust,
          # but will work. 

          #..ok lets define the necessary stuff..

          # force it to be tagged, remember to add dataStyle to array FIRST, before changing outputstyle
          $readObj = new XDF::TaggedXMLDataIOStyle();
          $self->{currentArray}->setXMLDataIOStyle($readObj);
          $readObj->setOutputStyle(&XDF::Constants::TAGGED_BYROW_OUTPUTSTYLE);

          $self->{psuedoSimpleReadObj} = new XDF::DelimitedXMLDataIOStyle($self->{currentArray}); 

          # we also need to create this too
          $self->{taggedLocatorObject} = $self->{currentArray}->createLocator;

          # configure axis ordering to be row-oriented
          my @newOrder = ( $self->{currentArray}->getColAxis(), $self->{currentArray}->getRowAxis() );
          $self->{taggedLocatorObject}->setIterationOrder(\@newOrder);

          $self->{currentRow} = 0;
  }

  return undef;
}  
      
# for the tags in tagged data
sub _row_node_end {
  my ($self) = @_;

  if ($self->{currentRow} == $self->{taggedLocatorObject}->getAxisIndex($self->{currentArray}->getRowAxis()))
  {
     # uh oh, we had a "short" read in the row.. apparently didnt supply all the cells. 
     # lets advance the row marker by 1 in this case and reset the column to "0"
     $self->{taggedLocatorObject}->setAxisIndex($self->{currentArray}->getRowAxis(), $self->{currentRow}+1);
     $self->{taggedLocatorObject}->setAxisIndex($self->{currentArray}->getColAxis(), 0);
  }

  $self->{currentRow}++;

}

sub _rowaxis_node_start {

  my ($self, %attrib_hash) = @_;

  my $axisObj = new XDF::RowAxis(\%attrib_hash);
  $self->_axis_node_add($axisObj, %attrib_hash);

}


sub _simpleDelimited_node_charData {
   my ($self, $string) = @_;

   if ($self->{dataNodeLevel} > 0) {

      # dont add this data unless it has more than just whitespace
      if (!$IGNORE_WHITESPACE_ONLY_DATA || $string !~ m/^\s*$/) {

#        my $location = $self->{taggedLocatorObject}->_dumpLocation;
#       debug("ADDING ROW DATA to:$location [$string]");

         # Badness. We need to parse row data, which may be multiple stuff into datum 
         # we can use. Unfortunately, delmited parsing is now in the DataCube, and we have
         # to (uncomforatably) access this PRIVATE routine. We also need to "fake" a default
         # delimited read object. Bah. 
         $self->{currentArray}->getDataCube()->_read_delimitted_data( $self->{taggedLocatorObject}, $string, $self->{psuedoSimpleReadObj});
      }

   }

}

sub _skipChar_node_start {
   my ($self, %attrib_hash) = @_;

  my $formatObj = $self->_currentFormatObject();
  my $skipCharObj = new XDF::SkipCharFormattedIOCmd(\%attrib_hash);
  return unless $formatObj->addFormatCommand($skipCharObj);

  return $skipCharObj;

}

sub _stringField_node_start {
   my ($self, %attrib_hash) = @_;

  # this can waste memory, however these should always be quite small. 
  # see perl cookbook on merging hashes
  my %merged_hash = (%{$self->{dataFormatAttribRef}}, %attrib_hash);

  # create the object, add it to the current datatype holder 
  my $dataTypeObj = $self->_currentFormatOwnerObject();
  my $name = ref $dataTypeObj;
  my $dataFormatObj;
  if ( $name eq 'XDF::Field' or $name eq 'XDF::Array' or $name eq 'XDF::Parameter' ) {

     $dataFormatObj = new XDF::StringDataFormat(\%merged_hash);
     return unless $dataTypeObj->setDataFormat($dataFormatObj); 


  } elsif ($name eq 'XDF::Axis' or $name eq 'XDF::ColAxis' or $name eq 'XDF::RowAxis' ) {

     $dataFormatObj = new XDF::StringDataFormat(\%merged_hash);
     $dataTypeObj->setLabelDataFormat($dataFormatObj);

  } else {

    $self->_printWarning("Unknown parent object, cant set string dataformat in $name, ignoring\n");

  }
  return $dataFormatObj;
}

sub _structure_node_start {
  my ($self, %attrib_hash) = @_;

#   if (!defined $self->{XDF}) {
#      $self->{XDF} = XDF::Structure->new(\%attrib_hash);
#      $self->{currentStructure} = $self->{XDF};
#   } else {
      my $structObj = new XDF::Structure(\%attrib_hash);
      return unless $self->{currentStructure}->addStructure($structObj);
      $self->{currentStructure} = $structObj;
#   }
   
   return $self->{currentStructure};
}

sub _taggedData_node_charData {
   my ($self, $string) = @_;

   if ($self->{dataNodeLevel} > 0) {

      my $readObj = $self->{currentArray}->getXMLDataIOStyle();

      if (ref ($readObj) eq 'XDF::TaggedXMLDataIOStyle' ) {

         # dont add this data unless it has more than just whitespace
         if (!$IGNORE_WHITESPACE_ONLY_DATA || $string !~ m/^\s*$/) {

#       my $location = $self->{taggedLocatorObject}->_dumpLocation;
#       debug("ADDING DATA to:$location [$string]");
           $self->{dataTagLevel} = $self->{currentDataTagLevel};
           $self->{currentArray}->addData($self->{taggedLocatorObject}, $string);
         }
      }
   }

}

sub _taggedStyle_node_end { 
  my ($self) = @_;

  # remove from format list
  pop @{$self->{currentFormatObjectList}}; 

}

sub _taggedStyle_node_start {
  my ($self, %attrib_hash) = @_;

  my $formatObj;
  if ( defined $self->{dataIOStyleAttribRef}) {

    $formatObj = new XDF::TaggedXMLDataIOStyle($self->{dataIOStyleAttribRef});

    $self->{currentArray}->setXMLDataIOStyle($formatObj); 

    my $dataStyleId = $formatObj->getDataStyleId();
    if (defined $dataStyleId) {
       $self->_printWarning( "Danger: More than one read node with dataStyleId=\"$dataStyleId\", using latest node.\n" )          
           if defined $self->{XMLDataIOStyleObj}->{$dataStyleId};
       $self->{XMLDataIOStyleObj}->{$dataStyleId} = $formatObj;
    }

    # so we dont init again (which is unlikely in the tagged case..)
    $self->{dataIOStyleAttribRef} = undef;

    # add to format list (probably not needed, but lets do for sake of good form..) 
    push @{$self->{currentFormatObjectList}}, $formatObj;

  }

  return $formatObj;
}

sub _tagToAxis_node_start {
   my ($self, %attrib_hash) = @_;

  # add in the axis, tag information
  $self->{currentArray}->getXMLDataIOStyle()->setAxisTag($attrib_hash{'tag'}, $attrib_hash{'axisIdRef'});

  return undef;
}

sub _unit_node_charData {
  my ($self, $string) = @_;

  if (defined $self->{lastUnitObject}) {
    # add string as the value of the note
    $self->{lastUnitObject}->setValue($string);

  } else {

    # error! did they specify a value on an idRef'd node??
    $self->_printWarning( "Crazy error! tried to put value on non-existent note!($string)\n");

  }

}

sub _unit_node_start {
   my ($self, %attrib_hash) = @_;

  my $_parentNodeName = $self->_grandParentNodeName();

  my $unitObj = new XDF::Unit(\%attrib_hash);

  if ($_parentNodeName eq $XDF_node_name{'field'} ) {

     # add the unit to the last parameter node in grandparent
      my $fieldObj = $self->_lastFieldObj();

      return unless $fieldObj->addUnit($unitObj);

  } elsif ($_parentNodeName eq $XDF_node_name{'axis'} 
            or $_parentNodeName eq $XDF_node_name{'colAxis'} 
            or $_parentNodeName eq $XDF_node_name{'rowAxis'} 
   ) {

      my $axisObj = $self->_lastAxisObj();
      return unless $axisObj->addUnit($unitObj);

  } elsif ($_parentNodeName eq $XDF_node_name{'array'} ) {

      return unless $self->{currentArray}->addUnit($unitObj);

  } elsif ($_parentNodeName eq $XDF_node_name{'parameter'} ) {

      my $paramObj = $self->{lastParamObject};
      return unless $paramObj->addUnit($unitObj);

  } else {

      $self->_printWarning( "Got Weird parent node ($_parentNodeName) for unit. \n");

  }

  $self->{lastUnitObject} = $unitObj;

  return $unitObj;
}

sub _units_node_start { 
   my ($self, %attrib_hash) = @_;

   my $unitsObj = XDF::Units->new(\%attrib_hash);

   my $_parentNodeName = $self->_parentNodeName();

  if ($_parentNodeName eq $XDF_node_name{'field'} ) {

      my $fieldObj = $self->_lastFieldObj();
      $unitsObj = $fieldObj->setUnits($unitsObj);

  } elsif ($_parentNodeName eq $XDF_node_name{'array'} ) {

      $unitsObj = $self->{currentArray}->setUnits($unitsObj);
  
  } elsif ($_parentNodeName eq $XDF_node_name{'parameter'} ) {

      my $paramObj = $self->{lastParamObject};
      $unitsObj = $paramObj->setUnits($unitsObj);
  
  } elsif ($_parentNodeName eq $XDF_node_name{'axis'} 
             or $_parentNodeName eq $XDF_node_name{'colAxis'} or $_parentNodeName eq $XDF_node_name{'rowAxis'} 
          ) {

      my $axisObj = $self->_lastAxisObj();
      $unitsObj = $axisObj->setUnits($unitsObj);

  } else {

      $self->_printWarning( "Got Weird parent node ($_parentNodeName) for units. \n");
  
  }


  return $unitsObj;
}

sub _unitless_node_start {
   my ($self, %attrib_hash) = @_;
  # do nothing
  return undef;
}

sub _value_node_charData {
  my ($self, $string) = @_;

  my $parent_node = $self->_parentNodeName();

  my $valueObj = new XDF::Value($string);
  if (defined $self->{lastValueObjAttribRef}) {
     $valueObj->setXMLAttributes($self->{lastValueObjAttribRef});
     $self->{lastValueObjAttribRef} = undef;
  }

  $self->_addValue($valueObj, $parent_node);
}

sub _value_node_end {
   my ($self) = @_;

   # if attrib ref still defined, then we have to add this object
   if (defined $self->{lastValueObjAttribRef}) {

      # create the value
      my $valueObj = new XDF::Value();
      $valueObj->setXMLAttributes($self->{lastValueObjAttribRef});

      # add the value
      my $parent_node = $self->_parentNodeName();
      $self->_addValue($valueObj, $parent_node);

      # clear attrib ref, so we know that nothing is pending to be added.
      $self->{lastValueObjAttribRef} = undef;
   }

}

sub _value_node_start {
   my ($self, %attrib_hash) = @_;

   # save for later
   $self->{lastValueObjAttribRef} = \%attrib_hash;
}

sub _valueGroup_node_end { 
   my ($self) = @_;
   pop @{$self->{currentValueGroupList}}; 
}

sub _valueGroup_node_start {
   my ($self, %attrib_hash) = @_;

  my $_parentNodeName = $self->_parentNodeName();

  my $valueGroupObj = new XDF::ValueGroup(\%attrib_hash);

  if( $_parentNodeName eq $XDF_node_name{'axis'} 
       or $_parentNodeName eq $XDF_node_name{'colAxis'} or $_parentNodeName eq $XDF_node_name{'rowAxis'} 
    ) {

    my $axisObj = $self->_lastAxisObj();
    return unless $axisObj->addValueGroup($valueGroupObj);
    $self->{lastValueGroupParentObject} = $axisObj;

  } elsif($_parentNodeName eq $XDF_node_name{'parameter'} ) {

    my $paramObj = $self->{lastParamObject};
    return unless $paramObj->addValueGroup($valueGroupObj);
    $self->{lastValueGroupParentObject} = $paramObj;

  } elsif($_parentNodeName eq $XDF_node_name{'valueGroup'} ) {

    my $lastGroupObj = $self->{currentValueGroupList}->[$#{$self->{currentValueGroupList}}];
    return unless $lastGroupObj->addValueGroup($valueGroupObj);

  } else {

     die" weird parent node $_parentNodeName for valueGroup";

  }

  foreach my $groupObj (@{$self->{currentValueGroupList}}) {
     $valueGroupObj->addToGroup($groupObj);
  }

  # now add it to the list
  push @{$self->{currentValueGroupList}}, $valueGroupObj;

  return $valueGroupObj;
}


sub _valueList_node_charData {
   my ($self, $valueListString) = @_;

   # IF we get here, we have the delmited case for populating
   # a value list.

   # 1. split up string into Value Objects based on declared delimiter
   my @myValueList = &_splitStringIntoValueObjects( $valueListString, $self->{currentValueList});

   $self->{currentValueList}->setValues(\@myValueList);

   return $self->{currentValueList};

}

sub _valueList_node_end {
   my ($self) = @_;

   my $thisValueList = $self->{currentValueList};

   # 2. If there is a reference object, clone it to get
   #    the new valueList
   my $valueListIdRef = $thisValueList->getValueListIdRef();
   if (defined $valueListIdRef) {

      if (exists $self->{ValueListObj}{$valueListIdRef})
      {

         # Just a simple clone since we have stored the value list rather than the
         # ValueList object (which actually doesnt exist. :P
         my $refValueListObj = $self->{ValueListObj}{$valueListIdRef};

         $thisValueList = $refValueListObj->clone();

         # override with local values
         $thisValueList->setXMLAttributes($self->{currentValueList}->getAttributes());

         # set ID attribute to unique name 
         $thisValueList->setValueListId($self->_getUniqueIdName($valueListIdRef, \%{$self->{ValueListObj}}));
         $thisValueList->setValueListIdRef(undef); # unset IDREF attribute 

      } else {
         $self->_printWarning("Error: Reader got an valueList with ValueListIdRef=\"$valueListIdRef\" but no previous valueList has that id! Ignoring add valueList request.\n");
         return;
      }
   }

   # 3. add these values to the lookup table, if the original valueList had an ID
   my $valueListId = $thisValueList->getValueListId();
   if (defined $valueListId) {

       # a warning check, just in case 
       if (exists $self->{ValueListObj}{$valueListId})
       {
            $self->_printWarning("More than one valueList node with noteId=\"$valueListId\", using latest node.\n")
                if defined $self->{ValueListObj}{$valueListId};

            # add the valueList array into the list of valueList objects
            $self->{ValueListObj}{$valueListId} = $thisValueList;

       }
   }

   # 4. add into parent object
   my $parentNode = $self->{currentValueListParent};
   $self->_addValueListToParent($thisValueList, $parentNode);

   # 6. now add valueObjects to groups 
   # add these new value objects to all open groups
   foreach my $groupObj (@{$self->{currentValueGroupList}}) {
       foreach my $valueObj (@{$self->{currentValueList}->getValues}) {
          $valueObj->addToGroup($groupObj);
       }
   }

   return $self->{currentValueList};

}

sub _valueList_delimited_node_start {
   my ($self, %attrib_hash) = @_;

   # 1. re-init and populate ValueListparameters from attribute list 
   my @emptyValueObjList;
   $self->{currentValueList} = new XDF::ValueListDelimitedList(\%attrib_hash, \@emptyValueObjList);

   #needed for delimited list, as we cant add it until its 
   # populated with values from the CharData handler.
   $self->{currentValueListParent} = $self->_parentNodeName();

   return $self->{currentValueList};

}

sub _valueList_algorithm_node_start {
   my ($self, %attrib_hash) = @_;

   # 1. Create valueList Object from algorithm
   $self->{currentValueList} = new XDF::ValueListAlgorithm(\%attrib_hash);
 
   $self->{currentValueListParent} = $self->_parentNodeName();
   #$self->_addValueListToParent($self->{currentValueList}, $parentNode);

   return $self->{currentValueList};

}

sub _vector_node_start { 
   my ($self, %attrib_hash) = @_;

  my $parent_node = $self->_parentNodeName();

  my $axisValueObj = new XDF::UnitDirection(\%attrib_hash);
  if ($parent_node eq $XDF_node_name{'axis'}
       or $parent_node eq $XDF_node_name{'colAxis'} or $parent_node eq $XDF_node_name{'rowAxis'} 
     ) {

     my $axisObj = $self->_lastAxisObj();
     return unless $axisObj->addAxisUnitDirection($axisValueObj);

  } else {
        $self->_printWarning( "$XDF_node_name{'vector'} node not supported for $parent_node yet. Ignoring node.\n");
  }

  return $axisValueObj; 

}

#
# Other misc subroutines needed for the SaxDocumentHandler
#

# 
# Protected methods
#

# ugh. is this even used?
sub _printFatalError { 
   my ($msg) = @_; 
   &error("Fatal: $msg");
   exit -1;
}

sub _printWarning {
  my ($self, $msg) = @_;
  error("Warning: $msg");
  die "$0 exiting, too many warnings.\n" if ($self->{Options}->{maxWarnings} > 0 && 
                                             $self->{nrofWarnings}++ > $self->{Options}->{maxWarnings});
}

sub _currentFormatOwnerObject {
  my ($self)=@_;
  #return $self->{currentFormatOwnerObjectList}->[$#{$self->{currentFormatOwnerObjectList}}]; 
  return $self->_grandParentObj;
}

sub _currentFormatObject {
  my ($self)=@_;
  return $self->{currentFormatObjectList}->[$#{$self->{currentFormatObjectList}}]; 
}

sub _lastObj {
  my ($self)=@_;
  #return @{$self->{lastObjList}}->[$#{$self->{lastObjList}}];
  return $self->{lastObjList}->[$#{$self->{lastObjList}}];
}

sub _parentObj {
  my ($self)=@_;
  return $self->_lastObj;
}

sub _grandParentObj {
  my ($self)=@_;
  if ($#{$self->{lastObjList}} < 1 ) {
     $self->_printFatalError("cant find grandparent object at current parse step.\n");
  }
  return $self->{lastObjList}->[$#{$self->{lastObjList}}-1];
}

sub _lastFieldObj {
  my ($self)=@_;
  my @list = $self->{currentArray}->getFieldAxis()->getFields;
  return $list[$#list];
}

sub _lastAxisObj {
  my ($self)=@_;
  #return @{$self->{currentArray}->getAxisList()}->[$#{$self->{currentArray}->getAxisList()}]; 
  return $self->{currentArray}->getAxisList()->[$#{$self->{currentArray}->getAxisList()}]; 
}

#/** _currentNodeName
# Find the node name of the node the parser is currently working on.
#*/
sub _currentNodeName {
  my ($self)=@_;
  return $self->{currentNodePath}->[$#{$self->{currentNodePath}}]; 
}

#/** _parentNodeName
# Find the node name of the parent to the current node the parser
# is currently working on.
#*/
sub _parentNodeName {
   my ($self)=@_;
   return $self->{currentNodePath}->[$#{$self->{currentNodePath}}-1]; 
}

#/** _grandParentNodeName
# Find the node name of the grandparent to the current node the parser
# is currently working on.
#*/
sub _grandParentNodeName {
  my ($self)=@_;
  return $self->{currentNodePath}->[$#{$self->{currentNodePath}}-2]; 
}

#/** _getUniqueIdName
# Given a key value and a hash table reference, this will find a unique key value
# which is returned.
# */
sub _getUniqueIdName {
   my ($self, $id, $hash_ref) = @_;
   my %hash = %{$hash_ref};
  
   # this will create axes with name that has trailing zeros 
   while (exists $hash{$id}) { $id .= '0'; }

   return $id;
}
 

#
# Private methods
#

sub _addValueListToParent {
  my ($self, $newValueListObj, $parentNodeName) = @_;

    if( $parentNodeName eq $XDF_node_name{'axis'} 
         or $parentNodeName eq $XDF_node_name{'colAxis'} or $parentNodeName eq $XDF_node_name{'rowAxis'} 
      ) {

        my $axisObj = $self->_lastAxisObj();
        $self->_printWarning("Error: cant add AxisValueListObj\n") 
            unless $axisObj->addAxisValueList($newValueListObj);

    }
    elsif( $parentNodeName eq $XDF_node_name{'parameter'} ) 
    {

        my $paramObj = $self->{lastParamObject};
        $self->_printWarning("Error: cant add ValueListObj\n") 
              unless $paramObj->addValueList($newValueListObj);

    }
    elsif ( $parentNodeName eq $XDF_node_name{'valueGroup'} ) 
    {

       if (ref($self->{lastValueGroupParentObject}) eq 'XDF::Parameter') {

           $self->_printFatalError("cant add valueListObj to parameter\n") unless 
              $self->{lastValueGroupParentObject}->addValueList($newValueListObj);

       } elsif (ref($self->{lastValueGroupParentObject}) eq 'XDF::Axis') {

           $self->_printFatalError("cant add valueListObj to axis\n") unless 
              $self->{lastValueGroupParentObject}->addAxisValueList($newValueListObj);

       } else {
          my $name = ref($self->{lastValueGroupParentObject});
          $self->_printFatalError(" ERROR: UNKNOWN valueGroupParent object ($name), can't treat for valueList.\n");
       }

    } 
    else
    {
        $self->_printFatalError("Error: weird parent node $parentNodeName for valueList node, aborting read.\n");
    }

    return $newValueListObj;

}

sub _splitStringIntoValueObjects {
  my ( $valueListString, $thisValueList) = @_;

  my $delimiter = $thisValueList->getDelimiter();
  $delimiter =~ s/(\|)/\\$1/g; # kludge for making pipes work in perl 
  $delimiter = '/' . $delimiter;
  if ($thisValueList->getRepeatable() eq 'yes') {
    $delimiter .= '+/';
  } else {
    $delimiter .= '/';
  }
  my @values;
  eval " \@values = split $delimiter, \$valueListString ";

  my @valueObjList;
  my %attrib;
#    %attrib = (
#                 'noDataValue' => $thisValueList->getNoDataValue(),
#                 'infiniteValue' => $thisValueList->getInfiniteValue(),
#                 'infiniteNegativeValue' => $thisValueList->getInfiniteNegativeValue(),
#                 'notANumberValue' => $thisValueList->getNotANumberValue(),
#                 'underflowValue' => $thisValueList->getUnderflowValue(),
#                 'overflowValue' => $thisValueList->getOverflowValue(),
#               );
  for (@values) {
     my $valueObj = _create_valueList_value_object($_, \%attrib);
     push @valueObjList, $valueObj;
  }

  return @valueObjList;
}

sub _null_cmd { }

sub _addValue {
  my ($self, $valueObj, $parent_node) = @_;

  if ($parent_node eq $XDF_node_name{'parameter'} ) {

     # add the value in $string to last parameter node in grandparent
     my $paramObj = $self->{lastParamObject};
     die "cant add value to parameter\n" unless $paramObj->addValue($valueObj);

  } elsif ($parent_node eq $XDF_node_name{'axis'} 
         or $parent_node eq $XDF_node_name{'colAxis'} or $parent_node eq $XDF_node_name{'rowAxis'} 
    ) {

     # add the value in $string to last axis node in current array 
     my $axisObj = $self->_lastAxisObj();
     die "cant add value to axis\n" unless $axisObj->addAxisValue($valueObj);

  } elsif ( $parent_node eq $XDF_node_name{'valueGroup'} ) {

    if (ref($self->{lastValueGroupParentObject}) eq 'XDF::Parameter') {

       die "cant add value to parameter\n" unless $self->{lastValueGroupParentObject}->addValue($valueObj);

    } elsif (ref($self->{lastValueGroupParentObject}) eq 'XDF::Axis') {

       die "cant add value to axis\n" unless $self->{lastValueGroupParentObject}->addAxisValue($valueObj);

    } elsif (ref($self->{lastValueGroupParentObject}) eq 'XDF::ValueGroup') {

       # can this happen?? hurm.
       die "add value to valueGroup within valueGroup not supported yet\n";

    } else {
       my $name = ref($self->{lastValueGroupParentObject});
       die " ERROR: UNKNOWN valueGroupParent object ($name), can't treat for value.\n";
    }

  } else {

     die " ERROR: UNKNOWN parent node ($parent_node), can't treat for value.\n";

  }

  # add this object to all open groups
  foreach my $groupObj (@{$self->{currentValueGroupList}}) { $valueObj->addToGroup($groupObj); }

}

sub _create_valueList_value_object {
   my ($string_val, $attribRef) = @_;

#   my %attrib = %{$attribRef};
   my $valueObj = new XDF::Value(); 

   if (defined $string_val) {
#      if (defined $attrib{'infiniteValue'} && $attrib{'infiniteValue'} eq $string_val)
#      {
#         $valueObj->setSpecial('infinite');
#      }
#      elsif (defined $attrib{'infiniteNegativeValue'} && $attrib{'infiniteNegativeValue'} eq $string_val)
#      {
#         $valueObj->setSpecial('infiniteNegative');
#      }
#      elsif (defined $attrib{'noDataValue'} && $attrib{'noDataValue'} eq $string_val)
#      {
#         $valueObj->setSpecial('noData');
#      }
#      elsif (defined $attrib{'notANumberValue'} && $attrib{'notANumberValue'} eq $string_val)
#      {
#         $valueObj->setSpecial('notANumber');
#      }
#      elsif (defined $attrib{'underflowValue'} && $attrib{'underflowValue'} eq $string_val)
#      {
#         $valueObj->setSpecial('underflow');
#      }
#      elsif (defined $attrib{'overflowValue'} && $attrib{'overflowValue'} eq $string_val)
#      {
#         $valueObj->setSpecial('overflow');
#      }
#      else 
#      {
         $valueObj->setValue($string_val);
#      }
   }

   return $valueObj;
}

sub _init {
  my ($self, $optionsHashRef) = @_;

  $self->{XDF} = new XDF::XDF(); # reference to the toplevel XDF structure we are populating
  $self->{currentFormatObjectList} = []; 
  $self->{currentFieldGroupList} = []; 
  $self->{currentParamGroupList} = []; 
  $self->{currentValueGroupList} = []; 
  $self->{currentArrayAxes} = {};

  $self->{readAxisOrderList} = []; # @{$self->{readAxisOrderList} = ();
  $self->{readAxisOrderHash} = {}; # %ReadAxisOrder;

  #$self->{dataFormatAttribRef};  # used for holding on to the attrib_hash of a 'read' node
                                 # for later when we know what kind of DataFormat obj to use

  #$self->{dataIOStyleAttribRef}; # used for holding on to the attrib_hash of a 'read' node
                                 # for later when we know what kind of DataIOStyle obj to use

  # needed to capture internal entities.
  $self->{Notation} = {}; # hash 
  $self->{Entity} = {}; # hash
  $self->{UnParsedEntity} = {};

  # needed to properly keep track of whitespace data within non-CDATASectioned 
  # datablocks
  $self->{whitespaceData} = undef;
  $self->{thisDataNodeHasAlreadyAddedData} = 0;

  # needed to allow many supporting subroutines (like _parentNodeName) 
  # to work. Indicates our current position within the Document as we are
  # parsing it. 
  $self->{currentNodePath} = []; # array

  # global (switch) variables 
  $self->{dataNodeLevel} = 0;   # how nested we are within a set of datanodes. 
  $self->{currentDataTagLevel} = 0; # how nested we are within d0/d1/d2 data tags
  $self->{dataTagLevel} = 0;         # the level where the actual char data is

  # our options reference array
  $self->{Options} = {};
  if (defined $optionsHashRef && ref($optionsHashRef)) {
    while (my ($option, $value) = each %{$optionsHashRef}) {
       $self->{Options}->{$option} = $value;
    }
  }
  $self->{Options}->{msgThresh} = $PARSER_MSG_THRESHOLD unless defined $self->{Options}->{msgThresh};
  $self->{Options}->{maxWarnings} = $MAX_WARNINGS unless defined $self->{Options}->{maxWarnings};
  $self->{Options}->{quiet} = $QUIET unless defined $self->{Options}->{quiet};
  $DEBUG = $self->{Options}->{debug} if defined $self->{Options}->{debug};
  $self->{Options}->{loadDataOnDemand} = $DONT_LOAD_DATA_YET unless defined $self->{Options}->{loadDataOnDemand};
   $self->{Options}->{cacheDataOnDisk} = $STORE_DATA_ON_DISK unless defined $self->{Options}->{cacheDataOnDisk};

#print STDERR "reader dontLoadYet is ",$self->{Options}->{loadDataOnDemand},"\n";
#print STDERR "reader dontLoadHrefYet is ",$DONT_LOAD_DATA_YET,"\n";
#print STDERR "reader debug is ",$DEBUG,"\n";
#print STDERR "reader quiet is ",$self->{Options}->{quiet},"\n";
#print STDERR "reader maxWarning is ",$self->{Options}->{maxWarnings},"\n";

  # lookup hashes of handlers 
  $self->{startElementHandler} = \%Start_Handler;
  $self->{endElementHandler} = \%End_Handler;
  $self->{charDataHandler} = \%CharData_Handler;
  $self->{defaultHandler} = \%Default_Handler;

  # need this in order to properly simulate action of valueList node
  $self->{currentValueList} = undef;
  $self->{currentValueListParent} = undef;

  # hashes to keep track of various
  # ID's (so we can use IDREF mech to reference objects)
  $self->{ArrayObj} = {}; # hash
  $self->{AxisObj} = {};
  $self->{FieldObj} = {};
  $self->{XMLDataIOStyleObj} = {};
  $self->{NoteObj} = {};

  $self->{nrofWarnings} = 0; # a counter that is compared to $MAX_WARNINGS to see if we halt 

  $self->{lastObjList} = []; # a list of objects, should map roughly to xml node traversal order 
                             # but may contain null entries since not all XML nodes coorespond to XDF objects.
}

sub _create_parser {
  my ($self) = @_;
  
  my $nameSpaces = 0;
  my $parseParamEnt = 0;
  my $noExpand = 0;
  my $expandParamEnt = 1;
  
#  if (defined $optionsHashRef) {
#    my %option = %{$optionsHashRef};
    $noExpand = $self->{Option}->{NoExpand} if exists $self->{Option}->{NoExpand};
    $nameSpaces = $self->{Option}->{namespaces} if exists $self->{Option}->{namespaces};
    $parseParamEnt = $self->{Option}->{ParseParamEnt} if exists $self->{Option}->{ParseParamEnt};
    $expandParamEnt = $self->{Option}->{ExpandParamEnt} if exists $self->{Option}->{ExpandParamEnt};
#  }

                                #NoExpand => $noExpand,
   my $parser = new XML::Parser(  
                                ParseParamEnt => $parseParamEnt,
                                ExpandParamEnt => $expandParamEnt,
                                NoExpand => 1,
                                Namespaces => $nameSpaces,
                                Handlers => {
                                     Start => sub { &_handle_start($self, @_); },
                                     End   => sub { &_handle_end($self, @_); },
                                     Init =>  sub { &_handle_init($self, @_); }, 
                                     Final => sub { &_handle_final($self, @_); },
                                     Char  => sub { &_handle_char($self, @_); },
                                     Proc =>  sub { &_handle_proc($self, @_); },
                                     Comment => sub { &_handle_comment($self, @_); },
                                     CdataStart => sub { &_handle_cdata_start($self, @_); },
                                     CdataEnd => sub { &_handle_cdata_end($self, @_); },
                                     ExternEnt => sub { &_handle_external_ent($self, @_); },
                                     Entity =>  sub { &_handle_entity($self, @_); },
                                     Element => sub { &_handle_element($self, @_); },
                                     XMLDecl => sub { &_handle_xml_decl($self, @_); },
                                     Notation => sub { &_handle_notation($self, @_); },
                                     Unparsed => sub { &_handle_unparsed($self, @_); },
                                     Doctype => sub { &_handle_doctype($self, @_); },
                                     Attlist => sub { &_handle_attlist($self, @_); },
                                     Default => sub { &_handle_default($self, @_); },
                                            }
                              );

  return $parser;

}

sub _create_validating_parser {
  my ($optionsHashRef) = @_;

  my $noExpand = 0;
  my $nameSpaces = 0;
  my $parseParamEnt = 0;
  my $expandParamEnt = 1;

  if (defined $optionsHashRef) {
    my %option = %{$optionsHashRef};
    $noExpand = $option{'NoExpand'} if exists $option{'NoExpand'};
    $nameSpaces = $option{'namespaces'} if exists $option{'namespaces'};
    $parseParamEnt = $option{'ParseParamEnt'} if exists $option{'ParseParamEnt'};
    $expandParamEnt = $option{'ExpandParamEnt'} if exists $option{'ExpandParamEnt'};
  }

   my $parser = new XML::Checker::Parser (
                                ParseParamEnt => $parseParamEnt,
                                ExpandParamEnt => $expandParamEnt,
                                NoExpand => $noExpand,
                                Namespaces => $nameSpaces,
                                Handlers => {
                                     Start => \&_handle_start,
                                     End   => \&_handle_end,
                                     Init => \&_handle_init,
                                     Final => \&_handle_final,
                                     Char  => \&_handle_char,
                                     Proc => \&_handle_proc,
                                     Comment => \&_handle_comment,
                                     CdataStart => \&_handle_cdata_start,
                                     CdataEnd => \&_handle_cdata_end,
                                     ExternEnt => \&_handle_external_ent,
                                     Entity => \&_handle_entity,
                                     Element => \&_handle_element,
                                     XMLDecl => \&_handle_xml_decl,
                                     Notation => \&_handle_notation,
                                     Unparsed => \&_handle_unparsed,
                                     Doctype => \&_handle_doctype,
                                     Attlist => \&_handle_attlist,
                                     Default => \&_handle_default,
                                            }
                              );

}

# Throws an exception (with die) when an error is encountered, this
# will stop the parsing process.
# Don't die if a warning or info message is encountered, just print a message.
sub _my_fail {
   my $self = shift;
   my $code = shift;
   die XML::Checker::error_string ($code, @_) if $code < 200;
   XML::Checker::_printFatalError ($code, @_) if $code < $self->{Options}->{msgThresh};
}

sub _make_attrib_array_a_hash {
  my ($self, $arrayref) = @_;

  my @array = @{$arrayref};
  my %hash;

  while (@array) {
     my $var = shift @array;
     my $val = shift @array;
     $self->_printWarning("duplicate attributes for $var, overwriting\n")
       unless !defined $hash{$var} || $QUIET;
     $hash{$var} = $val;
  }

  return %hash;
}

# this is the actual default start handler for the Reader.
# (see Default_Handler hash)
# This subroutine WONT be used if the user uses the method
# setDefaultStartHandler().
sub _default_start_handler {
   my ($self,$e, $attrib_hash_ref) = @_;

   my $parentNodeName = $self->_parentNodeName();
   my $newelement;

   # the DTD sez that if we get non-xdf defined nodes, it IS 
   # allowed as long as these are children of the following 
   # XDF defined nodes, OR are children of a non-XDF defined node
   # (e.g. the child of one of these nodes, which we call 'XDF::XMLElementNode')
   if( $parentNodeName eq $XDF_node_name{'structure'} 
       || $parentNodeName eq $XDF_node_name{'root'} 
     ) 
   {

     $newelement = &_create_new_XMLelement($e, $attrib_hash_ref);
     $self->{currentStructure}->addXMLElement($newelement);

   } elsif( $parentNodeName eq $XDF_node_name{'array'} ) { 

     $newelement = &_create_new_XMLelement($e, $attrib_hash_ref);
     $self->{currentArray}->addXMLElement($newelement);

   } elsif( $parentNodeName eq $XDF_node_name{'fieldAxis'} ) { 

     $newelement = &_create_new_XMLelement($e, $attrib_hash_ref);
     $self->{currentArray}->getFieldAxis->addXMLElement($newelement);

   } elsif( $parentNodeName eq $XDF_node_name{'parameter'} ) { 

     $newelement = &_create_new_XMLelement($e, $attrib_hash_ref);
     $self->{lastParamObject}->addXMLElement($newelement);

   } elsif( $parentNodeName eq $XDF_node_name{'axis'} 
         or $parentNodeName eq $XDF_node_name{'colAxis'} or $parentNodeName eq $XDF_node_name{'rowAxis'} 
     ) { 

     $newelement = &_create_new_XMLelement($e, $attrib_hash_ref);
     $self->_lastAxisObj->addXMLElement($newelement);

   } elsif( $parentNodeName eq $XDF_node_name{'field'} ) { 

     $newelement = &_create_new_XMLelement($e, $attrib_hash_ref);
     $self->_lastFieldObj()->addXMLElement($newelement);

   } else {

      my $lastObj = $self->_lastObj; 
      if (defined $lastObj && ref($lastObj) eq 'XDF::XMLElementNode') {

         $newelement = &_create_new_XMLelement($e, $attrib_hash_ref);
         $lastObj->addXMLElement($newelement);

      } else {
         $self->_printWarning("ILLEGAL NODE:[$e] (child of $parentNodeName) encountered. Ignoring.\n") 
            unless $self->{Options}->{quiet}; 
      }

   }

   return $newelement;
}

# create a new XML element from passed attributes
sub _create_new_XMLelement {
  my ($name, $attrib_hash_ref) = @_;

   my $newelement = new XDF::XMLElementNode($name);
#   $newelement->setTagName($name);
   while ( my ($key, $value) = each %{$attrib_hash_ref}) {
#        my $attribObj = new XDF::XMLAttribute($key);
#        $attribObj->setName($key);
#        $attribObj->setValue($value);
        $newelement->setAttribute($key, $value);
   }
   return $newelement;
}

# this is the actual default CDATA handler for the Reader.
# This subroutine WONT be used if the user uses the method
# setCharDataHandler()
sub _default_cdata_handler {
   my ($self, $string) = @_;

   if (!$IGNORE_WHITESPACE_ONLY_DATA || $string !~ m/^\s*$/) {
      my $lastObj = $self->_lastObj();
      if (defined $lastObj) {
         if (ref($lastObj) eq 'XDF::XMLElementNode') {
           $lastObj->appendCData($string);
         } else {
            $self->_printWarning(" cant do anything with CDATA:[$string] for ".ref($lastObj).". Ignoring.\n"); 
         }
      } else {
         my $nodename = $self->_currentNodeName();
         $self->_printWarning(" CDATA encountered for $nodename:[$string]. Ignoring.\n"); 
      }
   }

}

# execute the appropriate start handler
sub _exec_default_Start_Handler {
   my ($self, $element, $attrib_hash_ref) = @_;

   if ( exists $self->{defaultHandler}->{'start'}) {
      $self->{defaultHandler}->{'start'}->($self, $element, $attrib_hash_ref);
   }
   else
   {
      die "ERROR: default start handler NOT defined. Cannot continue parsing\n";
   }
}

# execute the appropriate end handler
sub _exec_default_End_Handler {
   my ($self, $element) = @_;

   if ( exists $self->{defaultHandler}->{'end'}) {
      $self->{defaultHandler}->{'end'}->($self, $element);
   }
   else
   {
      die "ERROR: default end handler NOT defined. Cannot continue parsing\n";
   }
}

# execute the appropriate Cdata handler
sub _exec_default_CData_Handler {
   my ($self, $string) = @_;

   if ( exists $self->{defaultHandler}->{'cdata'}) {
      $self->{defaultHandler}->{'cdata'}->($self, $string);
   }
   else
   {
      die "ERROR: default char data handler NOT defined. Cannot continue parsing\n";
   }
}

# this code copied almost verbatim from the original Java
sub _appendArrayToArray {
   my ($self, $arrayToAppendTo, $arrayToAdd) = @_;

   &debug("appendArrayToArray\n");
   if (defined $arrayToAppendTo)
   {

      my @origAxisList = @{$arrayToAppendTo->getAxisList};
      my @addAxisList = @{$arrayToAdd->getAxisList};
      my %correspondingAddAxis;
      my %correspondingOrigAxis;

      #debug("Getting array alignments \n");

      # 1. determine the proper alignment of the axes between both arrays
      #    Then cross-reference each in lookup Hashtables.
      foreach my $origAxis (@origAxisList)
      {

         #AxisInterface origAxis = (AxisInterface) iter.next();
         my $align = $origAxis->getAlign();

         # search the list of the other array for a matching axis 
         my $gotAMatch = 0;
             #Iterator iter2 = addAxisList.iterator();
         foreach my $addAxis (@addAxisList)
         {

            #AxisInterface addAxis = (AxisInterface) iter2.next();
            my $thisAlign = $addAxis->getAlign();
            if(defined $thisAlign)
            {
               if($thisAlign eq $align)
               {
                   $correspondingAddAxis{$origAxis->getAxisId()} = $addAxis;
                   $correspondingOrigAxis{$addAxis->getAxisId()} = $origAxis;
                   $gotAMatch = 1;
                   last;
                }
             } else {
                $self->_printFatalError("Cant align axes, axis missing defined align attribute. Aborting.\n");
                #return $arrayToAppendTo;
             }
          }

          # no match?? then alignments are mis-specified.
          if (!$gotAMatch) {
              $self->_printFatalError("Cant align axes, axis has align attribute that is mis-specified. Aborting.\n");
              #return $arrayToAppendTo;
          }

      }

      &debug("Appending axisvalues to array axis\n");
      # 2. "Append" axis values to original axis. Because
      # there are 2 different ways to add in data we either
      # have a pre-existing axis value, in which case we dont
      # need to expand the existing axis, or there is no pre-existing
      # value so we tack it in. We need to figure out here if an
      # axis value already exists, and if it doesnt then we add it in. 
      foreach my $origAxis (@origAxisList)
      {

         #   AxisInterface origAxis = (AxisInterface) iter3.next();
         my $addAxis = $correspondingAddAxis{$origAxis->getAxisId};

         if (ref($addAxis) eq 'XDF::Axis' && ref($origAxis) eq 'XDF::Axis')
         {
            my @valuesToAdd = $addAxis->getAxisValues();

            # increase axis size
            #my $size_orig = $origAxis->getSize();
            #my $size_increase = $addAxis->getSize();
            #$origAxis->setSize($size_orig+$size_increase);

            foreach my $value (@valuesToAdd) {
               if (( $origAxis->getIndexFromAxisValue($value)) == -1) 
               {
                  my $valueObj = new XDF::Value($value);
                  $origAxis->addAxisValue($valueObj);
               }
            }

         } elsif (ref($addAxis) eq 'XDF::FieldAxis' && ref($origAxis) eq 'XDF::FieldAxis') {

            # both are fieldAxis
            die "Dont know how to merge field Axis data. Aborting array appendTo operation.";

         } else {
            # mixed class Axes?!? (e.g. a fieldAxis id matches Axis id??!? Error!!)
            die "Dont know how to merge this data. Aborting array appendTo operation.";
         }

      }

      # 3. Append data from one array to the other appropriately 
      my $origLocator = $arrayToAppendTo->createLocator();
      my $addLocator = $arrayToAdd->createLocator();

      while ($addLocator->hasNext())
      {

         #try {

         #retrieve the data
         my $data = $arrayToAdd->getData($addLocator);

         # set up the origLocator
         my @locatorAxisList = @{$addLocator->getIterationOrder()};
         #Iterator iter5 = locatorAxisList.iterator();
         debug("Appending data to array ");
         foreach my $addAxis (@locatorAxisList) {

            my $thisAxisValue = $addLocator->getAxisValue($addAxis);
            my $thisAxis = $correspondingOrigAxis{$addAxis->getAxisId()};

            $origLocator->setAxisIndexByAxisValue($thisAxis, $thisAxisValue);
            debug($origLocator->getAxisIndex($thisAxis).",");

         }

         # add in the data as appropriate.
         debug(") => [$data]\n");

         $arrayToAppendTo->setData($origLocator, $data);

         $addLocator->next(); # go to next location
      }

   } else {
      $self->_printWarning("Cannot append to null array. Ignoring request.");
   }

  # return $arrayToAppendTo;
}


# /** ADDITIONAL SECTION Reader Options
# The following options are currently supported:
#@   
#@ 
#@ 'validate'   => Set the reader to use a validating parser (XML::Parser::Checker). 
#@                 Defaults to 0 ('no'). 
#@   
#@ 'msgThresh'  => Set the reader parser message threshold. Messages BELOW this 
#@                 number will be displayed. Has no effect unless XML::Parser::Checker
#@                 is the parser. Defaults to 200. 
#@   
#@ 'noExpand'   => Don't expand entities in output if true. Default is false. 
#@
#@ 'ExpandParamEnt' => Expand parameter entities in output if true. Default is true. 
#@
#@ 'nameSpaces' => When this option is given with a true value, then the parser does namespace
#@                 processing. By default, namespace processing is turned off.
#@
#@ 'parseParamEnt' => Unless standalone is set to "yes" in the XML declaration, setting this to
#@                    a true value allows the external DTD to be read, and parameter entities
#@                    to be parsed and expanded. The default is false. 
#@
#@ 'cacheDataOnDisk' => When this option is given with a true value, then the parser will
#@                      create Arrays which store their data in a disk file rather than in 
#@                      memory. This allows users to load large arrays into XDF objects. By
#@                      default this option is 'false'.
#@
#@ 'loadDataOnDemand' => When this option is given with a true value, then the parser will
#@                       delay loading data into each Array. Actual loading will only occur
#@                       when a 'getData' or 'getRecords' method call to the array is name.
#@                       The option defaults to 'true' and speeds up accessing metadata in large
#@                       arrays.
#@
#@ 'quiet'      => Set the reader to run quietly. Defaults to 1 ('yes'). 
#@ 
#@ 'axisSize'   => Set the number of indices to allocate along each dimension. This
#@                 can speed up large file reads. Defaults to $XDF::BaseObject::DefaultDataArraySize. 
#@ 
#@ 'maxWarning" => Change the maximum allowed number of warnings before the XDF::Reader
#@                 will halt its parse of the input file/fileHandle. 
#@ 
# */

1;


__END__

=head1 NAME

XDF::Reader - Perl Class for Reader

=head1 SYNOPSIS


    my $DEBUG = 1;

    # test file for reading in XDF files.

    my $file = $ARGV[0];
    my %options = ( 'quiet' => $DEBUG, 
                    'validate' => 0, 
                    'loadDataOnDemand' => 1
                    'cacheDataOnDisk' => 1
                   );

    my $XDFReader = new XDF::Reader(\%options);
    my $XDFObject = $XDFReader->parseFile($file);



...

=head1 DESCRIPTION

 This class allows the user to create XDF objects from XDF files.  XDF::Reader will read in both Binary and ASCII data and tagged/delimited/ and formatted XDF data styles are supported. 



=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::Reader.

=over 4

=item getVersion (EMPTY)

returns the version of the XDF DTD supported by this parser.  

=item new ($optionsHashRef)

Create a new reader object. Returns the reader object if successfull. It takes an optional argument of an option HASH Reference  to initialize the object options.   

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::Reader.

=over 4

=item getReaderXDFObject (EMPTY)

returns the XDF object that the reader parses into.  

=item setReaderXDFObject ($XDF)

Sets the XDF object that the reader parses into.  

=item setForceSetXMLHeaderStuffOnXDFObject ($value)

 

=item parseFile ($file, $optionsHashRef)

Reads in the given file and returns a full XDF Perl object (an L<XDF::Structure>with at least one L<XDF::Array>). A second HASH argument may be supplied to specify runtime options for the XDF::Reader.  

=item parseFileHandle ($handle, $optionsHashRef)

Similar to parseFile but takes an open filehandle as an argument (so you can parse ANY open fileHandle, e.g. files, sockets, etc. Whatever Perl supports.).  

=item parseString ($string, $optionsHashRef)

Reads in the given string and returns a full XDF Perl object (an L<XDF::Structure>with at least one L<XDF::Array>). A second HASH argument may be supplied to specify runtime options for the XDF::Reader.  

=item addStartElementHandlers (%newHandlers)

Add new handlers to the internal XDF::Parser start element handler. The form of  the entries in the passed hash should be 'nodename' => sub { &handler_for_nodename(@_); }; If a 'nodename' for a handler already exists in the XDF start handler table,  this method will override it with the new handler. Returns 1 on success, 0 on failure.  

=item addEndElementHandlers (%newHandlers)

Add new handlers to the internal XDF::Parser end element handler. The form of  the entries in the passed hash should be 'nodename' => sub { &handler_for_nodename(@_); }; If a 'nodename' for a handler already exists in the XDF end handler table,  this method will override it with the new handler. Returns 1 on success, 0 on failure.  

=item addCharDataHandlers (%newHandlers)

Add new handlers to the internal XDF::Parser CDATA element handler. The form of  the entries in the passed hash should be 'nodename' => sub { &handler_for_nodename(@_); }; If a 'nodename' for a handler already exists in the XDF CDATA handler table,  this method will override it with the new handler. returns 1 on success, 0 on failure.  

=item setDefaultStartElementHandler ($codeRef)

This sets the subroutine which will handle all nodes which DONT match  an entry within the start element handler table.  

=item setDefaultEndElementHandler ($codeRef)

This sets the subroutine which will handle all nodes which DONT match  an entry within the end element handler table.  

=item setDefaultCharDataHandler ($codeRef)

This sets the subroutine which will handle all nodes which DONT match  an entry within the CDATA handler table.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4

=back

=back

=head1 Reader Options 



=over 4

 The following options are currently supported:    
  
  'validate'   => Set the reader to use a validating parser (XML::Parser::Checker). 
                  Defaults to 0 ('no'). 
    
  'msgThresh'  => Set the reader parser message threshold. Messages BELOW this 
                  number will be displayed. Has no effect unless XML::Parser::Checker
                  is the parser. Defaults to 200. 
    
  'noExpand'   => Don't expand entities in output if true. Default is false. 
 
  'ExpandParamEnt' => Expand parameter entities in output if true. Default is true. 
 
  'nameSpaces' => When this option is given with a true value, then the parser does namespace
                  processing. By default, namespace processing is turned off.
 
  'parseParamEnt' => Unless standalone is set to "yes" in the XML declaration, setting this to
                     a true value allows the external DTD to be read, and parameter entities
                     to be parsed and expanded. The default is false. 
 
  'cacheDataOnDisk' => When this option is given with a true value, then the parser will
                       create Arrays which store their data in a disk file rather than in 
                       memory. This allows users to load large arrays into XDF objects. By
                       default this option is 'false'.
 
  'loadDataOnDemand' => When this option is given with a true value, then the parser will
                        delay loading data into each Array. Actual loading will only occur
                        when a 'getData' or 'getRecords' method call to the array is name.
                        The option defaults to 'true' and speeds up accessing metadata in large
                        arrays.
 
  'quiet'      => Set the reader to run quietly. Defaults to 1 ('yes'). 
  
  'axisSize'   => Set the number of indices to allocate along each dimension. This
                  can speed up large file reads. Defaults to $XDF::BaseObject::DefaultDataArraySize. 
  
  'maxWarning" => Change the maximum allowed number of warnings before the XDF::Reader
                  will halt its parse of the input file/fileHandle. 
  


=back

=head1 SEE ALSO



=over 4

L<XDF::Add>, L<XDF::Array>, L<XDF::ArrayRefDataFormat>, L<XDF::BinaryFloatDataFormat>, L<XDF::BinaryIntegerDataFormat>, L<XDF::ColAxis>, L<XDF::Conversion>, L<XDF::Constants>, L<XDF::DelimitedXMLDataIOStyle>, L<XDF::Delimiter>, L<XDF::DocumentType>, L<XDF::Entity>, L<XDF::Exponent>, L<XDF::ExponentOn>, L<XDF::Field>, L<XDF::FloatDataFormat>, L<XDF::FormattedXMLDataIOStyle>, L<XDF::TaggedXMLDataIOStyle>, L<XDF::LogarithmBase>, L<XDF::Log>, L<XDF::Multiply>, L<XDF::NaturalLogarithm>, L<XDF::NewLine>, L<XDF::NotationNode>, L<XDF::IntegerDataFormat>, L<XDF::Parameter>, L<XDF::Polynomial>, L<XDF::Reader::ValueList>, L<XDF::RecordTerminator>, L<XDF::Relation>, L<XDF::RepeatFormattedIOCmd>, L<XDF::ReadCellFormattedIOCmd>, L<XDF::RowAxis>, L<XDF::SkipCharFormattedIOCmd>, L<XDF::StringDataFormat>, L<XDF::Structure>, L<XDF::ValueListAlgorithm>, L<XDF::ValueListDelimitedList>, L<XDF::XMLDataIOStyle>, L<XDF::XMLElementNode>, L<XDF::XMLDeclaration>, L<XDF::XDF>

=back

=head1 AUTHOR

    Brian Thomas  (brian.thomas@gsfc.nasa.gov)
    XML Group <http://xml.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut
