# TrAML
TrAML (Transparent Analogical Modeling of Language) is a graphical user interface for PERL 5 that uses the PERL-CLI of Algorithm::AM (https://github.com/garfieldnate/Algorithm-AM). Algorithm::AM (Skousen, Stanford &amp; Glenn 2013) is a computational implementation of Analogical Modeling theory (Analogical Modeling of Language; Skousen 1989 et seq., Skousen et al. eds. 2002).

# Developing

## Dependencies

This project is written in Perl 5. If you are on Windows, we recommend using [Strawberry Perl](https://strawberryperl.com/) (or [berrybrew](https://github.com/dnmfarrell/berrybrew)). Otherwise, use [Perlbrew](https://perlbrew.pl/).

Next, you should install [Carton](https://metacpan.org/pod/Carton), which will provide the dependency management.

If you are using Mac OS, you should install wxwidgets; the easiest method to do this is using [homebrew](https://brew.sh/):

    brew install wxmac

Finally, use `carton` to install all of the Perl depenencies in the local directory:

    carton install

## Running

To run the application, use `carton`:

    carton exec perl TrAML.pl

## Building an Executable

An executable can be built using [Par::Packer](https://metacpan.org/pod/PAR::Packer).

TODO
