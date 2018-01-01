#!/usr/bin/perl

use strict;
use warnings;

use IO::File;

use autodie; # die if problem reading or writing a file
use Cwd 'abs_path';
use File::Basename;
use File::HomeDir;

my $homedir = File::HomeDir->my_home;
my $dirname = abs_path(dirname(__FILE__));

# load include script template
my $inc_fh = IO::File->new();
$inc_fh->open("< $dirname/zshrc.inc");
my @inc_template_lines = <$inc_fh>;
$inc_fh->close;
my $inc_template = join '', @inc_template_lines;

# generate include script
my $rcfile = 'path/to/rcfile';
my $inc_text = $inc_template =~ s/\$FILE/$rcfile/r;

print $inc_text;

# load current .rc
my $rc_fh = IO::File->new();
$rc_fh->open("< $homedir/.zshrc") or die("didn't find .zshrc file");
my @rc_old_lines = <$rc_fh>;
$rc_fh->close;

# filter old include script from .rc
my @rc_new_lines = grep(!/$inc_text/, @rc_old_lines);

# put new include script on top of .rc
my $rc_new = join '', @rc_new_lines;

# kill (eventually) trailing \n
$inc_text =~ s/\R$//;
$rc_new =~ s/\R$//;
$rc_new = $inc_text . "\n" . $rc_new . "\n";

# .rc write back
my $rc_wb_fh = IO::File->new();
$rc_wb_fh->open("> /tmp/.zshrc") or die("No writerino to .zshrc file");
if (! defined $rc_wb_fh) {
    die('shit');
}
print $rc_wb_fh $rc_new;
$rc_wb_fh->close;
