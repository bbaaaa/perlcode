#!/usr/bin/perl

use strict;
use warnings;
use autodie;
use utf8;
use Date::Calc qw/Today_and_Now/;

my %ips = ();
my @ips_found=();
my $found = 0;
my ($min_n, $max_n);
my $out_name = sprintf("./out_%04d_%02d_%02d_%02d%02d%02d.txt",Today_and_Now());

open(IN,$ARGV[0]);
while(<IN>){
    $ips{$1}=create_aton($1) if(/^\s*(\d+\.\d+\.\d+\.\d+)\s*/i);
}
close(IN);

open(IN,$ARGV[1]);
while(<IN>){
    if($found){
	if(/^\s*(?:netname|descr):\s*(.+)/i){
	    push(@ips_found,$1);
	    $found++;
	}
    }
    if((/^\s*inetnum:\s*(\d+\.\d+\.\d+\.\d+)\s*-\s*(\d+\.\d+\.\d+\.\d+)/i)&&defined($1)&&defined($2)){
	$min_n = create_aton($1);
	$max_n = create_aton($2);
	foreach my $ip (keys %ips){
	    if(($ips{$ip}>=$min_n)&&($ips{$ip}<=$max_n)){
		print $1." - ".$2." ip: ".$ip."\n";
		push(@ips_found, $ip);
		$found = 1;
	    }
	}
    }
    if($found == 3){
	print map{ $_."\t" } (@ips_found);
	print "\n";
	out_log($out_name,\@ips_found) unless( $ips_found[-2] =~ /iana-blk|eu-zz-\d+/i);
	$found = 0;
	@ips_found=();
    }
}
close(IN);

sub out_log{
    my $fname = shift;
    my $ips=shift;
    open(OUT, ">>", $fname);
    print OUT map{ $_." " } (@{$ips});
    print OUT "\n";
    close(OUT);
}

sub create_aton{
    my $ip_dot=shift;
    my $res = undef;
    $res= ($1<<24)+($2<<16)+($3<<8)+$4 if($ip_dot =~ /(\d+)\.(\d+)\.(\d+)\.(\d+)/i);
    return $res;
}
