use strict;
use warnings;
use Coro;
use Coro::Socket;
use Coro::Semaphore;
use Coro::Event;
use Getopt::Long;

my $concurrent = 10;
my $port = 9010;
GetOptions(
    'concurrent=s' => \$concurrent,
    'port=i' => \$port,
);

print "coro: http://localhost:$port/\n";
print "concurrency: $concurrent\n";
my $sock = Coro::Socket->new(LocalHost => '0.0.0.0', LocalPort => $port, Listen => 10, ReuseAddr => 1);
my @coros;
for my $i (1..$concurrent) {
    print "awake thread $i\n";
    push @coros, async {
        while (1) {
            my $csock = $sock->accept;
            while (my $line = <$csock>) {
                print $csock $line;
            }
        }
    };
}
push @coros, async { Event::loop() };
$_->join for @coros;

