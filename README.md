# Schutz vor Fakeshops, Werbung, Tracking und anderen Angriffen aus dem Internet.

Für weitere Informationen schauen Sie sich das Video unter https://youtu.be/yV2tD-5_X5Y an.

Hier geht es um Webshops die aufgrund des Auftretens sehr unseriös erscheinen und unter dem Verdacht stehen, die Kunden übers Ohr zu hauen.

Deswegen hatten wir uns überlegt, genau solche "unseriösen" Webshops in dieser List zusammen zufassen. Nutzer können die Liste in Ihr Pi-Hole importieren und damit die anderen Nutzer im Netzwerk davor schützen.

> [!NOTE]
> Wenn Sie sich einbringen wollen, können Sie uns die URLs per eMail an RPIList@gmail.com senden oder direkt ein Issue hier auf Github eröffnen. Vielen Dank. 

## Warum gibt es Anti-Blocklisten?

Seit Pihole v6 kann man Listen importieren, die dann für die Freischaltung der Domain sorgen. Beispiel: Ein Bezahldienst im Internet wird sehr oft von Abzockern benutzt. Da unerfahrene Nutzer im Internet in Gefahr sind, wird der Dienstleister in unseren Listen gesperrt. Aber scheinbar nutzt die Post aus Österreich ebenfalls diesen Dienstleister. Und Sie kaufen Briefmarken bei der Post Österreich? Dann entweder unsere entsprechende Anti-Blocklist importieren oder die Domain von Hand freischalten. Ganz einfach.

## Pi-hole: Listen importieren

Haben Sie bereits ein Pi-hole und wollen unsere Listen importieren? Unsere Listen sowie eine Auswahl dritter Listen, 
haben wir für Sie bereits zusammen gestellt. Alle Links können ganz einfach, direkt per Copy&Paste, zum Pi-hole hinzugefügt werden.

### [Klicken Sie dafür bitte hier.](./Blocklisten.md)

> [!WARNING]
> Seit dem Update von Pi-hole Ende März 2023 auf die Version [Pi-hole FTL v5.22, Web v5.19 und Core v5.16.1](https://pi-hole.net/blog/2023/03/22/pi-hole-ftl-v5-22-web-v5-19-and-core-v5-16-1-released/), wird ein neues Listenformat in den ABP-style Format unterstützt, was bedeutet, das wir seit dem auch einige unserer Blocklisten auch in dem ABP-style Format umgestellt haben. Um weiterhin unsere Blocklisten nutzen zu können, ist es erforderlich, dass Sie das Pi-hole ggf. manuell mit dem Befehl `pihole -up` aktualisieren müssen. Danach werden unsere Blocklisten bei Ihnen auch wieder funktionieren.

> [!IMPORTANT]
> **Disclaimer:**
> These pages and the entire project is in no way affiliated with Pi-hole, which you can find on https://pi-hole.net/ 
We are only offering blocklists you can import to your Pi-hole.
