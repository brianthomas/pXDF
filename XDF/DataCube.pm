
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

use DB_File;
use XDF::Log;
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
                             _unparsedData
                             _hasData
                             _dataIsOnDisk
                             _tmpDataFile
                             _data
                          );
                             #_axisLookupIndexArray

my $DEFAULT_START_BYTE = 0;
my $DEFAULT_END_BYTE = 0;

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

# Class Data
my $Flag_Decimal = &XDF::Constants::INTEGER_TYPE_DECIMAL;
my $Flag_Octal = &XDF::Constants::INTEGER_TYPE_OCTAL;
my $Flag_Hex = &XDF::Constants::INTEGER_TYPE_HEX;

# CLASS Methods

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

# /** getCacheDataToDisk
# Determine if the data is being stored in system memory or in
# a (disk) file (e.g. simple database treatment).
# */
sub _getCacheDataToDisk {
  my ($self) = @_;
  return $self->{_dataIsOnDisk};
}

# /** _setCacheDataToDisk
# This *may* work on populated dataCube but its much more safe
# to only alter this attribute *before* loading the dataCube.
# */
sub _setCacheDataToDisk {
  my ($self, $cacheData) = @_;

  # IF we have a need to access this from disk file instead
  # of storing in memory (e.g. its a large amount of data)
  # we do the following..

  # need to treat various cases here
  if ($cacheData) {

    # IF we havent already set this, then do the following:
    unless ($self->{_dataIsOnDisk})
    {
  
       # save existing data aside into temp array
       my @temparray = @{$self->{_data}};

       # designate a new tempfile for our data to reside in
       $self->{_tmpDataFile} = ".tmpXDFData_" . $self; # just use our object ref as part of tempfile name
       unlink $self->{_tmpDataFile} if (-e $self->{_tmpDataFile}); # yes, this is needed.
  
       # create the tie between the file and the Perl array 
       tie (@{$self->{_data}}, 'DB_File', $self->{_tmpDataFile}, O_RDWR|O_CREAT, 0666, $DB_RECNO)
         or die("DataCube cant initialize disk-based storage for data: $!\n");
  
       # repopulate Perl array (now tied to disk file) with any pre-existing data
       if ($self->{_hasData}) 
       {
           foreach my $line (@temparray) { push @{$self->{_data}}, $line; }
       }
    }

  } else {

    if ($self->{_dataIsOnDisk})
    {

       # save existing data aside into temp array
       my @temp_array;
       if ($self->{_hasData}) 
       {
          foreach my $line (@{$self->{_data}}) { push @temp_array, $line; }
       }

       # now untie the dbfile, remove it
       untie @{$self->{_data}};
       unlink $self->{_tmpDataFile};

       # repopulate Perl array (now all in memory) with any pre-existing data
       $self->{_data} = \@temp_array; 
       

    }

  } 

  $self->{_dataIsOnDisk} = $cacheData;

}


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

# /** getHrefList 
# */
sub getHrefList {
   my ($self) = @_;
   return $self->{hrefList};
}

#/** getHref
# For the time being this is just aliased to getOutputHref method.
#*/
sub getHref {
  my ($self) =@_;
  return $self->getOutputHref();
}

