#!/usr/bin/perl -w

use LajlBot;

print "start\n";
my $bot = LajlBot->new({config => '/home/ajnasz/.lajlbotconf.ini'});
$bot->set('port', 6668);
$bot->connect();
print "connected\n";
$bot->start();
# print "started";
# use Data::Dumper;
# print Dumper $ize;
