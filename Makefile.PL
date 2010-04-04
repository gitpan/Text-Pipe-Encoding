
use strict;
use warnings;

 BEGIN { require 5.008; } 

use ExtUtils::MakeMaker 6.31;



my %WriteMakefileArgs = (
                       'test' => {
                                   'TESTS' => 't/*.t'
                                 },
                       'NAME' => 'Text::Pipe::Encoding',
                       'DISTNAME' => 'Text-Pipe-Encoding',
                       'CONFIGURE_REQUIRES' => {
                                                 'ExtUtils::MakeMaker' => '6.31'
                                               },
                       'AUTHOR' => 'Marcel Gruenauer <marcel@cpan.org>',
                       'BUILD_REQUIRES' => {
                                             'Scalar::Util' => '0',
                                             'English' => '0',
                                             'Encode' => '0',
                                             'Carp' => '0',
                                             'Test::More' => '0.88',
                                             'File::Find' => '0',
                                             'File::Temp' => '0',
                                             'Text::Pipe' => '0'
                                           },
                       'ABSTRACT' => 'Text pipes that can encode and decode in various ways',
                       'EXE_FILES' => [],
                       'VERSION' => '1.100950',
                       'PREREQ_PM' => {
                                        'parent' => '0',
                                        'MIME::Base64' => '3.09',
                                        'Text::Pipe::Base' => '0',
                                        'MIME::QuotedPrint' => '3.09'
                                      },
                       'LICENSE' => 'perl'
                     );


delete $WriteMakefileArgs{BUILD_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.56) };

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



