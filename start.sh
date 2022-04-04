#!/bin/sh
echo "$(date +'%a %b %d %H:%M:%S %Y') Start HvH SERVER Check";

pid="$(ps -ef |grep "[o]penvpn --config /mnt/data/split-vpn/openvpn/hvh/hvh-real.ovpn" | awk -F" " '{ print $1}')"

if [ -z "$pid" ]; then
echo "$(date +'%a %b %d %H:%M:%S %Y') Starting HvH Openvpn server";
openvpn --config /mnt/data/split-vpn/openvpn/hvh/hvh-real.ovpn &> openvpn.log
else
echo "$(date +'%a %b %d %H:%M:%S %Y') PID ID $pid"
fi
echo "$(date +'%a %b %d %H:%M:%S %Y') Done..."