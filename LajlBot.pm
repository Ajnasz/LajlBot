#!/usr/bin/perl -w

package LajlBot;

use 5.10.0;
use Net::IRC;
use Data::Dumper;
use LajlBot::Modules;
use File::Basename;
use Config::Simple;
use strict;

my $lajlbot_dir = dirname $0;
sub new {
  my $proto = shift;
  my $args = shift;
  my $class = ref($proto) || $proto;
  my $botname = 'lajl';
  my $conf = (dirname $0) . '/lajlbot.ini';
  if ($args->{config}) {
    $conf = $args->{config} 
  }
  my $config = {};
  Config::Simple->import_from('lajlbot.ini', $config);
  Config::Simple->import_from($conf, $config);
  my $self = {
    botname => $config->{'lajlbot.name'} || $botname,
    server => $config->{'lajlbot.server'} || 'localhost',
    port => $config->{'lajlbot.port'} || '6667',
    nick => $config->{'lajlbot.nick'} || $botname,
    ircname => $config->{'lajlbot.ircname'} || $botname,
    username => $config->{'lajlbot.username'} || $botname,
    channel => $config->{'lajlbot.channel'} || '#test',
    modules => LajlBot::Modules->new(),
    config => $config,
  };


  
  bless($self, $class);
  print "LajlBot instance created\n";
  return $self;
}

# set properties
sub set {
  my $self = shift;
  
  my ($key,$value) = @_;
  given($key) {
    when ('botname') {
        $self->{bothname} = $value;
    }
    when ('server') {
        $self->{server} = $value;
    }
    when ('port') {
        $self->{port} = $value;
    }
    when ('nick') {
        $self->{nick} = $value;
    }
    when ('ircname') {
        $self->{ircname} = $value;
    }
    when ('username') {
        $self->{username} = $value;
    }
    when ('channel') {
        $self->{channel} = $value
    }
    default {
      print "Invalid key\n";
      exit 1;
    }
  }
}
sub get_command {
  my ($self, $text, $msg) = @_;
  my $botname = $self->{nick};
  if($msg) {
    if($text =~ /^(?:[`,!]|$botname:? ?)?([^ ]+)(?: (.*))?/) {
      return [$1, $2];
    }
  } else {
    if ($text =~ /^(?:[`,!]|$botname:? ?)([^ ]+)(?: (.*))?/) {
      return [$1, $2];
    } else {
      return 0;
    }
  }
}
sub connect {
  my $self = shift;
  $self->{irc} = new Net::IRC;
  $self->{connection} = $self->{irc}->newconn(
    Server 		=> $self->{server},
    Port		=> $self->{port},
    Nick		=> $self->{nick},
    Ircname		=> $self->{ircname},
    Username	=> $self->{username},
  );
}
sub on_connect {
  my ($self, $conn) = @_;
  $conn->join($self->{channel});
  $self->{connected} = 1;
  return 1;
}

sub on_join {
	my ($self, $conn, $event) = @_;
  return 1;
}


sub on_part {

	# pretty much the same as above

	my ($self, $conn, $event) = @_;

  # my $nick = $event->{nick};
  # $conn->privmsg($conn->{channel}, "Goodbye, $nick!");
  return 1;
}

sub run_command {
  my $self = shift;
  my ($conn, $event, $command) = @_;
  if(!$command) {return 0;}
  my ($com, $arg) = @$command;
 	if ($com) {
    my $out = '';
    for my $module (@{$self->{modules}->{modules}}) {
      print 'in for: ', $module;
      if(grep(/^$com$/, @{$module->{commands}})) {
        if($module->{privacy} && $module->{privacy} eq 'msg' && $event->{format} ne 'msg') {
          $out = "You can not use this command on public channel!";
        } else {
          if($arg) {$arg =~ s/^([`,!]|$self->{nick})?$com\s+//;}
          $out = $module->action($com, $arg, $event, $self);
        }
        last;
      }
    }
    if($out) {
      # wrap text at 400 chars (about as much as you should put
      # into a single IRC message
      my @texts = split("\n", $out);
      if(length($out) > 300) {
        $out = substr($out, 300);
      }
      # $event->{to}[0] is the channel where this was said
      my $str;
      foreach (@texts) {
        $str = $_;
        if(length($_) > 300) {
          $str = substr($_, 300);
        }
        my $dst = $event->{format} eq 'msg' ? $event->{nick} : $event->{to}[0];
        $self->{config}->{'lajlbot.sendnotice'} ? $conn->notice($dst, $_) : $conn->privmsg($dst, $_);
      }
    }
	}
}

sub on_msg {
  my $self = shift;
  my ($conn, $event) = @_;
	my $text = $event->{args}[0];
  my @command = $self->get_command($text, 1);
  $self->run_command($conn, $event, @command);
}
sub on_public {
  my ($self, $conn, $event) = @_;
	my $text = $event->{args}[0];
  my @command = $self->get_command($text);
  $self->run_command($conn, $event, @command);
}

sub start {

  my $self = shift;
  # add event handlers for join and part events
  $self->{connection}->add_handler('join', sub {
      my ($conn, $event) = @_;
      $self->on_join($conn, $event);
    }
  );
  $self->{connection}->add_handler('part', sub {
      my ($conn, $event) = @_;
      $self->on_part($conn, $event);
    }
  );

# The end of MOTD (message of the day), numbered 376 signifies we've connect
  $self->{connection}->add_handler('376', sub {
      my $conn = shift;
      $self->on_connect($conn);
    }
  );
  $self->{connection}->add_handler('public', sub {
      my ($conn, $event) = @_;
      $self->on_public($conn, $event);
    }
  );
  $self->{connection}->add_handler('msg', sub {
      my ($conn, $event) = @_;
      print "PRIVMSG";
      $self->on_msg($conn, $event);
    }
  );

# start IRC
  $self->{irc}->start();
}

return 1;
