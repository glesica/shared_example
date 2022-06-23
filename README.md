# Shared Example

An example of working with shared and static libraries in C.

## Notes

On Redhat Linux it seems that the runtime library loader doesn't check the
current directory by default, whereas on Mac it does.

Building the library against the static versions of the dependencies does result
in a binary (shared library) without references to the dependencies, but it also
doesn't appear to have the necessary symbols linked in.

