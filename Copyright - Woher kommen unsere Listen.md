Bezgl. der Anfrage eines Nutzers, woher wir unsere Domains in den Listen beziehen, hier kurz erläutert, woher diese stammen. Offenbar gibt es in dem Bereich teilweise Sorgen, dass wir einfach nur Listen Dritter übernehmen.

Dazu direkt vorab: Wir übernehmen niemals Pi-hole bzw. Pi-hole nutzbare Listen Dritter. Finden wir eine Pi-hole nutzbare Liste im Internet, verlinken wir auf diese Liste auf der Seite Blocklisten.md. Dort findet man deswegen u.a. eine Blockliste für AndroidFireTV oder SmartTV usw...

Es gibt aber Listen im Internet, die nicht für das Pi-hole nutzbar sind. Hier ist kein Verlinken möglich, daher übernehmen wir die Daten als Grundlage und erstellen daraus eine eigene Liste. Als Beispiel die Daten der Website https://beallslist.net/ bzgl. sog. Predatory Publisher. Hier bereiten wir die vorhandenen Daten für die Nutzung im Pi-hole auf. D.h. die Domains werden extrahiert. Fehlt einer Domain die www. Subdomain wird ein zweiter Eintrag erstellt. Ist eine Domain nur mit der WWW. Subdomain vertreten, wird ebenfalls ein zweiter Eintrag ohne die Subdomain erstellt. Sollten bei einer Domain andere ccTLDs notwendig sein, werden diese ebenfalls erstellt und hinzugefügt. Sollten ccTLDs als Subdomain nötig sein, werden diese ebenfalls erstellt und hinzugefügt. Dieses Aufbereiten der Daten wird bei allen uns geführten Listen durchgeführt.

Ein anderes Beispiel sind z.B. die Daten der DDG-Tracking-Liste. Diese werden wie folgt im Internet angeboten:

`{
    "domain": "apptus.com",
    "owner": {
        "name": "Apptus Technologies AB",
        "displayName": "Apptus Technologies AB"
    },
    "source": [
        "DuckDuckGo"
    ],
    "prevalence": 0.000116,
    "sites": 5,
    "subdomains": [
        "cdn.esales"
    ],
    "fingerprinting": 1,
    "resources": [
        {
            "rule": "apptus\\.com\\/api\\/apptus-esales-api-2\\.0\\.1\\.js",
            "cookies": 0,
            "fingerprinting": 1,
            "subdomains": [
                "cdn.esales"
            ],`

Hier extrahieren wir die Domain, erweitern diese wie schon zuvor genannt und ergänzen ferner die im Text genanten Subdomains, da über diese das eigentliche Tracking stattfindet.

Als drittes Beispiel die Windows 10 Telemetry Liste welche im Original im PDF-Format vorliegt und daher nicht vom Pi-hole übernommen werden kann.

Solche "Grunddaten" werden von uns herangezogen, entsprechend aufbereitet und erweitert und landen dann in den Listen, die wir hier direkt anbieten. Insoweit betrachten wir "unsere" Listen als unsere Listen.

Wenn Sie jetzt sorgen haben, dass unsere "Aufbereitung" zu einem Aufblähen der Listen führt, dann haben Sie recht. Aber deswegen muss man sich keine Sorgen machen. :-) Natürlich ist es möglich, dass es zu einer Website gar keine WWW.-Subdomain gibt. Aber dies führt zu keinerlei Nachteilen. Aus der Logik dieses Projekts ergibt sich aber die Notwendigkeit auf Nummer sicher zu gehen. Was ist Ihnen lieber, dass wir www.naziwebsite.de blockieren obwohl sie nicht aufgerufen werden kann, wenn es sie nicht gibt oder dass es die Seite gibt und aufgrund von Nachläßigkeit dann nicht geblockt wird. Damit wird das Ziel der Liste nicht erreicht und dies ist das höhere Ziel. Die Tatsache, dass wenige Bytes im Arbeitsspeicher belegt werden ist dagegen unwichtig. Auf dieses Prinzip sind wir übrigens nicht selbst gekommen. Dies kam durch Anfragen von Nutzern, dass Blockeinträge einfach umgangen werden konnten, in dem man ein www. oder ein de. davor setzte.

Nachfolgend entsprechende Quellenangaben der o.g. Grundlagen:

https://beallslist.net<br>
https://www.bsi.bund.de<br>
https://github.com/duckduckgo/tracker-radar<br>
http://cybercrime-tracker.net<br>
https://openphish.com/<br>
https://zonefiles.io<br>
https://www.ut-capitole.fr<br>
https://isc.sans.edu<br>
https://github.com/disconnectme<br>
https://phishstats.info<br>
https://easylist.to<br>
https://www.cyberthreatcoalition.org<br>
https://phishing.army<br>
https://www.google.de <br>
sowie vielen Einsendungen per eMail<br>
