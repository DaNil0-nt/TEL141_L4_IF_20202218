#!/bin/bash
set -e

USUARIO="ubuntu"
SERVER1="10.0.10.1"
SERVER2="10.0.10.2"
SERVER3="10.0.10.3"
IFAZ_DATOS="ens4"


remoto() {
    IP=$1
    SCRIPT=$2
    shift 2
    ssh -o StrictHostKeyChecking=no $USUARIO@$IP 'bash -s' "$@" < ./$SCRIPT
}


for S in $SERVER1 $SERVER2 $SERVER3; do
    remoto $S reset_nodo.sh
done

echo "Inciando OVS"
remoto $SERVER1 init_worker.sh $IFAZ_DATOS
remoto $SERVER2 init_worker.sh $IFAZ_DATOS
remoto $SERVER3 init_master.sh $IFAZ_DATOS

echo "VLAN SIN DHCP"
remoto $SERVER3 create_network_vlan.sh 100 192.168.0.0/24 false
remoto $SERVER3 create_network_vlan.sh 200 192.168.2.0/24 false

echo "SALIDA INTERNET"
remoto $SERVER3 internet_to_network.sh 100 192.168.0.0/24
remoto $SERVER3 internet_to_network.sh 200 192.168.2.0/24

echo "VMS Y CONTENERDOR"
remoto $SERVER2 create_vm.sh vm100 br-int 100 5901
remoto $SERVER2 create_vm.sh vm200 br-int 200 5902
remoto $SERVER1 create_container.sh c100 100 false 192.168.0.20/24 192.168.0.1
remoto $SERVER1 create_container.sh c200 200 false 192.168.2.20/24 192.168.2.1

echo "Actividad 2 LISTOP"
