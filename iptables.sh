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


if [ -z "$LAN_IF" ]; then
    LAN_IF=$(grep -r "addresses:" /etc/netplan/*.yaml 2>/dev/null | \
        head -1 | awk -F':' '{print $1}' | xargs | sed 's|.*/||' | sed 's/\.yaml.*//')
fi


if [ -z "$LAN_IF" ]; then
    echo "Netplan nie dał wyniku – szukam po adresie prywatnym..."
    LAN_IF=$(ip -4 -o addr show | awk '
        $4 ~ /^(10\.|172\.(1[6-9]|2[0-9]|3[0-1])\.|169\.254\.)/ &&
        $0 !~ /secondary/ &&
        $2 != "lo" {print $2; exit}'
    )
fi


if [ -z "$LAN_IF" ]; then
    echo "Nie znaleziono żadnej karty LAN ze statycznym adresem!"
    echo "Sprawdź ręcznie: grep -r addresses /etc/netplan/"
    exit 1
fi

echo "  Interfejs: $LAN_IF"

# reszta tych komend iptables

sudo iptables --flush
sudo iptables --table nat --flush
sudo iptables --table nat --delete-chain
sudo iptables --delete-chain
sudo iptables --table nat --append POSTROUTING --out-interface "$WAN_IF" -j MASQUERADE
sudo iptables --append FORWARD --in-interface "$LAN_IF" -j ACCEPT
sudo iptables-save
sudo sysctl -w net.ipv4.ip_forward=1
#instalacja pakietu iptables-persistent żeby konfiguracja była na stałę
sudo apt install iptables-persistent -y


