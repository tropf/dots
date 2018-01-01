#!/usr/bin/perl

use strict;
use warnings;

use IO::File;

use autodie; # die if problem reading or writing a file
use Cwd 'abs_path';
use File::Basename;
use File::HomeDir;
use JSON::PP;

sub load_lines {
    my $argc = @_;
    if (1 != $argc) {
        die("can only load line of exactly one file");
    }
    my $fname = $_[0];
    my $fh = IO::File->new();
    $fh->open("< $fname");
    my @lines = <$fh>;
    $fh->close();
    return @lines;
}

sub load_text {
    return join '', load_lines(@_);
}

my $homedir = File::HomeDir->my_home;
my $dirname = abs_path(dirname(__FILE__));

my $conf_filename = $dirname . "/conf.json";
my $conf_text = load_text($conf_filename);
my @conf = @{decode_json($conf_text)};

my $conf_entry;
for $conf_entry (@conf) {
    my (%current_conf) = %{$conf_entry};

    my $template_filename = $dirname . "/" . $current_conf{"inc"};
    my $rc_included_filename = $dirname . "/" . $current_conf{"rc"};
    my $rc_actual_filename = $homedir . "/" . $current_conf{"target"};
    my $comment_filename = $dirname . "/" . $current_conf{"comment"};

    print $template_filename . "\n";
    print $rc_included_filename . "\n";
    print $rc_actual_filename . "\n";
    print $comment_filename . "\n";

    # load comment template
    my $comment_fh = IO::File->new();
    $comment_fh->open("< $comment_filename");
    my $comment_temmplate = <$comment_fh>;
    $comment_fh->close;

    $comment_temmplate =~ s/\R$//;
    $comment_temmplate .= "\n";

    # generate start & end comments
    my $comment_include_block_start = $comment_temmplate =~ s/\$COMMENT/***** BEGIN INCLUDE BLOCK *****/r;
    my $comment_include_block_end = $comment_temmplate =~ s/\$COMMENT/***** END INCLUDE BLOCK *****/r;

    # load include script template
    my $inc_fh = IO::File->new();
    $inc_fh->open("< $template_filename");
    my @inc_template_lines = <$inc_fh>;
    $inc_fh->close;
    my $inc_template = join '', @inc_template_lines;

    # generate include script
    my $inc_text = $inc_template =~ s/\$FILE/$rc_included_filename/r;

    # load current .rc
    my $rc_fh = IO::File->new();
    $rc_fh->open("< $rc_actual_filename") or die("didn't find .zshrc file");
    my @rc_old_lines = <$rc_fh>;
    $rc_fh->close;

    # filter old include script from .rc
    my @rc_new_lines;
    my $keep_copying = 1;

    # search for **** BEGIN INCLUDE BLOCK ***** and don't copy it
    my $line;
    foreach $line (@rc_old_lines) {
        if ($line =~ s/\s*\R?$//r eq $comment_include_block_start =~ s/\s*\R?$//r) {
            $keep_copying = 0;
        }

        if ($keep_copying) {
            push @rc_new_lines, $line;
        }

        if ($line =~ s/\s*\R?$//r eq $comment_include_block_end =~ s/\s*\R?$//r) {
            $keep_copying = 1;
        }
    }

    # put new include script on top of .rc
    my $rc_new = join '', @rc_new_lines;

    # kill (eventually) trailing \n
    $inc_text =~ s/\R$//;
    $inc_text .= "\n";
    $inc_text = $comment_include_block_start . $inc_text . $comment_include_block_end;

    $rc_new =~ s/\R$//;
    $rc_new = $inc_text . $rc_new . "\n";

    # .rc write back
    my $rc_wb_fh = IO::File->new();
    $rc_wb_fh->open("> $rc_actual_filename") or die("No writerino to .zshrc file");
    print $rc_wb_fh $rc_new;
    $rc_wb_fh->close;
}
