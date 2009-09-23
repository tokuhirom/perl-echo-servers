use strict;
use warnings;
use Coro;
use Coro::Socket;
use Coro::Semaphore;
use Getopt::Long;

my $concurrent = 10;
my $port = 9010;
GetOptions(
    'concurrent=s' => \$concurrent,
);

print "coro: http://localhost:9010/\n";
print "concurrency: $concurrent\n";
my $sock = Coro::Socket->new(LocalHost => 'localhost', LocalPort => $port, Listen => 10, ReuseAddr => 1);
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
$_->join for @coros;

