
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
#    Brian Thomas  (brian.thomas@gsfc.nasa.gov)
#    XML Group <http://xml.gsfc.nasa.gov>
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


__END__

=head1 NAME

XDF::Log - Perl Class for Log

=head1 SYNOPSIS

 


...

=head1 DESCRIPTION

 An XDF::Log is a class which handles logging output for  the XDF package.     By default log messages are sent to STDERR, but this may    be re-directed using setLogFileHandle in Specification.     There are four levels of priority, error > warn > debug > info    which have numerical values: 
    0: all levels are printed    1: priority >= debug are printed    2: priority >= warn are printed    3: priority >= error are printed 


XDF::Log inherits class and attribute methods of L< = qw (Exporter);>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::Log.

=over 4

=item info ($msg)

Print a informational message to the log.  

=item warn ($msg)

Print a warning message to the log.  

=item debug ($msg)

Print a debuging message to the log.  

=item error ($msg)

Print an error message to the log.  

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

L< XDF::Specification>, L<XDF::Constants>, L<XDF::Specification>

=back

=head1 AUTHOR

    Brian Thomas  (brian.thomas@gsfc.nasa.gov)
    XML Group <http://xml.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut
