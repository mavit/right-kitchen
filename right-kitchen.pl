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
foreach my $link_node ( $rss->findnodes('//item/link') ) {
    my $printed = 0;

    my $html = XML::LibXML->load_html(
        'location' => $link_node->textContent,
        'recover' => 1,
        'encoding' => 'Windows-1252',	# FIXME: override only ISO-8859-1.
    );
    foreach my $p (
        $html->findnodes('//div[@class="propertyDetailDescription"]/p')
    ) {
        if ( $p =~ m/kitchen.+(\d+\.\d+)\s*m(?:etres?)?\s*\S?\s*(\d+\.\d+)\s*m(?:etres?)?/i ) {
            my ($x, $y) = ($1, $2);
            print $x * $y, " m² (${x} m × ${y} m)\n";

            my $desc = $html->findnodes('//div[@id="propertyAddress"]')
                ->[0]->textContent;
            $desc =~ s/^\s*//mg;
            print $desc, $link_node->textContent, "\n\n";
            $printed = 1;
        }
    }

    print "FIXME: Didn't find a kitchen for ", $link_node->textContent, "\n\n"
        unless $printed;
}
