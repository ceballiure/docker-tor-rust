FROM rustlang/rust:nightly as builder

ARG TOR_BRANCH
RUN apt-get install -y autotools-dev automake libevent-dev
RUN git clone --depth 1 -b $TOR_BRANCH https://git.torproject.org/tor.git /build
WORKDIR /build
RUN git submodule init && git submodule update
RUN ./autogen.sh
RUN TOR_RUST_DEPENDENCIES=/build/src/ext/rust/crates ./configure --enable-coverage=no --enable-libfuzzer=no --enable-oss-fuzz=no --enable-unittests=no --enable-rust --disable-asciidoc --enable-static-libevent --with-libevent-dir=/usr/lib/x86_64-linux-gnu/ --enable-static-zlib --with-zlib-dir=/usr/lib/x86_64-linux-gnu/
RUN make

FROM ubuntu:18.04

RUN apt-get update && apt-get install -y openssl
COPY --from=builder /build/src/app/tor /usr/bin/tor

# Add Tor user
RUN groupadd -g 1000 tor && useradd -m -d /home/tor -g 1000 tor
RUN chmod u+x /usr/bin/tor
RUN chown tor:tor /usr/bin/tor
USER tor
EXPOSE 9001
