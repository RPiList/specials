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
# Aufrufparameter: 1. Backupverzeichnis              --> Pfad an dem das Archiv abgelegt werden soll
#                  2. Bereinigungsintervall in Tagen --> (optional) Logs und Archive älter als
#                                                                   X Tage löschen.
#                                                                   Standartwert ist: 90 Tage
#
# Aufruf:          sudo ./backupPiholeSettings.sh /mnt/nas/rpi/
#                  optional: sudo ./backupPiholeSettings.sh /mnt/nas/rpi/ 180
#
# Ausgabedateien: /var/log/svpihole/Ym_backupPiholeSettings.sh.log   --> monatliches Logfile
#                 /var/log/svpihole/backupPiholeSettings.cron.log    --> Logifile des Cron-Jobs
#                 /.../pi-hole-teleporter_Y-m-d_H-M-S.tar.gz         --> Teleporter Sicherungsarchiv
#
# Installation:   1. Script downloaden:
#                    wget https://raw.githubusercontent.com/RPiList/specials/master/dev/backupPiholeSettings.sh
#                 2. Script mittels sudo chmod +x backupPiholeSettings.sh ausführbar machen.
#
# Installation:   1. Script mittels sudo cp backupPiholeSettings.sh /root nach /root kopieren.
# (als Cron-Job)  2. Script mittels sudo chmod +x /root/backupPiholeSettings.sh ausführbar machen.
#                 3. Cron-Job mit sudo crontab -e erstellen
#                    Am Ende der Datei z.B. folgendes einfügen um das Script 2 x monatlich am 15. und 30. um 00:00 Uhr
#                    auszuführen:
#
#                    0 0 */15 * * /root/backupPiholeSettings.sh /mnt/nas/rpi/ > /var/log/svpihole/backupPiholeSettings.cron.log
#
#                  4. Datei speichern und schliessen (im nano Editor: Strg+o/Enter/Strg+x).
#
# Versionshistorie:
# Version 1.0.0 - [Zelo72]          - initiale Version
#         1.0.1 - [Zelo72/AleksCee] - Bereinigung von Minuten auf Tage umgestellt und Unterscheidung zwischen
#                                     Startpunkt und Suchmuster.
#                                   - Aufrufparameter für Bereinigungsintervall in Tagen hinzugefügt,
#                                     Standardwert ist 90 Tage

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

# Bereiniung nach x Tagen, Default: 90 Tage
cleaningInterval=90
# Prüfen ob ein Bereinigungsintervall in Tagen als 2. Aufrufparameter mitgegeben wurde.
if [ -n "$2" ]; then
    cleaningInterval=$2
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

# Logverzeichnis bereinigen, Logs älter als 90 Tage werden gelöscht.
writeLog "[I] Bereinige Logverzeichnis $logDir ..."
find $logDir -daystart -type f -mtime +"$cleaningInterval" -name \*backupPiholeSettings\*.log -exec rm -v {} \;
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

# Alte Teleporter Archive bereinigen, Archive älter als 90 Tage werden gelöscht.
writeLog "[I] Bereinige Backupverzeichnis $backupDir älter als $cleaningInterval Tage ..."
find "$backupDir" -daystart -type f -mtime +"$cleaningInterval" -name pi-hole-teleporter\*.\* -exec rm -v {} \;

writeLog "[I] Alte Backuparchive unter $backupDir wurden bereinigt."

writeLog "[I] Ende | Logfile: $log"
