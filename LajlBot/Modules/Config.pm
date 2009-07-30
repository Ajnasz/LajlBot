#!/usr/bin/perl -w

package LajlBot::Modules::Config;

use 5.10.0;
use Data::Dumper;
use strict; 

sub new {
  my $proto = shift;
  my $class = ref($proto) || $proto;
  my $self = {
    commands => ['trust', 'set', 'unset', 'distrust'],
    module_description => 'Configuring the bot',
    module_name => 'Delicious',
  };
  bless($self, $class);
  return $self;
}


sub action {
  my $self = shift;
  my ($command, $text, $event, $bot, $msg) = @_;

  Config::Simple->import_from('botconf.ini', $bot->{config});
  $self->{config} = Config::Simple->new('botconf.ini');
  my $output = '';
  if(grep(/^$event->{nick}$/, $self->{config}->param('botconf.trust'))) {
    given($command) {
      when('trust') {
        
      }
      when('distrust') {
      }
      when('set') {
        given($text) {
          when('notice') {
              $bot->{config}->{'lajlbot.sendnotice'} = 1;
              $self->{config}->{'lajlbot.sendnotice'} = 1;
              $output = 'messages will be sended as notice';
          }
          when('nonotice') {
              $bot->{config}->{'lajlbot.sendnotice'} = 0;
              $self->{config}->{'lajlbot.sendnotice'} = 0;
              $output = 'messages will be sended as message';
          }
        }
      }
      when('unset') {
      }
    }
  } else {
    return 'permission denied';
  }
  return $output;
}

1;
