## Anleitung

https://docs.pi-hole.net/guides/unbound/

-----

## Docker Variante

<details>
  <summary>docker-compose.yml</summary>

```yaml
version: '2'

services:
  pihole:
    container_name: pihole
    # Prüfen Sie unter https://github.com/pi-hole/docker-pi-hole/releases nach,
    # ob eine neuere Version als die hier getaggte Version vorliegt und verwenden Sie diese.
    # Die Verwendung von 'latest' als tag ist auf eigene Gefahr bezüglich "Breaking Changes"
    image: pihole/pihole:latest
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
      # Siehe: https://github.com/pi-hole/docker-pi-hole?tab=readme-ov-file#optional-variables
      - FTLCONF_dns_revServers=
      # Verbindung zu Unbound
      - FTLCONF_dns_upstreams=unbound#5053 # Hardcoded to our Unbound server
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
    image: crazymax/unbound:latest
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
