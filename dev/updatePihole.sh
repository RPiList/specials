#!/bin/bash

# Script: updatePihole.sh - https://github.com/Zelo72/rpi (/pihole/)
#
# Beschreibung: Das Script aktualisiert bei jedem Lauf die Pi-hole Gravity auf Basis der in Pi-hole
#               konfigurierten Blocklisten. Zusaetzlich werden, wenn das Script an einem Sonntag ausgefuehrt
#               wird, Raspberry Paketupdates simuliert.
#               Bei Bedarf wird ein Gravity-Update Bericht als Mail versendet. Dieser beinhaltet neben einem Pi-Hole
#               Gesundheitstatus auch die Statistik für das Pi-Hole und Gravity Update.
#               Das Script ist mit Pi-hole 4.x und 5.x kompatibel.
#
# Aufruf:       sudo ./updatePihole.sh name@domain.xy <-- mit Mailversand
#               sudo ./updatePihole.sh                <-- ohne Mailversand
#
# Ausgabedateien: /var/log/pihole/Ymd_updatePihole.sh.log   --> taegliches Logfile
#                 /var/log/pihole/updatePihole.stats.log    --> Pi-hole Gravity Update Bericht/Statistik
#                 /var/var/log/pihole/updatePihole.cron.log --> Logifile des Cron-Jobs
#
# Installation:   1. Script downloaden:
#                    wget -N https://raw.githubusercontent.com/Zelo72/rpi/master/pihole/updatePihole.sh
#                 2. Script mittels sudo chmod +x updatePihole.sh ausführbar machen.
#
# Installation:   1. Script mittels sudo cp updatePihole.sh /root nach /root kopieren.
# (als Cron-Job)  2. Script mittels sudo chmod +x /root/updatePihole.sh ausfuehrbar machen.
#                 3. Cron-Job mit sudo crontab -e erstellen
#                    Am Ende der Datei z.B. folgendes einfuegen um das Script taeglich um 03:00 Uhr zu starten
#                    und eine Mail mit dem Gravity Update Bericht an "name@domain.xy" zu schicken:
#
#                      0 3 * * * /root/updatePihole.sh name@domain.xy > /var/log/pihole/updatePihole.cron.log 2>&1
#
#                  4. Datei speichern und schliessen. (im nano Editor: Strg+o/Enter/Strg+x).
#
#                  -------
#                 :HINWEIS: Damit der Mailversand funktioniert, muss msmtp und mailutils installiert und konfiguriert
#                  -------  sein. Eine Anleitung dazu ist hier zu finden:
#                                 https://github.com/Zelo72/rpi/blob/master/tutorials/Mailversand-RPi-einrichten.md
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
#         1.0.5 - [Zelo72/AleksCee] - Logbereinigung von Minuten auf Tage umgestellt und Unterscheidung zwischen
#                                     Startpunkt und Suchmuster
#         1.0.6 - [Zelo72]          - Gravity Update Bericht erweitert: Hostname, CPU Temperatur, RAM Nutzung,
#                                                                       HDD Nutzung, Pi-hole Status (aktiv/offline)
#                                   - Fehler behoben: Nach waitfordns und anschliessend fehlgeschlagenem DNS-Test
#                                                     wurde der Code im If-Zweig zum erneuten DNS-Test nicht
#                                                     ausgefuehrt.
#         1.0.7 - [Zelo72]          - Kompatiblitaet fuer Pihole 5.x
#         1.0.8 - [Zelo72]          - Auf Update nur simulieren nicht automatisch durchführen umgestellt.
#                                     Betrifft Raspberry Pakete und das Pi-hole Softwareupdate.
#

# Prüfen ob das Script als root ausgefuehrt wird
if [ "$(id -u)" != "0" ]; then
   echo "Das Script muss mit Rootrechten ausgeführt werden!"
   exit 1
fi

# *** Initialisierung ***

# Logging initialisieren
logDir=/var/log/pihole
log=$logDir/$(date +'%Y%m%d')_updatePihole.sh.log
mkdir -p $logDir

# Hilfsfunktion zum loggen
writeLog() {
   echo -e "[$(date +'%Y.%m.%d-%H:%M:%S')]" "$*" | tee -a "$log"
}
writeLog "[I] Start | Logfile: $log"

# Tempverzeichnis initialisieren
tmp=/tmp/pihole
writeLog "[I] Initialisiere Tempverzeichnis $tmp ..."
mkdir -p $tmp
cd $tmp || exit

