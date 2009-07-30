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
  my ($command, $text, $event, $bot) = @_;

  my @output;
  warn 'delicious command: ', $command, "\ntext: $text\n";
  my $delicious = Net::Delicious->new({user => $bot->{config}->{'delicious.user'}, pswd => $bot->{config}->{'delicious.pswd'}});
  foreach my $post ($delicious->all_posts_for_tag({tag => $text})) {
    #print Dumper($p);

    push(@output, encode('iso8859-2', $post->href() . ' -> ' .$post->description()));
  }
  return "found " . @output ." results\n" . join("\n", @output);
}

1;
