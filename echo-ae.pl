use strict;
use warnings;
use AE;
use Getopt::Long;
use AnyEvent::Socket;
use AnyEvent::Handle;

my $port = 9010;
GetOptions(
    'port=i' => \$port,
);

print "$0: http://localhost:$port/\n";
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

