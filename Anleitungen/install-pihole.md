## Installation von Pihole für Raspberry Pi, VMs und Thin Clients

#### Hinweise vorab
<details>
  <summary>- Bei Ubuntu Betriebssystemen muss der `systemd-resolved` deaktiviert werden um den Port 53 nutzen zu können</summary>

1. Root Shell erlangen

- Als Root anmelden oder als User folgendes eingeben, um auf die Root Shell zu kommen

```bash
sudo -s
```

2. Deaktivieren und stoppen Sie den `systemd-resolved` Dienst:

```bash
systemctl disable systemd-resolved
systemctl stop systemd-resolved
```

3. Fügen Sie dann die folgende Zeile in den Abschnitt [main] Ihrer `/etc/NetworkManager/NetworkManager.conf` ein:

```
dns=default
```

4. Löschen Sie den Symlink `/etc/resolv.conf`

```bash
rm /etc/resolv.conf
```

5. Starte den `NetworkManager` neu

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

- Das Betriebssystem (Debian und Ubuntu) auf den neusten Stand bringen

```bash
apt update && apt upgrade -y && apt autoremove -y
```

3. `docker` und `docker-compose` installieren

- `docker` installieren (Debian und Ubuntu)

```bash
curl -sSL https://get.docker.com | bash
```

- `docker-compose` installieren

```bash
echo -e '#!/bin/sh\nexec docker compose "$@"' | tee /usr/local/bin/docker-compose && \
  ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose && \
  chmod +x /usr/local/bin/docker-compose
```

4. `pihole` über `docker-compose` installieren

- Erstelle einen neuen Ordner und erstelle in den neuen Ordner eine `docker-compose.yml`

```bash
mkdir ~/server/docker/pihole -p
cd ~/server/docker/pihole
```

```bash
nano docker-compose.yml
```

- In den `nano`-Fenster dann folgenden Inhalt reinkopieren

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

- Dann den Inhalt speichern mit Strg + O-Taste dann Enter und dann Strg + X-Taste zum verlassen

- Dann den Container starten mit dem folgenden Befehl

```bash
docker-compose up -d
```

- Das `pihole` ist nun über die IP-Adresse des Gerätes und den in der `docker-compose.yml`-Datei angegebenen Port (Webserver) erreichbar

Quellen: [Docker](https://docs.docker.com/engine/install/debian/#install-using-the-convenience-script); [Pihole](https://github.com/pi-hole/docker-pi-hole#quick-start)

#### Hinweise
- Wo ist das Passwort für das `pihole`?

Der `pihole` Container generiert sich ein eigenes Zufallspasswort.
Das Passwort kann wie folgt geändert werden:

<details>
  <summary>Bis pihole Version: 5</summary>
  
```bash
docker exec -it pihole pihole -a -p
```

</details>

<details>
  <summary>Ab pihole Version: 6</summary>

  ```bash
docker exec -it pihole pihole setpassword
```

</details>

- Der Pihole Container sollte hin und wieder aktualisiert werden

```bash
cd ~/server/docker/pihole
docker-compose pull
docker-compose up -d
```

- Ein automatisches Update über Watchtower ist auch möglich

[Installation von Watchtower](https://youtu.be/6EujFKzsvvA)
