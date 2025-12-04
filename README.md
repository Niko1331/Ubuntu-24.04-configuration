Automatyczna konfiguracja serwera ubuntu,

wszystkie pliki włącz jako root czyli użyj sudo bash nazwa_pliku.sh

plik WAN_detect.sh i LAN_detect.sh są po to żeby wykryć która karta to WAN a która to LAN, 
plik ipables_configuration.sh automatycznie sprawdzi nazwy tych kart i użyje w poleceniu iptables,
plik dhcp_configuration.sh automatycznie sprawdzi:
- adres ip karty LAN
- nazwę karty LAN
- zakres ip od - do
i jeszcze taki dodatek, automatycznie zapisze konfiguracje dhcp z adresem z LAN-u do pliku /etc/dhcp/dhcpd.conf
