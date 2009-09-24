use Class::MOP;

print "perl: $]\n";
print $^O, "\n";
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
    Class::MOP::load_class($c);
    print "$c: " . ${"$c\::VERSION"}, "\n";
}

