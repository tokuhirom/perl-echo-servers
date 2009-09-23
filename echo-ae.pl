use strict;
use warnings;
use AE;
use Getopt::Long;
use AnyEvent::Socket;
use AnyEvent::Handle;

my $concurrent = 10;
my $port = 9010;
GetOptions(
    'concurrent=s' => \$concurrent,
    'port=i' => \$port,
);

print "coro: http://localhost:$port/\n";
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
};
AE::cv->recv;

