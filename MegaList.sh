#!/bin/bash

linkfile=/tmp/RPi-LINKS.txt
blocklistfile=/tmp/RPi-BLOCKLIST
megalist=megalist.txt
blocklistenmd=https://github.com/RPiList/specials/raw/master/Blocklisten.md

# "n" (no) or "y" (yes)
abp-style=n

# ---------------------------------------------------------------------------
rm $linkfile
rm $blocklistfile-*.txt

echo downloading $blocklistenmd
curl -L -o $linkfile $blocklistenmd
RESULT=$?
if [ $RESULT -ne 0 ]; then
	echo downloading $blocklistenmd failed;
	curl -L -o $linkfile $blocklistenmd;
	RESULT=$?
	if [ $RESULT -ne 0 ]; then
		echo downloading $blocklistenmd failed again;
		exit 1;
	fi
fi

echo prepare $linkfile for next step
# Erklärung: Mit # beginenden Zeilen Wörter entfernen
sed -i 's/^#.*$//g' $linkfile
# Erklärung: Leere Leerzeilen entfernen
sed -i '/^$/d' $linkfile
# Erklärung: Doppelte Zeilen filtern
sort -u $linkfile > $linkfile.tmp
mv $linkfile.tmp $linkfile
# Erklärung: Alle Listen die nicht von RPiList/specials sind, aus linkfile entfernen
cat $linkfile | grep "RPiList/specials" > $linkfile.tmp
mv $linkfile.tmp $linkfile


while read line; do
	echo downloading $line
	curl -L -o $blocklistfile-$RANDOM$RANDOM$RANDOM.txt $line
	RESULT=$?
	if [ $RESULT -ne 0 ]; then
		echo downloading $line failed;
		curl -L -o $blocklistfile-$RANDOM$RANDOM$RANDOM.txt $line;
		RESULT=$?
		if [ $RESULT -ne 0 ]; then
			echo downloading $line failed again;
			rm $linkfile
			rm $blocklistfile-*.txt
			exit 1;
		fi
	fi
done < $linkfile

echo add downloaded $blocklistfile.txt to $megalist
cat $blocklistfile-*.txt > /tmp/$megalist
# Erklärung: Mit # beginenden Zeilen Wörter entfernen
sed -i 's/^#.*$//g' /tmp/$megalist
# Erklärung: Leere Leerzeilen entfernen
sed -i '/^$/d' /tmp/$megalist
# Erklärung: Doppelte Zeilen filtern
sort -u /tmp/$megalist > /tmp/$megalist.tmp
mv /tmp/$megalist.tmp $megalist


if [ "$abp-style" != "y" ]; then
	echo remove ABP-Style values out of $megalist
	sed -i 's/^||.*$//g' $megalist
	sed -i 's/^@@.*$//g' $megalist
	# Erklärung: Leere Leerzeilen entfernen
	sed -i '/^$/d' $megalist
	# Erklärung: Doppelte Zeilen filtern
	sort -u $megalist > /tmp/$megalist.tmp
	mv /tmp/$megalist.tmp $megalist
fi

rm $linkfile
rm $blocklistfile-*.txt

echo $megalist was created
