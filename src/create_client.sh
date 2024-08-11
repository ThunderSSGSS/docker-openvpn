#!/bin/bash

export EASYRSA_BATCH="yes"

if [ ! $OPENVPN ]; then
    echo "ERROR: The OPENVPN environment variable not defined!
This Variable represent the Openvpn config dir"
    exit 2;

elif [ ! $EASYRSA_PKI ]; then
    echo "ERROR: The EASYRSA_PKI environment variable not defined!
This Variable represent the easy-rsa pki config dir"
    exit 2;

elif [ ! $1 ]; then
    echo "You need to give arguments 
Example: create_client.sh <clientname>"
    exit 1;
fi

if [ ! -e $OPENVPN ]; then
    echo "ERROR: The dir $OPENVPN does not exist"
    exit 3;
elif [ ! -e $EASYRSA_PKI ]; then
    echo "ERROR: The dir $EASYRSA_PKI does not exist"
    exit 3;
fi

# START VARS
export OPENVPN_SERVER_CN=${OPENVPN_SERVER_CN:-"myserver.com"}
export OPENVPN_SERVER_PORT=${OPENVPN_SERVER_PORT:-"8443"}
export OPENVPN_SERVER_CLIENT_ROUTES="${OPENVPN_SERVER_CLIENT_ROUTES:-route 192.168.0.0 255.255.255.0}"

if [ $OPENVPN_SERVER_CLIENT_DNS_DOMAIN ]; then
    export DNS=$(dig +short $OPENVPN_SERVER_CLIENT_DNS_DOMAIN)
elif [ $OPENVPN_SERVER_CLIENT_DNS ]; then
    export DNS="$OPENVPN_SERVER_CLIENT_DNS" 
else
    export DNS="8.8.8.8"
fi

# END VARS

export EASYRSA_REQ_CN=$1
mkdir -p $OPENVPN/clients_conf

cd $EASYRSA_PKI &&
easyrsa gen-req $1 nopass &&
rm $EASYRSA_PKI/vars &&
easyrsa sign-req client $1 &&
rm $EASYRSA_PKI/vars

export result=$?
if (( $result != 0 )); then echo "ERROR"; exit 2; fi

echo "client
dev tun
proto tcp
remote $OPENVPN_SERVER_CN $OPENVPN_SERVER_PORT
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
auth SHA256
auth-nocache
verb 3

route-nopull
$OPENVPN_SERVER_CLIENT_ROUTES

dhcp-option DNS $DNS

<ca>
" > $OPENVPN/clients_conf/$1.ovpn

cat $EASYRSA_PKI/ca.crt >> $OPENVPN/clients_conf/$1.ovpn
echo "
</ca>
<cert>
" >> $OPENVPN/clients_conf/$1.ovpn

cat $EASYRSA_PKI/issued/$1.crt >> $OPENVPN/clients_conf/$1.ovpn
echo "
</cert>
<key>
" >> $OPENVPN/clients_conf/$1.ovpn

cat $EASYRSA_PKI/private/$1.key >> $OPENVPN/clients_conf/$1.ovpn
echo "
</key>" >> $OPENVPN/clients_conf/$1.ovpn


echo "
CONFIGURATION FOR CLIENT $1 GENERATED.
The File: $OPENVPN/clients_conf/$1.ovpn
"



