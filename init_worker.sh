#!/bin/bash
set -e

BRIDGE="br-int"

sudo ovs-vsctl br-exists $BRIDGE || sudo ovs-vsctl add-br $BRIDGE

for IFAZ in "$@"; do
    sudo ovs-vsctl add-port $BRIDGE $IFAZ 2>/dev/null || true
    sudo ip link set $IFAZ up
done

echo "Listo en $(hostname)"
