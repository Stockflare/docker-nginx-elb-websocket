FROM nginx:1.9.4

MAINTAINER David Kelley <david@stockflare.com>

ENV DEBIAN_FRONTEND noninteractive

ENV CONFD_VERSION 0.10.0

ADD etc/confd /etc/confd

ADD confd/confd-0.10.0-linux-amd64 /bin/confd

WORKDIR /nginx

ADD boot boot

CMD ["./boot"]
