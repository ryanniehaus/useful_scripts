#!/bin/bash

TEMP_DIR=~/.package_sync_script_temp_dir
SYNC_DIR=~/Dropbox/PACKAGE_SYNCING
SYNC_WAIT_TIME_SECS=10

function determine_current_selections
{
			dpkg --get-selections \
				| grep -vE "deinstall$" \
				| sed 's/[ \t]\+[^ \t]\+$//' \
				| sed 's/:.\+$//' \
				| sed 's/^lib\(x*\)32/lib\1/' \
				| sed 's/-multilib$//' \
				| sed 's/^ia32-libs$//' \
				| sed 's/-x32$//' \
				| sed 's/-i386$//' \
				| sed 's/-amd64$//' \
				| sed 's/-x86_64$//' \
				| sed 's/-x64$//' \
				| sort -du
}

if [ ! -f "$SYNC_DIR/LOCKED" ]
then
	hostname > "$SYNC_DIR/LOCKED"
	sleep $SYNC_WAIT_TIME_SECS
	
	myHostName=$(hostname)
	storedHostName=$(cat "$SYNC_DIR/LOCKED")
	if [ ! "$storedHostName" == "$myHostName" ]
	then
		echo "DROPBOX INDICATES THAT THE SYNCED PACKAGE LISTS ARE LOCKED.  Try Again Later!!"
	else
		temp_date=$(date -d "$(tail -n 1 /var/log/dpkg.log | tr -s "[:space:]" | cut -d " " -f 1-2)" +%s)
		if [ -f "$SYNC_DIR/SYNCED_DATE.txt" ]
		then
			synced_date=$(cat "$SYNC_DIR/SYNCED_DATE.txt")
		else
			synced_date=$(($temp_date-1))
		fi
		
		if [ ! -d "$TEMP_DIR" ]
		then
			mkdir "$TEMP_DIR"
		fi

		determine_current_selections > "$TEMP_DIR/my_selections.txt"
		
		if [ $temp_date -gt $synced_date ]
		then
			echo "sync my selections list to the shared selections list (new ones in my list added to shared list, removed ones in my list removed from shared list)"
		elif [ $temp_date -lt $synced_date ]
		then
			echo "sync shared selections list my selections list (new ones in shared list installed on my machine, removed ones in shared list removed from my machine)"
			diff "$SYNC_DIR/SYNCED_PACKAGES.txt" "$TEMP_DIR/my_selections.txt" > "$TEMP_DIR/selection_comparison.txt"
			temp_wc=$(cat "$TEMP_DIR/selection_comparison.txt" | wc -w)
			if [ ! "$temp_wc" == "0" ]
			then
				cat "$TEMP_DIR/selection_comparison.txt" \
					| grep -E "^<" \
					| sed 's/^[<>][ \t]\+\([^ \t]*\)/\1/' > "$TEMP_DIR/new_packages.txt"
				cat "$TEMP_DIR/selection_comparison.txt" \
					| grep -E "^>" \
					| sed 's/^[<>][ \t]\+\([^ \t]*\)/\1/' > "$TEMP_DIR/removed_packages.txt"
				sudo aptitude update
				temp_wc=$(cat "$TEMP_DIR/removed_packages.txt" | wc -w)
				if [ ! "$temp_wc" == "0" ]
				then
					echo "removing packages: "$(cat "$TEMP_DIR/removed_packages.txt")
					sudo aptitude remove $(cat "$TEMP_DIR/removed_packages.txt")
				fi
				temp_wc=$(cat "$TEMP_DIR/new_packages.txt" | wc -w)
				if [ ! "$temp_wc" == "0" ]
				then
					echo "installing packages: "$(cat "$TEMP_DIR/new_packages.txt")
					sudo aptitude install $(cat "$TEMP_DIR/new_packages.txt")
				fi
			fi
			determine_current_selections > "$TEMP_DIR/my_selections.txt"
			temp_date=$(date -d "$(tail -n 1 /var/log/dpkg.log | tr -s "[:space:]" | cut -d " " -f 1-2)" +%s)
		else
			echo "DATES MATCH... NO UPDATED NEEDED!"
		fi
		echo $temp_date > "$SYNC_DIR/SYNCED_DATE.txt"
		cp "$TEMP_DIR/my_selections.txt" "$SYNC_DIR/SYNCED_PACKAGES.txt"
		sleep $SYNC_WAIT_TIME_SECS
		rm "$SYNC_DIR/LOCKED"
	fi
else
	echo "DROPBOX INDICATES THAT THE SYNCED PACKAGE LISTS ARE LOCKED.  Try Again Later"
fi



