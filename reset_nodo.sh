#!/bin/bash

for f in /var/lib/vms/*.pid; do
    [ -f "$f" ] && sudo kill $(sudo cat "$f") 2>/dev/null || true
done
sudo pkill -9 -f qemu-system 2>/dev/null || true


sudo find /var/lib/vms -name '*.qcow2' ! -name 'base.qcow2' -delete 2>/dev/null || true
sudo rm -f /var/lib/vms/*.pid


sudo docker rm -f $(sudo docker ps -aq) 2>/dev/null || true
sudo pkill dnsmasq || true
sudo ovs-vsctl --if-exists del-br br-int

for ns in $(ip netns list | awk '{print $1}'); do
    sudo ip netns del "$ns" 2>/dev/null || true
done
for t in $(ip -o link show | awk -F': ' '{print $2}' | grep '^tap_' || true); do
    sudo ip tuntap del mode tap name "$t" 2>/dev/null || true
done

sudo iptables -F FORWARD
sudo iptables -t nat -F POSTROUTING
sudo iptables -P FORWARD ACCEPT

echo "LISTO"
