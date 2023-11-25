### OpenWRT

1. Klick auf **"Netzwerk"** (englisch "Network")
2. Klick auf **„Schnittstellen“** (englisch „Interfaces“)
![](openwrt1.png)


3. Klick auf den **„Bearbeiten“** (englisch „Edit“) Button des LAN-Interfaces
![](openwrt2.png)

4. Auf der Bearbeiten-Seite des LAN-Interfaces ganz nach unten scrollen
5. Klick auf den Reiter **„Erweiterte Einstellungen“** (englisch „Advanced Settings“) des DHCP-Servers des LAN-Interfaces
6. Im Feld **„DHCP-Optionen“** (englisch „DHCP-Options“) das Pi-Hole als DNS-Server eintragen: Syntax: `6, IP.DES.PI.HOLES`
7. Klick auf **„Speichern und Anwenden“** (englisch „Save & Apply“)
![](openwrt3.png)
