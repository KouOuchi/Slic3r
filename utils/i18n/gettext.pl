#!/usr/bin/perl

use strict;
use warnings;
use File::Temp qw(tempfile);
use File::Compare qw(compare );
use File::Touch qw(touch);
use File::Path;
use File::Find ();

# define locales
my(@LOCALE_LIST)=("de", "fr", "it", "pt", "ru", "zh_CN", "nl", "es", "lv", "ja");
my($debug); 

# define directory
my($PO_DIRECTORY)="var/po";
my($MO_DIRECTORY)="var/locale";
my(@SRC_FILE_OR_DIRECTORY_LIST)=("lib", "Build.PL", "slic3r.pl");

# define gettext name
my($PO_NAME)="slic3r";

print STDERR "gettext.pl: Start retrieving sources...\n";

# find2perl definition
use vars qw/*name *dir *prune/;
*name   = *File::Find::name;
*dir    = *File::Find::dir;
*prune  = *File::Find::prune;
sub wanted;

# initialize path
mkpath("$PO_DIRECTORY") if not -d "$PO_DIRECTORY";

# retrieve source files
my($fh, $filelist) = tempfile();

File::Find::find({wanted => \&wanted}, @SRC_FILE_OR_DIRECTORY_LIST);
$fh->close();

# debug
print STDERR "$filelist\n" if $debug;

# create xgettext command
my($package_gnu)='';
my($msgid_bugs_address)='bug-gnu-gettext@gnu.org';
my($xgettext_usage) = qx|xgettext --version|
  or die $@;
my(@xgettext_version) = split(/$/m, $xgettext_usage);

my($xgettext_command);
if($xgettext_version[0] =~ /(0.[0-9]|0.[0-9].*|0.1[0-5]|0.1[0-5].*|0.16|0.16.[0-1]*)/) {
    $xgettext_command = <<"EOF";
    xgettext --default-domain=$PO_NAME --from-code=utf-8 --add-comments=TRANSLATORS: -k_ --flag=_:1:pass-perl-format --flag=_:1:pass-perl-brace-format -k__ --flag=__:1:pass-perl-format --flag=__:1:pass-perl-brace-format -k'\$__' --flag=\$__:1:pass-perl-format --flag=\$__:1:pass-perl-brace-format -k'\%__' --flag=\%__:1:pass-perl-format --flag=\%__:1:pass-perl-brace-format -k__x --flag=__x:1:perl-brace-format -k__n:1,2 --flag=__n:1:pass-perl-format --flag=__n:1:pass-perl-brace-format --flag=__n:2:pass-perl-format --flag=__n:2:pass-perl-brace-format -k__nx:1,2 --flag=__nx:1:perl-brace-format --flag=__nx:2:perl-brace-format -k__xn:1,2 --flag=__xn:1:perl-brace-format --flag=__xn:2:perl-brace-format -kN__ --flag=N__:1:pass-perl-format --flag=N__:1:pass-perl-brace-format -k_u --flag=_u:1:pass-perl-format --flag=_u:1:pass-perl-brace-format --copyright-holder='Yoyodyne,Inc.' --msgid-bugs-address="$msgid_bugs_address" --files-from="$filelist" --output-dir="$PO_DIRECTORY"
EOF

} else {
    $xgettext_command = <<"EOF";
    xgettext --default-domain=$PO_NAME --from-code=utf-8 --add-comments=TRANSLATORS: -k_ --flag=_:1:pass-perl-format --flag=_:1:pass-perl-brace-format -k__ --flag=__:1:pass-perl-format --flag=__:1:pass-perl-brace-format -k'\$__' --flag=\$__:1:pass-perl-format --flag=\$__:1:pass-perl-brace-format -k'\%__' --flag=\%__:1:pass-perl-format --flag=\%__:1:pass-perl-brace-format -k__x --flag=__x:1:perl-brace-format -k__n:1,2 --flag=__n:1:pass-perl-format --flag=__n:1:pass-perl-brace-format --flag=__n:2:pass-perl-format --flag=__n:2:pass-perl-brace-format -k__nx:1,2 --flag=__nx:1:perl-brace-format --flag=__nx:2:perl-brace-format -k__xn:1,2 --flag=__xn:1:perl-brace-format --flag=__xn:2:perl-brace-format -kN__ --flag=N__:1:pass-perl-format --flag=N__:1:pass-perl-brace-format -k_u --flag=_u:1:pass-perl-format --flag=_u:1:pass-perl-brace-format --copyright-holder='Yoyodyne,Inc.' --package-name="$package_gnu$PO_NAME" --package-version='0' --msgid-bugs-address="$msgid_bugs_address" --files-from="$filelist" --output-dir="$PO_DIRECTORY"
EOF

}

# run xgettext
print STDERR "gettext.pl: Run xgettext...\n";

# debug
print STDERR "$filelist\n" if $xgettext_command;

system($xgettext_command) == 0 or die $@;

# not exists po
if(-f "$PO_DIRECTORY/$PO_NAME.pot") {
    # exists pot
    if ($^O eq 'MSWin32') {
	system('cmd.exe', '/K', 'perl', 'utils\i18n\remove-potcdata.pl', '<', "$PO_DIRECTORY/$PO_NAME.pot", '>', "$PO_DIRECTORY/$PO_NAME.1po") == 0
	    or die $@;
	system('cmd.exe', '/K', 'perl', 'utils\i18n\remove-potcdata.pl', '<', "$PO_DIRECTORY/$PO_NAME.po", '>', "$PO_DIRECTORY/$PO_NAME.2po") == 0
	    or die $@;
    } else {
	system("utils/i18n/remove-potcdata.pl < $PO_DIRECTORY/$PO_NAME.pot > $PO_DIRECTORY/$PO_NAME.1po") == 0
	    or die $@;
	system("utils/i18n/remove-potcdata.pl < $PO_DIRECTORY/$PO_NAME.po > $PO_DIRECTORY/$PO_NAME.2po") == 0
	    or die $@;
    }
    

    if(compare("$PO_DIRECTORY/$PO_NAME.1po", "$PO_DIRECTORY/$PO_NAME.2po") == 0) {
        unlink "$PO_DIRECTORY/$PO_NAME.po";
        unlink "$PO_DIRECTORY/$PO_NAME.1po";
        unlink "$PO_DIRECTORY/$PO_NAME.2po";
    } else {
        unlink "$PO_DIRECTORY/$PO_NAME.1po";
        unlink "$PO_DIRECTORY/$PO_NAME.2po";
        rename "$PO_DIRECTORY/$PO_NAME.po", "$PO_DIRECTORY/$PO_NAME.pot";
    }
} else {
    rename "$PO_DIRECTORY/$PO_NAME.po", "$PO_DIRECTORY/$PO_NAME.pot";
}

for(@LOCALE_LIST) {
    print STDERR "gettext.pl: Create message catalog ($_)...\n";

    touch("$PO_DIRECTORY/$PO_NAME-$_.po") if not -f "$PO_DIRECTORY/$PO_NAME-$_.po";
    mkpath("$MO_DIRECTORY/$_/LC_MESSAGES") if not -d "$MO_DIRECTORY/$_/LC_MESSAGES";

    system("msgmerge --update --quiet --lang=$_ $PO_DIRECTORY/$PO_NAME-$_.po $PO_DIRECTORY/$PO_NAME.pot") == 0
      or die $@;
    system("msgfmt $PO_DIRECTORY/$PO_NAME-$_.po -o $MO_DIRECTORY/$_/LC_MESSAGES/$PO_NAME.mo") == 0
      or die $@;
}

# clean
unlink $filelist;

print STDERR "\ngettext.pl: Done.\n";
print STDERR "gettext.pl: Don't forget to set environment variable(LC_ALL) to your locale.\n";

exit;

# this function is generated from find2perl
sub wanted {
    my ($dev,$ino,$mode,$nlink,$uid,$gid);

    if ( (($dev,$ino,$mode,$nlink,$uid,$gid) = lstat($_)) && -f _ )
    {
	$name =~ tr|\\|/|;
	print $fh "$name\n";
    }
}

__END__
