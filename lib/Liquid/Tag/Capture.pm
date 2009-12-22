package Liquid::Tag::Capture;
{
    use strict;
    use warnings;
    our $VERSION = 0.001;
    use lib '../../../lib';
    use Liquid::Error;
    use Liquid::Utility;
    BEGIN { our @ISA = qw[Liquid::Tag]; }
    Liquid->register_tag('capture', __PACKAGE__) if $Liquid::VERSION;

    sub new {
        my ($class, $args, $tokens) = @_;
        raise Liquid::ContextError {message => 'Missing parent argument',
                                    fatal   => 1
            }
            if !defined $args->{'parent'};
        raise Liquid::SyntaxError {
                   message => 'Missing argument list in ' . $args->{'markup'},
                   fatal   => 1
            }
            if !defined $args->{'attrs'};
        if ($args->{'attrs'} !~ qr[^(\S+)\s*?$]) {
            raise Liquid::SyntaxError {
                       message => 'Bad argument list in ' . $args->{'markup'},
                       fatal   => 1
            };
        }
        my $self = bless {name          => 'c-' . $1,
                          nodelist      => [],
                          tag_name      => $args->{'tag'},
                          variable_name => $1,
                          end_tag       => 'end' . $args->{'tag'},
                          parent        => $args->{'parent'},
                          markup        => $args->{'markup'},
        }, $class;
        $self->parse({}, $tokens);
        return $self;
    }

    sub render {
        my ($self) = @_;
        my $var    = $self->{'variable_name'};
        my $val    = '';
        for my $node (@{$self->{'nodelist'}}) {
            my $rendering = ref $node ? $node->render() : $node;
            $val .= defined $rendering ? $rendering : '';
        }
        $self->resolve($var, $val);
        return '';
    }
}
1;

=pod

=head1 NAME

Liquid::Tag::Capture - Extended variable assignment construct

=head1 Synopsis

    {% capture triple_x %}
        {% for x in (1..3) %}{{ x }}{% endfor %}
    {% endcapture %}

=head1 Description

If you want to combine a number of strings into a single string and save it to
a variable, you can do that with the C<capture> tag. This tag is a block which
"captures" whatever is rendered inside it, then assigns the captured value to
the given variable instead of rendering it to the screen.

=head1 See Also

The L<assign|Liquid::Tag::Assign> tag.

Liquid for Designers: http://wiki.github.com/tobi/liquid/liquid-for-designers

L<Liquid|Liquid/"Create your own filters">'s docs on custom filter creation

=head1 Author

Sanko Robinson <sanko@cpan.org> - http://sankorobinson.com/

The original Liquid template system was developed by jadedPixel
(http://jadedpixel.com/) and Tobias Lütke (http://blog.leetsoft.com/).

=head1 License and Legal

Copyright (C) 2009 by Sanko Robinson E<lt>sanko@cpan.orgE<gt>

This program is free software; you can redistribute it and/or modify it under
the terms of The Artistic License 2.0.  See the F<LICENSE> file included with
this distribution or http://www.perlfoundation.org/artistic_license_2_0.  For
clarification, see http://www.perlfoundation.org/artistic_2_0_notes.

When separated from the distribution, all original POD documentation is
covered by the Creative Commons Attribution-Share Alike 3.0 License.  See
http://creativecommons.org/licenses/by-sa/3.0/us/legalcode.  For
clarification, see http://creativecommons.org/licenses/by-sa/3.0/us/.

=cut
