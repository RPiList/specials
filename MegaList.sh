#!/bin/bash

linkfile=/tmp/RPi-LINKS.txt
blocklistfile=/tmp/RPi-BLOCKLIST
megalist=megalist.txt
blocklistenmd=https://github.com/RPiList/specials/raw/master/Blocklisten.md

# "n" (no) or "y" (yes)
# Accept cli input, if nothing is provided pass "n"
abp_style=${1:-n}

# ---------------------------------------------------------------------------
if [ "$abp_style" != "y" ] && [ "$abp_style" != "n" ]; then
	echo please enter "n" for no or "y" for yes as the parameter to define
	echo whether you want to receive the abp_style values in the megalist.
	echo e.g.
	echo ./MegaList.sh y
	echo or
	echo ./MegaList.sh n
	echo it also works to start the script without parameters.
	echo Without parameter also means "n"
	exit 1
fi

function cleanup() {
	rm $linkfile
	rm $blocklistfile-*.txt
}

cleanup

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


while read -r line; do
	echo downloading "$line"
	curl -L -o $blocklistfile-$RANDOM$RANDOM$RANDOM.txt "$line"
	RESULT=$?
	if [ $RESULT -ne 0 ]; then
		echo downloading "$line" failed;
		curl -L -o $blocklistfile-$RANDOM$RANDOM$RANDOM.txt "$line";
		RESULT=$?
		if [ $RESULT -ne 0 ]; then
			echo downloading "$line" failed again;
			cleanup
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


if [ "$abp_style" != "y" ]; then
	echo remove ABP-Style values out of $megalist
	sed -i 's/^||.*$//g' $megalist
	sed -i 's/^@@.*$//g' $megalist
	# Erklärung: Leere Leerzeilen entfernen
	sed -i '/^$/d' $megalist
	# Erklärung: Doppelte Zeilen filtern
	sort -u $megalist > /tmp/$megalist.tmp
	mv /tmp/$megalist.tmp $megalist
fi

cleanup

echo $megalist was created
