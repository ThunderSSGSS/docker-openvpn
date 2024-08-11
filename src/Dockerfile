FROM debian:12.6-slim

ARG VERSION=2.6.3-1+deb12u2
RUN apt update && \
    apt install -y openvpn=${VERSION} easy-rsa curl openssh-client iptables netcat-traditional net-tools dnsutils && \
    ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin

ENV OPENVPN=/etc/openvpn
ENV EASYRSA=/usr/share/easy-rsa
ENV EASYRSA_DIGEST=sha512
ENV EASYRSA_CRL_DAYS=3650
ENV EASYRSA_PKI=/etc/openvpn/easy-rsa

WORKDIR /etc/openvpn
COPY ./create_client.sh /usr/local/bin/create_client.sh
COPY ./remove_client.sh /usr/local/bin/remove_client.sh
COPY ./entrypoint.sh /entrypoint.sh

RUN chmod +x /usr/local/bin/create_client.sh && \
    chmod +x /usr/local/bin/remove_client.sh && \
    chmod +x /entrypoint.sh && \
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf 

ENTRYPOINT ["/entrypoint.sh"]