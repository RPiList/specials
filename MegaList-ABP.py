#!/usr/bin/python3.9
from urllib.request import Request, urlopen
import re, os, shutil, requests, sys
from pathlib import Path
from contextlib3 import suppress

# Create a single file list out of several pi-hole lists
# Customize the Data Division to your liking.

# Copyright 2022-2023 by Sprecher und Twitch-Chat
# Data Division:
homepfad = str(Path.home())

liste = 'megalist-ABP'
tempfile = homepfad + '/Desktop/filter/temp.txt'
targetfile = homepfad + '/Desktop/filter/' + liste
whitelist = homepfad + '/Desktop/filter/6whitelist'
printmessage1 = ' Mega-Liste ABP wird erstellt...'
printmessage2 = ' Lade Quellen...'
printmessage3 = ' Lade Quelle...'
printmessage4 = ' Neue Liste wird erstellt...                                    '
printmessage5 = ' Anzahl Domains: '
printmessage6 = ' Liste wird sortiert...'
printmessage7 = ' Zieldatei wird geschrieben...'
printmessage8 = ' Fertig.                                  '

MyURLs = ['https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/child-protection',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/Corona-Blocklist',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/crypto',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DatingSites',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting1',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting2',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting3',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting4',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/easylist',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/Fake-Science',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/gambling',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/malware',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/MS-Office-Telemetry',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/notserious',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/Overblock',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/Phishing-Angriffe',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/pornblock1',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/pornblock2',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/pornblock3',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/pornblock4',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/pornblock5',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/pornblock6',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/proxies',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/samsung',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/spam.mails',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/Streaming',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/SupportingRussia',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/Win10Telemetry',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/AddikoBank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/AnadiBank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/Bank99',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/BankBurgenland',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/Bawag',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/BKSBank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/ConsorsFinanz',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/Denizbank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/Easybank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/Eurambank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/Hypotirol',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/Kommunalkreditinvest',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/LichtensteinischeLandesbank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/N26',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/OberBank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/PrivatBankRaiffeisenlandesbank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/RaiffeisenBank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/Raiffeisenzertifikate',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/RenaultBankdirekt',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/SantanderBank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/SchelhammerCapitalBank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/Schoellerbank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/SpardaBank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/SparkasseBank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/SWKBank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/Teambank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/TFBank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/UniCreditBankAustria',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/VolksbankKaernten',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/VolksbankNiederoesterreich',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/VolksbankOberoesterreich',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/VolksbankSalzburg',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/VolksbankSteiermark',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/VolksbankTirol',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/VolksbankVorarlberg',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/VolksbankWien',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/AT/ZuercherKantonalbank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/AargauischeKantonalbank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/AlternativeBankSchweiz',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/Arabbank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/BankCler',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/BCJ-BanqueCantonaleduJura',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/BCN-BanqueCantonaleNeuchateloise',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/BCVS-BanqueCantonaleduValais',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/BNP-Paribas',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/Ca-Indosuez',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/Cash',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/CIC',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/Citi',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/Credit-Suisse-AG',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/DZ-Privatbank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/Gemeinschaftsbank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/HelvetischeBank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/Heritage',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/Hypobank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/HypoVoralberg',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/JSafraSarasin',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/LGTBank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/Mbaerbank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/Migrosbank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/Monyland',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/NeonSchwitzerlandAG',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/ObwaldnerKantonalbank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/OneSwissBank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/PKB',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/PostFinance',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/PPI-Schweiz',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/Raiffeisen',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/SaxoBank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/SchwyzerKantonalbank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/SNB-SchweizerischeNationalbank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/Swissbanking',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/SyzGroup',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/UBS',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/Vontobel',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/VPBank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/CH/ZKB',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/sonstige_Banken/Commerzbank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/sonstige_Banken/Consorsbank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/sonstige_Banken/Deka',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/sonstige_Banken/DeutscheBank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/sonstige_Banken/DKB',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/sonstige_Banken/HamburgCommercialBank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/sonstige_Banken/HelebaBank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/sonstige_Banken/Hypovereinsbank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/sonstige_Banken/ING',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/sonstige_Banken/KFWBank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/sonstige_Banken/LandesbankBadenWuerttemberg',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/sonstige_Banken/NorddeutscheLandesbank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/sonstige_Banken/NRWBank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/sonstige_Banken/Pfandbriefbank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/sonstige_Banken/Postbank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/sonstige_Banken/PSD-Bank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/sonstige_Banken/SantanderBank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/sonstige_Banken/Sparda-Bank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/sonstige_Banken/StaatsbankBadenWuerttemberg',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/sonstige_Banken/Targobank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/sonstige_Banken/VolkswagenBank',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/BadenWuerttemberg1',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/BadenWuerttemberg2',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/Bayern1',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/Bayern2',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/Berlin',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/Brandenburg',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/Bremen',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/Hamburg',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/Hessen1',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/Hessen2',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/MecklenburgVorpommern',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/Niedersachsen1',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/Niedersachsen2',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/NRW1',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/NRW2',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/NRW3',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/NRW4',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/RheinlandPfalz',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/Saarland',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/Sachsen',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/SachsenAnhalt',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/SchleswigHolstein',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/Thueringen',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Volks-und-Raiffeisenbank/VR-PLZ-0',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Volks-und-Raiffeisenbank/VR-PLZ-1-Teil-1',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Volks-und-Raiffeisenbank/VR-PLZ-1-Teil-2',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Volks-und-Raiffeisenbank/VR-PLZ-2',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Volks-und-Raiffeisenbank/VR-PLZ-3-Teil-1',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Volks-und-Raiffeisenbank/VR-PLZ-3-Teil-2',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Volks-und-Raiffeisenbank/VR-PLZ-4',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Volks-und-Raiffeisenbank/VR-PLZ-5-Teil-1',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Volks-und-Raiffeisenbank/VR-PLZ-5-Teil-2',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Volks-und-Raiffeisenbank/VR-PLZ-6',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Volks-und-Raiffeisenbank/VR-PLZ-7-Teil-1',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Volks-und-Raiffeisenbank/VR-PLZ-7-Teil-2',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Volks-und-Raiffeisenbank/VR-PLZ-8-Teil-1',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Volks-und-Raiffeisenbank/VR-PLZ-8-Teil-2',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Volks-und-Raiffeisenbank/VR-PLZ-9-Teil-1',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Volks-und-Raiffeisenbank/VR-PLZ-9-Teil-2',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Volks-und-Raiffeisenbank/VR-PLZ-9-Teil-3',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/INT/interactivebrokers',
          'https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/INT/traderepublic',]

