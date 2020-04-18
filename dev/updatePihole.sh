#!/bin/bash

# Script: updatePihole.sh
# Version: 1.0.0 - initial [Zelo72]

# Aufrufparameter: optional E-Mailadresse, wird diese uebergeben, wird ein Abschlussbericht via Mail verschickt.
#                  Aufruf: sudo ./updatePihole.sh rootoma@seniorenstift.xy <-- mit Mailversand
#                          sudo ./updatePihole.sh                       <-- ohne Mailversand

# Prüfen ob das Script als root ausgefuehrt wird
if [ "$(id -u)" != "0" ]; then
   echo "Das Script muss mit Rootrechten ausgeführt werden!"
   exit 1
fi

# *** Initialisierung ***

# Logging initialisieren
logDir=/var/log/svpihole
log=$logDir/updatePihole.sh.log
mkdir -p $logDir

# Hilfsfunktion zum loggen
writeLog() {
   echo -e "[$(date +'%Y.%m.%d-%H:%M:%S')]" "$*" | tee -a $log
}
writeLog "[I] Start | Logfile: $log"

# Tempverzeichnis initialisieren
tmp=/tmp/svpihole
writeLog "[I] Initialisiere Tempverzeichnis $tmp ..."
mkdir -p $tmp
cd $tmp || exit

# Variablen fuer Dateien
piholeDir=/etc/pihole
gravListPihole=$piholeDir/gravity.list
gravListBeforeUpdate=$tmp/gravity_before_update.list
gravListDiff=$tmp/gravity_diff.list
logStats=$logDir/updatePihole.stats.log

# Variablen fuer "Gesundheitsstatus": -1: Undefiniert / 0: true / >0: false
piholeUpdateOK=-1
piholeGravUpdateOK=-1
dnsTestOK=-1
inetTestOK=-1
rebootRequired=1

# *** Hilfsfunktionen ***

delimiter() {
   echo ""
}

status() {
   case "$*" in
   -1)
      echo "UNDEFINIERT #$*"
      ;;
   0)
      echo "JA #$*"
      ;;
   1 | *)
      echo "NEIN #$*"
      ;;
   esac
}

# Internetverbindung testen
checkinet() {
   writeLog "[I] Teste Internetverbindung ..."
   if ! (ping -c1 8.8.8.8 >/dev/null); then
      writeLog "[E] Keine Internetverbindung! Das Script wird beendet!"
      inetTestOK=1
      exit 1
   fi
   writeLog "[I] Internetverbindungstest erfolgreich."
   inetTestOK=0
   return 0
}

# DNS-Namensaufloesung testen
checkdns() {
   writeLog "[I] Teste DNS Namensaufloesung ..."
   if ! (ping -c1 google.de >/dev/null); then
      writeLog "[E] Keine DNS Namensaufloesung moeglich!"
      dnsTestOK=1
      return 1
   fi
   writeLog "[I] DNS Namensaufloesung erfolgreich."
   dnsTestOK=0
   return 0
}

# *** Pi-hole Update ***

# Internetverbindung / DNS testen
checkinet # besteht keine Internetverbindung wird das Script mit exitcode 1 beendet
checkdns
delimiter

# Nur Sonntags, die Raspberry Pakete und den Pi-hole selbst updaten.
if test "$(date "+%w")" -eq 0; then # Sonntags?
   # Raspberry Pakete updaten
   writeLog "[I] Raspberry Pakete updaten ..."
   apt-get update
   apt-get -y upgrade
   delimiter

   # Raspberry Pakete bereinigen
   writeLog "[I] Raspberry Pakete bereinigen ..."
   apt-get -y autoremove
   apt-get -y clean
   delimiter

   # Pi-hole updaten
   writeLog "[I] Pi-hole updaten ..."
   pihole -up
   piholeUpdateOK=$?
   writeLog "[I] Pi-hole Update exitcode: $piholeUpdateOK"
   delimiter

   # Pruefen ob durch die Updates ein Reboot erforderlich ist
   writeLog "[I] Pruefe ob ein Reboot erforderlich ist ..."
   if [ -f /var/run/reboot-required ]; then
      writeLog "[W] REBOOT nach Update erforderlich!"
      echo "*************************"
      echo "R E B O O T erforderlich!"
      echo "*************************"
      rebootRequired=0
   fi
   delimiter
