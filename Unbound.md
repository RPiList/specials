Anleitung unter:

https://docs.pi-hole.net/guides/unbound/

Update-Datei:

#!/bin/sh<br>
wget -O root.hints https://www.internic.net/domain/named.root<br>
rm /var/lib/unbound/roots.hints<br>
mv root.hints /var/lib/unbound/<br>

Crontab Eintrag:<br>
0 0 1 */6 * /root/updatehints &