# Logverzeichnis bereinigen, Logs aelter als 7 Tage werden geloescht.
writeLog "[I] Bereinige Logverzeichnis $logDir ..."
find $logDir -daystart -type f -mtime +7 -name \*updatePihole\*.log -exec rm -v {} \;
writeLog "[I] Logverzeichnis $logDir bereinigt."

# Variablen fuer Dateien
piholeDir=/etc/pihole
piholeBinDir=/usr/local/bin
gravityDB=$piholeDir/gravity.db
gravListPihole=$piholeDir/gravity.list
gravListBeforeUpdate=$tmp/gravity_before_update.list
gravListDiff=$tmp/gravity_diff.list
logStats=$logDir/updatePihole.stats.log

# Pihole 5.x?
[ -f $gravityDB ] && pihole5=1 || pihole5=0

# Variablen fuer "Gesundheitsstatus": -1: Undefiniert / 0: true / >0: false
rpiUpdateStatus=-1
piholeGravUpdateStatus=-1
dnsTestStatus=-1
inetTestStatus=-1

# *** Hilfsfunktionen ***

status() {
   case "$*" in
   -3)
      echo "|> UPDATES VERFUEGBAR! <|"
      ;;
   -2)
      echo "KEINE UPDATES VERFUEGBAR"
      ;;
   -1)
      echo "NICHT UEBERPRUEFT"
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
# das Raspberry Paket Update simulieren.
if test "$(date "+%w")" -eq 0; then # Sonntags = Wochentag 0
   # Raspberry Paketequellen updaten
   writeLog "[I] Raspberry Paket Update simulieren ..."
   echo ""
   apt-get update
   echo ""

   # Raspberry Paketupdate simulieren
   writeLog "[I] Ermitteln ob Paketupdates vorliegen ..."
   tst=$(apt-get --simulate upgrade | grep ^Inst)
   [ -n "$tst" ] && rpiUpdateStatus=-3 || rpiUpdateStatus=-2

   # Raspberry Pakete bereinigen
   writeLog "[I] Raspberry Pakete bereinigen ..."
   echo ""
   apt-get -y autoremove
   apt-get -y clean
   echo ""
fi

# *** Pi-hole Gravity Update ***

# AKtuelle Gravity Liste vom Pi-hole zwischenspeichern und
# Pi-hole Gravity aktualisieren
# Kompatiblitaet fuer Pihole 5.x
if [ "$pihole5" -eq 1 ]; then
   writeLog "[I] Exportiere Domains aus $gravityDB nach $gravListBeforeUpdate ..."
   sqlite3 "$gravityDB" "select distinct domain from gravity;" >$gravListBeforeUpdate
else
   writeLog "[I] Kopiere $gravListPihole nach $gravListBeforeUpdate ..."
   cp $gravListPihole $gravListBeforeUpdate
fi
writeLog "[I] Aktualisiere Pi-hole Gravity  ..."
echo ""
$piholeBinDir/pihole -g # Pi-hole Gravity aktualisieren
piholeGravUpdateStatus=$?
echo ""
writeLog "[I] Pi-hole Gravity Update exitcode: $piholeGravUpdateStatus"

# DNS nach Gravity Update testen
[ "$pihole5" -eq 0 ] && waitfordns 30 #waitfordns nach pihole -g nur bei Pihole Versionen < 5.x notwendig
if ! checkdns; then
   waitfordns 30
   if ! checkdns; then
      writeLog "[E] Pi-hole DNS Service reagiert nicht, versuche RestartDNS ..."
      $piholeBinDir/pihole restartdns
      waitfordns 90
      checkdns
   fi
fi

# Aktualisierte Pi-hole Gravityliste mit Gravityliste vor der Aktualisierung
# vergleichen und Aenderungen (hinzugefuegte/geloeschte Eintraege) in
# $gravListDiff Datei zur weiteren Auswertung speichern
writeLog "[I] Erstelle Aenderungs-Gravityliste $gravListDiff ..."
# Kompatiblitaet fuer Pihole 5.x
if [ "$pihole5" -eq 1 ]; then
   writeLog "[I] Exportiere Domains aus $gravityDB nach $tmp/gravity.list ..."
   sqlite3 "$gravityDB" "select distinct domain from gravity;" >$tmp/gravity.list
   gravListPihole=$tmp/gravity.list
fi
diff $gravListPihole $gravListBeforeUpdate | grep '[><]' >$gravListDiff
writeLog "[I] Aenderungs-Gravityliste mit $(grep -Evc '^#|^$' $gravListDiff) Eintraegen erstellt."

