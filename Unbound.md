**Anleitung**

https://docs.pi-hole.net/guides/unbound/

**Update-Datei**

Die Datei `updateroot` öffnen:
```
nano /root/updateroot
```

Folgenden Inhalt einfügen:
```
#!/bin/sh
wget -O root.hints https://www.internic.net/domain/named.root
rm /var/lib/unbound/root.hints
mv root.hints /var/lib/unbound/
```

Die Datei ausführbar machen:
```
chmod +x /root/updateroot
```

Cronjobs-Datei öffnen:<br>
```
crontab -e
````

Am Ende der Datei folgende Zeile einfügen:
```
0 0 1 */6 * /root/updateroot &
```
