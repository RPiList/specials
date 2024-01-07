## Installation von Pihole für Raspberry Pi, VMs und Thin Clients

#### Hinweise vorab
<details>
  <summary>- Bei Ubuntu Systemen muss der Systemctl resolve deaktiviert werden um den Port 53 nutzen zu können</summary>

1. Root Shell erlangen

- Als Root anmelden oder als User folgendes eingeben, um auf die Root Shell zu kommen

```bash
sudo -s
```

2. Deaktivieren und stoppen Sie den systemd-aufgelösten Dienst:

```bash
systemctl disable systemd-resolved
systemctl stop systemd-resolved
```

3. Fügen Sie dann die folgende Zeile in den Abschnitt [main] Ihrer /etc/NetworkManager/NetworkManager.conf ein:

```
dns=default
```

4. Löschen Sie den Symlink /etc/resolv.conf

```bash
rm /etc/resolv.conf
```

5. Starte NetworkManager neu

```bash
systemctl restart NetworkManager
```

Quelle: [askubuntu.com](https://askubuntu.com/questions/907246/how-to-disable-systemd-resolved-in-ubuntu)
</details>

### Installation von Docker und Pihole über Docker compose

1. Root Shell erlangen

- Als Root anmelden oder als User folgendes eingeben, um auf die Root Shell zu kommen

```bash
sudo -s
```

2. System aktualisieren

- Das System (Debian und Ubuntu) auf den neusten stand bringen

```bash
apt update && apt upgrade -y && apt autoremove -y
```

3. Docker und Docker-compose installieren

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

4. Pihole über Docker-compose installieren

- Erstelle einen neuen Ordner und erstelle in den neuen Ordner eine docker-compose.yml

```bash
mkdir ~/server/docker/pihole -p
cd ~/server/docker/pihole
```

```bash
nano docker-compose.yml
```

- In den "nano" Fenster dann folgenden Inhalt reinkopieren

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
      # Volume mount for pihole userdata
      - './etc-pihole:/etc/pihole'
      - './etc-dnsmasq.d:/etc/dnsmasq.d'
      # Sync Timezone
      - '/etc/timezone:/etc/timezone:ro'
    cap_add:
      - NET_ADMIN # Required if you are using Pi-hole as your DHCP server, else not needed
    restart: unless-stopped
```

- Dann den Inhalt speichern mit Strg + O-Taste dann Enter und dann Strg + X-Taste zum Verlassen

- Dann den Container starten mit folgendem Befehl

```bash
docker-compose up -d
```

- Das Pihole ist nun über die IP-Adresse des Gerätes und den in der compose file angegebenen Port (Webserver) erreichbar

Quellen: [Docker](https://docs.docker.com/engine/install/debian/#install-using-the-convenience-script); [Pihole](https://github.com/pi-hole/docker-pi-hole#quick-start)

#### Hinweise
- Wo ist das Passwort für das Pihole?

Der Pihole Container generiert sich ein eigenes Zufallspasswort.
Das Passwort kann wie folgt geändert werden:

```bash
# Bis Pihole Version 5
docker exec -it pihole pihole -a -p
```

```bash
# Ab Pihole Version 6
docker exec -it pihole pihole setpassword
```

- Der Pihole Container sollte hin und wieder aktualisiert werden

```bash
cd ~/server/docker/pihole
docker-compose pull
docker-compose up -d
```

- Ein automatisches Update über Watchtower ist auch möglich

[Installation von Watchtower](https://youtu.be/6EujFKzsvvA)
