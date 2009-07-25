#!/usr/bin/perl -w

package LajlBot;

use 5.10.0;
use Net::IRC;
use Data::Dumper;
use LajlBot::Modules;
use File::Basename;
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
  my $lajl_conf = Config::Simple->new($conf);
  my $self = {
    botname => $botname,
    server => 'localhost',
    port => '6667',
    nick => $botname,
    ircname => $botname,
    username => $botname,
    channel => '#test',
    modules => LajlBot::Modules->new(),
    config => $lajl_conf,
  };


  # if ($args->{config}) {
  #   $conf = $args->{config} 
  # }
  # my $config = Config::Simple->new($conf),
  # my $self = {
  #   botname => $config->{lajlbot}->{botname},
  #   server => $config->{lajlbot}->{server},
  #   port => $config->{lajlbot}->{port},
  #   nick => $config->{lajlbot}->{botname},
  #   ircname => $config->{lajlbot}->{botname},
  #   username => $config->{lajlbot}->{botname},
  #   channel => $config->{lajlbot}->{channel},
  #   modules => LajlBot::Modules->new(),
  #   config => $config,
  # };

  
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
sub getcommand {
  my ($self, $text) = @_;
  my $botname = $self->{botname};
	if ($text =~ /^(?:[`,!]|$botname:? ?)([^ ]+)/) {
    return $1;
  } else {
    return 0;
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

sub on_private {
  my ($self, $conn, $event) = @_;
	my $text = $event->{args}[0];
  print $text;
}
sub on_public {
  my ($self, $conn, $event) = @_;
	my $text = $event->{args}[0];
  my $command = $self->getcommand($text);
  print "\ncommand $command\n";
	if ($command) {
    my $out = '';
    for my $module (@{$self->{modules}->{modules}}) {
      # print 'commands: ', Dumper($module);
      if(grep(/^$command$/, @{$module->{commands}})) {
        $out = $module->action($text, $self);
        last;
      }
    }
    if($out) {
      # wrap text at 400 chars (about as much as you should put
      # into a single IRC message
      # my @texts = split("\n", $out);
      # my $str = '';
      $out = substr($out, 400);
      $conn->privmsg($event->{to}[0], $out);
      # $event->{to}[0] is the channel where this was said
      # foreach (@texts) {substr($_, 300);
      #   $conn->privmsg($event->{to}[0], $_);
      # }
    }
	}
}

sub start {

  my $self = shift;
  #print Dumper $self;
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
  $self->{connection}->add_handler('private', sub {
      my ($conn, $event) = @_;
      $self->on_private($conn, $event);
    }
  );

# start IRC
  $self->{irc}->start();
}

return 1;
