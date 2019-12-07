FROM rustlang/rust:nightly as builder

ARG TOR_BRANCH
EXPOSE 9001

RUN apt-get install --assume-yes autotools-dev automake libevent-dev
RUN git clone --depth 1 --branch=$TOR_BRANCH https://git.torproject.org/tor.git /build
WORKDIR /build
RUN git submodule init && git submodule update
RUN ./autogen.sh
RUN TOR_RUST_DEPENDENCIES=/build/src/ext/rust/crates ./configure \
    --enable-coverage=no \
    --enable-libfuzzer=no \
    --enable-oss-fuzz=no \
    --enable-unittests=no \
    --enable-rust \
    --disable-asciidoc \
    --enable-static-libevent \
    --with-libevent-dir=/usr/lib/x86_64-linux-gnu/ \
    --enable-static-zlib \
    --with-zlib-dir=/usr/lib/x86_64-linux-gnu/
RUN make

FROM debian:buster-slim

ARG UID=1000
ARG GID=1000

RUN apt-get update && apt-get install --assume-yes openssl
COPY --from=builder /build/src/app/tor /usr/bin/tor

RUN groupadd tor \
        --gid $GID \
    && useradd tor \
        --uid $UID --gid $GID \
        --home-dir /var/lib/tor \
        --create-home
RUN chmod 0755 /usr/bin/tor
USER tor
CMD /usr/bin/tor
