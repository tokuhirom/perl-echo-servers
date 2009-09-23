use warnings;
use strict;
use POE;
use POE::Component::Server::TCP;
use Getopt::Long;

my $port = 9010;
my $concurrent = 10;
GetOptions(
    'port=i' => \$port,
    'concurrent=i' => \$concurrent,
);
POE::Component::Server::TCP->new(
    Port         => $port,
    ClientInput  => sub { $_[HEAP]->{client}->put( $_[ARG0] ); },
    ClientFilter => [ "POE::Filter::Line", Literal => "\x0a" ],
    Address      => '0.0.0.0',
    Concurrency  => $concurrent,
);

print "$0: http://localhost:$port/\n";
print "concurrent: $concurrent\n";
POE::Kernel->run;
exit;

