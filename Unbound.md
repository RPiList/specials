**Anleitung**

https://docs.pi-hole.net/guides/unbound/

**Update-Datei**

Die Datei `updateroot` öffnen:
```
nano /root/updateroot
```

Folgenden Inhalt einfügen:
```
#!/bin/bash

if wget -O /tmp/root.hints https://www.internic.net/domain/named.root ; then
    mv /tmp/root.hints /var/lib/unbound/root.hints
    systemctl restart unbound
fi
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
