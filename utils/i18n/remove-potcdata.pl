#!/usr/bin/perl -w
eval 'exec /usr/bin/perl -S $0 ${1+"$@"}'
  if 0;
$0 =~ s/^.*?(\w+)[\.\w+]*$/$1/;

use strict;
use Symbol;
use vars qw{ $isEOF $Hold %wFiles @Q $CondReg
	     $doAutoPrint $doOpenWrite $doPrint };
$doAutoPrint = 1;
$doOpenWrite = 1;
# prototypes
sub _t();
sub openARGV();
sub getsARGV(;\$);
sub eofARGV();
sub printQ();

# Run: the sed loop reading input and applying the script
#
sub Run(){
    my( $h, $icnt, $s, $n );
    # hack (not unbreakable :-/) to avoid // matching an empty string
    my $z = "\000"; $z =~ /$z/;
    # Initialize.
    openARGV();
    $Hold    = '';
    $CondReg = 0;
    $doPrint = $doAutoPrint;
CYCLE:
    while( getsARGV() ){
	chomp();
	$CondReg = 0;   # cleared on t
BOS:;
# /^"POT-Creation-Date: .*"$/{
if( m /^"POT-Creation-Date: .*"$/s )
{
# x
{ ($Hold, $_) = ($_, $Hold) }
# s/P/P/
{ $s = s /P/P/s;
  $CondReg ||= $s;
}
# ta
{ goto L_1 if _t() }
# g
{ $_ = $Hold };
# d
{ $doPrint = 0;
  goto EOS;
}

# bb
{ goto L_2; }
# :a
L_1:;
# x
{ ($Hold, $_) = ($_, $Hold) }
# :b
L_2:;
# }
;}
EOS:    if( $doPrint ){
            print $_, "\n";
        } else {
	    $doPrint = $doAutoPrint;
	}
        printQ() if @Q;
    }

    exit( 0 );
}
Run();

# openARGV: open 1st input file
#
sub openARGV(){
    unshift( @ARGV, '-' ) unless @ARGV;
    my $file = shift( @ARGV );
    open( ARG, "<$file" )
    || die( "$0: can't open $file for reading ($!)\n" );
    $isEOF = 0;
}

# getsARGV: Read another input line into argument (default: $_).
#           Move on to next input file, and reset EOF flag $isEOF.
sub getsARGV(;\$){
    my $argref = @_ ? shift() : \$_; 
    while( $isEOF || ! defined( $$argref = <ARG> ) ){
	close( ARG );
	return 0 unless @ARGV;
	my $file = shift( @ARGV );
	open( ARG, "<$file" )
	|| die( "$0: can't open $file for reading ($!)\n" );
	$isEOF = 0;
    }
    1;
}

# eofARGV: end-of-file test
#
sub eofARGV(){
    return @ARGV == 0 && ( $isEOF = eof( ARG ) );
}

# makeHandle: Generates another file handle for some file (given by its path)
#             to be written due to a w command or an s command's w flag.
sub makeHandle($){
    my( $path ) = @_;
    my $handle;
    if( ! exists( $wFiles{$path} ) || $wFiles{$path} eq '' ){
        $handle = $wFiles{$path} = gensym();
	if( $doOpenWrite ){
	    if( ! open( $handle, ">$path" ) ){
		die( "$0: can't open $path for writing: ($!)\n" );
	    }
	}
    } else {
        $handle = $wFiles{$path};
    }
    return $handle;
}

# printQ: Print queued output which is either a string or a reference
#         to a pathname.
sub printQ(){
    for my $q ( @Q ){
	if( ref( $q ) ){
            # flush open w files so that reading this file gets it all
	    if( exists( $wFiles{$$q} ) && $wFiles{$$q} ne '' ){
		open( $wFiles{$$q}, ">>$$q" );
	    }
            # copy file to stdout: slow, but safe
	    if( open( RF, "<$$q" ) ){
		while( defined( my $line = <RF> ) ){
		    print $line;
		}
		close( RF );
	    }
	} else {
	    print $q;
	}
    }
    undef( @Q );
}

# _t: t command - condition register test/reset
#
sub _t(){
    my $res = $CondReg;
    $CondReg = 0;
    $res;
}

