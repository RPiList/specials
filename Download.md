# Aktuelle Version

## Raspberry Pi, VMs und Thin Clients:
- [Installation von Pihole über docker-compose (Schriftliche Anleitung)](./Anleitungen/install-pihole.md)

<details>
  <summary>SVPihole Image für Raspberry Pi (deprecated)</summary>

- https://heldendesbildschirms.de/download/software/betriebssysteme/svpihole/

| Kryptografie | Prüfsummen                                                       |
|:------------:|:----------------------------------------------------------------:|
| crc32        | 616d6acb                                                         |
| sha256       | 616d6acbb8dedf63b77911859f5f3b84042728eec1da338f942c7a3eb22739ec |
| md5          | de7d7db594c779600965c1fda9ce8522                                 |

#### Wichtige Infos:
- Das SSH-Passwort ist 123456
- Auf dem Pi ist neben Pihole auch Unbound installiert. Soll das Pihole Unbound nutzen, muss es vom Nutzer eingerichtet werden.
- Alles weitere in der dem ZIP beiligenden Datei 'wichtig.txt'.
- Dateiname endet auf .img. Wenn notwendig, einfach umbenennen auf .iso umbenennen.
- **Problembehandlung**
	- Falls sich seit dem letzten Update des svpihole Images Probleme bezüglich Pihole und u. a. den neuen ABP-style Listen ergeben, dann ggf. das Pihole manuell mit den Befehl `pihole -up` aktualisieren.
	- Falls sich die Links zu bereits hinzugefügten Listen ändern, dann diese Listen erneut mit den richtigen Links aus der [Blocklisten.md](./Blocklisten.md) hinzufügen.

### Weitere Download-Quellen:
- https://cloudflare-ipfs.com/ipfs/Qmab2Pc3pxrLqpt18JWmVvUbVptKKqaNBSevWiezgHVMkw?filename=svpihole2212.zip

#### Häufig gestellte Frage:
Worin besteht der Unterschied zur Vorversion?
Die Version 2010 nutzt die neue Gruppenfunktion des Pi-hole 5. Die Voreinstellung bestimmt dass die Listen zum Schutz von Minderjährigen (Glückspiel/FSK18-Seiten usw...) für den Standard-Nutzer gelten. Möchte ein Nutzer auf die zuvor genannten Seiten zugreifen, schiebt er seinen PC/Tablet in die Nutzergruppe "Adults". Eine ausführliche Erläuterung finden Sie hier: https://youtu.be/_Jj4Jv1s_hE
</details>

-----

## Synology Diskstation:
-  [Installation von Pihole über docker-compose (Video)](https://www.youtube.com/watch?v=dZKDlfqXRuc)

#### [Synology Modelle die Docker unterstützen (Video)](https://www.youtube.com/watch?v=2X1vrnZBpzc):
| Serie    | Modelle                                                                                                                   |
|:--------:|:-------------------------------------------------------------------------------------------------------------------------:|
| Serie 10 | RS810RP+, RS810+, DS1010+, DS710+                                                                                         |
| Serie 11 | RS3411RPxs, RS3411xs, RS2211RP+, RS2211+, DS3611xs, DS2411+, DS1511+, DS411+, DS411+II                                    |
| Serie 12 | RS3412RPxs, RS3412xs, RS2212RP+, RS2212+, RS812RP+, RS812+, DS3612xs, DS1812+, DS1512+, DS712+, DS412+                    |
| Serie 13 | RS10613xs+, RS3413xs+, DS2413+, DS1813+, DS1513+, DS713+                                                                  |
| Serie 14 | RS3614xs+, RS3614RPxs, RS3614xs, RS2414RP+, RS2414+, RS814RP+, RS814+                                                     |
| Serie 15 | RS815RP+, RS815+, RC18015xs+, DS3615xs, DS2415+, DS1815+, DS1515+, DS415+                                                 |
| Serie 16 | RS18016xs+, RS2416RP+, RS2416+, DS916+, DS716+, DS716+II, DS216+, DS216+II                                                |
| Serie 17 | FS3017, FS2017, RS18017xs+, RS4017xs+, RS3617xs+, RS3617RPxs, RS3617xs, DS3617xs, DS1817+, DS1517+                        |
| Serie 18 | FS1018, RS3618xs, RS2818RP+, RS2418RP+, RS2418+, RS818RP+, RS818+, DS3018xs, DS1618+, DS918+, DS718+, DS218+              |
| Serie 19 | RS1619xs+, RS1219+, DS2419+, DS1819+, DS1019+, DVA3219                                                                    |
| Serie 20 | FS6400, FS3600, FS3400, RS820RP+, RS820+, DS1520+, DS920+, DS720+, DS620slim, DS420+, DS220+, SA3600, SA3400, SA3200D     |
| Serie 21 | RS4021xs+, RS3621xs+, RS3621RPxs, RS2821RP+, RS2421RP+, RS2421+, RS1221RP+, RS1221+, DS1821+, DS1621xs+, DS1621+, DVA3221 |
| Serie 22 | RS822RP+, RS822+, RS422+, DS3622xs+, DS2422+, DS1522+, DVA1622                                                            |
| Serie 23 | DS923+, DS723+, DS423+, DS1823xs+, RS2423RP+, RS2423+, DS423, DS223                                                       |
| Serie 24 | DS224+                                                                                                                    |
| Serie FS | FS6400, FS3600, FS3400, FS3017, FS2017, FS1018, FS2500                                                                    |
| Serie HD | HD6500                                                                                                                    |
| Serie SA | SA6400, SA3610, SA3600, SA3410, SA3400, SA3200D                                                                           |
