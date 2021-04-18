requires 'Algorithm::AM', '>= 3.12, <4.0';
requires 'Class::Adapter::Builder', '>=1.09, <2.0';
requires 'Class::XSAccessor', '<=1.19, <2.0';
requires 'Data::Dumper', '>=2.173, <3.0';
requires 'File::Slurp', '>=9999.32, <10000.0';
requires 'File::Spec', '>= 3.75, <4.0';
requires 'Path::Class', '>=0.37, <1.0';
requires 'Text::CSV', '>= 1.95, <2.0'; # TODO: update to 2.0
requires 'Path::Tiny', '>= 0.104, <1.0';
requires 'Text::Diff', '>= 1.45, <2.0';
requires 'Text::Glob', '>= 0.11, <1.0';
requires 'Text::Patch', '>= 1.8, <2.0';
requires 'Text::Soundex', '>= 3.05, <4.0';
requires 'Try::Tiny', '>= 0.30, <1.0';
requires 'Unicode::LineBreak', '2019.001';
# wxwidgets must already be installed
requires 'Wx', '>= 0.9932, < 1.0';
requires 'Wx::Perl::Packager', '>= 0.27, <1.0';

on 'develop' => sub {
    requires 'PAR::Packer', '>=1.052, <2.0';
}
