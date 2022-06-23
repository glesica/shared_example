#!/usr/bin/env sh

set -e

CC=/usr/local/bin/gcc-10

rm -rf static
rm -rf dynamic

mkdir -p static
mkdir -p dynamic

cd bar
# Build the object file
$CC -c bar.c
# Build the static library
ar -r ../static/libbar.a bar.o
# Build the shared library
$CC -shared -fPIC -o ../dynamic/libbar.so bar.o
cd ..

cd foo
# Build the object file
$CC -c foo.c
# Build the static library
ar -r ../static/libfoo.a foo.o
# Build the shared library
$CC -shared -fPIC -o ../dynamic/libfoo.so foo.c
cd ..

# Build libtimesr as a shared library, but statically
# link it against libbar and libfoo so that they are
# not required in order to run consumer.
$CC -shared -Lstatic/ -Ibar/ -Ifoo/ -lbar -lfoo -fPIC -o libtimesr.so timesr.c

# Build consumer against libtimesr
$CC -L. -I. -ltimesr -o consumer consumer.c

# Now we can run consumer, it still requires libtimesr.so,
# which it will find since it is in the same directory,
# but it DOES NOT require libbar or libfoo. We can check
# on that using otool
otool -L consumer
otool -L libtimesr.so
./consumer

# Build libtimesr as a shared library, but link it
# dynamically against libbar and libfoo so that they
# are required in order to run consumer.
$CC -shared -Ldynamic/ -Ibar/ -Ifoo/ -lbar -lfoo -fPIC -o libtimesr.so timesr.c

# Build consumer as a dynamic binary
# Consumer relies on libtimesr, which in turn relies
# on libbar and libfoo, and all of them must be found
# at runtime.
$CC -L. -I. -ltimesr -o consumer consumer.c

# Now, when we run consumer, we need libbar and libfoo
# because they aren't statically linked into libtimesr
# (which is trivially found). Note also that otool
# tells us about the dependency on libtimesr, but it
# still doesn't include the dependencies on libbar and
# libfoo. This is because it doesn't depend on them, but
# if we run otool against libtimesr.so, we see them.
otool -L consumer
otool -L libtimesr.so
DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:dynamic/ ./consumer

