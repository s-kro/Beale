#!/usr/bin/perl

use strict;
use warnings;
use 5.30.1;
#use utf8;

#steve was here

use HTTP::Tiny;
use Data::Dumper qw(Dumper);

use lib './lib';

use Beale::B_Data 0.01 qw(get_beale_cyphertexts get_decl_of_ind);

my $url  = 'https://www.gutenberg.org/files/158/158-0.txt';
my $url2 = 'https://www.gutenberg.org/cache/epub/105/pg105.txt';
my $url3 = 'https://www.gutenberg.org/cache/epub/1/pg1.txt';
my $url4 = 'https://www.gutenberg.org/files/16780/16780-0.txt';

my $response = HTTP::Tiny->new->get($url4);
if ($response->{success}) {
    while (my ($name, $v) = each %{$response->{headers}}) {
        for my $value (ref $v eq 'ARRAY' ? @$v : $v) {
            say "$name: $value";
        }
    }
    if (length $response->{content}) {
        say 'Length: ', length $response->{content};
	($response->{content}) = $response->{content} =~ m/thirteen united States of America(.*)/s;
#	say 'Length2: ', length $response->{content}, ',' , $1;

	#$response->{content} = &get_decl_of_ind;
	say 'Length2: ', length $response->{content}, ", \n" , $response->{content};


	#$response->{content} =~ s/CHAPTER .*//g;
	$response->{content} =~ s/
	    (?<=\w)    # a pos look-behind with a char: 
	    -          # a dash, literal 
	    (?=\w)     # a pos look-ahead  with a char: 
	    / /gx ; # self-evident is two words
	$response->{content} =~ s/
	    (?<=\w)    # a pos look-behind with a char: 
	    '|’          # an apostrophe, literal 
	    (?=\w?)     # a pos look-ahead  with a char:
	    //gx ;
	
	$response->{content} =~ s/[^a-zA-Z1-9\r\n]/ /g;
	
#        print $response->{content};
#	delete $response->{content};
    }
#    print "\n";
#    print Dumper $response;
}

else {
    say "Failed: $response->{status} $response->{reasons}";
}

#    after word 154 ("institute") and before word 157 ("laying") one word must be added (probably "a")
#    after word 240 ("invariably") and before word 246 ("design") one word must be removed
#    after word 467 ("houses") and before word 495 ("be") ten words must be removed
#    after word 630 ("eat") and before word 654 ("to") one word must be removed
#    after word 677 ("foreign") and before word 819 ("valuable") one word must be removed

#    The first letter of the 811th word of the modified text ("fundamentally") is always used by Beale as a "y"
#    The first letter of the 1005th word of the modified text ("have") is always used by Beale as an "x"


foreach my $ct_ref (&get_beale_cyphertexts)
{
    my $text = '';
    foreach my $ct (@{$ct_ref}) {
	if ($ct > 154 && $ct < 246) { $ct--; }
	if ($ct > 467) { $ct = $ct + 10; }
	if ($ct > 630) { $ct++;}
	if ($ct > 677) { $ct++;}
	my ($nth) = $response->{content} =~ /(?:\w+(?:'s)?\W+){@{[$ct - 1]}}(\w+(?:'s)?)/;
	# capture ct-th word
	#$text .= $nth =~ m/^\w/;
	#print $ct . '- ' . $nth . ', ' unless $nth;
	# in the first cyphertext, 1329, 1443 go into the signatories
	# all the rest:
	# 1713, 1641, 2030, 2172, 1792, 1508, 1829, 1718, 2918,
	# are out of range of even the signatories.
	# in the third cyph there are no 4 digit numbers
	my ($t) = $nth ? $nth =~ /(^\w)/ : (' '); # 1,322 words 7,986 characters
	if  ($ct > 1322) { $t = ' ';}
	if ($ct == (811 + 12)) {$t = 'y'}
	if ($ct == (1005 + 12)) {$t = 'x'}
	$text .= lc $t;

    }
    print "\n" . $text;
    print "\n\n";
}
#For natural language processing (so that, for example, apostrophes are included in words), use instead \b{wb}

#        "don't" =~ / .+? \b{wb} /x;  # matches the whole string
