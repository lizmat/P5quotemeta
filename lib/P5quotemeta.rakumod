use v6.d;

proto sub quotemeta(|) is export {*}
multi sub quotemeta(--> Str:D) { quotemeta CALLER::LEXICAL::<$_> }
multi sub quotemeta(Str() $string --> Str:D) {
    given $string {
        S:g/ ( <[
          \x[34f]
          \x[0]..\x[2f]
          \x[3a]..\x[40]
          \x[5b]..\x[5e]
          \x[60]
          \x[7b]..\x[a7]
          \x[a9]
          \x[ab]..\x[ae]
          \x[b0]..\x[b1]
          \x[b6]
          \x[bb]
          \x[bf]
          \x[d7]
          \x[f7]
          \x[115f]..\x[1160]
          \x[61c]
          \x[1680]
          \x[17b4]..\x[17b5]
          \x[180b]..\x[180e]
          \x[2000]..\x[203e]
          \x[2041]..\x[2053]
          \x[2055]..\x[206f]
          \x[2190]..\x[245f]
          \x[2500]..\x[2775]
          \x[2794]..\x[2bff]
          \x[2e00]..\x[2e7f]
          \x[3000]..\x[3003]
          \x[3008]..\x[3020]
          \x[3030]
          \x[3164]
          \x[fd3e]..\x[fd3f]
          \x[fe00]..\x[fe0f]
          \x[fe45]..\x[fe46]
          \x[feff]
          \x[ffa0]
          \x[fff0]..\x[fff8]
          \x[1bca0]..\x[1bca3]
          \x[1d173]..\x[1d17a]
          \x[e0000]..\x[e0fff]
          \x[2adc]
        ]> ) /\\$0/        # 2adc should be part of 2794 .. 2e7f but isn't ?
    }
}

=begin pod

=head1 NAME

Raku port of Perl's quotemeta() built-in

=head1 SYNOPSIS

  use P5quotemeta; # exports quotemeta()

  my $a = "abc";
  say quotemeta $a;

  $_ = "abc";
  say quotemeta;

=head1 DESCRIPTION

This module tries to mimic the behaviour of Perl's C<quotemeta> function in
Raku as closely as possible.

=head1 ORIGINAL PERL 5 DOCUMENTATION

    quotemeta EXPR
    quotemeta
            Returns the value of EXPR with all the ASCII non-"word" characters
            backslashed. (That is, all ASCII characters not matching
            "/[A-Za-z_0-9]/" will be preceded by a backslash in the returned
            string, regardless of any locale settings.) This is the internal
            function implementing the "\Q" escape in double-quoted strings.
            (See below for the behavior on non-ASCII code points.)

            If EXPR is omitted, uses $_.

            quotemeta (and "\Q" ... "\E") are useful when interpolating
            strings into regular expressions, because by default an
            interpolated variable will be considered a mini-regular
            expression. For example:

                my $sentence = 'The quick brown fox jumped over the lazy dog';
                my $substring = 'quick.*?fox';
                $sentence =~ s{$substring}{big bad wolf};

            Will cause $sentence to become 'The big bad wolf jumped over...'.

            On the other hand:

                my $sentence = 'The quick brown fox jumped over the lazy dog';
                my $substring = 'quick.*?fox';
                $sentence =~ s{\Q$substring\E}{big bad wolf};

            Or:

                my $sentence = 'The quick brown fox jumped over the lazy dog';
                my $substring = 'quick.*?fox';
                my $quoted_substring = quotemeta($substring);
                $sentence =~ s{$quoted_substring}{big bad wolf};

            Will both leave the sentence as is. Normally, when accepting
            literal string input from the user, quotemeta() or "\Q" must be
            used.

            In Perl v5.14, all non-ASCII characters are quoted in
            non-UTF-8-encoded strings, but not quoted in UTF-8 strings.

            Starting in Perl v5.16, Perl adopted a Unicode-defined strategy
            for quoting non-ASCII characters; the quoting of ASCII characters
            is unchanged.

            Also unchanged is the quoting of non-UTF-8 strings when outside
            the scope of a "use feature 'unicode_strings'", which is to quote
            all characters in the upper Latin1 range. This provides complete
            backwards compatibility for old programs which do not use Unicode.
            (Note that "unicode_strings" is automatically enabled within the
            scope of a "use v5.12" or greater.)

            Within the scope of "use locale", all non-ASCII Latin1 code points
            are quoted whether the string is encoded as UTF-8 or not. As
            mentioned above, locale does not affect the quoting of ASCII-range
            characters. This protects against those locales where characters
            such as "|" are considered to be word characters.

            Otherwise, Perl quotes non-ASCII characters using an adaptation
            from Unicode (see <http://www.unicode.org/reports/tr31/>). The
            only code points that are quoted are those that have any of the
            Unicode properties: Pattern_Syntax, Pattern_White_Space,
            White_Space, Default_Ignorable_Code_Point, or
            General_Category=Control.

            Of these properties, the two important ones are Pattern_Syntax and
            Pattern_White_Space. They have been set up by Unicode for exactly
            this purpose of deciding which characters in a regular expression
            pattern should be quoted. No character that can be in an
            identifier has these properties.

            Perl promises, that if we ever add regular expression pattern
            metacharacters to the dozen already defined ("\ | ( ) [ { ^ $ * +
            ? ."), that we will only use ones that have the Pattern_Syntax
            property. Perl also promises, that if we ever add characters that
            are considered to be white space in regular expressions (currently
            mostly affected by "/x"), they will all have the
            Pattern_White_Space property.

            Unicode promises that the set of code points that have these two
            properties will never change, so something that is not quoted in
            v5.16 will never need to be quoted in any future Perl release.
            (Not all the code points that match Pattern_Syntax have actually
            had characters assigned to them; so there is room to grow, but
            they are quoted whether assigned or not. Perl, of course, would
            never use an unassigned code point as an actual metacharacter.)

            Quoting characters that have the other 3 properties is done to
            enhance the readability of the regular expression and not because
            they actually need to be quoted for regular expression purposes
            (characters with the White_Space property are likely to be
            indistinguishable on the page or screen from those with the
            Pattern_White_Space property; and the other two properties contain
            non-printing characters).

=head1 AUTHOR

Elizabeth Mattijsen <liz@raku.rocks>

If you like this module, or what I’m doing more generally, committing to a
L<small sponsorship|https://github.com/sponsors/lizmat/>  would mean a great
deal to me!

Source can be located at: https://github.com/lizmat/P5quotemeta . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018, 2019, 2020, 2021, 2023 Elizabeth Mattijsen

Stolen from Zoffix Znet's unpublished String::Quotemeta, as found at:

  https://github.com/zoffixznet/perl6-String-Quotemeta

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
