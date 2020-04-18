**msmtp und mailutils installieren**

`sudo apt-get install msmtp msmtp-mta mailutils`

**msmtp Konfiguration Systemweit und benutzerdefiniert anlegen**

Systemweit (root):

`sudo nano /etc/msmtprc`

Benutzerdefiniert (pi):

`nano ~/.msmtprc`

Für beide Konfigurationen kann man folgende Konfiguration verwenden, ggf. für root eine andere Mailadresse verwenden, falls vorhanden oder gewünscht:
```
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile         /var/log/msmtp/msmtp.log
aliases        /etc/aliases

# Mailaccountdaten
account          me@gmail.com
host             smtp.gmail.com
port             587
from             me@gmail.com
user             me@gmail.com
password         my@P4ssW0rt:0815+PiHol3
account default: me@gmail.com
```
Weil wir in der Datei Passwörter speichern, müssen die Zugriffsrechte eingeschränkt werden:

`sudo chmod 600 /etc/msmtprc`

`chmod 600 ~/.msmtprc`

**Fallback Empfänger-Adresse und die des Root-Accounts festlegen. An diese Mailadresse werden E-Mails versendet wenn z.B. ein Cronjob fehlschlägt.** 

`sudo nano /etc/aliases`

```
root: root@meinedomain.xy
default: root@meinedomain.xy
```

**Mailprogramm definieren**

`sudo nano /etc/mail.rc`

`set sendmail="/usr/bin/msmtp -t"`

**Mailversand testen**

**Über mail testen:**

`echo "Inhalt der E-Mail" | mail -s "Betreff" mein@empfaenger.xy`

**Über msmtp direkt mit Ausgabe von Debuginformationen falls eine Fehlersuche nötig ist:**

`echo "Inhalt der E-Mail" | msmtp -debug mein@empfaenger.xy`
