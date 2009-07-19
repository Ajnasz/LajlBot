#!/usr/bin/perl -w

package LajlBot::Modules::Help;

use strict;


sub new {
  my $proto = shift;
  my $class = ref($proto) || $proto;
  my $self = {
    commands => ['help'],
    module_description => 'Help stuff',
    module_name => 'Help',
  };
  bless ($self, $class);
  return $self;
}

sub action {
  my ($self, $command, $bot) = @_;
  my $output = '';
  for my $module (@{$bot->{modules}->{modules}}) {
    $output .= "\n" . $module->{module_name};
    $output .= "\n    " . join(', ', @{$module->{commands}});
    $output .= "\n    " . $module->{module_description};
  }
  return $output;
}

1;
