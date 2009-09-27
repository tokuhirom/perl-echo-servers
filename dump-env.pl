use Class::MOP;
use Config;

print "perl: $]\n";
print join(' ', $Config{osname}, $Config{osvers}, $Config{archname}), "\n";
print "useithreads: ", $Config{useithreads} ? "yes" : "no", "\n";
print "\n";

d($_) for qw/
    POE
    POE::XS::Queue::Array

    EV
    AnyEvent
    Coro

    IO::Epoll

    forks
/;


sub d {
    my $c = shift;
    eval { Class::MOP::load_class($c); };
    printf "%-22s: %s\n", $c, ($@ ? "MISSING" : ${"$c\::VERSION"});
}

