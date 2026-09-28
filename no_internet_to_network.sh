#!/bin/bash
set -e

ID_VLAN=$1
CIDR=$2
IFAZ_GW="gw_vlan$ID_VLAN"
IFAZ_SALIDA="ens3"

# QUITAR EL MASQUERADE DE SALIDAA INTERNET
sudo iptables -t nat -D POSTROUTING -s $CIDR -o $IFAZ_SALIDA -j MASQUERADE

# QUITAR EL PERMISO
sudo iptables -D FORWARD -i $IFAZ_GW -o $IFAZ_SALIDA -j ACCEPT

echo "VLAN $ID_VLAN sin salida a Internet"