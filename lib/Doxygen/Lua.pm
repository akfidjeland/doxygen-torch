package Doxygen::Lua;

use warnings;
use strict;

=head1 NAME

Doxygen::Lua - Make Doxygen support Lua

=head1 VERSION

Version 0.04

=cut

our $VERSION = '0.04';

=head1 SYNOPSIS

    use Doxygen::Lua;
    my $p = Doxygen::Lua->new;
    print $p->parse($input);

=head1 DESCRIPTION

A script named "lua2dox" will be installed. Then modify your Doxyfile as below:

    FILTER_PATTERNS = *.lua=../bin/lua2dox

That's all!

=head1 SUBROUTINES/METHODS

=head2 new

This function will create a Doxygen::Lua object.

=cut

sub new {
    my ($class, %args) = @_;
    my $self = bless \%args, $class;
    $self->_init;
    return $self;
}

sub _init {
    my $self = shift;
    $self->{mark} = '--!';
}

=head2 parse

This function will parse the given input file and return the result.

=cut

sub parse {
    my $self = shift;
    my $input = shift;

    my $in_block = 0;
    my $in_ml_comment = 0;
    my $in_function = 0;
    my $in_verbatim = 0;
    my $in_var = 0;
    my $verbatim_name = q{};
    my $block_name = q{};
    my $result = q{};
    my %classes = ();

    my $mark = $self->mark;
     
    open FH, "<$input"
        or die "Can't open $input for reading: $!";
     
    foreach my $line (<FH>) {
        chomp $line;

        # detect beginning of code/verbatim block
        if ($line =~ /\@(code|verbatim)/) {
            $verbatim_name = "\@end$1";
            $in_verbatim = 1;
        }

        # detect end of code/verbatim block
        if ($in_verbatim == 1 and $line =~ /$verbatim_name/) {
            $verbatim_name = q{};
            $in_verbatim = 0;
        }

        # detect beginning of multiline comment
        if ($line =~ /--\[\[\!/) {
            $in_ml_comment = 1;
            $line =~ s{--\[\[\!}{}
        }

        if ($in_ml_comment == 1) {
            $line = '/// ' . $line;
            if ($line =~ /\]\]/) {
                $in_ml_comment = 0;
                $line =~ s{(--)?\]\]}{}
            }
        } else {
            # include empty lines
            if ($line =~ m{^\s*$}) {
                $result .= "\n"
            }
        }

        if ($in_verbatim == 0) {
            # skip normal comments
            next if $line =~ /^\s*--[^!]/;
            # remove end of line comments
            $line =~ s/--[^!].*//;
        }

        # skip comparison
        next if $line =~ /==/;
        if ($in_verbatim == 0) {
            # translate to doxygen mark
            $line =~ s{$mark}{///};
        }

        # detect @var
        if ($line =~ /\/\/\/\s*\@var/) {
            $in_var = 1;
        }

        if ($line =~ m{^\s*///}) {
            $result .= "$line\n";
        }

        # torch class
        elsif ($line =~ /torch\.class\(['"](\S+\.)?(\S+?)['"]\)/) {
            my $namespace = $1;
            my $class = $2;
            $classes{$class} = 1;
            $line = "";
            if ($namespace) {
                $namespace = substr($namespace, 0, -1);
                $line = "/// \@ingroup $namespace\n" . $line;
            }
            $line = "/// \@class $class\n" . $line;
            $result .= "$line\n";
        }

        # member function start
        elsif ($line =~ /^function\s*(\S*):(\S*)\((.*)\)\s*$/) {
            my $class = $1;
            my $fn = $2;
            my $args = $3;
            if ($args) {
                $args = ', ' . $args
            }
            $in_function = 1;
            $line = "/// \@memberof $class\nfunction $class-$fn(self$args);";
            $result .= "$line\n";
        }

        # function start
        elsif ($line =~ /^function\s*([^(]+?\.)?/) {
            # add package/class membership.
            # extraneous @ingroup directives have no effect.
            my $group = $1;
            if ($group) {
                $group = substr($group, 0, -1);
                my $static = $classes{$group};
                my $grouptype = $static ? 'memberof' : 'ingroup';
                $line = "/// \@$grouptype $group\n" . $line;
            }
            $in_function = 1;
            $line .= q{;};
            $line =~ s/:/-/;
            $result .= "$line\n";
        }
        #local function start
        elsif ($line =~ /^local.+function/) {
            $in_function = 1;
            $line .= q{;};
            $line =~ s/function\s+/function-/;
            $result .= "$line\n";
        }
        # function end
        elsif ($in_function == 1 && $line =~ /^end/) {
            $in_function = 0;
        }
        # block start
        elsif ($in_function == 0 && $line =~ /^(\S+)\s*=\s*{/ && $line !~ /}/) {
            $block_name = $1; 
            $in_block = 1;
        }
        # block end
        elsif ($in_function == 0 && $line =~ /^\s*}/ && $in_block == 1) {
            $block_name = q{};
            $in_block = 0;
        }

        elsif ($in_var == 1 && ($line =~ /=/ || $line =~ /^\s*local\s/)) {
            $in_var = 0;
            $line =~ s/(?=\S)/$block_name./ if $block_name;
            $line =~ s{,?(\s*)(?=///|$)}{;$1};
            $result .= "$line\n";
        }
    }

    close FH;
    return $result;
}

=head2 mark

This function will set the mark style. The default value is "--!".

=cut

sub mark {
    my ($self, $value) = @_;
    $self->{mark} = $value if $value;
    return $self->{mark};
}

=head1 AUTHOR

Alec Chen, C<< <alec at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-doxygen-lua at rt.cpan.org>, or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Doxygen-Lua>.  I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Doxygen::Lua

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Doxygen-Lua>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Doxygen-Lua>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Doxygen-Lua>

=item * Search CPAN

L<http://search.cpan.org/dist/Doxygen-Lua/>

=back

=head1 ACKNOWLEDGEMENTS

=head1 REPOSITORY

See http://github.com/alecchen/doxygen-lua

=head1 LICENSE AND COPYRIGHT

Copyright 2010 Alec Chen.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1; # End of Doxygen::Lua
