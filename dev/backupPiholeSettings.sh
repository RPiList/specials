#!/bin/bash

# Script: backupPiholeSettings.sh - https://github.com/RPiList/specials (/dev/)
#
# Beschreibung: Das Script sichert mittels pihole -a teleporter die relevanten Pihole Konfigurationsdateien in einem
#               Teleporter tar.gz Archiv. Dieses Archiv lässt sich in der Weboberfläche des Pihole's unter
#               Settings > Teleporter wieder importieren womit die Pihole-Konfiguration wiederhergestellt wird.
#
#               Das Teleporterarchiv beinhaltet:
#                   - dnsmasq Konfiguration
#                   - Pihole Konfiguration setupVars.conf
#                   - Pihole-listen: adlists.list, auditlog.list, blacklist.txt, regex.list, whitelist.txt
#
# Aufruf:       sudo ./backupPiholeSettings.sh /mnt/nas/rpi/ <-- Pfad an dem das Archic abgelegt werden soll
#
# Ausgabedateien: /var/log/svpihole/Ym_backupPiholeSettings.sh.log   --> monatliches Logfile
#                 /var/log/svpihole/backupPiholeSettings.cron.log    --> Logifile des Cron-Jobs
#                 /.../pi-hole-teleporter_Y-m-d_H-M-S.tar.gz         --> Teleporter Sicherungsarchiv
#
# Installation:   1. Script nach /root kopieren.
# (als Cron-Job)  2. mit sudo chmod +x backupPiholeSettings.sh das Script ausführbar machen.
#                 3. Cron-Job mit sudo crontab -e erstellen
#                    Am Ende der Datei z.B. folgendes einfügen um das Script 2 x monatlich am 15. und 30. um 00:00 Uhr
#                    auszuführen:
#
#                    0 0 */15 * * /root/backupPiholeSettings.sh /mnt/nas/rpi/ > /var/log/svpihole/backupPiholeSettings.cron.log
#
#                  4. Datei speichern und schliessen.
#
# Versionshistorie:
# Version 1.0.0 - [Zelo72] - initiale Version
#

# Prüfen ob das Script als root ausgeführt wird
if [ "$(id -u)" != "0" ]; then
    echo "Das Script muss mit Rootrechten ausgeführt werden!"
    exit 1
fi

# Prüfen ob ein Backupverzeichnis angegeben wurde
if [ -z "$1" ]; then
    echo "Es wurde kein Backupverzeichnis angegeben!"
    exit 1
fi

# Prüfen ob das Backupverzeichnis existiert
if [ ! -d "$1" ]; then
    echo "Backupverzeichnis $1 existiert nicht!"
    exit 1
fi

# *** Initialisierung ***

# Logging initialisieren
logDir=/var/log/svpihole
log=$logDir/$(date +'%Y%m')_backupPiholeSettings.sh.log
mkdir -p $logDir

# Hilfsfunktion zum loggen
writeLog() {
    echo -e "[$(date +'%Y.%m.%d-%H:%M:%S')]" "$*" | tee -a "$log"
}
writeLog "[I] Start | Logfile: $log"

# Logverzeichnis bereinigen, Logs älter als 90 Tage (129600 Minuten) werden gelöscht.
writeLog "[I] Bereinige Logverzeichnis $logDir ..."
find $logDir/*backupPiholeSettings*.log -type f -mmin +129600 -exec rm {} \;
writeLog "[I] Logverzeichnis $logDir bereinigt."

# Variablen
piholeBinDir=/usr/local/bin
backupDir=$1

# *** Pihole Backup ***

writeLog "[I] Führe Pihole Backup durch ..."
cd "$backupDir" || exit
$piholeBinDir/pihole -a teleporter
if [ ! $? ]; then
    writeLog "[E] Fehler beim Backup, Exitcode: $?"
else
    writeLog "[I] Backup erfolgreich durchgeführt."
fi

# Alte Teleporter Archive bereinigen, Archive älter als 90 Tage (129600 Minuten) werden gelöscht.
writeLog "[I] Bereinige Backupverzeichnis $backupDir ..."
find "$backupDir"/pi-hole-teleporter*.* -type f -mmin +129600 -exec rm {} \;
writeLog "[I] Alte Backuparchive unter $backupDir wurden bereinigt."

writeLog "[I] Ende | Logfile: $log"
