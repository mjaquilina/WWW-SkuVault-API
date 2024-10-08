use 5.008006;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'WWW::SkuVault::API',
    VERSION_FROM      => 'lib/WWW/SkuVault/API.pm', # finds $VERSION
    PREREQ_PM         => { 'HTTP::Request::Common' => 0, 'JSON' => 0, 'LWP::UserAgent' => 0, 'Time::HiRes' => 0 },
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/WWW/SkuVault/API.pm', # retrieve abstract from module
       AUTHOR         => 'Michael Aquilina <aquilina@cpan.org>') : ()),
);


