use strict;
use warnings;
use Coro;
use Coro::Socket;
use Coro::Semaphore;
use Coro::EV;
use Getopt::Long;

my $concurrent =  shift @ARGV || 10;
my $port = 9010;
GetOptions(
    'port=i' => \$port,
    'concurrent=i' => \$concurrent,
);

print "coro: http://localhost:$port/\n";
print "concurrency: $concurrent\n";
local $Coro::POOL_SIZE = $concurrent;
my $sock = Coro::Socket->new(LocalHost => '0.0.0.0', LocalPort => $port, Listen => 10, ReuseAddr => 1);
while (1) {
    my $csock = $sock->accept;
    async_pool {
        my $nb_fh = $csock->fh;
        my $buf   = \$csock->rbuf;
        while (1) {
            $csock->readable or last;
            unless (sysread($nb_fh, $$buf, 8192)) {
                last;
            }
            $csock->writable or last;
            syswrite($csock, $$buf);
        }
    };
}