# /** getOutputHref
# This is always the first Href object in the list of Href's held by this datacube.
# */
sub getOutputHref {
  my ($self) =@_;

  my $hrefObj;
  if ($self->{hrefList} && $#{$self->{hrefList}} > -1) {
    #$hrefObj = @{$self->{hrefList}}->[0];
    $hrefObj = $self->{hrefList}->[0];
  }
  return $hrefObj;
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

   error("Cant set compression to $value, not allowed \n") 
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

   error("Cant set encoding to $value, not allowed \n") 
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

# /** addHref
#     add an Entity Object to the dataCube
# */   
sub addHref {
   my ($self, $entityObjectRef) = @_;
   if (ref($entityObjectRef) eq 'XDF::Entity') {
      push @{$self->{hrefList}}, $entityObjectRef;
   }   
}

# /** toXMLFileHandle
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
  if (defined $self->getOutputHref()) {
     my $href = $self->getOutputHref(); # kludge.. just use the first object
     print $fileHandle " href=\"";
     print $fileHandle $href->getName();
     print $fileHandle "\"";
     $writeHrefAttribute = 1;
  }

  # close the node, if needed 
  print $fileHandle ">" unless ($writeHrefAttribute);

  # write the data
  $self->writeDataToFileHandle($fileHandle, $indent, $self->{compression} );

  # close the tagged data section
  
  if ($writeHrefAttribute) {
     print $fileHandle "/>";
  } else {
     print $fileHandle "</" . $nodeName . ">";
  }

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
  my $href = $self->getOutputHref();

  my $readObj = $parentArray->getXMLDataIOStyle();

  unless (defined $readObj) {
    error("DataCube can't write out. No format reference object defined.\n"); 
    return;
  }

  my $dataFileHandle;
  my $dataFileName;

  # check for href -- writing to an external resource
  if ( defined $href ) {

      # now, while we may be able to read from other files
      # and combine, we are not going to be able to write back
      # out to so many files. Throw a warning here for the user.
      if ($#{$self->{hrefList}} > 0) {
        my $oldHrefName = $href->getName();
        warn "Warning: There is more than one href defined for this Array, but XDF::DataCube may only write to one, using:($oldHrefName)\n";
      }

      # BIG assumption: href is a file we want to read/write
      # Better Handling in future is needed
      if (defined $href->getSystemId()) {
        my $href_program;
        if ($compression_type) {
           $href_program .= "| " . &XDF::Utility::getDataCompressionProgram($compression_type);
        }
        $dataFileName = $href->getBase() if defined $href->getBase();
        $dataFileName .= $href->getSystemId();
        $href_program .= ">$dataFileName";

        open(DFH, $href_program); # we will write data to another file 
                                 # as specified by the entity
        $dataFileHandle = \*DFH;
        $dontPrintCDATATag = 1;
      } else {
        error("XDF::DataCube Href lacks SysId attribute, cannot write out data, aborting write.\n");
        return; 
      }   

  } else {
    $dataFileHandle = $fileHandle; # writing to metadata (XML) file 

    # some warning message
    error("XDF::DataCube can only compress data held in an external file (HREF). Ignoring\n") 
       unless (!defined $compression_type);
  } 

  unless (defined $dataFileHandle) {
    error("XDF::DataCube has no valid data filehandle, aborting.");
    exit -1;
  }

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
     $NoDataValues[0] = $parentArray->getDataFormat()->getNoDataValue();
  }

  # write the data
  #
  if (ref($readObj) eq 'XDF::TaggedXMLDataIOStyle' ) {

     print $dataFileHandle "\n" if $niceOutput;
     &_write_tagged_data($self, $dataFileHandle, $readObj, $indent, $niceOutput, $spec, $readObj->getOutputStyle());
     print $dataFileHandle "$indent" if $niceOutput;

  } else {

     print $dataFileHandle "<![CDATA[" unless $dontPrintCDATATag;

     if (ref($readObj) eq 'XDF::DelimitedXMLDataIOStyle')
     {
        my $fastestAxis = $readObj->getWriteAxisOrderList()->[0];
        $self->_write_untagged_data($dataFileHandle, $readObj, $indent, $niceOutput, $fastestAxis);
     } 
      elsif (ref($readObj) eq 'XDF::FormattedXMLDataIOStyle' )
     {
        my $iterationOrderRef = $readObj->getWriteAxisOrderList();
        $self->_writeFormattedData($dataFileHandle, $parentArray, $readObj, $iterationOrderRef, \@NoDataValues );

     } 
     else 
     {
        error("Unknown read object: $readObj. $self cannot write itself out.\n");
     }

     unless ($dontPrintCDATATag) {
        print $dataFileHandle "]]>";
        print $dataFileHandle "\n$indent" if $niceOutput;
     }

  }

  if ( $dataFileName ) { close DFH; }

}

#
# Private/Protected(?) Methods 
#

# /** _addData
# This routine will append data to a cell unless directed to do otherwise.
# RETURNS: 1 on success, 0 on failure.
# */
sub _addData {
  my ($self, $locator, $data ) = @_;

  return 0 unless defined $locator;

  #this style is actually slower!
  #my $self = shift;
  #my $axisListRef = shift;
  #my $locator = shift;
  #return 0 unless defined $locator;
  #my $data = shift;

  my $old = $self->_getData($locator); #, $axisListRef);
  $old = "" unless defined $old;
  $self->_setData($locator, $old . $data);
  return 1;

}

# /** _removeData
# Data held within the requested datacell is removed. The value of the datacell is set to undef.
# B<NOT CURRENTLY IMPLEMENTED>.
# */
sub _removeData {
  error("Remove_data not currently implemented.\n");
} 
  
