
# $Id$

package XDF::DataCube;

# /** COPYRIGHT
#    DataCube.pm Copyright (C) 2000 Brian Thomas,
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
# Holds the data for a given L<XDF::Array>. It is designed to flexibly expand as data 
# is added/appended onto it. It doesnt treat swaping of large array data out to file currently.
# */

# /** SYNOPSIS
#    my $dataObj = XDF::DataCube->new();
# */

# /** SEE ALSO
# XDF::Array
# */

use Carp;
use XDF::Utility;
use XDF::BaseObject;

# fields pragma requires Perl 5.005 support. what does this do exactly?? 
# It does the following:
# 1- Informats Perl compiler that these are only valid fields
#    in the class
# 2- Creates a package hash named %FIELDS with an entry for each named field.
#
# 3- Causes the Perl compiler to trnslate any pseudo-hash accesses into
#    direct array accesses. 
# Upshot: faster class 
# use fields @Class_Attributes;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

# CLASS DATA
my $Class_XML_Node_Name = "data";
my @Local_Class_XML_Attributes = qw (
                             href
                             encoding
                             checksum
                             compression
                             startByte
                             endByte
                          );
                             #_currentLocator
my @Local_Class_Attributes = qw (
                             dimension
                             _parentArray
                             _data
                             _axisLookupIndexArray
                          );

my $DEFAULT_START_BYTE = 0;

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


# /** dimension
# The number of dimensions within this dataCube.
# */
# /** href
# Reference to a separate resource (file, URL, etc) holding the actual data.
# */
# /** checksum
# The MD5 checksum of the data.
# */
# /** compression
# The STRING value which stores the type of compression algoritm used
# to compress the data.
# */

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# CLASS stuff..

# /** classXMLNodeName
# This method takes no arguments may not be changed. This method returns the class node name of XDF::DataCube.
# */
sub classXMLNodeName { 
  $Class_XML_Node_Name; 
}

# /** getClassAttributes
#  This method returns a list reference containing the names
#  of the class attributes of XDF::DataCube; 
#  This method takes no arguments may not be changed. 
# */
sub getClassAttributes { 
  \@Class_Attributes; 
}

# /** getClassXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
sub getClassXMLAttributes {
  return \@Class_XML_Attributes;
}

#
# Set/Get Methods 
#

# /** getChecksum
# */
sub getChecksum {
   my ($self) = @_;
   return $self->{checksum};
}

# /** setChecksum
#     Set the checksum attribute. 
# */
sub setChecksum {
   my ($self, $value) = @_;
   $self->{checksum} = $value;
}

# /** getEndByte
# */
sub getEndByte {
   my ($self) = @_;
   return $self->{endByte};
}

# /** setEndByte
#     Set the endByte attribute. 
# */
sub setEndByte {
   my ($self, $endByte) = @_;
   $self->{endByte} = $endByte;
}

# /** getHref
# */
sub getHref {
   my ($self) = @_;
   return $self->{href};
}

# /** setHref
#     Set the href attribute. 
# */
sub setHref {
   my ($self, $hrefObjectRef) = @_;
   if (!defined $hrefObjectRef || ref($hrefObjectRef) eq 'XDF::Entity') {
     $self->{href} = $hrefObjectRef;
   } else {
     warn "Cant set $hrefObjectRef as value in setHref. Ignoring\n";
   } 
}

# /** getCompression
# */
sub getCompression {
   my ($self) = @_;
   return $self->{compression};
}

# /** setCompression 
#     Set the compression attribute. 
# */
sub setCompression {
   my ($self, $value) = @_;

   carp "Cant set compression to $value, not allowed \n"
      unless (&XDF::Utility::isValidDataCompression($value));

   $self->{compression} = $value;
}

# /** getEncoding
# */
sub getEncoding {
   my ($self) = @_;
   return $self->{encoding};
}

# /** setEncoding
#     Set the encoding attribute. 
# */
sub setEncoding {
   my ($self, $value) = @_;

   carp "Cant set encoding to $value, not allowed \n"
      unless (&XDF::Utility::isValidDataEncoding($value));

   $self->{encoding} = $value;
}

