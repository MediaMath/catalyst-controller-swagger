use ExtUtils::MakeMaker;

WriteMakefile(
        NAME          => "Catalyst::Controller::Swagger",
        AUTHOR        => 'Logan Bell <logie@cpan.org>',
        VERSION_FROM  => "lib/Catalyst/Controller/Swagger.pm",
        LICENSE       => "perl_5",
        TEST_REQUIRES => {
                "Test::Deep" => 0,
                "Test::More" => 0,
        },
        PREREQ_PM     => {
                "Catalyst"      => 0,
                "JSON::XS"      => 0,
                "Sub::Exporter" => 0,
        }
);

