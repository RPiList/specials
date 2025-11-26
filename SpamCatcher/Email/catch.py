#!/usr/bin/env python3
import imaplib
import email
import re
import os
import urllib.parse
from urllib.parse import urlparse
from dotenv import load_dotenv
from pathlib import Path

# =====================================================================
# 0) Dateien
# =====================================================================
pfad = '/volume1/docker/apache/spam/spammail/'
output_file = pfad + 'myspam.txt'
clearwhite = pfad + 'SPAMwhitelist.txt'
pywhite = pfad + 'pyWhiteSPAM.txt'
source_mail_folder = "INBOX"
target_mail_folder = "Done"

# =====================================================================
# 1) Daten aus .env laden
# =====================================================================
print("[INFO] Lade .env …")
load_dotenv()
IMAP_SERVER = os.getenv("IMAP_SERVER")
IMAP_USER   = os.getenv("IMAP_USER")
IMAP_PASS   = os.getenv("IMAP_PASS")
raw_tlds = os.getenv("tlds", "")

VALID_TLDS = set(t.strip().lstrip(".").lower() for t in raw_tlds.split(",") if t.strip())

if not IMAP_SERVER or not IMAP_USER or not IMAP_PASS:
    raise ValueError("IMAP Zugangsdaten fehlen in .env")

if not VALID_TLDS:
    raise ValueError("TLDS in .env fehlen oder leer sind")

print(f"[INFO] Geladene TLDs: {len(VALID_TLDS)}")


# =====================================================================
# Empfänger aus Datei laden
# =====================================================================
def load_recipient():
    try:
        with open("from.txt", "r", encoding="utf-8") as f:
            return f.read().strip()
    except Exception as e:
        print("[FEHLER] Konnte from.txt nicht lesen:", e)
        return None


# =====================================================================
# 2) Links extrahieren
# =====================================================================
def clean_invisible_chars(text: str) -> str:
    invisible = [
        "\u200b", "\u200c", "\u200d",
        "\u2060", "\ufeff", "\u00ad"
    ]
    for ch in invisible:
        text = text.replace(ch, "")
    text = text.replace("&shy;", "")
    text = text.replace("<wbr>", "")
    text = text.replace("<wbr/>", "")
    text = text.replace("<wbr />", "")
    return text


def is_valid_domain(domain: str) -> bool:
    domain = domain.lower().strip()

    if "." not in domain:
        return False

    parts = domain.split(".")
    tld = parts[-1]

    if tld not in VALID_TLDS:
        return False

    for label in parts:
        if not re.match(r"^[a-z0-9-]+$", label):
            return False
        if label.startswith("-") or label.endswith("-"):
            return False

    return True


def extract_domain_from_url(url: str):
    try:
        host = urlparse(url).hostname
        if host:
            host = host.lower().replace("www.", "")
            if is_valid_domain(host):
                return host
    except:
        pass
    return None


# =====================================================================
# 3) Whitelists laden
# =====================================================================
def load_domains(filename, strip_www=False):
    domains = set()
    if not os.path.exists(filename):
        return domains

    with open(filename, "r", encoding="utf-8") as f:
        for line in f:
            d = line.strip().lower()
            if not d:
                continue
            if strip_www and d.startswith("www."):
                d = d[4:]
            domains.add(d)
    return domains


def cleanup_myspam_file():
    """ führt die gesamte Bereinigung aus """
    print("[INFO] Starte myspam-Reinigung …")

    myspam = load_domains(output_file, strip_www=True)
    whitelist = load_domains(clearwhite)
    endings = load_domains(pywhite)

    myspam -= whitelist

    filtered = set()
    for domain in myspam:
        if any(domain.endswith(end) for end in endings):
            continue
        filtered.add(domain)

    with open(output_file, "w", encoding="utf-8") as f:
        for d in sorted(filtered):
            f.write(d + "\n")

    print("[INFO] Bereinigung abgeschlossen.")


# =====================================================================
# 4) Emails laden und durchsuchen.
# =====================================================================
def fetch_and_extract_domains():

    print("[INFO] Verbinde zu IMAP …")
    mail = imaplib.IMAP4_SSL(IMAP_SERVER)

    print("[INFO] Login …")
    mail.login(IMAP_USER, IMAP_PASS)
    print("[OK] Login erfolgreich")

    print(f"[INFO] Öffne {source_mail_folder} …")
    mail.select(source_mail_folder)

    # Empfänger laden
    print("[INFO] Lade Empfänger aus from.txt …")
    recipient = load_recipient()
    if not recipient:
        print("[FEHLER] Kein gültiger Empfänger in from.txt")
        return

    print(f"[INFO] Suche nur Mails an: {recipient}")

    # IMAP SEARCH nur für TO-Feld
    search_str = f'(NOT DELETED HEADER To "{recipient}")'

    status, data = mail.uid("SEARCH", None, search_str)
    if status != "OK":
        print("[FEHLER] UID SEARCH fehlgeschlagen")
        return

    uids = data[0].split()
    print(f"[INFO] Gefundene Mails: {len(uids)}")

    with open(output_file, "a", encoding="utf-8") as f:

        for idx, uid in enumerate(uids, start=1):
            uid_str = uid.decode()
            print(f"[INFO] Verarbeite Mail {idx}/{len(uids)} (UID {uid_str})")

            status, msg_data = mail.uid("FETCH", uid, "(RFC822)")
            if status != "OK" or not msg_data or msg_data[0] is None:
                print(f"[WARNUNG] Mail UID {uid_str} konnte nicht geladen werden")
                continue

            msg = email.message_from_bytes(msg_data[0][1])
            body_text = ""

            if msg.is_multipart():
                for part in msg.walk():
                    ctype = part.get_content_type()
                    if ctype not in ["text/plain", "text/html"]:
                        continue
                    payload = part.get_payload(decode=True)
                    if payload:
                        body_text += payload.decode(errors="ignore") + "\n"
            else:
                payload = msg.get_payload(decode=True)
                if payload:
                    body_text += payload.decode(errors="ignore")

            if not body_text.strip():
                continue

            body_text = clean_invisible_chars(body_text)
            body_text = urllib.parse.unquote(body_text)

            urls = re.findall(r"https?://[^\s<>'\"]+", body_text)
            for url in urls:
                d = extract_domain_from_url(url)
                if d:
                    f.write(d + "\n")

            raw_domains = re.findall(r"\b([a-zA-Z0-9-]+\.[a-zA-Z0-9.-]+)\b", body_text)
            for d in raw_domains:
                d = d.lower().strip(".-")
                if is_valid_domain(d):
                    f.write(d + "\n")

            mail.create(target_mail_folder)
            mail.subscribe(target_mail_folder)
            copy_status, _ = mail.uid("COPY", uid, target_mail_folder)
            if copy_status != "OK":
                continue
            mail.uid("STORE", uid, "+FLAGS.SILENT", r"(\Deleted)")
            mail.uid("EXPUNGE", uid)

    print("[INFO] Logout …")
    mail.close()
    mail.logout()

    print(f"[FERTIG] Domains gespeichert in {output_file}")


# =====================================================================
# 5) MAIN
# =====================================================================
if __name__ == "__main__":
    fetch_and_extract_domains()
    cleanup_myspam_file()