# /** getDimension
# */
sub getDimension {
   my ($self) = @_;
   return $self->{dimension};
}

# /** getStartByte
# */
sub getStartByte {
   my ($self) = @_;
   return $self->{startByte};
}

# /** setStartByte
#     Set the startByte attribute. 
# */
sub setStartByte {
   my ($self, $startByte) = @_;
   $self->{startByte} = $startByte;
}

#
# Other Public methods 
#

# We overwrite the toXMLFileHandle method supplied by L<XDF::BaseObject> to 
# have some special handling for the XDF::DataCube. The interface for this
# method remains the same however. 
#
# we dont want to write back out all the attributes, the data
# needs special handling to write out, etc...
#
# This is PRIVATE, just too lazy to move down to right section.. -b.t.
sub _basicXMLWriter {
  my ($self, $fileHandle, $indent, $newNodeNameString, $noChildObjectNodeName ) = @_;

  my $writeHrefAttribute = 0;
  my $spec = XDF::Specification->getInstance();
  my $niceOutput = $spec->isPrettyXDFOutput;

  $indent = "" unless defined $indent;
  my $nodeName = $self->classXMLNodeName;
  $nodeName = $newNodeNameString if defined $newNodeNameString;

  # open the tagged data section
  print $fileHandle $indent if $niceOutput;
  print $fileHandle "<" . $nodeName ;

  # these have to be broken up, as _fileHandleToString doesn't like
  # compound lines with '"' in them
  if (defined $self->{checksum}) {
     print $fileHandle " checksum=\"";
     print $fileHandle $self->{checksum};
     print $fileHandle "\"";
  }
  if (defined $self->{compression}) {
     print $fileHandle " compression=\"";
     print $fileHandle $self->{compression};
     print $fileHandle "\"";
  }
  if (defined $self->{encoding}) {
     print $fileHandle " encoding=\"";
     print $fileHandle $self->{encoding};
     print $fileHandle "\"";
  }
  my $hrefObj = $self->getHref();
  if (defined $hrefObj) {
     print $fileHandle " href=\"";
     print $fileHandle $hrefObj->getName();
     print $fileHandle "\"";
  }

  print $fileHandle ">";

  # write the data
  $self->writeDataToFileHandle($fileHandle, $indent, $self->{compression} );

  # close the tagged data section
  print $fileHandle "</" . $nodeName . ">";

}

