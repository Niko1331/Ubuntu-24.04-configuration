#!/bin/bash

set -e

echo "Wykrywanie karty LAN..."

LAN_IF=$(ip -o -4 addr show | awk '
	$4 ~ /^(10\.|172\.(1[6-9]|2[0-9]|3[0-1])\.)/ && $0 !~ /secondary/ {print $2; exit}
')

if [ -z "$LAN_IF" ]; then
LAN_IF=$(ip link | awk -F: '/^[0-9]+:/ {print $2}' | grep -v lo | head -1)
fi
[ -z "$LAN_IF" ] && { echo "Nie znaleziono LAN!"; exit 1; }

echo "LAN = $LAN_IF"
