# **DOCKER OPENVPN** 
This repo will help you to setup and use openvpn server and client with OCI containers, using docker.<br> 

## OPENVPN CLIENT MODE
Start openvpn client is very easy, you need to map the ovpn file to /etc/openvpn/config.ovpn file on the container.<br>
For example, connectiong to vpn server using /var/vpn.ovpn client file:
```sh
docker run --name openvpn-client \
    -v /var/vpn.ovpn:/etc/openvpn/config.ovpn:ro \
    --cap-add=NET_ADMIN --device=/dev/net/tun \
    thunderssgss/openvpn:v2.6.3
```
**NOTE**: In this mode the VPN Client works through the container network, if you want to work through host network, change the container network mode to host.

<br>

## OPENVPN SERVER MODE
To Start openvpn server without any additional configuration, you need to run the command:<br>
```sh
docker run --name openvpn-server \
    -v /etc/openvpn:/etc/openvpn \
    --cap-add=NET_ADMIN --device=/dev/net/tun \
    --env OPENVPN_SERVER_CN=vpn-server \
    -p 8443:8443 \
    thunderssgss/openvpn:v2.6.3
```
**NOTE**: In this mode the VPN server works through the container network, if you want to work through host network, change the container network mode to host. The default server configuration uses tcp, if you want to use udp for speed and bandwidth, please see my docker wireguard repository.<br>
**NOTE2**: If you already have a server.conf file on /etc/openvpn directory, the server will not generate a new configuration file. The first time you start the container, the openvpn server may delay starting due to the process of generating keys and certificate authority and server certificate.
<br>

### Environment Variables (Server MODE)
| Name | Default |  Description  | 
|:----:|---------|---------------|
| OPENVPN_SERVER_CN | myserver.com | The server domain name. This will be used as common name of the server certs and to generate client configs, you need to regist this name on client dns or host files. NOTE: you can use the server real IP, its not recommend on production but on tests it will works. |
| OPENVPN_SERVER_PORT | 8443 | The server tcp listen port. |
| OPENVPN_SERVER_INTERNAL_NETWORK | 10.8.0.0 255.255.255.0 | The clients network on the server. NOTE: you can see the client ip on server reading the file /etc/openvpn/ipp.txt |
| OPENVPN_SERVER_CLIENT_ROUTES | route 192.168.0.0 255.255.255.0 | The routes configurations used on client ovpn file. This configs will be used on client ovpn files generated using create_client.sh script |
| OPENVPN_SERVER_CLIENT_DNS | 8.8.8.8 | The DNS config used on client ovpn file. NOTE: the ovpn default dns works only on windows clients, please see the openvpn official documentation for more information. |
| OPENVPN_SERVER_CLIENT_DNS_DOMAIN | - | The DNS domain name used on client ovpn file. This domain will be converted on IP address to add to client config when generating config file. Example, on k8s environment you can use kube-dns.kube-system. NOTE: If this variable not be setted the OPENVPN_SERVER_CLIENT_DNS will be used.   |
<br>

### Creating client certs and ovpn file (Server MODE)
Inside openvpn server container, you can generate client certs and ovpn file using the script:
```sh
create_client.sh client_name
```
**NOTE**: The client_name will be use as common name of the client cert. This command will generate a ovpn file on /etc/openvpn/client_confs/client_name.ovpn.

### Revoking client certs and remove ovpn file (Server MODE)
Inside openvpn server container, you can revoke client certs and remove ovpn file using the script:
```sh
remove_client.sh client_name
```
**NOTE**: If the removed client is connected to the vpn server, it will not be disconnected imediatly, because the certificate is used only to authenticate. To disconnect the client you need to restart the container. You can generate a new certificate to the client using the create_client.sh script.
<br>

## DevInfos:
- James Artur (Thunder), a DevOps and infrastructure enthusiastics.