use strict;
use warnings;
use Getopt::Long;
use IO::Socket::INET;
use IO::Epoll;
use Fcntl;

my $concurrent = 10; # max event
my $port = 9010;
GetOptions(
    'concurrent=s' => \$concurrent,
    'port=i'       => \$port,
);

print "$0: http://localhost:$port/\n";
print "concurrency: $concurrent\n";

#my $EPOLLONESHOT = (1 << 30);
my $epfd = epoll_create($concurrent);

my $listener = IO::Socket::INET->new(
    LocalHost => '0.0.0.0',
    LocalPort => $port,
    Listen    => 10,
    ReuseAddr => 1
) or die $!;

my @Sock_Holder;
my $listener_fd = fileno $listener;

epoll_ctl($epfd, EPOLL_CTL_ADD, $listener_fd, EPOLLIN) >= 0
    || die "epoll_ctl: $!\n";

while (1) {
    my $events = epoll_wait($epfd, $concurrent, -1); # Max 10 events returned, 1s timeout

    ### $events
    for my $ev (@$events) {
        ### ev: $ev;
        if ($ev->[0] == $listener_fd) {
            ### >listenr: $$
            my $sock = $listener->accept;
            my $sock_fd = fileno $sock;
            $Sock_Holder[$sock_fd] = $sock;
            my $flags = fcntl($sock, F_GETFL, 0) or die "fcntl  GET_FL: $!";
            fcntl($sock, F_SETFL, $flags|O_NONBLOCK) or die "fcntl  SET_FL: $!";
            epoll_ctl($epfd, EPOLL_CTL_ADD, $sock_fd, EPOLLIN) >= 0
                || die "epoll_ctl: $!\n";
        } else {
            ### >client: $ev->[0], $$
            open my $sock, "+<&=".$ev->[0] or die "fdopen: $!";
            my $line = <$sock>;
            if ($line) {
                print $sock $line;
            } else {
                ### no data: $ev->[0], $$
                epoll_ctl($epfd, EPOLL_CTL_DEL, $ev->[0], 0) >= 0
                    || die "epoll_ctl: $!\n";
                $Sock_Holder[$ev->[0]] = undef;
                close $sock;
            }
        }
    }
}
