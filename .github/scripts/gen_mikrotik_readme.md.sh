#!/bin/bash
set -e # Beende das Skript bei einem Fehler

function runner() {
TEMPLATE_S1=./.github/markdown_templates/$ARBEITSVERZEICHNIS/$SUCHVERZEICHNIS/$PATCHTHEFILE/01
TEMPLATE_S2=./.github/markdown_templates/$ARBEITSVERZEICHNIS/$SUCHVERZEICHNIS/$PATCHTHEFILE/02

LINKS=/tmp/$SUCHVERZEICHNIS.txt

# Hole die Links
if [ -e "$LINKS" ]; then
  rm "$LINKS"
fi


find ./$ARBEITSVERZEICHNIS/$SUCHVERZEICHNIS/* -name '*' -type f \
  | grep -v ".md" \
  | sed 's#^.#https://raw.githubusercontent.com/RPiList/specials/master#g' \
  | grep -v "DomainSquatting/" \
  | sort >> $LINKS

find ./$ARBEITSVERZEICHNIS/$SUCHVERZEICHNIS/* -name '*' -type f \
  | grep -v ".md" \
  | sed 's#^.#https://raw.githubusercontent.com/RPiList/specials/master#g' \
  | grep "DomainSquatting/" \
  | sort >> $LINKS

# Lösche die Datei
rm $ARBEITSVERZEICHNIS/$SUCHVERZEICHNIS/$PATCHTHEFILE

# Erstelle die Datei
# Schicht 1
while read line; do
    echo "$line " >> $ARBEITSVERZEICHNIS/$SUCHVERZEICHNIS/$PATCHTHEFILE
done < $TEMPLATE_S1

# Die Links
while read line; do
    echo "$line " >> $ARBEITSVERZEICHNIS/$SUCHVERZEICHNIS/$PATCHTHEFILE
done < $LINKS

# Schicht 2
while read line; do
    echo "$line " >> $ARBEITSVERZEICHNIS/$SUCHVERZEICHNIS/$PATCHTHEFILE
done < $TEMPLATE_S2

}


# Setzte Arbeitsverzeichnis
ARBEITSVERZEICHNIS=Mikrotik-Hosts

# Voreinstellungen 1
SUCHVERZEICHNIS=IPv4
PATCHTHEFILE=readme.md

runner

# Voreinstellungen 2
SUCHVERZEICHNIS=IPv6
PATCHTHEFILE=readme.md

runner

