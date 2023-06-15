#!/bin/bash

# Hinweis: Wenn Adguardhome als Docker Image genutzt wird, dann unter "configfile=" den genauen Pfad der AdGuardHome.yaml zu finden ist, eintragen.
configfile=/etc/adguardhome/AdGuardHome.yaml

# Hinweis: Die Textdatei in den die Links eingetragen sind.
linkfile=links.txt

# Hinweis: Vorher in AdguardHome alle bisher eingetragenen bzw. die Standard Listen löschen damit, das Script das ohne Probleme einfügen kann.

# Hinweis: Download der Listen (auskommentieren wenn eine eigene links.txt erstellt wurde)
curl -L -o $linkfile https://github.com/RPiList/specials/raw/master/Blocklisten.md

# Erklärung: Mit # beginenden Zeilen Wörter entfernen
sed -i 's/^#.*$//g' $linkfile
# Erklärung: Leere Leerzeilen entfernen
sed -i '/^$/d' $linkfile
# Erklärung: Doppelte Zeilen filtern
sort -u $linkfile > $linkfile.tmp
mv $linkfile.tmp $linkfile

# Erklärung: Bestimmte Zeile aus configfile löschen
sed -i 's/^filters: .*$//g' $configfile

# Erklärung: Einfügen der links aus der linkfile
echo "filters:" >> $configfile

while read line; do
    echo "  - enabled: true" >> $configfile
    echo "    url: $line" >> $configfile
    echo "    name: $line"  >> $configfile
    echo "    id: 9$RANDOM$RANDOM" >> $configfile
done < $linkfile


# Hinweis: Nur verwenden wenn Adguardhome nicht als Docker Image läuft ansonsten auskommentieren.
systemctl restart adguardhome.service