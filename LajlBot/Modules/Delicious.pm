#!/usr/bin/perl -w

package LajlBot::Modules::Delicious;

use Data::Dumper;
use Net::Delicious;
use Log::Dispatch::Screen;
use Encode;
use strict; 


sub new {
  my $proto = shift;
  my $class = ref($proto) || $proto;
  my $self = {
    commands => ['bookmark'],
    module_description => 'Bookmark management with delicious',
    module_name => 'Delicious',
  };
  bless($self, $class);
  return $self;
}

sub action {
  my $self = shift;
  my ($command, $bot) = @_;

  my @output;
  print 'create new delicious instance';
  my $del = Net::Delicious->new($bot->{config});
  print Dumper $del;
  foreach my $p ($del->recent_posts()) {
    #print Dumper($p);

    push(@output, encode('iso8859-2', $p->href() . ' -> ' .$p->description()));
  }
  return join("\n", @output);
}

1;
