#!/usr/bin/perl

=head1 NAME

B<right-kitchen> - Filter I<Rightmove> listings by room size

=head1 SYNOPSIS

B<right-kitchen.pl> I<RSS location>

=head1 DESCRIPTION

Print a summary of properties advertised on L<http://www.rightmove.co.uk/>
that includes the area and dimensions of the kitchen.

This is a hack.

=cut

use strict;
use warnings;
use utf8;
use open ':locale';

use Getopt::Long;
use XML::LibXML;

sub pod2usage {
    require Pod::Usage;
    return Pod::Usage::pod2usage(@_);
}

my %opt;
GetOptions(
    'help|h' => \$opt{'help'},
    'man' => \$opt{'man'},
) or pod2usage( '-verbose' => 0 );
pod2usage( '-verbose' => 1 ) if $opt{'help'};
pod2usage( '-verbose' => 2 ) if $opt{'man'};
pod2usage( '-verbose' => 0 ) unless @ARGV == 1;

my $rss_url = shift;
my $parser = XML::LibXML->new();
my $rss = $parser->parse_file($rss_url);

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

__END__

=head1 OPTIONS

=over 4

=item I<RSS location>

The URL or filename of a Rightmove search RSS feed.

=item B<-h>, B<--help>

Displays brief help.

=item B<--man>

Displays the full manual.

=back

=head1 AUTHOR

Peter Oliver

=head1 BUGS

See L<https://github.com/mavit/right-kitchen/issues>.

=head1 LICENCE

Copyright 2013, Peter Oliver.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

=head1 SEE ALSO

L<https://github.com/mavit/right-kitchen>, L<http://www.rightmove.co.uk/>
