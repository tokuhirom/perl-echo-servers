use strict;
use warnings;
use Getopt::Long;
use threads;
use threads::shared;
use IO::Socket::INET;

my $concurrent = 10;
my $port = 9090;
GetOptions(
    'concurrent=s' => \$concurrent,
    'port=i' => \$port,
);
my $locker : shared;

my $sock = IO::Socket::INET->new(
    LocalHost => 'localhost',
    LocalPort => $port,
    Listen    => 10,
    ReuseAddr => 1
) or die $!;
my @threads;
for my $i (1..$concurrent) {
    push @threads, threads->create(sub {
        while (1) {
            my $csock = do {
                lock($locker);
                $sock->accept;
            };
            while (my $line = <$csock>) {
                print $csock $line;
            }
        }
    });
}
print "ithread: http://localhost:$port/\n";
print "concurrency: $concurrent\n";
$_->join for @threads;

