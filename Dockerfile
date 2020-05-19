FROM ubuntu:bionic
ENV DEBIAN_FRONTEND noninteractive
WORKDIR /root
COPY files/* /root

RUN apt update && apt full-upgrade -y && \
    apt install -y --no-install-recommends git curl ca-certificates sudo

RUN git clone https://github.com/tonlabs/main.ton.dev.git && mkdir /var/ton-work && \
    cd main.ton.dev/scripts && . ./env.sh && ./build.sh && ./setup.sh

CMD ["/root/runton.sh"]
