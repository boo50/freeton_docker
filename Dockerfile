FROM ubuntu:20.04 as builder

ARG HOST_USER_UID=1000
ARG HOST_USER_GID=1000
ENV DEBIAN_FRONTEND=noninteractive
ENV CMAKE_BUILD_PARALLEL_LEVEL=2

RUN set -ex && \
    apt-get update && \
    apt-get install --no-install-recommends -y curl cargo ninja-build sudo ca-certificates build-essential cmake clang openssl libssl-dev zlib1g-dev gperf wget git && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd --gid "$HOST_USER_GID" ton \
    && useradd --uid "$HOST_USER_UID" --gid "$HOST_USER_GID" --create-home --shell /bin/bash ton && \
    echo "ton ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
	mkdir /opt/freeton/ && \
	chown ton:ton /opt/freeton/

USER ton
WORKDIR /opt/freeton/
RUN git clone --depth 1 --recursive https://github.com/tonlabs/net.ton.dev.git
WORKDIR /opt/freeton/net.ton.dev/scripts/
RUN ./env.sh && ./build.sh


FROM ubuntu:20.04

ARG HOST_USER_UID=1000
ARG HOST_USER_GID=1000
ENV DEBIAN_FRONTEND=noninteractive

RUN set -ex && \
    apt-get update && \
    apt-get install --no-install-recommends -y curl sudo ca-certificates wget && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd --gid "$HOST_USER_GID" ton \
    && useradd --uid "$HOST_USER_UID" --gid "$HOST_USER_GID" --create-home --shell /bin/bash ton && \
    echo "ton ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
	mkdir /opt/freeton/ && \
	chown ton:ton /opt/freeton/

COPY --from=builder /opt/freeton/net.ton.dev /opt/freeton/net.ton.dev
USER ton
WORKDIR /opt/freeton/net.ton.dev/scripts/
RUN ./setup.sh
COPY entrypoint.sh .
EXPOSE 43678 43679

ENTRYPOINT ["./entrypoint.sh"]
