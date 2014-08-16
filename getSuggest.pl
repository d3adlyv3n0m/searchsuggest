#!/usr/bin/perl
#
# -- getSuggests.pl
#
# -- script to access google and retrieve the full list
# -- of the given search suggestions
# 
# -- D3adlyV3n0m -> d3adlyv3n0m AT gmx.com
#

use strict;
use LWP::UserAgent;
use HTTP::Request;
use XML::Simple;
use Term::ANSIColor qw(:constants);
$Term::ANSIColor::AUTORESET = 1;

# create the user agent instance
my $ua = LWP::UserAgent->new();

# create a browser-like user agent
# i.e. pretend to be the camino web 
# browser
$ua->agent("Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en; rv:1.9.2.14pre) Gecko/20101212 Camino/2.1a1pre (like Firefox/3.6.14pre)");

# clear the screen and display our banner
print "\033[2J";
print "\033[0;0H";
print BOLD CYAN UNDERLINE "GOOGLE SEARCH SUGGESTION LISTER\n\n";
sleep(2);

# get the starting search phrase
print BOLD CYAN "Enter the partial search phrase:\n";
print BOLD CYAN "> ";
chomp(my $srch_phrase = <STDIN>);

# set the base url
my $base_url = "http://google.com/complete/search?output=toolbar&q=";

# format search phrase before appending to base url
$srch_phrase =~ s/ /+/g;

# format the request
my $req = HTTP::Request->new("GET" => $base_url . $srch_phrase);
$req->header("Accept" => "text/html");

# send the request 
my $result = $ua->request($req);

# make sure request was sent successfully and store the 
# content. exit if there was an issue
my $xml_content;
if($result->is_success) {
    $xml_content = $result->decoded_content;
} else {
    print "Error: " . $result->status_line . "\n";
    exit(1);
}

# create an xml instance and store the content in a 
# file 
my $xs = XML::Simple->new();
my $content = XMLin($xml_content);
my @xml = $xs->XMLout($content);
my $xmlout = "/tmp/xml.out";
if(@xml) {
    open(XMLOUT, ">$xmlout") or die;
    foreach my $resp (@xml) {
        print XMLOUT "$resp\n";
    }
    close(XMLOUT);
} else {
    print BOLD RED "ERROR: No data returned from search.!\n";
    exit(1);
}

# re-open the file and parse out suggestions
$srch_phrase =~ s/\+/ /g;
print BOLD YELLOW "\nFull list of Google suggestions for: [ $srch_phrase ]\n";
open(XMLIN, "<$xmlout") or die; 
while(<XMLIN>) {
    if($_ =~ /<opt><\/opt>/) {
        print BOLD RED "No results found.\n";
        last;
    }
    if($_ =~ /.*data=\"(.*)\".*/) {
        print BOLD WHITE "$1\n";
    }
}
close(XMLIN);

# done
unlink($xmlout);
exit(0);
