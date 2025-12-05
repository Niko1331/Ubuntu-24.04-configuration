
							Automatyczna konfiguracja serwera ubuntu,

wszystkie pliki włącz jako root czyli użyj sudo bash nazwa_pliku.sh

plik WAN.sh i LAN.sh są po to żeby wykryć która karta to WAN a która to LAN, 
Plik iptables.sh automatycznie sprawdzi nazwy tych kart i użyje w poleceniu iptables,
Plik dhcp.sh automatycznie sprawdzi:
- Adres ip karty LAN
- Nazwę karty LAN
- Zakres ip od - do
- Automatycznie pisze konfiguracje dhcp z adresem z LAN-u do pliku /etc/dhcp/dhcpd.conf

Nie robi tylko zmian w pliku /etc/default/isc-dhcp-server 
