#!/bin/bash

set -e

# kod na wykrycie karty WAN

echo "Wykrywanie karty WAN..."
WAN_IF=$(ip -o route get 8.8.8.8 | awk '{print $5; exit}')

if [ -z  "$WAN_IF" ]; then
	echo "Nie znaleziono karty WAN, sprawdź połączenie z internetem i spróbuj ponownie"
	exit 1
fi
echo "Karta WAN = $WAN_IF"


# kod na wykrycie karty LAN

echo "Wykrywanie karty LAN..."
LAN_IF=$(ip -o -4 addr show | awk '
	$4 ~ /^(10\.|172\.(1[6-9]|2[0-9]|3[0-1])\.)/ && $0 !~ /secondary/ {print $2; exit}
')

if [ -z "$LAN_IF" ]; then
LAN_IF=$(ip link | awk -F: '/^[0-9]+:/ {print $2}' | grep -v lo | head -1)
fi
[ -z "$LAN_IF" ] && { echo "Nie znaleziono LAN!"; exit 1; }

echo "LAN = $LAN_IF"

# reszta tych komend iptables

sudo iptables --flush
sudo iptables --table nat --flush
sudo iptables --table nat --delete-chain
sudo iptables --delete-chain
sudo iptables --table nat --append POSTROUTING --out-interface "$WAN_IF" -j MASQUERADE
sudo ipables --append FORWARD --in-interface "$LAN_IF" -j ACCEPT
sudo iptables-save
sudo sysctl -w net.ipv4.ip_forward=1
#instalacja pakietu iptables-persistent żeby konfiguracja była na stałę
sudo apt install iptables-persistent -y


