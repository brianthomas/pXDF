#!/usr/bin/perl -w -I ../

# a very simple viewer for XDF files.

# /** COPYRIGHT
#    guiview.pl Copyright (C) 2000 Brian Thomas,
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

# CVS $Id$

use Tk;
use XDF::Reader;

use strict;

# program defs
my $VERSION = "0.1";
my $TOOLNAME = "XDF Viewer Tool";

# GLOBAL Variables
my $XDF;    # reference to the XDF object of interest
my $XDF_FILE; 
my $DISPLAY_SIZE = 'normal';
my %WIDGET; # hash table of GUI widget references

# GLOBAL RunTIME Vars
my $DEBUG = 0;
my $QUIET = 1;

# Signal handling
$SIG{'HUP'} = "my_exit";
$SIG{'INT'} = "my_exit";
$SIG{'QUIT'} = "my_exit";

# GUI Config

# my wonderfull color defs
my ( $Red ,$Green, $Blue, $Lite_blue, $Yellow, $Dark_green, $Grey, $Dark_grey, $Medium_grey, $White, $Black) =
   ("#c24","#6e5","#178",   "#5ab"  , "#cb1",  "#181"    ,"#bbb","#555"    ,"#888",      "#eee","#111");

my $baseColor = $Lite_blue;

my %Font = ( 'tiny'   => '-adobe-fixed-medium-r-normal--12-*-*-*-*-*-*-*', 
             'small'  => '-adobe-fixed-medium-r-normal--14-*-*-*-*-*-*-*',
             'normal' => '-adobe-fixed-medium-r-normal--18-*-*-*-*-*-*-*',
             'large'  => '-adobe-fixed-medium-r-normal--24-*-*-*-*-*-*-*'
           );

my %BoldFont  = ( 'tiny'   => '-adobe-helvetica-bold-r-normal--12-*-*-*-*-*-*-*',
                  'small'  => '-adobe-helvetica-bold-r-normal--14-*-*-*-*-*-*-*',
                  'normal' => '-adobe-helvetica-bold-r-normal--18-*-*-*-*-*-*-*',
                  'large'  => '-adobe-helvetica-bold-r-normal--24-*-*-*-*-*-*-*'
                );



# B E G I N  P R O G R A M 

  &argv_loop();

  # init section
  print STDERR "init gui\n";
  &init_gui();
  print STDERR "init mouse bindings\n";
  &init_mouse_bindings();
  print STDERR "init key bindings\n";
  &init_key_bindings();

  print STDERR "loading $XDF_FILE\n";
  &load_xdf_file($XDF_FILE);

  print STDERR "running gui\n";

  # run Tk
  MainLoop;


# S U B R O U T I N E S 

sub init_mouse_bindings { }

sub init_key_bindings { }

