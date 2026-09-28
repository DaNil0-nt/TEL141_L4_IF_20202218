#!/bin/bash
set -e

NOMBRE_VM=$1
NOMBRE_OVS=$2
ID_VLAN=$3
PUERTO_VNC=$4

DIR_VMS="/var/lib/vms"
IMAGEN_BASE="$DIR_VMS/base.qcow2"
DISCO_VM="$DIR_VMS/$NOMBRE_VM.qcow2"
INTERFAZ_TAP="tap_$NOMBRE_VM"
DISPLAY_VNC=$((PUERTO_VNC - 5900))
CODIGO_PUCP="20202218"

sudo mkdir -p $DIR_VMS

# DESCARGAR LA IMAGEN
[ -f $IMAGEN_BASE ] || sudo wget -O $IMAGEN_BASE \
    http://download.cirros-cloud.net/0.5.1/cirros-0.5.1-x86_64-disk.img

# CREA EL DISCO DE LA VM
sudo qemu-img create -f qcow2 -b $IMAGEN_BASE -F qcow2 $DISCO_VM

# SE CREA EL TAP Y SE CONECTA AL OVS
sudo ip tuntap add mode tap name $INTERFAZ_TAP
sudo ovs-vsctl add-port $NOMBRE_OVS $INTERFAZ_TAP tag=$ID_VLAN
sudo ip link set dev $INTERFAZ_TAP up

# SE ARMA LA MAC
MAC="${CODIGO_PUCP:0:2}:${CODIGO_PUCP:2:2}:${CODIGO_PUCP:4:2}:${CODIGO_PUCP:6:2}:$(printf '%02x' $ID_VLAN):$(printf '%02x' $((PUERTO_VNC % 256)))"

#SE LEVANTA LA VM
sudo qemu-system-x86_64 \
    -enable-kvm \
    -vnc 0.0.0.0:$DISPLAY_VNC \
    -netdev tap,id=tap1,ifname=$INTERFAZ_TAP,script=no,downscript=no \
    -device e1000,netdev=tap1,mac=$MAC \
    -daemonize \
    -pidfile $DIR_VMS/$NOMBRE_VM.pid \
    $DISCO_VM

echo " $NOMBRE_VM lista en VLAN $ID_VLAN sobre $NOMBRE_OVS"
