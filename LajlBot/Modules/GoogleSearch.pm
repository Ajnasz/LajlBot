#!/usr/bin/perl -w

package LajlBot::Modules::GoogleSearch;

use REST::Google::Search;
use Encode;
use strict;


sub new {
  my $proto = shift;
  my $class = ref($proto) || $proto;
  my $self = {
    commands => ['g', 'google'],
    module_description => 'search on google',
    module_name => 'Google Search',
  };
  bless ($self, $class);
  return $self;
}

sub action {
  my $self = shift;
  my ($command, $text, $event, $bot) = @_;
  if($text eq '') {
    return 'no given search pattern';
  }

  REST::Google::Search->http_referer('http://google.com');
  my $google = REST::Google::Search->new(q=>$text, hl=>'en', num=>3);
  die "response status failure" if $google->responseStatus != 200;
  my @results = $google->responseData->results;
  # print Dumper @results;
  my @out;
  push(@out, 'searching for ' . $text);
  foreach my $r (@results) {
    # print $r->title;
    push(@out, encode('iso8859-2', $r->titleNoFormatting) . ' -> ' . $r->url);
  }
  return join("\n", @out);
}

1;
