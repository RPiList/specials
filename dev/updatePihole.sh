#!/bin/bash

# Script: updatePihole.sh - https://github.com/RPiList/specials (/dev/)
#
# Beschreibung: Das Script aktualisiert bei jedem Lauf die Pi-hole Gravity (gravity.list) auf Basis der in Pi-hole
#               konfigurierten Blocklisten (adlists.list). Zusaetzlich werden, wenn das Script an einem Sonntag ausgefuehrt
#               wird, die Raspberry Pakete und die Pi-hole Software selbst aktualisiert sofern ein Update vorliegt.
#               Bei Bedarf wird ein Gravity-Update Bericht als Mail versendet. Dieser beinhaltet neben einem Pi-Hole
#               Gesundheitstatus auch die Statistik für das Pi-Hole und Gravity Update.
#
# Aufruf:       sudo ./updatePihole.sh rootoma@senioren.xy <-- mit Mailversand
#               sudo ./updatePihole.sh                     <-- ohne Mailversand
#
# Ausgabedateien: /var/log/svpihole/Ymd_updatePihole.sh.log   --> taegliches Logfile
#                 /var/log/svpihole/updatePihole.stats.log    --> Pi-hole Gravity Update Bericht/Statistik
#                 /var/var/log/svpihole/updatePihole.cron.log --> Logifile des Cron-Jobs
#
# Installation:   1. Script nach /root kopieren.
# (als Cron-Job)  2. mit sudo chmod +x updatePihole.sh das Script ausfuehrbar machen.
#                 3. Cron-Job mit sudo crontab -e erstellen
#                    Am Ende der Datei z.B. folgendes einfuegen um das Script taeglich um 03:00 Uhr zu starten
#                    und eine Mail mit dem Gravity Update Bericht an "rootoma" zu schicken:
#                      0 3 * * * /root/updatePihole.sh rootoma@senioren.xy > /var/log/svpihole/updatePihole.cron.log
#                  4. Datei speichern und schliessen.
#
#                  -------
#                 :HINWEIS: Damit der Mailversand funktioniert, muss msmtp und mailutils installiert und konfiguriert
#                  -------  sein. Eine Anleitung dazu ist hier zu finden:
#                                   https://github.com/RPiList/specials/blob/master/dev/EinrichtungMailversand.md
#
# Versionshistorie:
# Version 1.0.0 - [Zelo72]          - initiale Version
#         1.0.1 - [Zelo72/AleksCee] - Umstellung von wc -l auf grep -Evc '^#|^$' um auskommentierte und leere Zeilen
#                                     beim Zählen herauszufiltern.
#                                   - Damit die Mail mit dem Abschlussbericht nicht vom Mailserver des Empfaengers
#                                     als Spam eingestuft wird, wurde die Ausgabe der Top 50 hinzugefuegten und
#                                     geloeschten Domains auskommentiert.
#                                   - Gesundheitsstatus von JA/NEIN/UNDEFINIERT auf OK/FEHLER/NICHT DURCHGEFUEHRT
#                                     umgestellt.
#                                   - Von Gesamtlogfile auf taegliche Logs umgestellt
#                                   - Delimiter in der Ausgabe entfernt
#         1.0.2 - [Zelo72/AleksCee] - n Sekunden warten bevor der DNS Check nach dem Pi-hole Update durchgefuehrt
#                                     wird. Der Pi-Hole DNS Service braucht manchmal etwas bis er verfuegbar ist.
#                                   - Versuch von RestartDNS wenn der DNS Service nach dem Pi-hole Update nicht
#                                     mehr reagiert.
#                                   - Möglicher Fehler Exitcode 127 bei Aufruf des pihole binaries aus einem Cron
#                                     Job heraus behoben: von pihole -u/-g auf /usr/local/bin/pihole ... umgestellt.
#         1.0.3 - [Zelo72]          - Beschreibung, Aufruf, Ausgabedateien und Installation beschrieben.
#         1.0.4 - [Zelo72]          - Logverzeichnis bereinigen, Logs aelter als 7 Tage werden geloescht.
#

# Prüfen ob das Script als root ausgefuehrt wird
if [ "$(id -u)" != "0" ]; then
   echo "Das Script muss mit Rootrechten ausgeführt werden!"
   exit 1
fi

# *** Initialisierung ***

# Logging initialisieren
logDir=/var/log/svpihole
log=$logDir/$(date +'%Y%m%d')_updatePihole.sh.log
mkdir -p $logDir

