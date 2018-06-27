

# What is this repository?

Toy HTTP Server written in nasm 64 bits.

Useless, incomplete, unstable, not portable, _fast_ at least.


---

My goal here is to use socket's option [SO_REUSEPORT](https://lwn.net/Articles/542629/)
to bind a bunch of these to an unique port.

There is two goal here:
- find how relying on kernel instead of userland _good ol' event polling_
  or a _threadpool_ may impact performances.

- make fun of people choosing and/or benchmarking HTTP frameworks/librairies
  over static "Hello World" HTTP responses. In the real world, the overhall design
  of the service and the underlying database are far more problematic than
  replying static content, like kind of JSON representation of "Hello world" ;)


# How to build and run

You'll need _nasm_ and an x86_64 Linux

build by running `make`

execute by running `./exxx`