# /** writeDataToFileHandle
# Writes out just the data to the proscribed filehandle.
# */
sub writeDataToFileHandle {
  my ($self, $fileHandle, $indent, $compression_type) = @_;

  my $dontPrintCDATATag = 0;
  my $spec = XDF::Specification->getInstance();
  my $niceOutput = $spec->isPrettyXDFOutput;
  $indent = "" unless defined $indent;

  # a couple of shortcuts
  my $parentArray = $self->{_parentArray};
  my $href = $self->getHref();

  my $readObj = $parentArray->getXMLDataIOStyle();

  croak "DataCube can't write out. No format reference object defined.\n"
     unless defined $readObj;

  my $dataFileHandle;
  my $dataFileName;

  # check for href -- writing to an external file 
  if ( defined $href ) {

      # BIG assumption: href is a file we want to read/write
      # Better Handling in future is needed
      if (defined $href->getSystemId()) {
        my $href_program;
        $href_program .= &_dataCompressionProgram($compression_type);
        $dataFileName = $href->getBase() if defined $href->getBase();
        $dataFileName .= $href->getSystemId();
        $href_program .= ">$dataFileName";

        open(DFH, $href_program); # we will write data to another file 
                                 # as specified by the entity
        $dataFileHandle = \*DFH;
        $dontPrintCDATATag = 1;
      } else {
        croak "XDF::DataCube Href lacks SysId attribute, cannot write out data.\n";
      }   

  } else {
    $dataFileHandle = $fileHandle; # writing to metadata (XML) file 

    # some warning message
    carp "XDF::DataCube can only compress data held in an external file (HREF). Ignoring\n"
       unless (!defined $compression_type);
  } 

  croak "XDF::DataCube has no valid data filehandle" unless defined $dataFileHandle;

  #my $fastestAxis = $parentArray->getAxisList()->[0];

  # fastest axis is the first in the array, always 
  #my $fastestAxis = $readObj->getWriteAxisOrderList()->[0];

  # stores the NoDataValues for the parentArray,
  # used in writing out when NoDataException is caught
  my @NoDataValues;

  if (defined $parentArray->getFieldAxis()) {
     my @dataFormatList = $parentArray->getDataFormatList();
     for (my $i = 0; $i <= $#NoDataValues; $i++) {
        my $d =  $dataFormatList[$i];
        if (defined $d && defined $d->getNoDataValue())
        {
           $NoDataValues[$i] = $d->getNoDataValue();
        }
     }
  }
  else 
  {
     # If there is no fieldAxis, then no fields,
     # and hence, only ONE noDataValue.
     $NoDataValues[0] = $parentArray->getNoDataValue();
  }

  # write the data
  #
  if (ref($readObj) eq 'XDF::TaggedXMLDataIOStyle' ) {

     print $dataFileHandle "\n" if $niceOutput;
     &_write_tagged_data($self, $dataFileHandle, $readObj, $indent, $niceOutput, $spec);
     print $dataFileHandle "$indent" if $niceOutput;

  } else {

     print $dataFileHandle "<![CDATA[" unless $dontPrintCDATATag;

     if (ref($readObj) eq 'XDF::DelimitedXMLDataIOStyle')
     {
        my $fastestAxis = $readObj->getWriteAxisOrderList()->[0];
        &_write_untagged_data($self, $dataFileHandle, $readObj, $indent, $niceOutput, $fastestAxis);
     } 
      elsif (ref($readObj) eq 'XDF::FormattedXMLDataIOStyle' )
     {
        my $iterationOrderRef = $readObj->getWriteAxisOrderList();
        $self->_writeFormattedData($dataFileHandle, $parentArray, $readObj, $iterationOrderRef, \@NoDataValues );

     } 
     else 
     {
        carp "Unknown read object: $readObj. $self cannot write itself out.\n";
     }

     unless ($dontPrintCDATATag) {
        print $dataFileHandle "]]>";
        print $dataFileHandle "\n$indent" if $niceOutput;
     }

  }

  if ( $dataFileName ) { close DFH; }

}

# /** addData
# This routine will append data to a cell unless directed to do otherwise.
# RETURNS: 1 on success, 0 on failure.
# */
sub addData {
  my ($self, $locator, $data, $no_append ) = @_;

  return 0 unless defined $locator;

  if ($no_append) {
     $self->setData($locator, $data);
     return 1;
  } else {
     my $old = $self->getData($locator);
     $old = "" unless defined $old;
     $self->setData($locator, $old . $data);
     return 1;
  }

}

# /** removeData
# Data held within the requested datacell is removed. The value of the datacell is set to undef.
# B<NOT CURRENTLY IMPLEMENTED>.
# */
sub removeData {
  carp "Remove_data not currently implemented.\n";
} 
  