sub argv_loop { 

  &usage() unless ($#ARGV > -1);

  while ($_ = shift @ARGV) {
   #  print $_, "\n";
    if(/-help/) { print "NO help available for $0 currently, sorry\n"; &my_exit();
    } elsif(/-q/) { $QUIET = 1; 
    } elsif(/-v/) { $DEBUG = 1; 
    } else {
      $XDF_FILE = $_;
    }
  }

}

sub usage {
   print STDERR "Usage: $0 <filename> \n";
   &my_exit();
}

sub init_gui { 
  
  $WIDGET{'main'} = new MainWindow();
  $WIDGET{'main'}->configure ( title => "$TOOLNAME v$VERSION", bg => $Grey );

  # Frames 
  my $menubarFrame = $WIDGET{'main'}->Frame->pack(side => 'top', fill => 'x');
  my $topFrame     = $WIDGET{'main'}->Frame->pack(fill => 'both');
  my $topTopFrame  = $topFrame->Frame->pack(side=> 'top', fill => 'both');
  my $topBottomFrame  = $topFrame->Frame->pack(fill => 'both');
  my $fieldsFrame  = $WIDGET{'main'}->Frame->pack(side => 'top', fill => 'both');
  my $viewFrame    = $WIDGET{'main'}->Frame->pack(expand => 'yes', fill => 'both');
  my $axisRowFrame = $viewFrame->Frame->pack(expand => 'yes', fill => 'y', side => 'left');
  my $tableFrame   = $viewFrame->Frame->pack(expand => 'yes', fill => 'both' );
  #my $tscrollFrame  = $viewFrame->Frame->pack(expand => 'yes', fill => 'y', side => 'right');

  # configure frames
  $menubarFrame->configure( relief => 'raised', bd => 2, bg => $baseColor);
  $topFrame ->configure ( relief => 'flat', bd => 2, bg => $baseColor );
  $topTopFrame ->configure ( relief => 'flat', bd => 2, bg => $baseColor );
  $topBottomFrame ->configure ( relief => 'flat', bd => 2, bg => $baseColor );

  
  # Widgets
  # menuBar Frame Widgets
  &create_menu($menubarFrame);

  # top Frame Widgets
  $WIDGET{'toolLabel'} = $topTopFrame->Label( text => "XDF Table Viewer Tool", 
                                              bg => $baseColor, fg => $Black,
                                              font => $BoldFont{$DISPLAY_SIZE},
                                             )->pack(fill => 'x', side=> 'top' );

  $WIDGET{'fileLabel'} = $topBottomFrame->Label( text => "File Name:",
                                                 bg => $baseColor, fg => $Black,
                                                 font => $Font{$DISPLAY_SIZE},
                                               )->pack(fill => 'x', side=> 'left' );

  $WIDGET{'fieldsFrame'} = $fieldsFrame;

  $WIDGET{'tableText'} = $tableFrame->Text()->pack(expand => 'yes', fill => 'both');
  my $y_scroll = $tableFrame->Scrollbar()->pack(side => 'left');
  &add_horizontal_scrollbar_to_text_widget($WIDGET{'tableText'},$tableFrame,'right',$y_scroll);

  

}

sub create_menu {
  my ($menu) = @_;

  my $menuOpt;
  my $menuHelp;

  $menuOpt = $menu->Menubutton(text => "Options",
                                       -font => $Font{$DISPLAY_SIZE},
                                     bg => $baseColor,
                                     -menu => $menuOpt
                                  )->pack(side => 'left');

  $menuHelp = $menu->Menubutton(text => "Help",
                                       -font => $Font{$DISPLAY_SIZE},
                                     bg => $baseColor,
                                     -menu => $menuHelp,
                                  )->pack(side => 'right');

  &create_options_menu($menuOpt);
  &create_help_menu($menuHelp);

}

sub create_options_menu {
  my ($menuOpt) = @_;

  $menuOpt->separator(bg => $baseColor);
  my $menu_cb = 'Change Tool Display Size';
  my $menu_options_size_cascade =
           $menuOpt->cascade(-label => $menu_cb, bg => $baseColor); # , -font => $font{$display_size});
    my $cm = $menuOpt->cget(-menu);
    my $cc = $cm->Menu;
    $menuOpt->entryconfigure($menu_cb, -menu => $cc);
    my $menu_opt_size_cas_tiny = $cc->command(-label => '   Tiny (800x600)  ',
                            #                         -font => $Font{$DISPLAY_SIZE},
                                                      bg => $baseColor,
                                                     -command => sub { });
    my $menu_opt_size_cas_small = $cc->command(-label => '  Small (1024x768) ',
                            #                         -font => $Font{$DISPLAY_SIZE},
                                                      bg => $baseColor,
                                                     -command => sub { });
    $cc->invoke(1);


   # the quit button
   $menuOpt->command(-label => 'Quit',
                          # -font => $Font{$DISPLAY_SIZE},
                            bg => $baseColor,
                           -command => sub { &my_exit; });

}

sub create_help_menu {
  my ($this) = @_;

   $this->command(-label => 'About',
                          # -font => $Font{$DISPLAY_SIZE}, 
                           bg => $baseColor,
                           -command => sub { });

   $this->command(-label => 'Help',
                          # -font => $Font{$DISPLAY_SIZE}, 
                           bg => $baseColor,
                           -command => sub { });

}


sub load_xdf_file {
  my ($file) = @_;

  return unless defined $file && -e $file;

   my %options = ('quiet' => $QUIET, 'debug' => $DEBUG, );
   # set the new XDF object
   $XDF = &XDF::Reader::createXDFObjectFromFile($file, \%options);

   # update the widgets
   $WIDGET{'fileLabel'}->configure(text => "File Name: $file");

   &update_table_viewer();
}

sub update_table_viewer {

  print STDERR "update table viewer\n";

  # get info about the XDF structure

  my $arrayObj = @{$XDF->arrayList}->[0];


  return unless defined $arrayObj;

  my $data_separator = "\t";

  my $textWidget = $WIDGET{'tableText'};
  my $fieldFrame = $WIDGET{'fieldsFrame'};

  $fieldFrame->Label(width => 8, text => "AxisRow")->pack(side => 'left');;
  foreach my $fieldObj ($arrayObj->fieldAxis->getFields) { 
    my $string = $fieldObj->name . "\n". $fieldObj->units->value . "\n";
    my $fieldLabel = $fieldFrame->Label( width => 10, 
                                         text => $string,
                                       )->pack(side => 'left'); 
  }

   # dump the array
   # get the number of indices along each axis 
   my @size = @{$arrayObj->maxDataIndices()};

   my $rowAxis = @{$arrayObj->axisList}->[0];
   my $colAxis = @{$arrayObj->axisList}->[1];

   my $locator = $arrayObj->createLocator;

   foreach my $col (0 .. $size[1]) {
     my $rowName = " " x (6 - length($col)) . $col;
     $textWidget->insert('end', "$rowName || "); # oops! should be the axisValue 
     my $dataline;
     foreach my $row (0 .. $size[0]) {
       $locator->setAxisLocation($rowAxis, $row);
       $locator->setAxisLocation($colAxis, $col);
       my $datum = $arrayObj->getData($locator);
       $datum = " " unless defined $datum;
       $dataline .= $datum . $data_separator;
#       $textWidget->insert('end', $datum . $data_separator);
     }
     $textWidget->insert('end', "$dataline\n");
   }

}

sub my_exit { exit 0; }

sub null_cmd { }

sub add_horizontal_scrollbar_to_text_widget {
  my ($widget,$frame,$barside,$yscroll) = @_;

  $barside = defined $barside ? $barside : "right";
 
  my $widget_side = $barside eq 'right' ? 'left' : 'right';

  $yscroll = $frame->Scrollbar unless $yscroll;
  $yscroll->configure(-command => ['yview', $widget]);
  $widget->configure (-yscrollcommand => ['set', $yscroll]); 
  $widget->pack(side => $widget_side, fill => 'both', expand => 'yes');
  $yscroll->pack(side => $barside, fill => 'y');

}


