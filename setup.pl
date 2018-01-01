#!/usr/bin/perl

use strict;
use warnings;

use IO::File;

use autodie; # die if problem reading or writing a file
use Cwd 'abs_path';
use File::Basename;
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

my $dirname = abs_path(dirname(__FILE__));

my $conf_filename = $dirname . "/conf.json";
my $conf_text = load_text($conf_filename);
my @conf = @{decode_json($conf_text)};

my $conf_entry;
for $conf_entry (@conf) {
    my (%current_conf) = %{$conf_entry};

    print "=== " . $current_conf{"target"} . " ===\n";

    if (exists $current_conf{"setup"}) {
        my $setup_script_file = $dirname . "/" . $current_conf{"setup"};
        print "  running setup script $setup_script_file\n";
        if (-e $setup_script_file && -X $setup_script_file) {
           system("sh", $setup_script_file);
        } else {
            print "  ERROR can't execute script\n";
        }
    } else {
        print "  no setup script, skipping\n";
    }
}