#/** setData
# Set the value of the requested datacell. 
# Overwrites existing datacell value if already populated with a value.
# */
sub setData {
   my ($self, $locator, $datum ) = @_;

   # safety check
   $self->_updateInternalLookupIndices() if ($#{$self->{_data}} == -1);

   # data are stored in a huge 2D array. The long array axis
   # mirrors all dimensions but the 2nd axis. The 2nd axis gives
   # the index on the 'short' internal array.
   my $longIndex = $self->_getLongArrayIndex($locator);
#   my $shortIndex = $self->_getShortArrayIndex($locator);

   # Bounds checking
#   &checkDataArrayBounds($longIndex, $shortIndex);

   # Set the Data
#   byte realValue = 1;
   # indicate its corresponding datacell holds valid data
#   java.lang.reflect.Array.setByte(longDataArray.get(longIndex), shortIndex, realValue);

#print STDERR "setData($datum) @($longIndex)\n";

   # put data into the requested datacell
   $self->{_data}->[$longIndex] = $datum;

}

# This whole routine should probably be in the locator.
# and update ONLY when the current location is changed.
# Note that because of complications in storing values from fieldAxis
# which is always the at the 0 index position (if it exists)
# we can't simply treat index0 as the short axis. Instead, we
# have to use the axis at index1 (if it exists).
sub _getLongArrayIndex {
   my ($self, $locator) = @_;

   my $longIndex = 0;

   my @axisList = @{$self->{_parentArray}->getAxisList()};
   my $numOfAxes = ($#axisList+1); # should be internal variable updated on add/removeAxis in Array 

   if ($numOfAxes > 0) {
      my $axis = $axisList[0];
      $longIndex = $locator->getAxisIndex($axis);

      my $array_ref = $self->{_axisLookupIndexArray};
      my @mult = @{$array_ref};
      for (my $i = 1; $i < $numOfAxes; $i++) {
         $axis = $axisList[$i];
         $longIndex += $locator->getAxisIndex($axis) * $mult[$i];
      }
   }

   return $longIndex;

}

# Should be hardwired w/ private variable. Only
# updates when addAxis is called by parentArray.
sub _getShortArrayIndex {
   my ($self, $locator) = @_; 

   my $shortIndex = 0;

   my $shortaxis = $self->_getShortAxis();
   if (defined $shortaxis ) {
        $shortIndex = $locator->getAxisIndex($shortaxis);
   }

   return $shortIndex;
}

# get the axis that represents the short axis
# short axis is axis "1" (not "0"; causes complications when
# we have a fieldAxis, which is at 0).
sub _getShortAxis {
   my ($self) = @_;

   my $shortAxis;

   my @axisList = @{$self->{_parentArray}->getAxisList()};
   if ($#axisList > 0) {
        $shortAxis = $axisList[1];
   }

   return $shortAxis;
}

# /** getData
#   We return whatever is stored in the datacell.
# */
sub getData {
   my ($self, $locator) = @_;

   my $longIndex = $self->_getLongArrayIndex($locator);
#   my $shortIndex = $self->_getShortArrayIndex($locator);

   my $value = $self->{_data}->[$longIndex];

#print STDERR "getData($value) [$longIndex]\n";

   return $value;

}



# /** getData_old 
# Retrieve the SCALAR value of the requested datacell.
# */
# do we need to do some bounds checking here??
sub getData_old {
  my ($self, $locator) = @_;

  unless (defined $locator and ref($locator) eq 'XDF::Locator') {
    warn "getData method not passed a valid XDF::Locator object, ignoring request\n";
    return;
  }

  my $get_string = "\$self->{_data}";
  foreach my $axisObj (@{$self->{_parentArray}->getAxisList()}) {
     my $loc = $locator->getAxisIndex($axisObj);
     $get_string = $get_string . "->[$loc]";
  }

  my $result = eval "$get_string";
#print STDERR "getData evalstring: [$get_string]\n";
  return $result;

}

#
# Private/Protected(?) Methods 
#

# This is called when we cant find any defined method
# exists already. Used to handle general purpose set/get
# methods for our attributes (object fields).
sub AUTOLOAD {
  my ($self,$val) = @_;
  #&XDF::BaseObject::AUTOLOAD($self, $val, $AUTOLOAD, \%{$XDF::DataCube::FIELDS} );
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}

# only perl needs this. Need as private method?
# Certainly this implementation is bad, very bad. 
# At the minimum we need to put this info in constants
# class and make it user configurable at make time.
sub _dataCompressionProgram {
  my ($compression_type) = @_;

  return "" unless defined $compression_type;

  my $compression_program = "| ";
  if ($compression_type eq &XDF::Constants::DATA_COMPRESSION_GZIP() ) {
     $compression_program .= &XDF::Constants::DATA_COMPRESSION_GZIP_PATH();
     $compression_program .= ' -c ';
  } elsif ($compression_type eq &XDF::Constants::DATA_COMPRESSION_BZIP2() ) {
     $compression_program .= &XDF::Constants::DATA_COMPRESSION_BZIP2_PATH();
     $compression_program .= ' -c ';
  } elsif ($compression_type eq &XDF::Constants::DATA_COMPRESSION_COMPRESS() ) {
     $compression_program .= &XDF::Constants::DATA_COMPRESSION_COMPRESS_PATH();
     $compression_program .= ' -c ';
  } elsif ($compression_type eq &XDF::Constants::DATA_COMPRESSION_ZIP() ) {
     $compression_program .= &XDF::Constants::DATA_COMPRESSION_ZIP_PATH();
     $compression_program .= ' -pq ';
  } else {
     croak "Data compression for type: $compression_type NOT Implemented. Aborting write.\n";
  }

  return $compression_program;
}


sub _init {
  my ($self) = @_;

  $self->SUPER::_init();

  # declare the _data attribute as an array 
  # as we add data (below) it may grow in
  # dimensionality, but defaults to 0 at start. 
  $self->{dimension} = 0;
  $self->{_data} = [];
  $self->{startByte} = $DEFAULT_START_BYTE;
  $self->{_axisLookupIndexArray} = [];

  # set the minimum array size (essentially the size of the axis)
  my $spec= XDF::Specification->getInstance();
  $#{$self->{_data}} = $spec->getDefaultDataArraySize();

  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

}

sub _updateInternalLookupIndices {
   my ($self) = @_;

#print STDERR "updateInternal Lookup table\n";

   $self->{_axisLookupIndexArray} = [];
   push @{$self->{_axisLookupIndexArray}}, 0; # first axis is always 0
   my @axisList = @{$self->{_parentArray}->getAxisList()};
   my $mult = 1;
   foreach my $axisNum (1 .. $#axisList) {
      $mult *= $axisList[$axisNum-1]->getLength();
      push @{$self->{_axisLookupIndexArray}}, $mult;
   }

}


# Yes, this is crappy. I plan to come back and do it 'right' one day.
#
# Note: we need to consider the case where the user *DIDNT* supply 
# tag names for the axes. In this case, we use 'd0','d1' ...'d8' tag 
# notation.
sub _write_tagged_data {
  my ($self, $fileHandle, $readObj, $indent, $niceOutput, $spec) = @_;

  # now we populate the data , if there are any dimensions 
  if ($self->{dimension} > 0) {

#    my @axisList = @{$self->{_parentArray}->getAxisList()};
    my @axisList = @{$readObj->getWriteAxisOrderList()};

    # gather info. Find out what tags go w/ which axii
    my @AXIS_TAG = reverse $readObj->getAxisTags(); 

    # now build the formatting stuff. 
    my $data_indent = $indent . $spec->getPrettyXDFOutputIndentation;
    my $startDataRecordTag = $data_indent;
    my $endDataRecordTag = "";
    foreach my $axis (0 .. ($#axisList-1)) {
      $startDataRecordTag .= "<" . $AXIS_TAG[$axis] . ">";
    }
    foreach my $axis (reverse 0 .. ($#axisList-1)) {
      $endDataRecordTag .= "</" . $AXIS_TAG[$axis] . ">";
    }
    $endDataRecordTag .= "\n";
    my $startDataTag = "<" . $AXIS_TAG[$#axisList] . ">";
    my $endDataTag = "</" . $AXIS_TAG[$#axisList] . ">";
    my $emptyDataTag = "<" . $AXIS_TAG[$#axisList] . "/>";
 
    # ok, time to build the eval block that will write out the tagged data
    my $eval_block;
    my $locator = $self->{_parentArray}->createLocator;

    my $more_data = 1;
    my $fast_axis_length = @{$self->{_parentArray}->getAxisList()}->[0]->getLength(); 
    my $dataNumb = 0; 
    while ($more_data) {
       print $fileHandle $startDataRecordTag if ($dataNumb == 0);
       $self->_print_data($fileHandle, $locator, $startDataTag, $endDataTag, $emptyDataTag);
       $dataNumb++;
       if( $dataNumb >= $fast_axis_length ) {
         print $fileHandle $endDataRecordTag;
         $dataNumb = 0;
       }
       $more_data = $locator->next();
    }
  }

}

sub _write_untagged_data {
  my ($self, $fileHandle, $formatObj, $indent, $fastestAxis) = @_;

  # now we populate the data, if there are any dimensions 
  if ($self->{dimension} > 0) {

    my $sprintfFormat;
    my $terminator;
    my $fast_axis_length;
    my $template;
    my @outArray;

    if (ref($formatObj) eq 'XDF::DelimitedXMLDataIOStyle') {
      # tis a shame that we dont use the outArray/template system here.
      $sprintfFormat = $formatObj->_sprintfNotation();
      $terminator = $formatObj->getRecordTerminator()->getStringValue();
      $fast_axis_length = @{$self->{_parentArray}->getAxisList()}->[0]->getLength(); 
    } elsif (ref($formatObj) eq 'XDF::FormattedXMLDataIOStyle') {
      $template = $formatObj->_templateNotation(0);
      @outArray = $formatObj->_outputSkipCharArray;
    } else {
      die "$self got weird formatobj for untagged output of DataCube: $formatObj\n";
    }

    my $locator = $self->{_parentArray}->createLocator(); 
    $locator->setIterationOrder($formatObj->getWriteAxisOrderList());

    if (ref($formatObj) eq 'XDF::DelimitedXMLDataIOStyle') { 

      my $there_is_more_data = 1;
      my $dataNumb = 0;

      while ($there_is_more_data) {
        my $this_data = $self->getData($locator);
        $this_data = "" unless defined $this_data; # bad, we should use noData value here (or throw error).
        $dataNumb++;
        if( $dataNumb >= $fast_axis_length ) {
          print $fileHandle $this_data . $terminator;
          $dataNumb = 0;
        } else {
          print $fileHandle sprintf($sprintfFormat, $this_data);
        } 
        $there_is_more_data = $locator->next();
      }

    } elsif (ref($formatObj) eq 'XDF::FormattedXMLDataIOStyle') { 

      my @outData = ();
      my $outArrayNumb = 0;
      my $there_is_more_data = 1;

      while ($there_is_more_data) {
        push @outData, $self->getData($locator) if !defined $outArray[$outArrayNumb];
        $outArrayNumb++;
        while (defined $outArray[$outArrayNumb]) { 
          push @outData, $outArray[$outArrayNumb++];
        }
        if( $outArrayNumb >= $#outArray ) {
          print $fileHandle pack($template, @outData);
          $outArrayNumb = 0;
          @outData = ();
        }
        $there_is_more_data = $locator->next();
      }

    } else {

      die "$self got wierd XMLDataIOStyle object : $formatObj\n";

    }

  }

}

sub _writeFormattedData {
   my ($self, $fileHandle, $parentArray, $readObj, 
       $iterationOrderRef, $noDataValRef ) = @_;
 
   my $fastAxisObj = @{$iterationOrderRef}[0]; # first axis is the fast one

   my $locator = $parentArray->createLocator();
   $locator->setIterationOrder($iterationOrderRef);

   my @noDataValues = @{$noDataValRef};
   my $nrofNoDataValues = $#noDataValues;

   # print out the data as appropriate for the format
   my @commands = $readObj->getCommands(); # returns expanded list (no repeat cmds) 

   my $endian = $readObj->getEndian();
   my $nrofCommands = $#commands;
   my $currentCommand = 0;

   # init important dataFormat information into arrays, this 
   # will help speed up long writes.
   my @dataFormat = $parentArray->getDataFormatList();
   my $nrofDataFormats = $#dataFormat;
   my $currentDataFormat = 0;
   my @pattern;
#   my @intFlag;
   my @numOfBytes;

   for (my $i = 0; $i <= $nrofDataFormats; $i++) {
      $pattern[$i] = $dataFormat[$i]->_outputTemplateNotation();

      $numOfBytes[$i] = $dataFormat[$i]->numOfBytes();
#      if (ref($dataFormat[$i]) eq 'XDF::IntegerDataFormat')
#      {
#         $intFlag[$i] = $dataFormat[$i]->getType();
#      } else { 
#         $intFlag[$i] = undef;
#      }
   }

   # loop thru all of the dataCube until finished with all data and commands 
   my $atEndOfDataCube = 0;
   my $backToStartOfDataCube = 0;
   while (!$backToStartOfDataCube)
   {

      my $command = $commands[$currentCommand];

      if($atEndOfDataCube && $locator->getAxisIndex($fastAxisObj) == 0)
      {
          $backToStartOfDataCube = 1;
      }

      if (ref($command) eq 'XDF::ReadCellFormattedIOCmd')
      {

          if ($backToStartOfDataCube) { last; } # dont bother, we'd be re-printing data 

          my $datum = $self->getData($locator);
          if (defined $datum) {
              &_doReadCellFormattedIOCmdOutput( $fileHandle,
                                           $dataFormat[$currentDataFormat],
                                           $numOfBytes[$currentDataFormat],
                                           $pattern[$currentDataFormat],
                                           $endian,
                                           $noDataValues[$currentDataFormat],
                                           $datum);
                                           #$intFlag[$currentDataFormat],

          } else {

              # no data here, hurm. Print the noDataValue. 
              # sloppy algorithm as a result of clean up after Kelly 
              my $noData;

              if ($nrofNoDataValues > 1)
              {
                 $noData = $noDataValues[$locator->getAxisIndex($fastAxisObj)];
              } else {
                 $noData = $noDataValues[0];
              }

              if (defined $noData) {
                 print $fileHandle $noData;
              } else {
                 warn "Can't print out null data: noDataValue NOT defined.\n";
              }

          }

          # advance the data location 
          $locator->next();

          # advance the DataFormat to be used  
          if ($nrofDataFormats > 0)
          {
             $currentDataFormat++;
             if ( $currentDataFormat > $nrofDataFormats)
             {
                      $currentDataFormat = 0;
             }
          }

       }
       elsif (ref($command) eq 'XDF::SkipCharFormattedIOCmd')
       {

          &_doSkipCharFormattedIOCmdOutput ( $fileHandle, $command);

       }
       else
       {
          if (defined $command) {
             carp("DataCube cannot write out, unimplemented format command:$command\n");
          } else {
             carp("DataCube cannot write out, format command not defined (weird)!\n");
          }
       }

       if($nrofCommands > 0)
       {
          $currentCommand++;
          if ( $currentCommand > $nrofCommands) {
              $currentCommand = 0;
          }
       }

       if(!$atEndOfDataCube && !$locator->hasNext()) { $atEndOfDataCube = 1; } 


   } # end of while loop 

}

sub _doSkipCharFormattedIOCmdOutput 
{
   my ($fileHandle, $skipCharCommand) = @_;
   print $fileHandle $skipCharCommand->getOutput()->getValue();
}

sub _doReadCellFormattedIOCmdOutput {
   my ($fileHandle, $thisDataFormat, $formatsize, $template, 
       $endian, $noDataValue, $datum) = @_;
       #$endian, $intFlagType, $noDataValue, $datum) = @_;

   my $output;
#   my $template = $thisDataFormat->_templateNotation(0);

   if (ref($thisDataFormat) eq 'XDF::StringDataFormat'
      )
   {
      $output = pack $template, $datum;
   }
   elsif (ref($thisDataFormat) eq 'XDF::FloatDataFormat') 
   {

      # we have our own print formatting routine here as 
      # printf leads to some uncomfortable conversions of numbers
      # (e.g. "-.9" becomes "-0.9" which is 1 char bigger than the
      #  declared width).
      #$output = sprintf $template, $datum;
      #$output = pack $template, $datum;

      # pad with leading spaces
      my $padsize = $formatsize - length($datum);
      if ($padsize > 0) {
          $output = " " x $padsize . $datum;
      } elsif ($padsize < 0) {
          warn "Error: cant write data:[$datum], actual length is larger than declared size ($formatsize) ";
          if (defined $noDataValue) {
             warn "printing with noDataValue:[$noDataValue]\n";
             $output = $noDataValue; # just print no datavalue
          } else { 
             warn "printing as blanks.\n";
             $output = " " x $formatsize; # just print as blanks
          }
      }  else {
         $output = $datum; # exactly right size 
      }
#      while ($actualsize < $formatsize)
#      {
#         print $fileHandle " ";
#         $actualsize++;
#      }

   }
   elsif (ref($thisDataFormat) eq 'XDF::IntegerDataFormat') 
   {
      # $output = pack $template, $datum;
      $output = sprintf $template, $datum;
#      if (defined $intFlagType) {
#         if ($intFlagType eq XDF::Constants::INTEGER_TYPE_OCTAL) {
#            warn "Cant write OCTAL integers yet, aborting cell write";
#            return;
#         } elsif ($intFlagType eq XDF::Constants::INTEGER_TYPE_HEX) {
#            warn "Cant write HEX integers yet, aborting cell write";
#            return;
#         }
#      }
   }
   elsif (ref($thisDataFormat) eq 'XDF::BinaryIntegerDataFormat') 
   {

      $output = $thisDataFormat->convertIntegerToIntegerBits($datum, $endian);

   } 
   elsif (ref($thisDataFormat) eq 'XDF::BinaryFloatDataFormat') 
   {

      $output = $thisDataFormat->convertFloatToFloatBits($datum, $endian);

   } 
   else
   {
      # a failure to communicate :)
      carp("Unknown Dataformat:".ref($thisDataFormat).
           " is not implemented for formatted writes. Aborting.");
      exit(-1);
   }

   # if we have some output, write it
   if (defined $output) {

      # pad with leading spaces
#      my $actualsize = length($output);
#      while ($actualsize < $formatsize)
#      {
#         print $fileHandle " ";
#         $actualsize++;
#      }

      # now write the data out
      print $fileHandle $output;

   } else {
      # throw error
      carp("doReadCellFormattedIOCmdOutput got NO data\n");
   }

}

sub _print_data {
  my ($self, $fileHandle, $locator, $startTag, $endTag, $emptyTag) = @_;

  my $datum = $self->getData($locator);
  if (defined $datum) {
     print $fileHandle $startTag . $datum . $endTag;
  } else {
     print $fileHandle $emptyTag;
  }
}

# private method
sub _build_locator_string {
  my ($parentArray, $locator) = @_;

  my $string = '$self->{_data}';
  foreach my $axisObj (@{$parentArray->getAxisList()}) {
    $string = $string . "->[" . $locator->getAxisIndex($axisObj) . "]";
  }
  return $string;
} 

1;


__END__

=head1 NAME

XDF::DataCube - Perl Class for DataCube

=head1 SYNOPSIS

    my $dataObj = XDF::DataCube->new();


...

=head1 DESCRIPTION

 Holds the data for a given L<XDF::Array>. It is designed to flexibly expand as data  is added/appended onto it. It doesnt treat swaping of large array data out to file currently. 

XDF::DataCube inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::DataCube.

=over 4

=item classXMLNodeName (EMPTY)

This method takes no arguments may not be changed. This method returns the class node name of XDF::DataCube.  

=item getClassAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes of XDF::DataCube; This method takes no arguments may not be changed.  

=item getClassXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=item removeData (EMPTY)

Data held within the requested datacell is removed. The value of the datacell is set to undef. B<NOT CURRENTLY IMPLEMENTED>.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::DataCube.

=over 4

=item getChecksum (EMPTY)

 

=item setChecksum ($value)

Set the checksum attribute.  

=item getEndByte (EMPTY)

 

=item setEndByte ($endByte)

Set the endByte attribute.  

=item getHref (EMPTY)

 

=item setHref ($hrefObjectRef)

Set the href attribute.  

=item getCompression (EMPTY)

 

=item setCompression ($value)

Set the compression attribute.  

=item getEncoding (EMPTY)

 

=item setEncoding ($value)

Set the encoding attribute.  

=item getDimension (EMPTY)

 

=item getStartByte (EMPTY)

 

=item setStartByte ($startByte)

Set the startByte attribute.  

=item writeDataToFileHandle ($fileHandle, $indent, $compression_type)

Writes out just the data to the proscribed filehandle.  

=item addData ($locator, $data, $no_append)

This routine will append data to a cell unless directed to do otherwise. RETURNS: 1 on success, 0 on failure.  

=item setData ($locator, $datum)

Set the value of the requested datacell. Overwrites existing datacell value if already populated with a value.  

=item getData ($locator)

We return whatever is stored in the datacell.  

=item getData_old ($locator)

Retrieve the SCALAR value of the requested datacell.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::DataCube inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::DataCube inherits the following instance (object) methods of L<XDF::BaseObject>:
B<getXMLAttributes>, B<setXMLAttributes>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L< XDF::Array>, L<XDF::Utility>, L<XDF::BaseObject>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut
