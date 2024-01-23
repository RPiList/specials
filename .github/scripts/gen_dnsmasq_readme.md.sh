#!/bin/bash

# Voreinstellungen
SUCHVERZEICHNIS=DNSMASQ
PATCHTHEFILE=readme.md

TEMPLATE_S1=./Template/$SUCHVERZEICHNIS/$PATCHTHEFILE/01
TEMPLATE_S2=./Template/$SUCHVERZEICHNIS/$PATCHTHEFILE/02

LINKS=/tmp/$SUCHVERZEICHNIS.txt

# Hole die Links
rm $LINKS

find ./$SUCHVERZEICHNIS/* -name '*' -type f \
  | grep -v ".md" \
  | sed 's#^.#https://raw.githubusercontent.com/RPiList/specials/master#g' \
  | grep -v "DomainSquatting/" \
  | sort >> $LINKS

find ./$SUCHVERZEICHNIS/* -name '*' -type f \
  | grep -v ".md" \
  | sed 's#^.#https://raw.githubusercontent.com/RPiList/specials/master#g' \
  | grep "DomainSquatting/" \
  | sort >> $LINKS

# Lösche die Datei
rm $SUCHVERZEICHNIS/$PATCHTHEFILE

# Erstelle die Datei
# Schicht 1
while read line; do
    echo "$line " >> $SUCHVERZEICHNIS/$PATCHTHEFILE
done < $TEMPLATE_S1

# Die Links
while read line; do
    echo "$line " >> $SUCHVERZEICHNIS/$PATCHTHEFILE
done < $LINKS

# Schicht 2
while read line; do
    echo "$line " >> $SUCHVERZEICHNIS/$PATCHTHEFILE
done < $TEMPLATE_S2
