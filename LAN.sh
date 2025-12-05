#!/bin/bash
# setup-nat-smart.sh – sam znajduje LAN (statyczny, nie 192.168) i WAN
# Działa idealnie z Netplanem

set -e

echo "Szukam karty LAN (statyczny adres, nie 192.168.x.x)..."

# 1. Znajdź interfejs z ręcznie ustawionym adresem w Netplanie
#    (plik .yaml w /etc/netplan/)
LAN_IF=$(grep -r "addresses:" /etc/netplan/*.yaml 2>/dev/null | \
    grep -v "#" | head -1 | awk -F'[/ ]' '{print $1}' | awk -F: '{print $1}')

# Jeśli Netplan nie dał wyniku – znajdź interfejs z prywatnym IP, ale NIE 192.168
if [ -z "$LAN_IF" ] || ! ip -4 addr show dev "$LAN_IF" | grep -q "inet "; then
    LAN_IF=$(ip -4 -o addr show | awk '
        $4 ~ /^(10\.|172\.(1[6-9]|2[0-9]|3[0-1])\.)/ && $0 !~ /secondary/ {
            gsub(/\/.*/, "", $4); print $2; exit
        }')
fi

# 2. Znajdź WAN – interfejs z domyślną trasą do internetu
WAN_IF=$(ip -o route get 8.8.8.8 | awk '{print $5; exit}')

# Sprawdzenie
[ -z "$LAN_IF" ] && { echo "Nie znaleziono karty LAN!"; exit 1; }
[ -z "$WAN_IF" ] && { echo "Nie znaleziono karty WAN!"; exit 1; }
[ "$LAN_IF" = "$WAN_IF" ] && { echo "LAN i WAN to ta sama karta!"; exit 1; }

echo "LAN  → $LAN_IF  (statyczny, nie 192.168)"
echo "WAN  → $WAN_IF  (domyślna trasa do internetu)"