FROM ubuntu:22.04 AS mavrouter_builder

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


FROM ubuntu:22.04 AS ardu_builder

RUN apt-get update -y; \
    apt-get install -y git meson ninja-build pkg-config gcc g++ systemd python3 sudo; \
    useradd --create-home pilot

WORKDIR /home/pilot

RUN git clone --recursive --depth 1 https://github.com/ArduPilot/ardupilot.git


RUN apt-get install -y python-is-python3 python3-pip rsync


RUN python -m pip install empy

WORKDIR /home/pilot/ardupilot

RUN ./waf configure

RUN python -m pip install pexpect; \
    python -m pip install future

RUN ./waf copter

RUN ./waf plane

RUN DESTDIR=/home/pilot/dist ./waf install

FROM ubuntu:22.04
RUN apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y dash bash libc6 libgcc-s1 iproute2 && \
    apt-get clean && \
    rm -rf /usr/share/doc/* /usr/share/man/* /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    useradd --create-home pilot

COPY --from=ardu_builder /home/pilot/dist/usr/bin/* /usr/bin/
COPY --from=mavrouter_builder /home/pilot/dist/usr/bin/* /usr/bin/
COPY ./app/ /app/
ENTRYPOINT ["/usr/bin/bash", "/app/launch.sh"]

