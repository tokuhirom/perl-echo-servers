use strict;
use warnings;
use AE;
use Getopt::Long;
use AnyEvent::Socket;
use AnyEvent::Handle;

my $concurrent = 2; # = number of CPU core or a few over
my $port = 9010;
GetOptions(
    'port=i' => \$port,
    'concurrent=s' => \$concurrent,
);

print "$0: http://localhost:$port/\n";
print "concurrency: $concurrent\n";

tcp_server undef, $port, sub {
    my ($fh, $host, $port) = @_;
    my $sock = AnyEvent::Handle->new(fh => $fh);
    $sock->on_read(
        sub {
            $sock->push_write($_[0]->{rbuf});
            $_[0]->{rbuf} = '';
        }
    );
}, sub {
    my ($fh, $host, $port) = @_;
    for (2 .. $concurrent) {
        fork || return;
    }
};
AE::cv->recv;

