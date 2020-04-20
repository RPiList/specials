**Einrichtung des zeitgesteuerten automatischen pi hole Updates**

*Ersteller des Skriptes: Zelo72*

1. Per SSH mit dem Pi hole verbinden oder die Konsole aufrufen
2. Folgendes eingeben oder kopieren und dann mit Enter bestätigen:
`nano /home/pi/updatePihole.sh`
3. Das Skript aus "updatePihole.sh" kopieren und einfügen
4. STRG+X
5. "Y" für yes
6. ENTER
7. Das skript mit folgendem Befehl testen:
`sudo ./updatePihole.sh`
8. Das Ergebnis sollte in der Konsole wie folgt aussehen:
`[2020.04.19-19:16:44] [I] Pi-hole Gravity Update exitcode: 0
[2020.04.19-19:16:44] [I] Teste DNS Namensaufloesung ...
ping: google.de: Temporary failure in name resolution
[2020.04.19-19:16:54] [E] Keine DNS Namensaufloesung moeglich!
[2020.04.19-19:16:54] [I] Erstelle Aenderungs-Gravityliste /tmp/svpihole/gravity_diff.list ...
[2020.04.19-19:17:03] [I] Aenderungs-Gravityliste mit 0 Eintraegen erstellt.
[2020.04.19-19:17:03] [I] Erstelle PiHole Gravity Update Bericht/Statistik 2020.04.19-191703 ...
Pi-hole Gravity Update Bericht: 2020.04.19-191703

# Pi-hole Gesundheitsstatus #

Reboot erforderlich: NEIN
Internetverbindung: OK
DNS Test: FEHLER #Exitcode:1
Pi-hole Update: OK
Pi-hole Gravity Update: OK

# Pi-hole Statistik #

Domains Gravitylist: 5190008
Domains Blacklist: 0
RegEx-Filter Blacklist: 22
Domains Whitelist: 15

Anzahl Blocklisten: 61

# Pi-hole Gravity Updatestatistik #

(+): 0 hinzugefuegte Domains
(-): 0 geloeschte Domains
(S): 0 insgesamt geaenderte Domains
[2020.04.19-19:17:07] [I] Pi-hole Gravity Update Bericht/Statistik /var/log/svpihole/updatePihole.stats.log erstellt.
[2020.04.19-19:17:07] [I] Ende | Logfile: /var/log/svpihole/20200419_updatePihole.sh.log`
9. Wenn das Skript erfolgreich durchlief, wird es in das Verzeichnis /root kopiert
´sudo cp /home/pi/updatePihole.sh /root`
10. Das Skript ausführbar machen mit
´sudo chmod +x /root/updatePihole.sh`
12. Crontab aufrufen
´sudo crontab -e`
13. Am Ende des Skriptes (nach den #) folgende Zeile einfügen
´0 6 * * * /root/updatePihole.sh >/dev/null 2>&1`
Jetzt läuft das Skript täglich um 06:00 Uhr und aktualisiert die im Pi hole eingetragenen Blocklisten.
