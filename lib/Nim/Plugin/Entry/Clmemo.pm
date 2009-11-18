package Nim::Plugin::Entry::Clmemo;
use Any::Moose;

use Path::Class qw/file/;
use DateTime::Format::DateManip;

with 'Nim::Plugin';

has file => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has path => (
    is      => 'rw',
    isa     => 'Str',
    default => 'clmemo',
);

has open_layer => (
    is      => 'rw',
    isa     => 'Str',
    default => ':utf8',
);

has limit => (
    is      => 'rw',
    isa     => 'Int',
    default => 0,
);

no Any::Moose;

sub register {
    my ($self, $context) = @_;

    $context->register_hook(
        $self,
        find_entries => $self->can('find'),
    );
}

sub find {
    my ($self, $context) = @_;

    my $clmemo = Path::Class::File->new($self->file);
    die qq[Can't find clmemo file: $clmemo] unless -f $clmemo;

    open my $fh, '<' . $self->open_layer, $clmemo;

    my @cache;
    my ($parsed, $added);
    my ($date, $author, $time, $title, @tags, $body);
    while (my $line = <$fh>) {
        if ($line =~ /^\d+/) {
            # header
            if ($parsed) {
                push @cache, {
                    date   => $time || $date,
                    author => $author,
                    title  => $title,
                    tags   => [@tags],
                    body   => $body,
                };
            }
            $parsed = 0;

            if (@cache) {
                $self->add_entries($context, @cache);
                $added += scalar @cache;
                @cache = ();

                last if ($self->limit and $added >= $self->limit);
            }

            my ($d, $a) = $line =~ m!^([\d\-]+\s*(?: \(.*?\))?)\s*(.*)$!;
            $date = DateTime::Format::DateManip->parse_datetime($d);
            $author = $a;
        }
        else {
            if ($line =~ /^\t\*/) {
                # entry header
                if ($parsed) {
                    push @cache, {
                        date   => $time || $date,
                        author => $author,
                        title  => $title,
                        tags   => [@tags],
                        body   => $body,
                    };
                }
                $parsed++;

                my ($d, $t, $tags, $b) =
                    $line =~ m!^\t\*\s*(\d+:\d+)?\s*(.*?)(\[.*?\])?:\s*$!;

                if ($date && $d) {
                    $time = $date->clone;
                    my ($h, $m) = split ':', $d;
                    $time->set_hour($h);
                    $time->set_minute($m);
                }
                else {
                    undef $time;
                }

                $title = $t || q[];

                if ($tags) {
                    $tags =~ s/^\[|\]$//g;
                    @tags = split /\]\s*?\[/, $tags;
                }
                else {
                    @tags = ();
                }

                $body = $b || q[];
            }
            else {
                $line =~ s/^\t//;
                $body .= $line;
            }
        }
    }

    $self->add_entries($context, @cache)
        if @cache;

    close $fh;
}

sub add_entries {
    my ($self, $context, @day_entries) = @_;

    my @entries;
    my $id = 0;
    for my $info (reverse @day_entries) {
        $info->{title} =~ s/(^\s+|\s+$)//g;

        push @entries, Nim::Entry->new(
            context  => $context,
            path     => join('/', $self->path, $info->{date}->ymd('/')),
            filename => ++$id,
            time     => $info->{date}->epoch,
            datetime => $info->{date},
            loader   => sub {
                my ($entry, $want) = @_;

                $entry->title( $info->{title} );
                $entry->body( $info->{body} );

                $want eq 'title' ? $info->{title} : $info->{body};
            },
            meta => {
                tags => $info->{tags},
            },
        );
    }

    push @{ $context->entries }, reverse @entries;
}

__PACKAGE__->meta->make_immutable;
