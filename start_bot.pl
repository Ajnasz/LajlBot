#!/usr/bin/perl -w

use LajlBot;

print "start\n";
my $ize = LajlBot->new();
$ize->connect();
print "connected\n";
$ize->start();
# print "started";
# use Data::Dumper;
# print Dumper $ize;
