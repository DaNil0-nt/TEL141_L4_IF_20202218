#!/bin/bash
set -e

VLAN1=$1
VLAN2=$2

sudo iptables -D FORWARD -i gw_vlan$VLAN1 -o gw_vlan$VLAN2 -j ACCEPT
sudo iptables -D FORWARD -i gw_vlan$VLAN2 -o gw_vlan$VLAN1 -j ACCEPT

echo "Ruteo deshabilitado entre VLAN $VLAN1 y VLAN $VLAN2"
