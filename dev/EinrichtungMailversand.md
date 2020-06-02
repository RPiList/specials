# Mailversand auf dem Raspberry Pi einrichten

**msmtp, mutt, mailutils und ca-certificates installieren**

`sudo apt-get install msmtp msmtp-mta mutt mailutils ca-certificates`

***Hinweis:** In der folgenden Konfigurationsanleitung werden unterschiedliche Mailaccounts für den root und den pi Benutzer verwendet. Sollte nur ein Mailaccount gewünscht sein, kann dieser bei allen Konfigurationen verwendet werden.*

# msmtp

**msmtp Konfiguration Systemweit und benutzerdefiniert anlegen**

Systemweite Konfiguration (root, ...):

`sudo nano /etc/msmtprc`

Inhalt systemweite Konfiguration:

```
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
aliases        /etc/aliases

# Mailaccountdaten
account        mailadresse@rootuser.xy
host           smtp.mailanbieter.de
port           587
from           mailadresse@rootuser.xy
user           mailadresse@rootuser.xy
password       my@P4ssW0rt:0815+PiHol3

# Default Account festlegen
account default: mailadresse@rootuser.xy
```
***password**: bei Multi Faktor Authentifizierung anwendungsspezifisches Passwort für den Raspberry beim Mailanbieter anlegen.*

Benutzerdefinierte Konfiguration (pi):

`nano /home/pi/.msmtprc`

Inhalt benutzerdefinierte Konfirguration:

```
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
aliases        /etc/aliases

# Mailaccountdaten
account        mailadresse@piuser.xy
host           smtp.mailanbieter.de
port           587
from           mailadresse@piuser.xy
user           mailadresse@piuser.xy
password       my@P4ssW0rt

# Default Account festlegen
account default: mailadresse@piuser.xy
```
***password**: bei Multi Faktor Authentifizierung anwendungsspezifisches Passwort für den Raspberry beim Mailanbieter anlegen.*

Zugriff auf benutzerdefinierte Konfiguration beschränken:

`chmod 600 /home/pi/.msmtprc`

**Empfänger-Adressen der Useraccounts und Fallback-Adresse (default) festlegen** 

`sudo nano /etc/aliases`

```
root: mailadresse@rootuser.xy
pi: mailadresse@piuser.xy
default: mailadresse@rootuser.xy
```

**Mailprogramm definieren**

`sudo nano /etc/mail.rc`

Inhalt der mail.rc:

`set sendmail="/usr/bin/msmtp -t"`

# Mutt

**Mutt Konfiguration Systemweit und benutzerdefiniert anlegen**

Systemweite Konfiguration:

`sudo nano /etc/muttrc`

Inhalt systemweite Konfiguration:

```
my_hdr From: mailadresse@rootuser.xy
set realname="system"
```

Benutzerdefinierte Konfiguration für root User:

`sudo nano /root/.muttrc`

Inhalt root Konfiguration:

```
my_hdr From: mailadresse@rootuser.xy
set realname="root"
```

Benutzerdefinierte Konfiguration für pi User:

`nano /home/pi/.muttrc`

Inhalt pi Konfiguration:

```
my_hdr From: mailadresse@piuser.xy
set realname="pi"
```

# Test der Konfiguration

**Mailversand testen**

**Über mail testen:**

`echo "Inhalt der E-Mail" | mail -s "Betreff" mein@empfaenger.xy`

**Über mutt mit Dateianhang testen:**

```
echo "Das ist ein Anhang" > anhang.txt
echo "Inhalt der E-Mail" | mutt -s "Betreff" mein@empfaenger.xy -a anhang.txt
```

**Über msmtp direkt mit Ausgabe von Debuginformationen falls eine Fehlersuche nötig ist:**

`echo "Debug" | msmtp -debug mein@empfaenger.xy`
