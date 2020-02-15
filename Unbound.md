Anleitung unter:

https://docs.pi-hole.net/guides/unbound/

Update-Datei:

#!/bin/sh
wget -O root.hints https://www.internic.net/domain/named.root
rm /var/lib/unbound/roots.hints
mv root.hints /var/lib/unbound/

Crontab Eintrag:
0 0 1 */6 * /root/updatehints &



