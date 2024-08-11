#!/bin/bash

export OPENVPN=/etc/openvpn
export EASYRSA=/usr/share/easy-rsa
export EASYRSA_DIGEST=sha512
export EASYRSA_CRL_DAYS=3650
export EASYRSA_PKI=/etc/openvpn/easy-rsa
export EASYRSA_BATCH="yes"


if [ ! -e $OPENVPN/config.ovpn ]; then # verify if is client

    if [ ! -e $OPENVPN/server.conf ]; then

        export OPENVPN_SERVER_CN=${OPENVPN_SERVER_CN:-"myserver.com"}
        export OPENVPN_SERVER_PORT=${OPENVPN_SERVER_PORT:-"8443"}
        export OPENVPN_SERVER_INTERNAL_NETWORK="${OPENVPN_SERVER_INTERNAL_NETWORK:-10.8.0.0 255.255.255.0}"
        export OPENVPN_SERVER_CLIENT_ROUTES="${OPENVPN_SERVER_CLIENT_ROUTES:-route 192.168.0.0 255.255.255.0}"

        export EASYRSA_REQ_CN=$OPENVPN_SERVER_CN
        #make-cadir $EASYRSA_PKI
        mkdir -p  $EASYRSA_PKI

        # Generate server CA and certificate
        cd $EASYRSA_PKI
        easyrsa init-pki
        easyrsa build-ca nopass
        easyrsa gen-req server nopass
        easyrsa gen-dh
        easyrsa sign-req server server
        easyrsa gen-crl # revoke list
        rm $EASYRSA_PKI/vars


        # easyrsa 
        cp $EASYRSA_PKI/dh.pem $EASYRSA_PKI/ca.crt $EASYRSA_PKI/issued/server.crt $EASYRSA_PKI/private/server.key $OPENVPN/


        echo "
        # See details on https://github.com/OpenVPN/openvpn/blob/master/sample/sample-config-files/server.conf
        port $OPENVPN_SERVER_PORT
        proto tcp

        verb 3
        dev tun

        topology subnet
        server $OPENVPN_SERVER_INTERNAL_NETWORK
        ifconfig-pool-persist $OPENVPN/ipp.txt

        crl-verify $EASYRSA_PKI/crl.pem

        persist-tun

        ca $OPENVPN/ca.crt
        cert $OPENVPN/server.crt
        key $OPENVPN/server.key
        dh $OPENVPN/dh.pem" > $OPENVPN/server.conf

        #openvpn --genkey --secret ta.key
        echo "Configuration Finished!"
    fi

    echo "CONFIG route tables"
    export DEFAULT_INTERFACE=$(route | grep '^default' | grep -o '[^ ]*$')
    echo "Default interface $DEFAULT_INTERFACE"

    iptables -t nat -A POSTROUTING -o $DEFAULT_INTERFACE -j MASQUERADE
    iptables -A FORWARD -i $DEFAULT_INTERFACE -o tun0 -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -i tun0 -o $DEFAULT_INTERFACE -j ACCEPT

    cd $OPENVPN
    openvpn --config server.conf $@

else
    cd $OPENVPN
    openvpn --config config.ovpn $@
fi

