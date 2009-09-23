use strict;
use warnings;
use Parallel::Prefork;
use Getopt::Long;
use IO::Socket::INET;
use Parallel::Prefork;

my $concurrent = 10;
my $port = 9040;
GetOptions(
    'concurrent=s' => \$concurrent,
    'port=i'       => \$port,
);

print "$0: http://localhost:$port/\n";
print "concurrency: $concurrent\n";

my $sock = IO::Socket::INET->new(
    LocalHost => '0.0.0.0',
    LocalPort => $port,
    Listen    => 10,
    ReuseAddr => 1
) or die $!;

my $pm = Parallel::Prefork->new(
    {
        max_workers  => $concurrent,
        trap_signals => {
            TERM => 'TERM',
            HUP  => 'TERM',
        },
    }
);
while ( $pm->signal_received ne 'TERM' ) {
    $pm->start and next;
    while (1) {
        my $csock = $sock->accept;
        while (my $line = <$csock>) {
            print $csock $line;
        }
    }
    $pm->finish;
}
$pm->wait_all_children;


