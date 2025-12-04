#!/bin/bash

set -e

LAN_INFO=$(ip -4 -o addr show | awk '
	$4 ~ /^(10\.|172\.(1[6-9]|2[0-9]|3[0-1])\.)/ && $0 !~ /secondary/ {
	gsub(/\/.*/, "", $4); print $2":"$4; exit
	}')

if [ -z "$LAN_INFO" ]; then
	echo "Nie znaleziono karty LAN ze statycznym adresem"
	echo "Sprawdź: ip addr"
	exit 1
fi

LAN_IF=$(echo "$LAN_INFO" | cut -d: -f1)
LAN_IP=$(echo "$LAN_INFO" | cut -d: -f2)
NETWORK=$(echo "$LAN_IP" | awk -F. '{print $1"."$2"."$3".0"}')
GATEWAY="$LAN_IP"

RANGE_START=$(echo "$LAN_IP" | awk -F. '{print $1"."$2"."$3".10"}')
RANGE_END=$(echo "$LAN_IP" | awk -F. '{print $1"."$2"."$3".100"}')

echo "LAN: $LAN_IF > $LAN_IP"
echo "Sieć: $NETWORK /24"
echo "Zakres od: $RANGE_START - $RANGE_END"

sudo bash -c "cat > /etc/dhcp/dhcpd.conf" << EOF
default-lease-time 600;
max-lease-time 7200;

subnet $NETWORK netmask 255.255.255.0 {
	range $RANGE_START $RANGE_END;
	opion routers $GATEWAY;
	option domain-name-servers 1.1.1.1;
}

authoriative;
EOF