fi

# *** Pi-hole Gravity Update ***

# AKtuelle Gravity Liste vom Pi-hole zwischenspeichern und
# Pi-hole Gravity aktualisieren
writeLog "[I] Aktualisiere Pi-hole Gravity $gravListPihole ..."
cp $gravListPihole $gravListBeforeUpdate
pihole -g # Pi-hole Gravity aktualisieren
piholeGravUpdateOK=$?
writeLog "[I] Pi-hole Gravity Update exitcode: $piholeGravUpdateOK"
delimiter

# DNS nach Gravity Update testen
checkdns
delimiter

# Aktualisierte Pi-hole Gravityliste mit Gravityliste vor der Aktualisierung
# vergleichen und Aenderungen (hinzugefuegte/geloeschte Eintraege) in
# $gravListDiff Datei zur weiteren Auswertung speichern
writeLog "[I] Erstelle Aenderungs-Gravityliste $gravListDiff ..."
diff $gravListPihole $gravListBeforeUpdate | grep '[><]' >$gravListDiff
writeLog "[I] Aenderungs-Gravityliste mit $(wc <$gravListDiff -l) Eintraegen erstellt."
delimiter
delimiter

# *** Pi-hole Gravity Update Bericht/Statistik ***

# Id für Pi-hole Gravity Update Bericht erzeugen
id=$(date +"%Y.%m.%d-%H%M%S")

# Gravity Update Bericht erzeugen und in die unter $logStats angegebene Datei schreiben.
writeLog "[I] Erstelle PiHole Gravity Update Bericht/Statistik $id ..."
delimiter
(
   echo "Pi-hole Gravity Update Bericht: $id"
   echo ""
   echo "# Pi-hole Gesundheitsstatus #"
   echo ""
   echo "Reboot erforderlich: $(status $rebootRequired)"
   echo "Internetverbindung (OK? #Exitcode): $(status $inetTestOK)"
   echo "DNS Test (OK? #Exitcode): $(status $dnsTestOK)"
   echo "Pi-hole Update (OK? #Exitcode): $(status $piholeUpdateOK)"
   echo "Pi-hole Gravity (OK? #Exitcode): $(status $piholeGravUpdateOK)"
   echo ""
   echo "# Pi-hole Statistik #"
   echo ""
   echo "Domains Gravitylist: $(wc <$gravListPihole -l)"
   echo "Domains Blacklist: $(wc <${piholeDir}/blacklist.txt -l)"
   echo "RegEx-Filter Blacklist: $(wc <${piholeDir}/regex.list -l)"
   echo "Domains Whitelist: $(wc <${piholeDir}/whitelist.txt -l)"
   echo ""
   echo "Anzahl Blocklisten: $(wc <${piholeDir}/adlists.list -l)"
   echo ""
   echo "# Pi-hole Gravity Updatestatistik #"
   echo ""
   echo "(+): $(grep -c '<' $gravListDiff) hinzugefuegte Domains"
   echo "(-): $(grep -c '>' $gravListDiff) geloeschte Domains"
   echo "(S): $(wc <$gravListDiff -l) insgesamt geaenderte Domains"
   echo ""
   echo "(+) Hinzugefuegte Domains (Top 50):"
   grep -m50 '<' $gravListDiff
   echo ""
   echo "(-) Geloeschte Domains (Top 50):"
   grep -m50 '>' $gravListDiff
) | tee $logStats #Ausgaben innerhalb von () in die $logStats Datei schreiben
writeLog "[I] Pi-hole Gravity Update Bericht/Statistik $logStats erstellt."
delimiter

# *** E-Mail Versand des Update Berichtes ***

# Aufrufparameter 1
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
   delimiter
fi
writeLog "[I] Ende | Logfile: $log"
