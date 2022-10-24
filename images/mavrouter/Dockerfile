FROM ubuntu:22.04 AS builder

RUN apt-get update -y; \
    apt-get install -y git meson ninja-build pkg-config gcc g++ systemd; \
    useradd --create-home pilot

USER pilot

WORKDIR /home/pilot

RUN git clone https://github.com/mavlink-router/mavlink-router.git

WORKDIR /home/pilot/mavlink-router

RUN git submodule update --init --recursive

RUN cd /home/pilot/mavlink-router && \
    meson setup build . && \
    ninja -C build && \
    DESTDIR=/home/pilot/dist ninja -C build install

FROM ubuntu:22.04
RUN apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y bash libc6 libgcc-s1 && \
    apt-get clean && \
    rm -rf /usr/share/doc/* /usr/share/man/* /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=builder /home/pilot/dist/usr/bin/mavlink-routerd /usr/bin/mavlink-routerd
ENTRYPOINT '/usr/bin/mavlink-routerd'
