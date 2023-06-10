#!/bin/bash

# Wenn Adguardhome als Docker Image genutzt wird, dann unter "configfile=" den genauen Pfad der AdGuardHome.yaml zu finden ist
configfile=/etc/adguardhome/AdGuardHome.yaml

# Die Textdatei in den die Links eingetragen sind. Es dürfen keine Leerzeilen dazwischen sein.
linkfile=./links.txt

# Vorher in AdguardHome alle bisher bzw. die Standard Listen löschen damit, das Script das besser einfügen kann.


sed -i 's/^filters: .*$/ /g' $configfile

echo "filters:" >> $configfile

while read line; do
    echo "  - enabled: true" >> $configfile
    echo "    url: $line" >> $configfile
    echo "    name: $line"  >> $configfile
    echo "    id: 9$RANDOM" >> $configfile
done < $linkfile

# Nur verwenden wenn Adguardhome nicht als Docker Image läuft ansonsten auskommentieren.
systemctl restart adguardhome.service
