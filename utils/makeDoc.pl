#!/usr/bin/perl

# A badly written program to make perldoc code 
# from perl object package file

# /** COPYRIGHT
#    makeDoc.pl Copyright (C) 2000 Brian Thomas,
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

my $MAKE_SUMMARY = 0;

my $file = $ARGV[0];

# GLOBAL CONSTANTS
my $packagename = "XDF";

# GLOBAL VARIABLES
my $ClassName;
my $SuperClass; 
my @IncludeObject;
my @Class_Method;
my @Methods;
my @SuperMethods;
my @Attributes;
my @AddSection;
my $Class_Description;
my $Class_Synopsis;
my $Class_Author;
my %Method_Comment;
my %Native_Method;
my %SuperClassHash;

#unless ($MAKE_SUMMARY) {
  &remove_POD_from_module($file);
#}

open (FILE, "tmp");

while (<FILE>) { 
   chomp unless (m/^#\@/);

   if($gotAMethod) {

     my $item = $_;
    
     my $things = " (";
     my $isClassMethod = 1;

     if ($item =~ m/^\s*?my.*?\@_;/) {
       $item =~ s/^.*?\(//;
       $item =~ s/\).*?$//;

       my @things = split ',', $item; 

       # if it has $self, it is a 'instance method' otherwise itsa class method
       while (@things) {
         my $thing = shift @things;
         $thing =~ s/^\s+//;
         $thing =~ s/\s+$//;
         $isClassMethod = 0 if $thing =~ m/\$self/; 
         #$Methods[$#Methods] .= "$thing, " unless $thing =~ m/\$(self|proto)/; 
         $things .= "$thing, " unless $thing =~ m/\$(self|proto)/; 
       }

       if ($things =~ m/\($/) {
          $things .= "EMPTY";
       } else {
          chop $things;
          chop $things;
       }

     } else { 
       #$Methods[$#Methods] .= "EMPTY";  
       $things .= "EMPTY";  
     }

     $things .= ")";  

     if ($isClassMethod) 
     {
        my $method_name_line = $Methods[$#Methods] . $things;
        pop @Methods; # remove from (instance) method list
        $Class_Method[$#Class_Method+1] = $method_name_line;
     } else {
        $Methods[$#Methods] .= $things;
     }

     $gotAMethod = 0;
     next;
   }

   if($readAttributes) {
     my $item = $_;
     $item =~ s/^\s+//;
     $item =~ s/^\s+//;
     next unless $item;
     next unless $item !~ m/^\_/; 

     if( $item =~ m/\);/ ) { 
       $readAttributes = 0;
       next;
     }

     push @Attributes, $item;

   }

   if ($_ =~ m/^my\s\@Class\_XML\_Attributes/) {
     $readAttributes = 1; 
     next;
   }

   if ($_ =~ m/^use\s(.*?)/) {
     my $item = $';
     $item =~ s/;$//; 
     push @IncludeObject, $item if $item =~ m/$packagename/;
   } 

   # name of this class
   if ($_ =~ m/^package\s(.*?)/) {
     my $item = $';
     $item =~ s/;$//; 
     $item =~ s/^$packagename\:\://; 
     $ClassName = $item;
   }

   # object that is super class
   if ($_ =~ m/^\@ISA/) {
     my $item = $';
     $item =~ s/^.*?\"//; 
     $item =~ s/\".*?$//; 

     push @SuperClass, $item;

   }

   # other methods
   if ($_ =~ m/^sub\s+/ and !$noMorePublicMethods ) {
     my $item = $';

     $item =~ s/\s.*?$//; 

     next unless $item =~ m/[^A-Z]/;
     next unless $item !~ m/^\_/;

     $Native_Method{$item} = 1; 

     push @Methods, $item; 
     $gotAMethod = 1;
   }

   # got a comment
   if ($_ =~ m/^#/) {

     if ($_ =~ m/^#\s*?\/\*\*\s*?DESCRIPTION/) {
        $addDescription = 1; 
        next;
     }

     if ($_ =~ m/^#\s*?\/\*\*\s*?PRIVATE METHODS/) {
        $noMorePublicMethods = 1; 
        next;
     }

     if ($_ =~ m/^#\s*?\/\*\*\s*?ADDITIONAL SECTION(.*)/) {
        $addSection = 1; 
        push @AddSection, {};
        $AddSection[$#AddSection]->{'name'} = $1;
        next;
     }

     if ($_ =~ m/^#\s*?\/\*\*\s*?AUTHOR/) {
        $addAuthor = 1; 
        next;
     }
     if ($_ =~ m/^#\s*?\/\*\*\s*?SYNOPSIS/) {
        $addSynopsis = 1; 
        next;
     }

     if ($_ =~ m/^#\s*?\/\*\*\s*?SEE ALSO/) {
        $addSeeAlso = 1; 
        next;
     }

     if ($_ =~ m/^#\s*?\/\*\*\s*(.*?)\s*?/) {
       $addMethodComment = $';
       $addMethodComment =~ s/^\s*//;
       $addMethodComment =~ s/\s*$//;
       $addMethodComment = "" unless defined $addMethodComment;
       next;
     }

     $addAuthor = 0 if ($addAuthor && $_ =~ m/^#\s*?\*\//);
     $addMethodComment = undef if (defined $addMethodComment && $_ =~ m/^#\s*?\*\//);
     $addSynopsis = 0 if ($addSynopsis && $_ =~ m/^#\s*?\*\//);
     $addDescription = 0 if ($addDescription && $_ =~ m/^#\s*?\*\//);
     $addSeeAlso = 0 if ($addSeeAlso && $_ =~ m/^#\s*?\*\//);
     $addSection = 0 if ($addSection && $_ =~ m/^#\s*?\*\//);

     if ($addDescription) {
       s/^#//;
       unless (m/^\@/) {
         chomp;
         s/$/ / if m/\.$/;
       } else {
         s/^\@/ /;
       } 
       $Class_Description .= $_;
     }

     if ($addSection) {
       s/^#//;
       unless (m/^\@/) {
         chomp;
         s/$/ / if m/\.$/;
       } else {
         s/^\@/ /;
       }
       $AddSection[$#AddSection]->{'text'} .= $_;
     }

     if ($addAuthor) {
       s/^#//;
       $Class_Author .= $_ . "\n";
     }

     if ($addSynopsis) {
       s/^#//;
       $Class_Synopsis .= $_ . "\n";
     }

     if (defined $addMethodComment) {
       s/^#\s*//;
       chomp;
       s/$/ / if m/\.$/;
       $Method_Comment{$addMethodComment} .= $_;
     }
   
     if ($addSeeAlso) {
       s/^#//;
       chomp;
       push @IncludeObject, $_;
     }
   }

   last if m/^1;\s*?$/;
}

close FILE;

while ($#SuperClass > -1 ) { 
  my $sclass = shift @SuperClass; 
  push @SuperClass, &deal_with_superClass($sclass);
}


if ($MAKE_SUMMARY) {
  print STDOUT "\n******\n$packagename\:\:$ClassName\n******\n\n";

  # sort the class and other methods
  for (@Methods) {
    if ($_ =~ m/^class/) {
      push @Class_Method, $_;
    } else {
      push @Method, $_;
    }
  }

#  print STDOUT "CLASS METHOD:\n";
#  if ($#Class_Method >= 0) {
#    for (@Class_Method) {
#     # $_ =~ s/(.*?)\s*?\(.*?\)/$1/;
#      print STDOUT "$_\n";
#    }
#  }

#  print STDOUT "ATTRIBS:\n";
#  if ($#Attributes >= 0) {
#    for (@Attributes) {
#      $_ =~ s/(.*?)\s*?\(.*?\)/$1/;
#      print STDOUT "\t$_\n";
#    }
#  }

  print STDOUT "METHODS:\n";
  if ($#Method >= 0) {
    for (@Method) {
      $_ =~ s/(.*?)\s*?\(.*?\)/$1/;
      print STDOUT "\t$_\n";
    }
  }

  print STDOUT "INHERITED METHODS:\n";
  foreach my $superClass (@keys) {

      my @Super_Method = ();
      my @Super_Class_Method = ();

      for (@{$SuperClassHash{$superClass}}) {
        if ($_ =~ m/^[A-Z]/) { push @Super_Class_Method, $_; } else { push @Super_Method, $_; }
      }

      if ($#Super_Method >= 0) {
        print STDOUT "\t$superClass:\n";
        for (@Super_Method) {
          print STDOUT "\t\t$_\n";
        }
      }

  }


} else {
  # now tack on the doc stuff
  &make_POD_doc_in_file()

}

exit 0;

# S U B R O U T I N E S

sub make_POD_doc_in_file {

  open (FILE, ">>tmp");

  print FILE "\n\n__END__\n\n";
  print FILE "=head1 NAME\n\n$packagename\:\:$ClassName - Perl Class for $ClassName\n\n";
  #print FILE "=head1 SYNOPSIS\n\n  use $packagename\:\:$ClassName;\n\n";
  print FILE "=head1 SYNOPSIS\n\n";
  print FILE $Class_Synopsis . "\n\n" if defined $Class_Synopsis;
  print FILE "...\n\n";
  print FILE "=head1 DESCRIPTION\n\n";
  print FILE $Class_Description . "\n\n" if defined $Class_Description;
  if ((my @keys = keys %SuperClassHash)) {
    print FILE "$packagename\:\:$ClassName inherits class and attribute methods of ";
    my $string;
    for (@keys) { $string .= "L<$_>, "; }
    chop $string; chop $string;
    print FILE "$string.\n";
  } 
  print FILE "\n\n";

  print FILE "=head1 METHODS\n\n";

  print FILE "=over 4\n\n";

# sort the class and other methods
  for (@Methods) {
    if ($_ =~ m/^class/) {
      push @Class_Method, $_;
    } else {
      push @Method, $_;
    }
  }
  
  if ($#Class_Method >= 0) {
    print FILE "=head2 CLASS Methods\n\n"; 
    print FILE "The following methods are defined for the class $packagename\:\:$ClassName.\n\n=over 4\n\n";
    for (@Class_Method) { 
      print FILE "=item $_\n\n";
      $_ =~ s/(.*?)\s*?\(.*?\)/$1/;
      print FILE $Method_Comment{$_} if exists $Method_Comment{$_};
      print FILE " \n\n"; 
    }
    print FILE "=back\n\n";
  } 
  
#  if ($#Attributes >= 0) {
#     print FILE "=head2 ATTRIBUTE Methods\n\n"; 
#     print FILE "These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).\n\n"; 
#    print FILE "=over 4\n\n"; 
#    for (@Attributes) { 
#      print FILE "=item $_\n\n";
#      $_ =~ s/(.*?)\s*?\(.*?\)/$1/;
#      print FILE $Method_Comment{$_} if exists $Method_Comment{$_};
#      print FILE " \n\n"; 
#    }
#    print FILE "=back\n\n";
#  }
  
  if ($#Method >= 0) {
    print FILE "=head2 INSTANCE (Object) Methods\n\n"; 
    print FILE "The following instance (object) methods are defined for $packagename\:\:$ClassName.\n\n"; 
    print FILE "=over 4\n\n"; 
    for (@Method) { 
      print FILE "=item $_\n\n";
      $_ =~ s/(.*?)\s*?\(.*?\)/$1/;
      print FILE $Method_Comment{$_} if exists $Method_Comment{$_};
      print FILE " \n\n"; 
    }
    print FILE "=back\n\n";
  }

  if (defined (my @keys = keys %SuperClassHash)) {
  
    print FILE "\n\n=head2 INHERITED Class Methods\n\n"; 
    print FILE "=over 4\n\n"; 
  
    foreach my $superClass (@keys) {
  
      my @Super_Class_Method = (); 
      my @Super_Method = (); 
  
      for (@{$SuperClassHash{$superClass}}) {
        if ($_ =~ m/^[A-Z]/) { push @Super_Class_Method, $_; } else { push @Super_Method, $_; }
      }
    
      if ($#Super_Class_Method >= 0) {
  
        print FILE "\n\n=over 4\n\nThe following class methods are inherited from L<$superClass>:\n";
        my $list = join '>, B<', @Super_Class_Method;
        $list = 'B<' . $list . '>.' if $list;
        print FILE $list;
        print FILE " \n\n=back\n\n";
      }
  
    }
    print FILE "=back\n\n";
  
    print FILE "\n\n=head2 INHERITED INSTANCE Methods\n\n"; 
    print FILE "=over 4\n\n"; 
  
    foreach my $superClass (@keys) {
  
      my @Super_Method = (); 
      my @Super_Class_Method = (); 
  
      for (@{$SuperClassHash{$superClass}}) {
        if ($_ =~ m/^[A-Z]/) { push @Super_Class_Method, $_; } else { push @Super_Method, $_; }
      }
  
      if ($#Super_Method >= 0) {
        print FILE "\n\n=over 4\n\n$packagename\:\:$ClassName inherits the following instance (object) methods of L<$superClass>:\n";
        my $list = join '>, B<', @Super_Method;
        $list = 'B<' . $list . '>.' if $list;
        print FILE $list;
        print FILE "\n\n=back\n\n";
      }
  
    }
    print FILE "=back\n\n";
  
  }
  print FILE "=back\n\n"; # end of method section
  
  for (@AddSection) {
    print FILE "=head1",$_->{'name'}," \n\n";
    print FILE "\n\n=over 4\n\n";
    print FILE $_->{'text'};
    print FILE "\n\n=back\n\n";
  }
  
  print FILE "=head1 SEE ALSO\n\n";
  print FILE "\n\n=over 4\n\n";
  if ($#IncludeObject >= 0) {
    my $string = join '>, L<', @IncludeObject;
    $string = 'L<' . $string . '>';
    print FILE $string;
  }
  print FILE "\n\n=back\n\n";
  
  print FILE "=head1 AUTHOR\n\n"; 
  print FILE $Class_Author if defined $Class_Author;
  print FILE " \n\n";
  
  print FILE "=cut\n";
  
  close FILE;
  
  # now overwrite original w/ tmp
  rename("tmp", $file);

}
  
sub deal_with_superClass {
     my ($name) = @_;
  
     $SuperClassHash{$name} = ();
     @More_SuperClass = ();
  
     my $file = $name;
  
     next unless $file =~ m/$packagename\:\:/;
     $file =~ s/$packagename\:\://;
  
     open (SUPERFILE, "$file.pm") or die "Cant open $file.pm\n";
  
   # other methods
     while (<SUPERFILE>) {
  
       chomp;
  
       # object that is its super class
       if ($_ =~ m/^\@ISA/) {
         my $item = $';
         $item =~ s/^.*?\"//;
         $item =~ s/\".*?$//;
  
         push @More_SuperClass, $item;
  
       }
  
       if ($_ =~ m/^sub\s+/) {
         my $item = $';
  
         $item =~ s/\s(.*?)$//;
  
         next unless $item =~ m/[^A-Z]/;
         next unless $item !~ m/^\_/;
         next unless $item !~ m/^class[A-Z]/;
  
         push @{$SuperClassHash{$name}}, $item unless exists $Native_Method{$item};
  
         $Native_Method{$item} = 1;
         $gotAMethod = 1;
       }
  
       last if m/^1;\s*?$/;

     }

     close SUPERFILE;

     return @More_SuperClass;
}

sub remove_POD_from_module {
  my ($file) = @_;

  open (FILE, $file);
  open (TMPFILE, ">tmp");

  while (<FILE>) { 
    print TMPFILE $_;
    last if /^\s*1;\s*?$/;
  }

  close TMPFILE;
  close FILE;

}

