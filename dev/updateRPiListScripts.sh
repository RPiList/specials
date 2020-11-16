#!/bin/bash

# Script: updateRPiListScripts.sh - https://github.com/RPiList/specials (/dev/)
#
# Beschreibung: Das Script lädt die im Array $scripturls angegebenen Scripte vom RPiList Github herunter und macht diese
#               mit chmod +x auführbar. Sind die Scripte im angegebenen Downloadverzeichnis bereits vorhanden, werden
#               diese - sofern die Github-Verion neuer ist - überschrieben.
#               Wird beim Aufruf kein Downloadverzeichnis angegeben, wird das Homeverzeichnis des Benutzers verwendet
#               von dem dieses Script aufgerufen wurde. Für Benutzer pi --> /home/pi/
#
# Aufruf:       sudo ./updateRPiListScripts.sh /root  <-- Scripts ins Verzeichnis /root downloaden
#               ./updateRPiListScripts.sh             <-- Scripts ins Benutzerverzeichnis $HOME downloaden
#
# Versionshistorie:
# Version 1.0.0 - [Zelo72]          - initiale Version

# Downloadverzeichnis Default: Homeverzeichnis des Benutzers
downloadDir=$HOME

# Downloadverzeichnis übernemhmen falls angegeben
if [ -n "$1" ]; then
    downloadDir=$1
fi

# Prüfen ob das Downloadverzeichnis existiert
if [ ! -d "$downloadDir" ]; then
    echo "Downloadverzeichnis $downloadDir existiert nicht!"
    exit 1
fi

# In Downloadverzeichnis wechseln
cd "$downloadDir" || exit

# Script-Dateien die heruntergeladen werden sollen, weitere einfach hinzufügen
scripturls=("https://raw.githubusercontent.com/RPiList/specials/master/dev/updatePihole.sh"
    "https://raw.githubusercontent.com/RPiList/specials/master/dev/backupPiholeSettings.sh")

# Scripte herunterladen und in $DownloadDir speichern/updaten und mit chmod ausführbar machen
for url in "${scripturls[@]}"; do
    # Script downloaden
    wget -N "$url"
    # Scriptdateiname aus URL mittels RegEx extrahieren
    scriptfile=$(echo "$url" | sed 's/.*\///')
    # Script ausführbar machen
    chmod -v +x "$downloadDir"/"$scriptfile"
done
