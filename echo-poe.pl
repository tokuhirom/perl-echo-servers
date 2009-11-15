#!/usr/bin/env perl
# vim: ts=2 sw=2 expandtab

use warnings;
use strict;

# To profile the server:
# rm -rf nytprof nytprof.out ; perl -d:NYTProf echo-poe.pl ; nytprofhtml
#
# Client:
#./echobench -p 9010 -a 100 -c 100 -h 127.0.0.1 -n 10000

# POE::XS::Queue::Array is automatically loaded if it's installed.

use POE 1.280;
use POE::Wheel::ListenAccept;

use Getopt::Long;
use Socket qw(IPPROTO_TCP TCP_NODELAY);
use IO::Handle;

my $clients    = 0;
my $port       = 9010;
my $concurrent = 10;

# Concurrent isn't an option.
GetOptions(
  'port=i'       => \$port,
  'concurrent=i' => \$concurrent,
);

POE::Session->create(
  inline_states => {
    _start    => \&setup_server,
    on_accept => \&setup_connection,
    on_input  => \&do_echo,
  }
);

print "$0: http://localhost:$port/\n";
print "concurrent: $concurrent\n";

POE::Kernel->run;
exit;

### Handlers.

sub setup_server {
  my $listen_socket = IO::Socket::INET->new(
    LocalHost => '0.0.0.0',
    LocalPort => $port,
    Listen    => $concurrent,
    ReuseAddr => 1,
  );

  $_[HEAP]{listener} = POE::Wheel::ListenAccept->new(
    Handle      => $listen_socket,
    AcceptEvent => "on_accept",
  );
}

sub setup_connection {
  my $client_socket = $_[ARG0];
  $_[KERNEL]->select_read($client_socket => "on_input");
  setsockopt($client_socket, IPPROTO_TCP, TCP_NODELAY, 1);
  $client_socket->blocking(1);
  $clients++;
}

sub do_echo {
  my $client_socket = $_[ARG0];

	my $buf = "";
	unless (
		sysread($client_socket, $buf, 8192) and
		syswrite($client_socket, $buf)
	) {
    $_[KERNEL]->select_read($client_socket => undef);
    delete $_[HEAP]{listener} unless --$clients;
  }
}
