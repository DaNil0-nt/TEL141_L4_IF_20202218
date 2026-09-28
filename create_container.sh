#!/bin/bash
set -e

NOMBRE=$1
ID_VLAN=$2
CON_DHCP=$3
IP_CIDR=${4:-}
GATEWAY=${5:-}

VETH_OVS="vo_$NOMBRE"
VETH_CONT="vc_$NOMBRE"


sudo docker run -itd --network none --name $NOMBRE --cap-add=NET_ADMIN -d alpine sleep infinity

# Par veth
sudo ip link add $VETH_OVS type veth peer name $VETH_CONT
sudo ovs-vsctl add-port br-int $VETH_OVS tag=$ID_VLAN
sudo ip link set dev $VETH_OVS up

# Extremo dentro del namespace del contenedor
PID=$(sudo docker inspect -f '{{.State.Pid}}' $NOMBRE)
sudo ip link set $VETH_CONT netns $PID
sudo docker exec $NOMBRE ip link set dev $VETH_CONT up

if [ "$CON_DHCP" = "true" ]; then
    sudo docker exec $NOMBRE udhcpc -i $VETH_CONT -q -n
else
    sudo docker exec $NOMBRE ip addr add $IP_CIDR dev $VETH_CONT
    sudo docker exec $NOMBRE ip route add default via $GATEWAY
fi

echo "create_container.sh: $NOMBRE lista en VLAN $ID_VLAN"
