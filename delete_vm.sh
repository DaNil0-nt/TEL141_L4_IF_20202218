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
PIDFILE="$DIR_VMS/$NOMBRE_VM.pid"

# DETENER PROCESO
sudo kill $(cat $PIDFILE)
sudo rm -f $PIDFILE

# QUITA EL INTERFAZ
sudo ovs-vsctl del-port $NOMBRE_OVS $INTERFAZ_TAP
sudo ip tuntap del mode tap name $INTERFAZ_TAP

# BORRAR EL DISCO DE VM
sudo rm -f $DISCO_VM

# BORRAR LO RESTANTE
QUEDAN=$(sudo find $DIR_VMS -name '*.qcow2' ! -name 'base.qcow2' \
    -exec qemu-img info {} \; | grep -c "backing file: $IMAGEN_BASE" || true)

if [ "$QUEDAN" -eq 0 ]; then
    sudo rm -f $IMAGEN_BASE
fi

echo " $NOMBRE_VM eliminada"
