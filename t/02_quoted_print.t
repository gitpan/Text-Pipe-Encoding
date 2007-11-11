#!/usr/bin/env perl

# ripped largely from MIME-Base64's t/ directory

use warnings;
use strict;
use Text::Pipe;
use Test::More tests => 74;

my $x70 = "x" x 70;

my @tests = (
   # plain ascii should not be encoded
   ["", ""],
   ["quoted printable"  =>
    "quoted printable=\n"],

   # 8-bit chars should be encoded
   ["v\xe5re kj\xe6re norske tegn b\xf8r \xe6res" =>
    "v=E5re kj=E6re norske tegn b=F8r =E6res=\n"],

   # trailing space should be encoded
   ["  " => "=20=20=\n"],
   ["\tt\t" => "\tt=09=\n"],
   ["test  \ntest\n\t \t \n" => "test=20=20\ntest\n=09=20=09=20\n"],

   # "=" is special an should be decoded
   ["=30\n" => "=3D30\n"],
   ["\0\xff0" => "=00=FF0=\n"],

   # Very long lines should be broken (not more than 76 chars)
   ["The Quoted-Printable encoding is intended to represent data that largly consists of octets that correspond to printable characters in the ASCII character set." =>
    "The Quoted-Printable encoding is intended to represent data that largly con=
sists of octets that correspond to printable characters in the ASCII charac=
ter set.=\n"
    ],

   # Long lines after short lines were broken through 2.01.
   ["short line
In America, any boy may become president and I suppose that's just one of the risks he takes. -- Adlai Stevenson" =>
    "short line
In America, any boy may become president and I suppose that's just one of t=
he risks he takes. -- Adlai Stevenson=\n"],

   # My (roderick@argon.org) first crack at fixing that bug failed for
   # multiple long lines.
   ["College football is a game which would be much more interesting if the faculty played instead of the students, and even more interesting if the
trustees played.  There would be a great increase in broken arms, legs, and necks, and simultaneously an appreciable diminution in the loss to humanity. -- H. L. Mencken" =>
    "College football is a game which would be much more interesting if the facu=
lty played instead of the students, and even more interesting if the
trustees played.  There would be a great increase in broken arms, legs, and=
 necks, and simultaneously an appreciable diminution in the loss to humanit=
y. -- H. L. Mencken=\n"],

   # Don't break a line that's near but not over 76 chars.
   ["$x70!23"       => "$x70!23=\n"],
   ["$x70!234"      => "$x70!234=\n"],
   ["$x70!2345"     => "$x70!2345=\n"],
   ["$x70!23456"    => "$x70!23456=\n"],
   ["$x70!234567"   => "$x70!2345=\n67=\n"],
   ["$x70!23456="   => "$x70!2345=\n6=3D=\n"],
   ["$x70!23\n"     => "$x70!23\n"],
   ["$x70!234\n"    => "$x70!234\n"],
   ["$x70!2345\n"   => "$x70!2345\n"],
   ["$x70!23456\n"  => "$x70!23456\n"],
   ["$x70!234567\n" => "$x70!2345=\n67\n"],
   ["$x70!23456=\n" => "$x70!2345=\n6=3D\n"],

   # Not allowed to break =XX escapes using soft line break
   ["$x70===xxxxx"  => "$x70=3D=\n=3D=3Dxxxxx=\n"],
   ["$x70!===xxxx"  => "$x70!=3D=\n=3D=3Dxxxx=\n"],
   ["$x70!2===xxx"  => "$x70!2=3D=\n=3D=3Dxxx=\n"],
   ["$x70!23===xx"  => "$x70!23=\n=3D=3D=3Dxx=\n"],
   ["$x70!234===x"  => "$x70!234=\n=3D=3D=3Dx=\n"],
   ["$x70!2=\n"     => "$x70!2=3D\n"],
   ["$x70!23=\n"    => "$x70!23=\n=3D\n"],
   ["$x70!234=\n"   => "$x70!234=\n=3D\n"],
   ["$x70!2345=\n"  => "$x70!2345=\n=3D\n"],
   ["$x70!23456=\n" => "$x70!2345=\n6=3D\n"],
   #                              ^
   #                      70123456|
   #                             max
   #                          line width

   # some extra special cases we have had problems with
   ["$x70!2=x=x" => "$x70!2=3D=\nx=3Dx=\n"],
   ["$x70!2345$x70!2345$x70!23456\n", "$x70!2345=\n$x70!2345=\n$x70!23456\n"],

   # trailing whitespace
   ["foo \t ", "foo=20=09=20=\n"],
   ["foo\t \n \t", "foo=09=20\n=20=09=\n"],
);

my $enc_pipe = Text::Pipe->new('Encoding::QuotedPrint::Encode');
my $dec_pipe = Text::Pipe->new('Encoding::QuotedPrint::Decode');

for (@tests) {
    my ($plain, $expected) = @$_;
    my $encoded = $enc_pipe->filter($plain);
    is($encoded, $expected, "encoded ($plain)");
    is($dec_pipe->filter($encoded), $plain, "decoded ($encoded)");
}

__END__
for my $test
$notests = @tests + 16;
print "1..$notests\n";

$testno = 0;
for (@tests) {
    $testno++;
    ($plain, $encoded) = @$_;
    if (ord('A') == 193) {  # EBCDIC 8 bit chars are different
        if ($testno == 2) { $plain =~ s/\xe5/\x47/; $plain =~ s/\xe6/\x9c/g; $plain =~ s/\xf8/\x70/; }
        if ($testno == 7) { $plain =~ s/\xff/\xdf/; }
    }
    $x = encode_qp($plain);
    if ($x ne $encoded) {
    print "Encode test failed\n";
    print "Got:      '$x'\n";
    print "Expected: '$encoded'\n";
    print "not ok $testno\n";
    next;
    }
    $x = decode_qp($encoded);
    if ($x ne $plain) {
    print "Decode test failed\n";
    print "Got:      '$x'\n";
    print "Expected: '$plain'\n";
    print "not ok $testno\n";
    next;
    }
    print "ok $testno\n";
}