# *** Pi-hole Gravity Update Bericht/Statistik ***

# Id für Pi-hole Gravity Update Bericht erzeugen
id=$(date +"%Y.%m.%d-%H%M%S")

# Ermittle Pi-hole Status
if [[ "$($piholeBinDir/pihole status web 2>/dev/null)" == "1" ]]; then
   phStatus="AKTIV"
else
   phStatus="OFFLINE!"
fi
# Kompatiblitaet fuer Pihole 5.x
if [ "$pihole5" -eq 1 ]; then
   writeLog "[I] Exportiere Blacklist, RegExlisten, Whitelist und Adlists aus $gravityDB nach $tmp ..."
   sqlite3 "$gravityDB" "select domain from vw_blacklist;" >$tmp/blacklist.txt
   blacklist=$tmp/blacklist.txt
   sqlite3 "$gravityDB" "select domain from vw_regex_blacklist;" >$tmp/regex_blacklist.txt
   regexblacklist=$tmp/regex_blacklist.txt
   sqlite3 "$gravityDB" "select domain from vw_regex_whitelist;" >$tmp/regex_whitelist.txt
   regexwhitelist=$tmp/regex_whitelist.txt
   sqlite3 "$gravityDB" "select domain from vw_whitelist;" >$tmp/whitelist.txt
   whitelist=$tmp/whitelist.txt
   sqlite3 "$gravityDB" "select address from vw_adlist;" >$tmp/adlists.txt
   adlists=$tmp/adlists.txt
else
   blacklist=$piholeDir/blacklist.txt
   regexblacklist=$piholeDir/regex.list
   whitelist=$piholeDir/whitelist.txt
   adlists=$piholeDir/adlists.list
fi

# Gravity Update Bericht erzeugen und in die unter $logStats angegebene Datei schreiben.
writeLog "[I] Erstelle Pi-hole Gravity Update Bericht/Statistik $id ..."
echo ""
(
   echo "# Raspberry Info #"
   echo ""
   echo "Hostname: $(hostname)"
   echo "RAM Nutzung: $(awk '/^Mem/ {printf("%.2f%%", 100*($2-$4-$6)/$2);}' <(free -m))"
   echo "HDD Nutzung: $(df -B1 / 2>/dev/null | awk 'END{ print $5 }')"
   echo "Paket Updates?: $(status $rpiUpdateStatus)"
   echo ""
   echo "# Pi-hole Info #"
   echo ""
   echo "Pi-hole Status: $phStatus"
   echo "Internet: $(status $inetTestStatus)"
   echo "DNS-Test: $(status $dnsTestStatus)"
   echo "Gravity Update: $(status $piholeGravUpdateStatus)"
   echo ""
   echo "# Pi-hole Update Status #"
   echo ""
   $piholeBinDir/pihole -up --check-only
   echo ""
   echo "# Pi-hole Statistik #"
   echo ""
   echo "Domains Gravitylist: $(grep -Evc '^#|^$' $gravListPihole)"
   echo "Domains Blacklist: $(grep -Evc '^#|^$' $blacklist)"
   echo "RegEx Blacklist: $(grep -Evc '^#|^$' $regexblacklist)"
   echo "Domains Whitelist: $(grep -Evc '^#|^$' $whitelist)"
   # Kompatiblitaet fuer Pihole 5.x
   if [ "$pihole5" -eq 1 ]; then
      echo "RegEx Whitelist: $(grep -Evc '^#|^$' $regexwhitelist)"
   fi
   echo "Aktive Blocklisten: $(grep -Evc '^#|^$' $adlists)"
   echo ""
   echo "# Pi-hole Gravity Updatestatistik #"
   echo ""
   echo "(+): $(grep -c '<' $gravListDiff) Domains hinzugefuegt"
   echo "(-): $(grep -c '>' $gravListDiff) Domains geloescht"
   echo "(S): $(grep -Evc '^#|^$' $gravListDiff) Domains geaendert"
) | tee $logStats #Ausgaben innerhalb von () in die $logStats Datei schreiben
echo ""
writeLog "[I] Pi-hole Gravity Update Bericht/Statistik $logStats erstellt."

# *** E-Mail Versand des Update Berichtes ***

# Aufrufparameter 1: sudo ./updatePihole.sh name@domain.xy
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

# Temp-Verzeihnis bereinigen
writeLog "[I] Bereinige $tmp"
rm -rf $tmp

writeLog "[I] Ende | Logfile: $log"
