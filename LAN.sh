#!/bin/bash
# find-lan-from-netplan.sh – działa na każdej konfiguracji Netplana Ubuntu 24.04

set -e

echo "Szukam karty LAN z adresem statycznym z Netplana..."

# 1. Znajdź linijkę z "addresses:" i wyciągnij nazwę interfejsu
LAN_IF=$(grep -r "^[[:space:]]*addresses:" /etc/netplan/*.yaml 2>/dev/null | \
    head -1 | \
    sed -E 's|.*/([a-zA-Z0-9-]+)\.yaml:.*/|\1/' | \
    awk '{print $1}' | xargs)

# Fallback – jeśli inna składnia Netplana
if [ -z "$LAN_IF" ]; then
    LAN_IF=$(grep -r "addresses:" /etc/netplan/*.yaml 2>/dev/null | \
        head -1 | awk -F':' '{print $1}' | xargs | sed 's|.*/||' | sed 's/\.yaml.*//')
fi

# Fallback 2 – znajdź interfejs z prywatnym IP (nie 192.168, nie loopback)
if [ -z "$LAN_IF" ]; then
    echo "Netplan nie dał wyniku – szukam po adresie prywatnym..."
    LAN_IF=$(ip -4 -o addr show | awk '
        $4 ~ /^(10\.|172\.(1[6-9]|2[0-9]|3[0-1])\.|169\.254\.)/ && 
        $0 !~ /secondary/ && 
        $2 != "lo" {print $2; exit}'
    )
fi

# Ostateczne sprawdzenie
if [ -z "$LAN_IF" ]; then
    echo "Nie znaleziono żadnej karty LAN ze statycznym adresem!"
    echo "Sprawdź ręcznie: grep -r addresses /etc/netplan/"
    exit 1
fi

LAN_IP=$(ip -4 -o addr show dev "$LAN_IF" | awk '{print $4}' | cut -d/ -f1 | head -1)

echo ""
echo "LAN wykryty automatycznie:"
echo "  Interfejs: $LAN_IF"
echo "  Adres IP : $LAN_IP"
echo ""
echo "Użyj w skrypcie NAT: LAN_IF=\"$LAN_IF\""