# Hilfsfunktion zum loggen
writeLog() {
   echo -e "[$(date +'%Y.%m.%d-%H:%M:%S')]" "$*" | tee -a "$log"
}
writeLog "[I] Start | Logfile: $log"

# Tempverzeichnis initialisieren
tmp=/tmp/svpihole
writeLog "[I] Initialisiere Tempverzeichnis $tmp ..."
mkdir -p $tmp
cd $tmp || exit

# Logverzeichnis bereinigen, Logs aelter als 7 Tage (10080 Minuten) werden geloescht.
writeLog "[I] Bereinige Logverzeichnis $logDir ..."
find $logDir/*updatePihole*.log -type f -mmin +10080 -exec rm {} \;
writeLog "[I] Logverzeichnis $logDir bereinigt."

# Variablen fuer Dateien
piholeDir=/etc/pihole
piholeBinDir=/usr/local/bin
gravListPihole=$piholeDir/gravity.list
gravListBeforeUpdate=$tmp/gravity_before_update.list
gravListDiff=$tmp/gravity_diff.list
logStats=$logDir/updatePihole.stats.log

# Variablen fuer "Gesundheitsstatus": -1: Undefiniert / 0: true / >0: false
piholeUpdateStatus=-1
piholeGravUpdateStatus=-1
dnsTestStatus=-1
inetTestStatus=-1
rebootRequired="NEIN"

# *** Hilfsfunktionen ***

status() {
   case "$*" in
   -1)
      echo "NICHT DURCHGEFUEHRT"
      ;;
   0)
      echo "OK"
      ;;
   1 | *)
      echo "FEHLER #Exitcode:$*"
      ;;
   esac
}

# Internetverbindung testen
checkinet() {
   writeLog "[I] Teste Internetverbindung ..."
   if ! (ping -c1 8.8.8.8 >/dev/null); then
      writeLog "[E] Keine Internetverbindung! Das Script wird beendet!"
      inetTestStatus=1
      exit 1
   fi
   writeLog "[I] Internetverbindungstest erfolgreich."
   inetTestStatus=0
   return 0
}

# DNS-Namensaufloesung testen
checkdns() {
   writeLog "[I] Teste DNS Namensaufloesung ..."
   if ! (ping -c1 google.de >/dev/null); then
      writeLog "[E] Keine DNS Namensaufloesung moeglich!"
      dnsTestStatus=1
      return 1
   fi
   writeLog "[I] DNS Namensaufloesung erfolgreich."
   dnsTestStatus=0
   return 0
}

# Auf DNS Service warten
waitfordns() {
   writeLog "[I] Warte $1 Sek. auf DNS Service ..."
   sleep "$1"
}

# *** Pi-hole Update ***

# Internetverbindung / DNS testen
checkinet # besteht keine Internetverbindung wird das Script mit exitcode 1 beendet
checkdns

# Nur wenn dieses Script Sonntags am Wochentag 0 ausgeführt wird:
# die Raspberry Pakete und die Pi-hole Software selbst updaten.
if test "$(date "+%w")" -eq 0; then # Sonntags = Wochentag 0
   # Raspberry Pakete updaten
   writeLog "[I] Raspberry Pakete updaten ..."
   apt-get update
   apt-get -y upgrade

   # Raspberry Pakete bereinigen
   writeLog "[I] Raspberry Pakete bereinigen ..."
   apt-get -y autoremove
   apt-get -y clean

   # Pi-hole updaten
   writeLog "[I] Pi-hole updaten ..."
   $piholeBinDir/pihole -up
   piholeUpdateStatus=$?
   writeLog "[I] Pi-hole Update exitcode: $piholeUpdateStatus"

   # Pruefen ob durch die Updates ein Reboot erforderlich ist
   writeLog "[I] Pruefe ob ein Reboot erforderlich ist ..."
   if [ -f /var/run/reboot-required ]; then
      writeLog "[W] REBOOT nach Update erforderlich!"
      echo "*************************"
      echo "R E B O O T erforderlich!"
      echo "*************************"
      rebootRequired="JA"
   fi
fi

# *** Pi-hole Gravity Update ***

# AKtuelle Gravity Liste vom Pi-hole zwischenspeichern und
# Pi-hole Gravity aktualisieren
writeLog "[I] Aktualisiere Pi-hole Gravity $gravListPihole ..."
cp $gravListPihole $gravListBeforeUpdate
$piholeBinDir/pihole -g # Pi-hole Gravity aktualisieren
piholeGravUpdateStatus=$?
writeLog "[I] Pi-hole Gravity Update exitcode: $piholeGravUpdateStatus"

# DNS nach Gravity Update testen
waitfordns 30
checkdns
if [ ! $? ]; then
   writeLog "[E] Pi-hole DNS Service reagiert nicht, versuche RestartDNS ..."
   $piholeBinDir/pihole restartdns
   waitfordns 60
   checkdns
fi

# Aktualisierte Pi-hole Gravityliste mit Gravityliste vor der Aktualisierung
# vergleichen und Aenderungen (hinzugefuegte/geloeschte Eintraege) in
# $gravListDiff Datei zur weiteren Auswertung speichern
writeLog "[I] Erstelle Aenderungs-Gravityliste $gravListDiff ..."
diff $gravListPihole $gravListBeforeUpdate | grep '[><]' >$gravListDiff
writeLog "[I] Aenderungs-Gravityliste mit $(grep -Evc '^#|^$' $gravListDiff) Eintraegen erstellt."

# *** Pi-hole Gravity Update Bericht/Statistik ***

# Id für Pi-hole Gravity Update Bericht erzeugen
id=$(date +"%Y.%m.%d-%H%M%S")

# Gravity Update Bericht erzeugen und in die unter $logStats angegebene Datei schreiben.
writeLog "[I] Erstelle PiHole Gravity Update Bericht/Statistik $id ..."
(
   echo "Pi-hole Gravity Update Bericht: $id"
   echo ""
   echo "# Pi-hole Gesundheitsstatus #"
   echo ""
   echo "Reboot erforderlich: $rebootRequired"
   echo "Internetverbindung: $(status $inetTestStatus)"
   echo "DNS Test: $(status $dnsTestStatus)"
   echo "Pi-hole Update: $(status $piholeUpdateStatus)"
   echo "Pi-hole Gravity Update: $(status $piholeGravUpdateStatus)"
   echo ""
   echo "# Pi-hole Statistik #"
   echo ""
   echo "Domains Gravitylist: $(grep -Evc '^#|^$' $gravListPihole)"
   echo "Domains Blacklist: $(grep -Evc '^#|^$' $piholeDir/blacklist.txt)"
   echo "RegEx-Filter Blacklist: $(grep -Evc '^#|^$' $piholeDir/regex.list)"
   echo "Domains Whitelist: $(grep -Evc '^#|^$' $piholeDir/whitelist.txt)"
   echo ""
   echo "Anzahl Blocklisten: $(grep -Evc '^#|^$' $piholeDir/adlists.list)"
   echo ""
   echo "# Pi-hole Gravity Updatestatistik #"
   echo ""
   echo "(+): $(grep -c '<' $gravListDiff) hinzugefuegte Domains"
   echo "(-): $(grep -c '>' $gravListDiff) geloeschte Domains"
   echo "(S): $(grep -Evc '^#|^$' $gravListDiff) insgesamt geaenderte Domains"

   # Auskommentiert, damit der Spamfilter des Mailservers wegen den Domains nicht "glueht"!
   #echo ""
   #echo "(+) Hinzugefuegte Domains (Top 50):"
   #grep -m50 '<' $gravListDiff
   #echo ""
   #echo "(-) Geloeschte Domains (Top 50):"
   #grep -m50 '>' $gravListDiff
) | tee $logStats #Ausgaben innerhalb von () in die $logStats Datei schreiben
writeLog "[I] Pi-hole Gravity Update Bericht/Statistik $logStats erstellt."

# *** E-Mail Versand des Update Berichtes ***

# Aufrufparameter 1: sudo ./updatePihole.sh rootoma@seniorenstift.xy
email="$1"

# Mail mit Gravity Update Bericht wird nur versendet wenn beim Aufruf des Scriptes eine
# Mailadresse mit uebergeben wurde!
if [ -n "$email" ]; then
   writeLog "[I] E-Mail Pi-hole Gravity Update Bericht $id wird an $email versendet ..."
   mail <$logStats -s "Pi-hole Gravity Update Bericht $id" "$email"

   # Pruefen ob der E-Mailversand fehlgeschlagen ist
   if [ $? -ne 0 ]; then
      writeLog "[E] E-Mailversand an $email fehlgeschlagen!"
   else
      writeLog "[I] E-Mailversand an $email erfolgreich."
   fi
fi
writeLog "[I] Ende | Logfile: $log"
