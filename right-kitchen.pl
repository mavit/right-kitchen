#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use open ':locale';

use LWP::UserAgent;
use XML::LibXML;
use Data::Dumper;

my $rss_url = shift;
my $rss = XML::LibXML->load_xml(
    'location' => $rss_url,
);

foreach my $link_node (
    $rss->findnodes('//item[category[text() != "Rightmove Search"]]/link')
) {
    my @report = ();
    my $html = XML::LibXML->load_html(
        'location' => $link_node->textContent,
        'recover' => 1,
        'encoding' => 'Windows-1252',	# FIXME: override only ISO-8859-1.
    );

    foreach my $detail (
        $html->findnodes('//div[@class="propertyDetailDescription"]')
    ) {
        if ( $detail =~ m/.*(?:^|>)(.*?kitchen[^<]{0,12}(?:[\s\d[:punct:]x]|yds|(?:min|max)(?:imum)?|<[^>]*>)*?(\d+(?:\.\d+)?)\s*m(?:etres?)?(?:[\s\d[:punct:]x]|yds|(?:min|max)(?:imum)?)*?(\d+(?:\.\d+)?)\s*m(?:etres?)?)/im ) {
            my ($text, $x, $y) = ($1, $2, $3);
            push @report, $x * $y. " m²\t($text)\n";
        }
    }
    
    my $desc = $html->findnodes('//div[@id="propertyAddress"]')
        ->[0]->textContent;
    $desc =~ s/^\s*//mg;

    print(
        $desc,
        (@report ? @report : "Couldn't find a kitchen.\n"),
        $link_node->textContent,
        "\n\n"
    );
}
