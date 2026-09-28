#!/bin/bash
set -e

ID_VLAN=$1
CIDR=$2
CON_DHCP=$3
RANGO_DHCP=${4:-}

IFAZ_GW="gw_vlan$ID_VLAN"
PREFIJO="${CIDR#*/}"

# IP DE GATEWAY Y DEL DHCP
read IP_GW IP_DHCP MASCARA <<< $(python3 -c "
import ipaddress
red = ipaddress.ip_network('$CIDR', strict=False)
hosts = list(red.hosts())
print(hosts[0], hosts[1], red.netmask)
")

# INTERFAZ INTERNA DEL GATWAY Y ASIGNA LA VLAN
sudo ovs-vsctl add-port br-int $IFAZ_GW tag=$ID_VLAN -- set interface $IFAZ_GW type=internal
sudo ip addr add $IP_GW/$PREFIJO dev $IFAZ_GW
sudo ip link set $IFAZ_GW up


if [ "$CON_DHCP" = "true" ]; then
    INICIO=${RANGO_DHCP%%,*}
    FIN=${RANGO_DHCP##*,}
    NS="dhcp_vlan$ID_VLAN"
    PUERTO_DHCP="dhcp_vlan$ID_VLAN"

    sudo ip netns add $NS
    sudo ovs-vsctl add-port br-int $PUERTO_DHCP tag=$ID_VLAN -- set interface $PUERTO_DHCP type=internal
    sudo ip link set $PUERTO_DHCP netns $NS
    sudo ip netns exec $NS ip addr add $IP_DHCP/$PREFIJO dev $PUERTO_DHCP
    sudo ip netns exec $NS ip link set $PUERTO_DHCP up
    sudo ip netns exec $NS ip link set lo up

    sudo ip netns exec $NS dnsmasq \
        --interface=$PUERTO_DHCP \
        --bind-interfaces \
        --dhcp-range=$INICIO,$FIN,$MASCARA \
        --dhcp-option=3,$IP_GW \
        --dhcp-option=6,8.8.8.8
fi

echo " VLAN $ID_VLAN lista (gateway $IP_GW)"
