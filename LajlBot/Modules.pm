#!/usr/bin/perl -w
package LajlBot::Modules;

use Data::Dumper;
use Carp;
use strict;

sub new {
  my $that = shift;
  my $class = ref($that) || $that;
  my $dir = $class;
  $dir =~ s/.*://;
  opendir(DIR, 'LajlBot/Modules');
  my @FILES = readdir(DIR);
  my $self = {
    modules => [],
  };
  my $module;
  foreach my $file (@FILES) {
      if($file =~ /^[^\.].+\.pm$/) {
        $file =~ s/\.pm$//;
        eval "use LajlBot::Modules::$file";
        $module = eval("LajlBot::Modules::$file->new()");
        if($module) {
          push(@{$self->{modules}}, $module);
        } else {
          print "Failed to initialize module: $file\n";;;;
        }
        # $file->new();
      }
  }
  bless ($self, $class);
  print "LajlBot::Modules instance created\n";
  return $self;
}

return 1;
