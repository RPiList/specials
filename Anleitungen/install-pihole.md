## Installation von Pihole für Raspberry Pi (gilt auch für VMs und Thin Clients)

#### Hinweise vorab
- bei Ubuntu Systemen muss der Systemctl resolve deaktiviert werden um den Port 53 nutzen zu können

  - Beschreibung folgt


### Installation von Docker und Pihole über Docker compose

1. Root Shell erlangen

- Als Root anmelden oder als User folgendes eingeben um auf die Root Shell zu kommen

```bash
sudo -s
```

2. Docker und Docker-compose installieren

- Docker installieren (Debian und Ubuntu)

```bash
curl -sSL https://get.docker.com | bash
```

- Docker compose installieren

```bash
curl -SL $(curl -L -s https://api.github.com/repos/docker/compose/releases/latest | grep -o -E "https://(.*)docker-compose-linux-$(uname -m)") -o /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

3. Pihole über Docker-compose installieren

- Erstelle einen neuen Ordner und erstelle in den neuen Ordner eine docker-compose.yml

```bash
mkdir ~/server/docker/pihole -p
cd ~/server/docker/pihole
```

```bash
nano docker-compose.yml
```

- In den "nano" Fenster dann folgenden Inhalt rein kopieren

```yaml
version: "3"

# More info at https://github.com/pi-hole/docker-pi-hole/ and https://docs.pi-hole.net/
services:
  pihole:
    container_name: pihole
    image: pihole/pihole:latest
    # For DHCP it is recommended to remove these ports and instead add: network_mode: "host"
    ports:
      - "53:53/tcp" # DNS
      - "53:53/udp" # DNS
      - "67:67/udp" # DHCP server
      - "80:80/tcp" # Webserver
    volumes:
      - './etc-pihole:/etc/pihole'
      - './etc-dnsmasq.d:/etc/dnsmasq.d'
      # Sync Timezone
      - '/etc/timezone:/etc/timezone:ro'
    cap_add:
      - NET_ADMIN # Required if you are using Pi-hole as your DHCP server, else not needed
    restart: unless-stopped
```

- Dann den Inhalt speichern mit strg + O-Taste dann Enter und dann Strg + X-Taste zum verlassen

- Dann den Container starten mit folgenden Befehl

```bash
docker-compose up - d
```

- Das Pihole ist nun über die ip Adresse des Gerätes und den in der compose file angegebenen Port (Webserver) erreichbar

#### Hinweise
- der Pihole Container sollte hin und wieder aktualisiert werden

```bash
cd ~/server/docker/pihole
docker-compose pull
docker-compose up -d
```

- Ein automatisches update über Watchtower ist auch möglich

[Installation von Watchtower](https://youtu.be/6EujFKzsvvA)
