#!/usr/bin/perl -w

package LajlBot::Modules::Ping;

use strict;


sub new {
  my $proto = shift;
  my $class = ref($proto) || $proto;
  my $self = {
    commands => ['ping'],
    module_description => 'Ping stuff',
    module_name => 'Ping',
  };
  bless ($self, $class);
  return $self;
}

sub action {
  return 'pong';
}

1;
