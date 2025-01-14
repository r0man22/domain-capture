#!/bin/bash

result=$(sudo fping -a -g 192.168.1.0/24 2>/dev/null)
echo "$result"
