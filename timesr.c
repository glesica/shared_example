#include "bar/bar.h"
#include "foo/foo.h"

int do_timesing() {
    int b = bar_times_two(5);
    int c = foo_times_two(10);
    return b + c;
}