# END Data Division:

MyTuple = (".aaa", ".aarp", ".abarth", ".abb", ".abbott", ".abbvie", ".abc", ".able", ".abogado", ".abudhabi", ".ac", ".academy", ".accenture", ".accountant", ".accountants", ".aco", ".actor", ".ad", ".adac", ".ads", ".adult", ".ae", ".aeg", ".aero", ".aetna", ".af", ".afamilycompany", ".afl", ".africa", ".ag", ".agakhan", ".agency", ".ai", ".aig", ".aigo", ".airbus", ".airforce", ".airtel", ".akdn", ".al", ".alfaromeo", ".alibaba", ".alipay", ".allfinanz", ".allstate", ".ally", ".alsace", ".alstom", ".am", ".americanexpress", ".americanfamily", ".amex", ".amfam", ".amica", ".amsterdam", ".analytics", ".android", ".anquan", ".anz", ".ao", ".aol", ".apartments", ".app", ".apple", ".aq", ".aquarelle", ".ar", ".arab", ".aramco", ".archi", ".army", ".arpa", ".art", ".arte", ".as", ".asda", ".asia", ".associates", ".at", ".athleta", ".attorney", ".au", ".auction", ".audi", ".audible", ".audio", ".auspost", ".author", ".auto", ".autos", ".avianca", ".aw", ".aws", ".ax", ".axa", ".az", ".azure", ".ba", ".baby", ".baidu", ".banamex", ".bananarepublic", ".band", ".bank", ".bar", ".barcelona", ".barclaycard", ".barclays", ".barefoot", ".bargains", ".baseball", ".basketball", ".bauhaus", ".bayern", ".bb", ".bbc", ".bbt", ".bbva", ".bcg", ".bcn", ".bd", ".be", ".beats", ".beauty", ".beer", ".bentley", ".berlin", ".best", ".bestbuy", ".bet", ".bf", ".bg", ".bh", ".bharti", ".bi", ".bible", ".bid", ".bike", ".bing", ".bingo", ".bio", ".biz", ".bj", ".black", ".blackfriday", ".blockbuster", ".blog", ".bloomberg", ".blue", ".bm", ".bms", ".bmw", ".bn", ".bnpparibas", ".bo", ".boats", ".boehringer", ".bofa", ".bom", ".bond", ".boo", ".book", ".booking", ".bosch", ".bostik", ".boston", ".bot", ".boutique", ".box", ".br", ".bradesco", ".bridgestone", ".broadway", ".broker", ".brother", ".brussels", ".bs", ".bt", ".budapest", ".bugatti", ".build", ".builders", ".business", ".buy", ".buzz", ".bv", ".bw", ".by", ".bz", ".bzh", ".ca", ".cab", ".cafe", ".cal", ".call", ".calvinklein", ".cam", ".camera", ".camp", ".cancerresearch", ".canon", ".capetown", ".capital", ".capitalone", ".car", ".caravan", ".cards", ".care", ".career", ".careers", ".cars", ".casa", ".case", ".caseih", ".cash", ".casino", ".cat", ".catering", ".catholic", ".cba", ".cbn", ".cbre", ".cbs", ".cc", ".cd", ".ceb", ".center", ".ceo", ".cern", ".cf", ".cfa", ".cfd", ".cg", ".ch", ".chanel", ".channel", ".charity", ".chase", ".chat", ".cheap", ".chintai", ".christmas", ".chrome", ".church", ".ci", ".cipriani", ".circle", ".cisco", ".citadel", ".citi", ".citic", ".city", ".cityeats", ".ck", ".cl", ".claims", ".cleaning", ".click", ".clinic", ".clinique", ".clothing", ".cloud", ".club", ".clubmed", ".cm", ".cn", ".co", ".coach", ".codes", ".coffee", ".college", ".cologne", ".com", ".comcast", ".commbank", ".community", ".company", ".compare", ".computer", ".comsec", ".condos", ".construction", ".consulting", ".contact", ".contractors", ".cooking", ".cookingchannel", ".cool", ".coop", ".corsica", ".country", ".coupon", ".coupons", ".courses", ".cpa", ".cr", ".credit", ".creditcard", ".creditunion", ".cricket", ".crown", ".crs", ".cruise", ".cruises", ".csc", ".cu", ".cuisinella", ".cv", ".cw", ".cx", ".cy", ".cymru", ".cyou", ".cz", ".dabur", ".dad", ".dance", ".data", ".date", ".dating", ".datsun", ".day", ".dclk", ".dds", ".de", ".deal", ".dealer", ".deals", ".degree", ".delivery", ".dell", ".deloitte", ".delta", ".democrat", ".dental", ".dentist", ".desi", ".design", ".dev", ".dhl", ".diamonds", ".diet", ".digital", ".direct", ".directory", ".discount", ".discover", ".dish", ".diy", ".dj", ".dk", ".dm", ".dnp", ".do", ".docs", ".doctor", ".dog", ".domains", ".dot", ".download", ".drive", ".dtv", ".dubai", ".duck", ".dunlop", ".dupont", ".durban", ".dvag", ".dvr", ".dz", ".earth", ".eat", ".ec", ".eco", ".edeka", ".edu", ".education", ".ee", ".eg", ".email", ".emerck", ".energy", ".engineer", ".engineering", ".enterprises", ".epson", ".equipment", ".er", ".ericsson", ".erni", ".es", ".esq", ".estate", ".esurance", ".et", ".etisalat", ".eu", ".eurovision", ".eus", ".events", ".exchange", ".expert", ".exposed", ".express", ".extraspace", ".fage", ".fail", ".fairwinds", ".faith", ".family", ".fan", ".fans", ".farm", ".farmers", ".fashion", ".fast", ".fedex", ".feedback", ".ferrari", ".ferrero", ".fi", ".fiat", ".fidelity", ".fido", ".film", ".final", ".finance", ".financial", ".fire", ".firestone", ".firmdale", ".fish", ".fishing", ".fit", ".fitness", ".fj", ".fk", ".flickr", ".flights", ".flir", ".florist", ".flowers", ".fly", ".fm", ".fo", ".foo", ".food", ".foodnetwork", ".football", ".ford", ".forex", ".forsale", ".forum", ".foundation", ".fox", ".fr", ".free", ".fresenius", ".frl", ".frogans", ".frontdoor", ".frontier", ".ftr", ".fujitsu", ".fujixerox", ".fun", ".fund", ".furniture", ".futbol", ".fyi", ".ga", ".gal", ".gallery", ".gallo", ".gallup", ".game", ".games", ".gap", ".gay", ".gb", ".gbiz", ".gd", ".gdn", ".ge", ".gea", ".gent", ".genting", ".george", ".gf", ".gg", ".ggee", ".gh", ".gi", ".gift", ".gifts", ".gives", ".giving", ".gl", ".glade", ".gle", ".global", ".globo", ".gm", ".gmail", ".gmbh", ".gmx", ".gn", ".gold", ".goldpoint", ".goo", ".goodyear", ".goog", ".google", ".gop", ".got", ".gov", ".gp", ".gq", ".gr", ".graphics", ".gratis", ".green", ".gripe", ".grocery", ".group", ".gs", ".gt", ".gu", ".guardian", ".gucci", ".guge", ".guide", ".guitars", ".guru", ".gw", ".gy", ".hair", ".hamburg", ".hangout", ".haus", ".hbo", ".hdfc", ".hdfcbank", ".health", ".healthcare", ".help", ".helsinki", ".here", ".hermes", ".hgtv", ".hiphop", ".hitachi", ".hk", ".hkt", ".hm", ".hn", ".hockey", ".holdings", ".homedepot", ".homegoods", ".homes", ".homesense", ".horse", ".hosting", ".hoteles", ".hotels", ".hotmail", ".house", ".how", ".hr", ".hsbc", ".hu", ".hughes", ".hyatt", ".hyundai", ".ibm", ".icbc", ".ice", ".icu", ".id", ".ie", ".ieee", ".ifm", ".ikano", ".il", ".im", ".imamat", ".imdb", ".immo", ".immobilien", ".in", ".inc", ".industries", ".infiniti", ".info", ".ing", ".ink", ".institute", ".insurance", ".insure", ".int", ".intel", ".international", ".intuit", ".investments", ".io", ".ipiranga", ".iq", ".ir", ".irish", ".is", ".ismaili", ".ist", ".istanbul", ".it", ".itau", ".itv", ".iveco", ".jaguar", ".java", ".jcb", ".jcp", ".je", ".jeep", ".jetzt", ".jewelry", ".jio", ".jll", ".jm", ".jmp", ".jnj", ".jo", ".jobs", ".joburg", ".jot", ".joy", ".jp", ".jpmorgan", ".jprs", ".juegos", ".juniper", ".kaufen", ".kddi", ".ke", ".kerryhotels", ".kerrylogistics", ".kerryproperties", ".kfh", ".kg", ".kh", ".ki", ".kia", ".kim", ".kinder", ".kindle", ".kitchen", ".kiwi", ".km", ".kn", ".koeln", ".komatsu", ".kosher", ".kp", ".kpmg", ".kpn", ".kr", ".krd", ".kred", ".kuokgroup", ".kw", ".ky", ".kyoto", ".kz", ".la", ".lacaixa", ".lamborghini", ".lamer", ".lancaster", ".lancia", ".land", ".landrover", ".lanxess", ".lasalle", ".lat", ".latino", ".latrobe", ".law", ".lawyer", ".lb", ".lc", ".lds", ".lease", ".leclerc", ".lefrak", ".legal", ".lego", ".lexus", ".lgbt", ".li", ".lidl", ".life", ".lifeinsurance", ".lifestyle", ".lighting", ".like", ".lilly", ".limited", ".limo", ".lincoln", ".linde", ".link", ".lipsy", ".live", ".living", ".lixil", ".lk", ".llc", ".llp", ".loan", ".loans", ".locker", ".locus", ".loft", ".lol", ".london", ".lotte", ".lotto", ".love", ".lpl", ".lplfinancial", ".lr", ".ls", ".lt", ".ltd", ".ltda", ".lu", ".lundbeck", ".lupin", ".luxe", ".luxury", ".lv", ".ly", ".ma", ".macys", ".madrid", ".maif", ".maison", ".makeup", ".man", ".management", ".mango", ".map", ".market", ".marketing", ".markets", ".marriott", ".marshalls", ".maserati", ".mattel", ".mba", ".mc", ".mckinsey", ".md", ".me", ".med", ".media", ".meet", ".melbourne", ".meme", ".memorial", ".men", ".menu", ".merckmsd", ".metlife", ".mg", ".mh", ".miami", ".microsoft", ".mil", ".mini", ".mint", ".mit", ".mitsubishi", ".mk", ".ml", ".mlb", ".mls", ".mm", ".mma", ".mn", ".mo", ".mobi", ".mobile", ".moda", ".moe", ".moi", ".mom", ".monash", ".money", ".monster", ".mormon", ".mortgage", ".moscow", ".moto", ".motorcycles", ".mov", ".movie", ".mp", ".mq", ".mr", ".ms", ".msd", ".mt", ".mtn", ".mtr", ".mu", ".museum", ".mutual", ".mv", ".mw", ".mx", ".my", ".mz", ".na", ".nab", ".nadex", ".nagoya", ".name", ".nationwide", ".natura", ".navy", ".nba", ".nc", ".ne", ".nec", ".net", ".netbank", ".netflix", ".network", ".neustar", ".new", ".newholland", ".news", ".next", ".nextdirect", ".nexus", ".nf", ".nfl", ".ng", ".ngo", ".nhk", ".ni", ".nico", ".nike", ".nikon", ".ninja", ".nissan", ".nissay", ".nl", ".no", ".nokia", ".northwesternmutual", ".norton", ".now", ".nowruz", ".nowtv", ".np", ".nr", ".nra", ".nrw", ".ntt", ".nu", ".nyc", ".nz", ".obi", ".observer", ".off", ".office", ".okinawa", ".olayan", ".olayangroup", ".oldnavy", ".ollo", ".om", ".omega", ".one", ".ong", ".onl", ".online", ".onyourside", ".ooo", ".open", ".oracle", ".orange", ".org", ".organic", ".origins", ".osaka", ".otsuka", ".ott", ".ovh", ".pa", ".page", ".panasonic", ".paris", ".pars", ".partners", ".parts", ".party", ".passagens", ".pay", ".pccw", ".pe", ".pet", ".pf", ".pfizer", ".pg", ".ph", ".pharmacy", ".phd", ".philips", ".phone", ".photo", ".photography", ".photos", ".physio", ".pics", ".pictet", ".pictures", ".pid", ".pin", ".ping", ".pink", ".pioneer", ".pizza", ".pk", ".pl", ".place", ".play", ".playstation", ".plumbing", ".plus", ".pm", ".pn", ".pnc", ".pohl", ".poker", ".politie", ".porn", ".post", ".pr", ".pramerica", ".praxi", ".press", ".prime", ".pro", ".prod", ".productions", ".prof", ".progressive", ".promo", ".properties", ".property", ".protection", ".pru", ".prudential", ".ps", ".pt", ".pub", ".pw", ".pwc", ".py", ".qa", ".qpon", ".quebec", ".quest", ".qvc", ".racing", ".radio", ".raid", ".re", ".read", ".realestate", ".realtor", ".realty", ".recipes", ".red", ".redstone", ".redumbrella", ".rehab", ".reise", ".reisen", ".reit", ".reliance", ".ren", ".rent", ".rentals", ".repair", ".report", ".republican", ".rest", ".restaurant", ".review", ".reviews", ".rexroth", ".rich", ".richardli", ".ricoh", ".rightathome", ".ril", ".rio", ".rip", ".rmit", ".ro", ".rocher", ".rocks", ".rodeo", ".rogers", ".room", ".rs", ".rsvp", ".ru", ".rugby", ".ruhr", ".run", ".rw", ".rwe", ".ryukyu", ".sa", ".saarland", ".safe", ".safety", ".sakura", ".sale", ".salon", ".samsclub", ".samsung", ".sandvik", ".sandvikcoromant", ".sanofi", ".sap", ".sarl", ".sas", ".save", ".saxo", ".sb", ".sbi", ".sbs", ".sc", ".sca", ".scb", ".schaeffler", ".schmidt", ".scholarships", ".school", ".schule", ".schwarz", ".science", ".scjohnson", ".scor", ".scot", ".sd", ".se", ".search", ".seat", ".secure", ".security", ".seek", ".select", ".sener", ".services", ".ses", ".seven", ".sew", ".sex", ".sexy", ".sfr", ".sg", ".sh", ".shangrila", ".sharp", ".shaw", ".shell", ".shia", ".shiksha", ".shoes", ".shop", ".shopping", ".shouji", ".show", ".showtime", ".shriram", ".si", ".silk", ".sina", ".singles", ".site", ".sj", ".sk", ".ski", ".skin", ".sky", ".skype", ".sl", ".sling", ".sm", ".smart", ".smile", ".sn", ".sncf", ".so", ".soccer", ".social", ".softbank", ".software", ".sohu", ".solar", ".solutions", ".song", ".sony", ".soy", ".space", ".sport", ".spot", ".spreadbetting", ".sr", ".srl", ".ss", ".st", ".stada", ".staples", ".star", ".statebank", ".statefarm", ".stc", ".stcgroup", ".stockholm", ".storage", ".store", ".stream", ".studio", ".study", ".style", ".su", ".sucks", ".supplies", ".supply", ".support", ".surf", ".surgery", ".suzuki", ".sv", ".swatch", ".swiftcover", ".swiss", ".sx", ".sy", ".sydney", ".symantec", ".systems", ".sz", ".tab", ".taipei", ".talk", ".taobao", ".target", ".tatamotors", ".tatar", ".tattoo", ".tax", ".taxi", ".tc", ".tci", ".td", ".tdk", ".team", ".tech", ".technology", ".tel", ".temasek", ".tennis", ".teva", ".tf", ".tg", ".th", ".thd", ".theater", ".theatre", ".tiaa", ".tickets", ".tienda", ".tiffany", ".tips", ".tires", ".tirol", ".tj", ".tjmaxx", ".tjx", ".tk", ".tkmaxx", ".tl", ".tm", ".tmall", ".tn", ".to", ".today", ".tokyo", ".tools", ".top", ".toray", ".toshiba", ".total", ".tours", ".town", ".toyota", ".toys", ".tr", ".trade", ".trading", ".training", ".travel", ".travelchannel", ".travelers", ".travelersinsurance", ".trust", ".trv", ".tt", ".tube", ".tui", ".tunes", ".tushu", ".tv", ".tvs", ".tw", ".tz", ".ua", ".ubank", ".ubs", ".ug", ".uk", ".unicom", ".university", ".uno", ".uol", ".ups", ".us", ".uy", ".uz", ".va", ".vacations", ".vana", ".vanguard", ".vc", ".ve", ".vegas", ".ventures", ".verisign", ".versicherung", ".vet", ".vg", ".vi", ".viajes", ".video", ".vig", ".viking", ".villas", ".vin", ".vip", ".virgin", ".visa", ".vision", ".vistaprint", ".viva", ".vivo", ".vlaanderen", ".vn", ".vodka", ".volkswagen", ".volvo", ".vote", ".voting", ".voto", ".voyage", ".vu", ".vuelos", ".wales", ".walmart", ".walter", ".wang", ".wanggou", ".watch", ".watches", ".weather", ".weatherchannel", ".webcam", ".weber", ".website", ".wed", ".wedding", ".weibo", ".weir", ".wf", ".whoswho", ".wien", ".wiki", ".williamhill", ".win", ".windows", ".wine", ".winners", ".wme", ".wolterskluwer", ".woodside", ".work", ".works", ".world", ".wow", ".ws", ".wtc", ".wtf", ".xbox", ".xerox", ".xfinity", ".xihuan", ".xin", ".xn--11b4c3d", ".xn--1ck2e1b", ".xn--1qqw23a", ".xn--2scrj9c", ".xn--30rr7y", ".xn--3bst00m", ".xn--3ds443g", ".xn--3e0b707e", ".xn--3hcrj9c", ".xn--3oq18vl8pn36a", ".xn--3pxu8k", ".xn--42c2d9a", ".xn--45br5cyl", ".xn--45brj9c", ".xn--45q11c", ".xn--4gbrim", ".xn--54b7fta0cc", ".xn--55qw42g", ".xn--55qx5d", ".xn--5su34j936bgsg", ".xn--5tzm5g", ".xn--6frz82g", ".xn--6qq986b3xl", ".xn--80adxhks", ".xn--80ao21a", ".xn--80aqecdr1a", ".xn--80asehdb", ".xn--80aswg", ".xn--8y0a063a", ".xn--90a3ac", ".xn--90ae", ".xn--90ais", ".xn--9dbq2a", ".xn--9et52u", ".xn--9krt00a", ".xn--b4w605ferd", ".xn--bck1b9a5dre4c", ".xn--c1avg", ".xn--c2br7g", ".xn--cck2b3b", ".xn--cg4bki", ".xn--clchc0ea0b2g2a9gcd", ".xn--czr694b", ".xn--czrs0t", ".xn--czru2d", ".xn--d1acj3b", ".xn--d1alf", ".xn--e1a4c", ".xn--eckvdtc9d", ".xn--efvy88h", ".xn--estv75g", ".xn--fct429k", ".xn--fhbei", ".xn--fiq228c5hs", ".xn--fiq64b", ".xn--fiqs8s", ".xn--fiqz9s", ".xn--fjq720a", ".xn--flw351e", ".xn--fpcrj9c3d", ".xn--fzc2c9e2c", ".xn--fzys8d69uvgm", ".xn--g2xx48c", ".xn--gckr3f0f", ".xn--gecrj9c", ".xn--gk3at1e", ".xn--h2breg3eve", ".xn--h2brj9c", ".xn--h2brj9c8c", ".xn--hxt814e", ".xn--i1b6b1a6a2e", ".xn--imr513n", ".xn--io0a7i", ".xn--j1aef", ".xn--j1amh", ".xn--j6w193g", ".xn--jlq61u9w7b", ".xn--jvr189m", ".xn--kcrx77d1x4a", ".xn--kprw13d", ".xn--kpry57d", ".xn--kpu716f", ".xn--kput3i", ".xn--l1acc", ".xn--lgbbat1ad8j", ".xn--mgb9awbf", ".xn--mgba3a3ejt", ".xn--mgba3a4f16a", ".xn--mgba7c0bbn0a", ".xn--mgbaakc7dvf", ".xn--mgbaam7a8h", ".xn--mgbab2bd", ".xn--mgbah1a3hjkrd", ".xn--mgbai9azgqp6j", ".xn--mgbayh7gpa", ".xn--mgbbh1a", ".xn--mgbbh1a71e", ".xn--mgbc0a9azcg", ".xn--mgbca7dzdo", ".xn--mgbcpq6gpa1a", ".xn--mgberp4a5d4ar", ".xn--mgbgu82a", ".xn--mgbi4ecexp", ".xn--mgbpl2fh", ".xn--mgbt3dhd", ".xn--mgbtx2b", ".xn--mgbx4cd0ab", ".xn--mix891f", ".xn--mk1bu44c", ".xn--mxtq1m", ".xn--ngbc5azd", ".xn--ngbe9e0a", ".xn--ngbrx", ".xn--node", ".xn--nqv7f", ".xn--nqv7fs00ema", ".xn--nyqy26a", ".xn--o3cw4h", ".xn--ogbpf8fl", ".xn--otu796d", ".xn--p1acf", ".xn--p1ai", ".xn--pbt977c", ".xn--pgbs0dh", ".xn--pssy2u", ".xn--q7ce6a", ".xn--q9jyb4c", ".xn--qcka1pmc", ".xn--qxa6a", ".xn--qxam", ".xn--rhqv96g", ".xn--rovu88b", ".xn--rvc1e0am3e", ".xn--s9brj9c", ".xn--ses554g", ".xn--t60b56a", ".xn--tckwe", ".xn--tiq49xqyj", ".xn--unup4y", ".xn--vermgensberater-ctb", ".xn--vermgensberatung-pwb", ".xn--vhquv", ".xn--vuq861b", ".xn--w4r85el8fhu5dnra", ".xn--w4rs40l", ".xn--wgbh1c", ".xn--wgbl6a", ".xn--xhq521b", ".xn--xkc2al3hye2a", ".xn--xkc2dl3a5ee0h", ".xn--y9a3aq", ".xn--yfro4i67o", ".xn--ygbi2ammx", ".xn--zfr164b", ".xxx", ".xyz", ".yachts", ".yahoo", ".yamaxun", ".yandex", ".ye", ".yodobashi", ".yoga", ".yokohama", ".you", ".youtube", ".yt", ".yun", ".za", ".zappos", ".zara", ".zero", ".zip", ".zm", ".zone", ".zurich", ".zw")

