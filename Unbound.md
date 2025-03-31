## Anleitung

https://docs.pi-hole.net/guides/unbound/

-----

## Docker Variante


<details>
  <summary>Pi-hole Version: 5</summary>

```yaml
version: '2'

services:
  pihole:
    container_name: pihole
    image: pihole/pihole:2024.07.0 # <- update image version here, see: https://github.com/pi-hole/docker-pi-hole/releases
    ports:
      - 53:53/tcp   # DNS
      - 53:53/udp   # DNS
      - 80:80/tcp   # HTTP
      - 443:443/tcp # HTTPS
    environment:
      # Standardangaben
      - FTLCONF_LOCAL_IPV4=<IP-Adresse von Docker Host>
      - TZ=Europe/Berlin
      - WEBPASSWORD=<Hier das Passwort eintragen>
      # Für das Lokale erreichen der Geräte unter der Domain des Routers (z.B. fritz.box)
      # Siehe: https://github.com/pi-hole/docker-pi-hole/tree/2024.07.0?tab=readme-ov-file#optional-variables
      - REV_SERVER=
      - REV_SERVER_TARGET=
      - REV_SERVER_DOMAIN=
      - REV_SERVER_CIDR=
      # Verbindung zu Unbound
      - PIHOLE_DNS_=unbound # Hardcoded to our Unbound server
      - DNSSEC=true # Enable DNSSEC
    volumes:
      - etc_pihole:/etc/pihole:rw
      - etc_pihole_dnsmasq:/etc/dnsmasq.d:rw
    networks:
      - pihole-unbound
    restart: unless-stopped
    depends_on:
      - unbound

  unbound:
    container_name: unbound
    image: mvance/unbound:latest
    networks:
      - pihole-unbound
    restart: unless-stopped

networks:
  pihole-unbound:

volumes:
  etc_pihole:
  etc_pihole_dnsmasq:
```

</details>


<details>
  <summary>Pi-hole Version: 6</summary>

```yaml
version: '2'

services:
  pihole:
    container_name: pihole
    image: pihole/pihole:2025.03.1 # <- update image version here, see: https://github.com/pi-hole/docker-pi-hole/releases
    ports:
      - 53:53/tcp   # DNS
      - 53:53/udp   # DNS
      - 80:80/tcp   # HTTP
      - 443:443/tcp # HTTPS
    environment:
      # Standardangaben
      - TZ=Europe/Berlin
      - FTLCONF_webserver_api_password=<Hier das Passwort eintragen>
      # Für das Lokale erreichen der Geräte unter der Domain des Routers (z.B. fritz.box)
      # Siehe: https://github.com/pi-hole/docker-pi-hole/tree/2025.03.1?tab=readme-ov-file#optional-variables
      - FTLCONF_dns_revServers=
      # Verbindung zu Unbound
      - FTLCONF_dns_upstreams=unbound # Hardcoded to our Unbound server
      - FTLCONF_dns_dnssec=true # Enable DNSSEC
    volumes:
      - etc_pihole:/etc/pihole:rw
      - etc_pihole_dnsmasq:/etc/dnsmasq.d:rw
    networks:
      - pihole-unbound
    restart: unless-stopped
    depends_on:
      - unbound

  unbound:
    container_name: unbound
    image: mvance/unbound:latest
    networks:
      - pihole-unbound
    restart: unless-stopped

networks:
  pihole-unbound:

volumes:
  etc_pihole:
  etc_pihole_dnsmasq:
```

</details>

Quelle:
https://discourse.pi-hole.net/t/pihole-v6-unbound-in-one-docker-container/70091/5
