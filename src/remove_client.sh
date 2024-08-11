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
Example: remove_client.sh <clientname>"
    exit 1;
fi


if [ ! -e $OPENVPN ]; then
    echo "ERROR: The dir $OPENVPN does not exist"
    exit 3;
elif [ ! -e $EASYRSA_PKI ]; then
    echo "ERROR: The dir $EASYRSA_PKI does not exist"
    exit 3;
fi


# END
cd $EASYRSA_PKI && easyrsa revoke $1 &&
rm $EASYRSA_PKI/vars &&
easyrsa gen-crl &&
rm $EASYRSA_PKI/vars

export result=$?
if (( $result != 0 )); then echo "ERROR"; exit 2; fi

rm $OPENVPN/clients_conf/$1.ovpn

echo "Client $1 removed!"