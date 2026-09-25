## Anleitung

https://docs.pi-hole.net/guides/unbound/

-----

## Docker Variante

<details>
  <summary>docker-compose.yml</summary>

```yaml
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
      #- 67:67/udp   # DHCP
      #- 123:123/udp # NTP
    environment:
      # Standardangaben
      - TZ=Europe/Berlin
      - FTLCONF_webserver_api_password=<Hier das Passwort eintragen>
      # Für das Lokale erreichen der Geräte unter der Domain des Routers (z.B. fritz.box)
      # Siehe: https://github.com/pi-hole/docker-pi-hole?tab=readme-ov-file#optional-variables
      - FTLCONF_dns_revServers=
      # Verbindung zu Unbound
      - FTLCONF_dns_upstreams=unbound#5335 # Hardcoded to our Unbound server
      - FTLCONF_dns_dnssec=true # Enable DNSSEC
      # Restliche Angaben
      - FTLCONF_dns_listeningMode=ALL # If using Docker's default `bridge` network setting the dns listening mode should be set to 'ALL'
    volumes:
      - etc_pihole:/etc/pihole:rw
      - etc_pihole_dnsmasq:/etc/dnsmasq.d:rw
    networks:
      - pihole-unbound
    cap_add:
      #- NET_ADMIN # Required if you are using Pi-hole as your DHCP server, else not needed
      #- SYS_TIME  # Required if you are using Pi-hole as your NTP client to be able to set the host's system time
      - SYS_NICE  # Optional, if Pi-hole should get some more processing time
    restart: unless-stopped
    depends_on:
      - unbound

  unbound:
    container_name: unbound
    image: alpinelinux/unbound:latest
    networks:
      - pihole-unbound
    restart: unless-stopped
    post_start:
      - command: |
          sh -c "cat > /etc/unbound/unbound.conf << EOF
          server:
            verbosity: 0
            interface: 0.0.0.0
            port: 5335
            do-ip4: yes
            do-udp: yes
            do-tcp: yes
            do-ip6: yes
            prefer-ip6: no
            harden-glue: yes
            harden-dnssec-stripped: yes
            use-caps-for-id: no
            edns-buffer-size: 1232
            prefetch: yes
            num-threads: $(nproc 2>/dev/null || echo 1)
            so-rcvbuf: 1m
            private-address: 192.168.0.0/16
            private-address: 169.254.0.0/16
            private-address: 172.16.0.0/12
            private-address: 10.0.0.0/8
            private-address: fd00::/8
            private-address: fe80::/10
            private-address: 192.0.2.0/24
            private-address: 198.51.100.0/24
            private-address: 203.0.113.0/24
            private-address: 255.255.255.255/32
            private-address: 2001:db8::/32
            access-control: 10.0.0.0/8 allow
            access-control: 127.0.0.0/8 allow
            access-control: 172.16.0.0/12 allow
            access-control: 192.168.0.0/16 allow
            access-control: fd00::/8 allow
            access-control: fe80::/10 allow
            access-control: ::1/128 allow
          EOF
          until kill -HUP $(pidof unbound) >/dev/null 2>&1; do
            sleep 1
          done"
    healthcheck:
      interval: 30s
      timeout: 10s
      retries: 3
      test: >
        CMD nslookup one.one.one.one 127.0.0.1:5335 >/dev/null 2>&1 || \
            nslookup dns.google 127.0.0.1:5335 >/dev/null 2>&1 || \
            exit 1

networks:
  pihole-unbound:

volumes:
  etc_pihole:
  etc_pihole_dnsmasq:
```

</details>

Quelle:
https://discourse.pi-hole.net/t/pihole-v6-unbound-in-one-docker-container/70091/5
