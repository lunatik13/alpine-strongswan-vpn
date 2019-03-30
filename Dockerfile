#
# StrongSwan VPN + Alpine Linux
#

FROM alpine:3.7

ENV STRONGSWAN_RELEASE https://download.strongswan.org/strongswan.tar.bz2

RUN apk --update add build-base \
            ca-certificates \
            curl \
            curl-dev \
            ip6tables \
            iproute2 \
            iptables-dev \
            openssl \
            openssl-dev && \
    mkdir -p /tmp/strongswan && \
    curl -Lo /tmp/strongswan.tar.bz2 $STRONGSWAN_RELEASE && \
    tar --strip-components=1 -C /tmp/strongswan -xjf /tmp/strongswan.tar.bz2 && \
    cd /tmp/strongswan && \
    ./configure --prefix=/usr \
            --sysconfdir=/etc \
            --libexecdir=/usr/lib \
            --with-ipsecdir=/usr/lib/strongswan \
            --enable-aesni \
            --enable-chapoly \
            --enable-cmd \
            --enable-curl \
            --enable-dhcp \
            --enable-eap-dynamic \
            --enable-eap-identity \
            --enable-eap-md5 \
            --enable-eap-mschapv2 \
            --enable-eap-radius \
            --enable-eap-tls \
            --enable-farp \
            --enable-files \
            --enable-gcm \
            --enable-md4 \
            --enable-newhope \
            --enable-ntru \
            --enable-openssl \
            --enable-sha3 \
            --enable-shared \
            --disable-aes \
            --disable-des \
            --disable-gmp \
            --disable-hmac \
            --disable-ikev1 \
            --disable-md5 \
            --disable-rc2 \
            --disable-sha1 \
            --disable-sha2 \
            --disable-static && \
    make && \
    make install && \
    rm -rf /tmp/* && \
    apk del build-base curl-dev openssl-dev && \
    rm -rf /var/cache/apk/*
RUN rm /etc/ipsec.secrets

ADD ./etc/* /etc/
ADD ./bin/* /usr/bin/

ARG LEFT_ID
ARG VPN_USER
ARG DNS_1
ARG DNS_2

ENV ENV_LEFT_ID ${LEFT_ID:-example.host.com}
ENV ENV_VPN_USER ${VPN_USER:-vpnuser}
ENV ENV_DNS_1 ${DNS_1:-1.1.1.1}
ENV ENV_DNS_2 ${DNS_2:-1.0.0.1}

EXPOSE 500/udp \
       4500/udp

ENTRYPOINT ["/usr/sbin/ipsec"]
CMD ["start", "--nofork"]
