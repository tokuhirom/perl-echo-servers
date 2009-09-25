use strict;
use warnings;
use Coro;
use Coro::Socket;
use Coro::Semaphore;
use Coro::EV;
use Getopt::Long;

my $concurrent = 10;
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
        while (my $line = <$csock>) {
            print $csock $line;
        }
    };
}

