
# $Id$

# /** COPYRIGHT
#    Specification.pm Copyright (C) 2002 Brian Thomas,
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
# An XDF::Log is a class which handles logging output for 
# the XDF package.
#    By default log messages are sent to STDERR, but this may
#    be re-directed using setLogFileHandle in Specification.
#    There are four levels of priority, error > warn > debug > info
#    which have numerical values:
#@
#    0: all levels are printed
#    1: priority >= debug are printed
#    2: priority >= warn are printed
#    3: priority >= error are printed
#@
# */

# /** SYNOPSIS
# 
# */

# /** SEE ALSO
# XDF::Specification
# */

package XDF::Log;

use XDF::Constants;
use XDF::Specification;

use Exporter;

use vars qw (@EXPORT @ISA);

@ISA = qw (Exporter);
@EXPORT = qw /debug warn info error/;

# CLASS DATA
my $Specification = XDF::Specification->getInstance();
my $DEBUG_LEVEL = &XDF::Constants::LOG_DEBUG_MSG_LEVEL;
my $WARN_LEVEL = &XDF::Constants::LOG_WARN_MSG_LEVEL;
my $INFO_LEVEL = &XDF::Constants::LOG_INFO_MSG_LEVEL;

# Class (Static) Methods

#/** info
# Print a informational message to the log.
#*/
sub info {
   my ($msg) = @_;
   my $current_level = $Specification->getLogMessageLevel();
   my $LOG_FILE_HANDLE = $Specification->_getLogFileHandle();
   print $LOG_FILE_HANDLE $msg if $current_level <= $INFO_LEVEL;
}

#/** warn 
# Print a warning message to the log.
#*/
sub warn {
   my ($msg) = @_;
   my $current_level = $Specification->getLogMessageLevel();
   my $LOG_FILE_HANDLE = $Specification->_getLogFileHandle();
   print $LOG_FILE_HANDLE $msg if $current_level <= $WARN_LEVEL;
}

#/** debug
# Print a debuging message to the log.
#*/
sub debug {
   my ($msg) = @_;
   my $current_level = $Specification->getLogMessageLevel();
   my $LOG_FILE_HANDLE = $Specification->_getLogFileHandle();
   print $LOG_FILE_HANDLE $msg if $current_level <= $DEBUG_LEVEL;
}

#/** error
# Print an error message to the log.
#*/
sub error {
   my ($msg) = @_;
   my $LOG_FILE_HANDLE = $Specification->_getLogFileHandle();
   print $LOG_FILE_HANDLE $msg; # always print errors 
}

1;