#/** _setData
# Set the value of the requested datacell. 
# Overwrites existing datacell value if already populated with a value.
# */
sub _setData {
   my ($self, $locator, $datum ) = @_;

   return unless defined $locator;

   # this style is actually slower!
   #my $self = shift;
   #my $axisListRef = shift;
   #my $locator = shift;
   #return unless defined $locator;
   #my $datum = shift;

   # safety check
#   $self->_updateInternalLookupIndices() if ($#{$self->{_data}} == -1);

   # data are stored in a huge 2D array. The long array axis
   # mirrors all dimensions but the 2nd axis. The 2nd axis gives
   # the index on the 'short' internal array.
   my $longIndex = $locator->_getLongArrayIndex();

   # put data into the requested datacell
   $self->{_data}->[$longIndex] = $datum;

   $self->{_hasData} = 1; # faster than using if ($#{$self->{_data}} == -1) statements; 

#print STDERR "_setData() value:[$datum] index:[$longIndex] ",$locator->_dumpLocation(),"\n";
}

sub _setRecords {
   my ($self, $locator, $data_array_ref ) = @_;

   my $longIndex = $locator->_getLongArrayIndex();

   if ( $locator->_hasDefaultAxesIOOrder() ) {
     # fast way, can take a short cut or two 
     foreach my $datum (@{$data_array_ref}) {
       $self->{_data}->[$longIndex] = $datum;
       $longIndex++;
     }
     $locator->forward($#{$data_array_ref}+1);

   } else {
     # have to do this the slow way
     foreach my $datum (@{$data_array_ref}) {
       $self->_setData($locator, $datum);
       $locator->next();
     }
   } 

   $self->{_hasData} = 1;
}

sub _resetDataCube () {
  my ($self) = @_;

  $self->{_data} = [];

  # set the minimum array size (essentially the size of the axis)
  my $spec= XDF::Specification->getInstance();
  $#{$self->{_data}} = $spec->getDefaultDataArraySize();

  $self->{_hasData} = 0;
  $self->{_unparsedData} = undef;
}

# /** getData
#   We return whatever is stored in the datacell.
# */
sub _getData {
   my ($self, $locator) = @_;

   #my @axisList = @{$self->{_parentArray}->getAxisList()};
   my $longIndex = $locator->_getLongArrayIndex();
#   my $shortIndex = $self->_getShortArrayIndex($locator);

   # did we load data yet? No? then we should do so now
   # Note: order of these 2 calls IS important
   $self->_load_unparsed_data if ($self->{_unparsedData});
   $self->_load_external_data unless ($self->{_hasData});

   my $value = $self->{_data}->[$longIndex];

#print STDERR "_getData() value:[$value] index:[$longIndex] location:",$locator->_dumpLocation,"\n";

   return $value;

}

sub _getRecords {
  my ($self, $locator, $nrofRecords) = @_;
  my @records = ();

  # did we load data yet? No? then we should do so now
  # Note: order of these 2 calls IS important
  $self->_load_unparsed_data if ($self->{_unparsedData});
  $self->_load_external_data unless ($self->{_hasData});

  my $longIndex = $locator->_getLongArrayIndex();
  my $dimensions;

  if ( $locator->_hasDefaultAxesIOOrder() ) {
     # fast way, can take a short cut or two 
     while ($nrofRecords-- > 0) {
       push @records, $self->{_data}->[$longIndex];
       $longIndex++;
     }

  } else {

     if($self->{dimension} == 2) {
        # try a kludge for 2D

        my $startingLongAxis = $longIndex;
        my @iterAxes = @{$locator->getIterationOrder()};
        my $secondAxisSize = $iterAxes[1]->getLength();
        my $nrofAllocatedDataCells = $iterAxes[0]->getLength() * $secondAxisSize;

        while ($nrofRecords-- > 0) {

           push @records, $self->{_data}->[$longIndex];
           $longIndex += $secondAxisSize;

           if ($longIndex > $nrofAllocatedDataCells) {

              $startingLongAxis++;
              $longIndex = $startingLongAxis;

              if ($longIndex > $nrofAllocatedDataCells) {
                 # hmm. wrapping back around to beginning? Nah.
                 last;
              }
           }
        }

     } else {
       # have to do this the slow way
       while ($nrofRecords-- > 0) {
          push @records, $self->_getData($locator);
          $locator->next();
       }
     }
  }

  return \@records;
}

sub _load_unparsed_data {
  my ($self) = @_;

  return unless $self->{_unparsedData};

  my $dataBlock = $self->{_unparsedData}; # must capture BEFORE reset
  $self->_resetDataCube();

  my $formatObj = $self->{_parentArray}->getXMLDataIOStyle();
  my $locator = $self->{_parentArray}->createLocator; 
  $locator->setIterationOrder($formatObj->getWriteAxisOrderList());
  $self->_parseAndLoadDataString ( $dataBlock,
                                   $locator, 
                                   $formatObj, 
  				   $self->getStartByte(),
				   $self->getEndByte
                                 ); 
   # only needed by the read part, we will only write relevant bytes on output
   # so let's clean up.. set start/end byte to defaults
   $self->setStartByte(0);
   $self->setEndByte(undef);
}

# (re)-load all external data
sub _load_external_data {
   my ($self) = @_;

   $self->_resetDataCube();

   # needs to be declared outside of foreach loop below
   my $formatObj = $self->{_parentArray}->getXMLDataIOStyle();
   my $locator = $self->{_parentArray}->createLocator;
   $locator->setIterationOrder($formatObj->getWriteAxisOrderList());

   # loop over href's
   foreach my $href (@{$self->{hrefList}}) {

     die "Cant getData, data Cube is empty and has no Href defined\n"
       unless $href;

     my $openstatement = $self->_getHrefOpenStatement($href);

     if ($openstatement) {

       my $can_open = open(DATAFILE, $openstatement);
       if (!$can_open) {
          warn "Cant open external resource:[$openstatement], aborting read.\n";
          return undef;
       }

       my $startByte = $href->{'_startByte'}; # $self->getStartByte();
       my $endByte = $href->{'_endByte'};     # $self->getEndByte();

       if (ref ($formatObj) eq 'XDF::FormattedXMLDataIOStyle') {
          my $hrefName = $href->getName();
          $startByte = $DEFAULT_START_BYTE unless defined $startByte;
          $endByte   = $DEFAULT_END_BYTE unless defined $endByte;
          $self->_read_formatted_data_from_fileHandle(\*DATAFILE, $locator, $startByte, $endByte, $formatObj, $hrefName);
       } else {

          undef $/; #input rec separator, once newline, now nothing.
                    # will cause whole file to be read in one whack 

          my $text = <DATAFILE>;

#          if (defined $text) {
#            if ($startByte || $endByte) {
#              if ($endByte) {
#                 my $length = $endByte - $startByte;
#                 $text = substr $text, $startByte, $length;
#              } else {
#                 $text = substr $text, $startByte;
#              }
#            }
            # only needed by the read part, we will only write relevant bytes on output
#            $self->setStartByte(0);
#            $self->setEndByte(undef);
#          }

          $self->_parseAndLoadDataString($text, $locator, $formatObj, $startByte, $endByte);
       }

       # only needed by the read part, we will only write relevant bytes on output
       $href->{'_startByte'} = 0; # probably not needed, but I feel "formal" today
       $href->{'_endByte'} = undef; # probably not needed, but I feel "formal" today

       close DATAFILE;

     } else {
       warn "No data loaded from external resource:",$href->getName,"\n";
     }

   }

   # do this regardless to prevent looping (?)
   $self->{_hasData} = 1; 
}

sub _parseAndLoadDataString {
   my ($self, $dataBlock, $locator, $formatObj, $startByte, $endByte, $delayLoad) = @_;

   # trim down the datablock, IF these are defined still
   #my $startByte = $self->getStartByte();
   #my $endByte = $self->getEndByte();

   if ($startByte || $endByte) {

      if ($endByte) {
        my $length = $endByte - $startByte + 1;
        $dataBlock = substr $dataBlock, $startByte, $length;
      } else {
        $dataBlock = substr $dataBlock, $startByte;
      }

      # only needed by the read part, we will only write relevant bytes on output
#      $self->setStartByte(0);
#      $self->setEndByte(undef);

   }

   if ($delayLoad) {
      $self->{_unparsedData} = $dataBlock;
      return;
   }


   # gather general information

   if (ref($formatObj) eq 'XDF::FormattedXMLDataIOStyle')
   {
      # this *shouldnt* be called anymore? 
      $self->_read_formatted_data( $locator, $dataBlock, $formatObj );
   }
   else
   {
#      die "Cannot read binary data within a delimited array, aborting read.\n" if ($data_has_binary_values);
      $self->_read_delimitted_data($locator, $dataBlock, $formatObj );
   }

}

# a slow, outdated routine
# we should use read/seek on string, if we could
sub _read_formatted_data {
  my ($self, $locator, $dataBlockString, $formatObj) = @_;
      #$data_has_special_integers, $data_has_binary_values) = @_;

  my $data_has_special_integers = $self->{_parentArray}->hasSpecialIntegers();
  my $data_has_binary_values = $self->{_parentArray}->hasBinaryData();

  my $endian = $formatObj->getEndian();
  my $template  = $formatObj->_templateNotation(1);
  my $recordSize = $formatObj->numOfBytes();
  my @dataFormat = $self->{_parentArray}->getDataFormatList;

  while ( $dataBlockString ) {

      $dataBlockString =~ s/(.{$recordSize})//s;

      # pick off a record
      die "Read Error: short read on datablock, improper specified format? (expected size=$recordSize)\n" unless $1;

      my @data = unpack($template, $1);

      # In part because we are using a regex mechanism below,
      # it doesnt make sense to store binary data in delimited manner,
      # so we only see it as a fixed Formatted case.
      # this may have to be re-evaluated in the future. -b.t.
      @data = &_deal_with_binary_data(\@dataFormat, \@data, $endian)
         if $data_has_binary_values;

      # if we got data, fire it into the array
      if ($#data > -1) {

        @data = &_deal_with_special_integer_data(\@dataFormat, \@data)
           if $data_has_special_integers;

        for (@data) {
#          &_printDebug("ADDING DATA [$locator]($self->{_parentArray}) : [".$_."]\n");
         #print STDERR "ADDING DATA : [".$_."]\n";
          $self->_setData($locator, $_);
          $locator->next();
        }

      } else {

        my $line = join ' ', @data;
        error("Unable to get data! Template:[$template] failed on Line: [$line]\n");
        error("BLOCK: $dataBlockString\n");
        exit -1;

      }

      # slow?
      last unless $dataBlockString !~ m/^\s*$/;

    }

}

sub _read_delimitted_data {
  my ($self, $locator, $dataBlockString, $formatObj) = @_;

  my $data_has_special_integers = $self->{_parentArray}->hasSpecialIntegers();

  my $regex = $formatObj->_regexNotation();

  # A kludge. But some users abut the ending tag to the end of the delimited
  # string without including the record terminator, so we will check here and
  # do it, IF needed as a means to make delimited reads more robust.
  my $last_char = $dataBlockString;
  $last_char =~ s/.*(.)$/$1/;

  $dataBlockString .= $formatObj->getRecordTerminator()->getStringValue()
       if ($formatObj->getRecordTerminator()->getStringValue() ne $last_char);

  my @dataFormat = $self->{_parentArray}->getDataFormatList;
  while ( $dataBlockString ) {

      $_ = $dataBlockString;
      my @data = m/$regex/;

      # remove data from data 'resevoir' (yes, there is probably a one-liner
      # for these two statements, but I cant think of it :P
      $dataBlockString =~ s/$regex//;

      # if we got data, fire it into the array
      if ($#data > -1) {

        @data = &_deal_with_special_integer_data(\@dataFormat, \@data)
           if $data_has_special_integers;

        for (@data) {
#          &_printDebug("ADDING DATA [$locator]($self->{_parentArray}) : [".$_."]\n");
          #&_printDebug("ADDING DATA : [".$_."]\n");
          $self->_setData($locator, $_);
          $locator->next();
        }

      } else {

        my $line = join ' ', @data;
        error("Unable to get data! Regex:[$regex] failed on Line: [$line]\n");
        error("Remaining data block to parse:[$dataBlockString]\n");
        exit -1;
      }

      # slow?
      last unless $dataBlockString !~ m/^\s*$/;

    }

}

# a faster, more modern routine
sub _read_formatted_data_from_fileHandle {
  my ($self, $fileHandle, $hrefLocator, $startByte, $endByte, $formatObj, $externalName) = @_;

  $endByte = -1 unless defined $endByte;

  # gather general information
  my $data_has_special_integers = $self->{_parentArray}->hasSpecialIntegers();
  my $data_has_binary_values = $self->{_parentArray}->hasBinaryData();
  #my $locator = $self->{currentArray}->createLocator();

  #info("locator[".$self->{hrefLocator}."] has axisOrder:[",join ',', @{$self->{readAxisOrderList}},"]\n");
#  info("locator[".$hrefLocator."] has axisOrder:[".@{$hrefLocator->getIterationOrder}."]\n");

  my $endian = $formatObj->getEndian();
  my $template  = $formatObj->_templateNotation(1);
  my $recordSize = $formatObj->numOfBytes();
  my @dataFormat = $self->{_parentArray}->getDataFormatList;

  my @data = ();
  my @new_data = ();
  my $offset = $startByte;
  my $buf;
  my $total_bytes_read = 0;

  while ( 1 ) {

      # pick off a record
      seek ($fileHandle, $offset, 0);
      my $nrof_bytes_read = read ($fileHandle, $buf, $recordSize);

      last unless $nrof_bytes_read > 0;

      $total_bytes_read += $nrof_bytes_read;
      last if ($endByte > 0 && $total_bytes_read > $endByte);

      # unpack it. We catch errors here and pass on to user what actually happened
      if (!eval { @new_data = unpack($template, $buf); }) {
         my $msg = "Fatal Error: bad formatted read from external resource:[".$externalName."] for array:[".$self->{_parentArray}->getName()."]\n";
         $msg .= "Perl Error:[$@]\n";
         $msg .= "last data unpack template:[$template]\n";
         $msg .= "last data buffer (actual bytes:".length ($buf).") (expected bytes:$recordSize) chars:[$buf]\n";
         die $msg;
      }

      # In part because we are using a regex mechanism below,
      # it doesnt make sense to store binary data in delimited manner,
      # so we only see it as a fixed Formatted case.
      # this may have to be re-evaluated in the future. -b.t.
      @new_data = &_deal_with_binary_data(\@dataFormat, \@new_data, $endian)
         if $data_has_binary_values;

      push @data, @new_data;
      $offset += $nrof_bytes_read;
      @new_data = ();

   }

   # if we got data, fire it into the array
   if ($#data > -1) {

        @data = &_deal_with_special_integer_data(\@dataFormat, \@data)
           if $data_has_special_integers;


        #foreach my $item (@data) { &debug("ADDING DATA : [$item]\n"); } 

        #$self->{_parentArray}->setRecords($self->{hrefLocator}, \@data);
        #$self->{hrefLocator}->forward($#data+1);
        $self->_setRecords($hrefLocator, \@data);

   } else {
#        my $line = join ' ', @data;
#        $self->_printWarning( "Unable to get data! Template:[$template] failed on Line: [$line]\n");
   }

}

sub _deal_with_binary_data { # STATIC 
  my ($dataFormatListRef, $data_ref, $endian) = @_;

  my @data = @{$data_ref};
  my @dataFormatList = @{$dataFormatListRef};

  foreach my $dat_no (0 .. $#dataFormatList) {
     if ( ref($dataFormatList[$dat_no]) eq 'XDF::BinaryIntegerDataFormat') {
        $data[$dat_no] = $dataFormatList[$dat_no]->convertBitStringToIntegerBits($data[$dat_no], $endian);
     } elsif ( ref($dataFormatList[$dat_no]) eq 'XDF::BinaryFloatDataFormat') {
        $data[$dat_no] = $dataFormatList[$dat_no]->convertBitStringToFloatBits($data[$dat_no], $endian);
     }
  }

  return @data;
}


# Treatment for hex, octal reads
# that can occur in formatted data
sub _deal_with_special_integer_data { # STATIC 
  my ($dataFormatListRef, $data_ref) = @_;
  my @data = @{$data_ref};
  my @dataFormatList = @{$dataFormatListRef};

  foreach my $dat_no (0 .. $#dataFormatList) {
    $data[$dat_no] = &_change_integerField_data_to_flagged_format($dataFormatList[$dat_no], $data[$dat_no] )
                if ref($dataFormatList[$dat_no]) eq 'XDF::IntegerDataFormat';
  }

  return @data;
}

sub _change_integerField_data_to_flagged_format { #STATIC 
  my ($integerFormatObj, $datum ) = @_;

  return $datum unless (defined $integerFormatObj);

  my $formatflag = $integerFormatObj->type();
  return $datum unless defined $formatflag;

  if ($formatflag eq $Flag_Decimal ) {

    return $datum; # do nothing 

  } elsif ($formatflag eq $Flag_Octal ) {

    return oct($datum);

  } elsif ($formatflag eq $Flag_Hex ) {

    return hex($datum);

  } else {

    &_printError("XDF::DataCube does'nt understand integer type: $formatflag\n");
    return $datum;
  }

}

sub _getHrefOpenStatement {
  my ($self, $href) = @_;

   return unless defined $href;

   my $file;
   if (defined $href->getSystemId) {
       $file = $href->getBase() if $href->getBase();
       $file .= $href->getSystemId();

       # print STDERR "got Href File:$file\n";

       my $openstatement = $file;
       my $compression_prog = &XDF::Utility::getDataDecompressionProgram($self->getCompression());

       if (defined $compression_prog) {
          $openstatement = " $compression_prog $openstatement|";
       }

       return $openstatement;

   } else {
      warn "XDF::Reader can't read Href data, SYSID is not defined!\n";
   }

}

# This is called when we cant find any defined method
# exists already. Used to handle general purpose set/get
# methods for our attributes (object fields).
sub AUTOLOAD {
  my ($self,$val) = @_;
  #&XDF::BaseObject::AUTOLOAD($self, $val, $AUTOLOAD, \%{$XDF::DataCube::FIELDS} );
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}

sub _init {
  my ($self) = @_;

  $self->SUPER::_init();

  # declare the _data attribute as an array 
  # as we add data (below) it may grow in
  # dimensionality, but defaults to 0 at start. 
  $self->{dimension} = 0;
  $self->{_hasData} = 0;
  $self->{startByte} = $DEFAULT_START_BYTE;
  $self->{endByte} = $DEFAULT_END_BYTE;
  $self->{_axisLookupIndexArray} = [];
  $self->{hrefList} = [];

  $self->{_dataIsOnDisk} = 0;
 
  # initialize the datablock (just a single array).
  $self->{_data} = [];

  # set the minimum array size (essentially the size of the axis)
  my $spec= XDF::Specification->getInstance();
  $#{$self->{_data}} = $spec->getDefaultDataArraySize();

  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

}

# Yes, this is crappy. I plan to come back and do it 'right' one day.
#
# Note: we need to consider the case where the user *DIDNT* supply 
# tag names for the axes. In this case, we use 'd0','d1' ...'d8' tag 
# notation.
sub _write_tagged_data {
  my ($self, $fileHandle, $readObj, $indent, $niceOutput, $spec, $style) = @_;

  # now we populate the data , if there are any dimensions 
  if ($self->{dimension} > 0) {

#    my @axisList = @{$self->{_parentArray}->getAxisList()};
    my @axisList = @{$readObj->getWriteAxisOrderList()};

    # gather info. Find out what tags go w/ which axii
    my @AXIS_TAG = reverse @{$readObj->getAxisTags()}; 

    my $locator = $self->{_parentArray}->createLocator;

    # now build the formatting stuff. 
    my $data_indent = $indent . $spec->getPrettyXDFOutputIndentation;
    my $startDataRecordTag = $data_indent;
    my $endDataRecordTag = "";
    my $startDataTag;
    my $endDataTag;
    my $emptyDataTag;
    if ($style eq &XDF::Constants::TAGGED_DEFAULT_OUTPUTSTYLE) {
       foreach my $axis (0 .. ($#axisList-1)) {
          $startDataRecordTag .= "<" . $AXIS_TAG[$axis] . ">";
       }
       foreach my $axis (0 .. ($#axisList-1)) {
          $endDataRecordTag .= "</" . $AXIS_TAG[$axis] . ">";
       }
       $endDataRecordTag .= "\n";
       $startDataTag = "<" . $AXIS_TAG[$#axisList] . ">";
       $endDataTag = "</" . $AXIS_TAG[$#axisList] . ">";
       $emptyDataTag = "<" . $AXIS_TAG[$#axisList] . "/>";
    } elsif ($style eq &XDF::Constants::TAGGED_BYROWANDCELL_OUTPUTSTYLE) {
       my $rectag = &XDF::Constants::SIMPLE_ROW_TAG;
       my $dtag = &XDF::Constants::SIMPLE_CELL_TAG;
       $startDataRecordTag .= "<$rectag>";
       $startDataTag = "<$dtag>";
       $endDataRecordTag = "</$rectag>\n";
       $endDataTag = "</$dtag>";
       $emptyDataTag = "<$dtag/>";

       # configure axis ordering to be row-oriented
       my @newOrder = ( $self->{_parentArray}->getColAxis(), $self->{_parentArray}->getRowAxis() );
       $locator->setIterationOrder(\@newOrder);

    } elsif ($style eq &XDF::Constants::TAGGED_BYROW_OUTPUTSTYLE) {
       my $rectag = &XDF::Constants::SIMPLE_ROW_TAG;
       $startDataRecordTag .= "<$rectag>";
       $endDataRecordTag = "</$rectag>\n";
       $startDataTag = ""; # nothing
       $endDataTag .= " "; # always single space
       $emptyDataTag .= "  "; # not really possible, but lets put 2 spaces anyways 

       # configure axis ordering to be row-oriented
       my @newOrder = ( $self->{_parentArray}->getColAxis(), $self->{_parentArray}->getRowAxis() );
       $locator->setIterationOrder(\@newOrder);

    } elsif ($style eq &XDF::Constants::TAGGED_BYCOLANDCELL_OUTPUTSTYLE) {
       my $rectag = &XDF::Constants::SIMPLE_COLUMN_TAG;
       my $dtag = &XDF::Constants::SIMPLE_CELL_TAG;
       $startDataRecordTag .= "<$rectag>";
       $startDataTag = "<$dtag>";
       $endDataRecordTag = "</$rectag>\n";
       $endDataTag = "</$dtag>";
       $emptyDataTag = "<$dtag/>";

       # configure axis ordering to be column-oriented
       my @newOrder = ( $self->{_parentArray}->getRowAxis(), $self->{_parentArray}->getColAxis() );
       $locator->setIterationOrder(\@newOrder);

    } elsif ($style eq &XDF::Constants::TAGGED_BYCOL_OUTPUTSTYLE) {
       my $rectag = &XDF::Constants::SIMPLE_COLUMN_TAG;
       $startDataRecordTag .= "<$rectag>";
       $endDataRecordTag = "</$rectag>\n";
       $startDataTag = ""; # nothing
       $endDataTag .= " "; # always single space
       $emptyDataTag .= "  "; # not really possible, but lets put 2 spaces anyways 

       # configure axis ordering to be column-oriented
       my @newOrder = ( $self->{_parentArray}->getRowAxis(), $self->{_parentArray}->getColAxis() );
       $locator->setIterationOrder(\@newOrder);

    }
 
    # ok, time to build the eval block that will write out the tagged data
    my $eval_block;

    my $more_data = 1;

    #my $fast_axis_length = @{$readObj->getWriteAxisOrderList()}->[0]->getLength(); 
    my $fast_axis_length = $readObj->getWriteAxisOrderList()->[0]->getLength(); 
#    my $fast_axis_length = @{$self->{_parentArray}->getAxisList()}->[0]->getLength(); 
    my $dataNumb = 0; 
    while ($more_data) {
       print $fileHandle $startDataRecordTag if ($dataNumb == 0);
       $self->_print_tagged_data($fileHandle, $locator, $startDataTag, $endDataTag, $emptyDataTag);
       $dataNumb++;
       if( $dataNumb >= $fast_axis_length ) {
         print $fileHandle $endDataRecordTag;
         $dataNumb = 0;
       }
       $more_data = $locator->next();
    }
  }

}

# for formatted and delmited data
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
      #$fast_axis_length = @{$self->{_parentArray}->getAxisList()}->[0]->getLength(); 
      $fast_axis_length = $self->{_parentArray}->getAxisList()->[0]->getLength(); 
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
        my $this_data = $self->_getData($locator);
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
        push @outData, $self->_getData($locator) if !defined $outArray[$outArrayNumb];
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
   $locator->setIterationOrder($readObj->getWriteAxisOrderList());

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

          my $datum = $self->_getData($locator);

#print STDERR "data:[$datum] ",$locator->_dumpLocation,"\n";

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
                 error("Can't print out null data: noDataValue NOT defined.\n");
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
             error("DataCube cannot write out, unimplemented format command:$command\n");
          } else {
             error("DataCube cannot write out, format command not defined (weird)!\n");
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
       or ref($thisDataFormat) eq 'XDF::ArrayRefDataFormat') 
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
          error("Error: cant write data:[$datum], actual length is larger than declared size ($formatsize)\n");
          if (defined $noDataValue) {
             info("printing with noDataValue:[$noDataValue]\n");
             $output = $noDataValue; # just print no datavalue
          } else { 
             info("printing noDataValue as blanks.\n");
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
      error("Unknown Dataformat:".ref($thisDataFormat)." is not implemented for formatted writes. Aborting.");
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
      error("doReadCellFormattedIOCmdOutput got NO data\n");
   }

}

# for printting tagged data
sub _print_tagged_data {
  my ($self, $fileHandle, $locator, $startTag, $endTag, $emptyTag) = @_;

  my $datum = $self->_getData($locator);
  if (defined $datum) {
     print $fileHandle $startTag . $datum . $endTag;
  } else {
     print $fileHandle $emptyTag;
  }
}

# need to override the destructor for this special case
sub DESTROY { #private
  my $self = shift;

  if ($self->{_dataIsOnDisk}) 
  {

    # untie the array from database file
    untie @{$self->{_data}};
    # remove the database file
    unlink $self->{_tmpDataFile} if (-e $self->{_tmpDataFile}); # yes, this is needed.

  }

  $self->SUPER::DESTROY();

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

=item toXMLFileHandle (EMPTY)

We overwrite the toXMLFileHandle method supplied by L<XDF::BaseObject> to have some special handling for the XDF::DataCube. The interface for thismethod remains the same however.  

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

For the time being this is just aliased to getOutputHref method.  

=item getOutputHref (EMPTY)

This is always the first Href object in the list of Href's held by this datacube.  

=item getCompression (EMPTY)

 

=item setCompression ($value)

Set the compression attribute.  

=item getEncoding (EMPTY)

 

=item setEncoding ($value)

Set the encoding attribute.  

=item getDimension (EMPTY)

 

=item getStartByte (EMPTY)

=item addHref ($hrefObjectRef)

add an Href Object to the dataCube 

=item writeDataToFileHandle ($fileHandle, $indent, $compression_type)

Writes out just the data to the proscribed filehandle.  

=item setStartByte ($startByte)

Set the startByte attribute.  

=item writeDataToFileHandle ($fileHandle, $indent, $compression_type)

Writes out just the data to the proscribed filehandle.  

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