os.system('clear')
print(printmessage1)
print(printmessage2, end="\r")

MyList = []
MySetWhite = set()
MySet = set()
MySet2 = set()

quelle = 1
if os.path.exists(tempfile):
    os.remove(tempfile)

for URL in MyURLs:
    print(printmessage3 + str(quelle) + '/' + str(len(MyURLs)), end="\r")
    quelle = quelle + 1
    #Datei aus Internet runterladen
    with suppress(Exception):
        req = Request(URL, headers={'User-Agent': 'Mozilla/5.0'})
        webpage = urlopen(req).read()
        with open(tempfile, mode="ab") as f:
            f.write(webpage)
            f.close()
os.system('clear')

MyURLs.clear()

print(printmessage4)
pattern6 = re.compile("^[a-z0-9\-\.]{2,256}\.[a-z]{2,18}$")
pattern7 = re.compile("^\|\|[a-z0-9\-\.]{2,256}\.[a-z]{2,18}\^$")
with open(tempfile, "r") as f1:
    for line in f1:
        if pattern6.match(line) is not None:
            MySet.add(line.strip())
        if pattern7.match(line) is not None:
            MySet.add(line[2:-2].strip())

# START Whitelisting
if os.path.exists(whitelist):
    with open(whitelist, "r") as f3:
        for line in f3:
            MySetWhite.add(line.strip())
    MySet = MySet.difference(MySetWhite)
    # Spare RAM durch Löschen alter Sets
    MySetWhite.clear()
# END Whitelisting

FormatSetCounter = '{:,}'.format(len(MySet)).replace(',', '.')
print(printmessage5 + str(FormatSetCounter) + '            ')

for item in MySet:
    MySet2.add('||' +  item.strip() + '^\n')

# Spare RAM durch Löschen alter Sets
MySet.clear()
# Umwandlung vom Set zur List
print(printmessage6, end="\r")

MyList = sorted(MySet2)
# Spare RAM durch Löschen alter Sets
MySet2.clear()

print(printmessage7, end="\r")

# Evtl. alte vorhandene Datei wird gelöscht
if os.path.exists(targetfile):
    os.remove(targetfile)

# neue Datei wird geschrieben
with open(targetfile, 'a') as fp:
    for item in MyList:
        fp.write(item)
# Spare RAM durch Löschen alter Sets
MyList.clear()

if os.path.exists(tempfile):
    os.remove(tempfile)
print(printmessage8)
