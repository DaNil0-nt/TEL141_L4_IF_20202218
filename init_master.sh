#!/bin/bash
set -e

BRIDGE="br-int"

# CREAR EL BRIDGE OVS
sudo ovs-vsctl br-exists $BRIDGE || sudo ovs-vsctl add-br $BRIDGE

# CONECTAR CADA INTERFAZ RECIBIDA
for IFACE in "$@"; do
    sudo ovs-vsctl add-port $BRIDGE $IFACE 2>/dev/null || true
    sudo ip link set $IFACE up
done

# HABILITA EL FORWANDING IPV4
sudo sysctl -w net.ipv4.ip_forward=1

# NO REENVIAR NADA
sudo iptables -P FORWARD DROP

# DEJAR PASAR EL TRAFICO
sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

echo "Listo en $(hostname)"