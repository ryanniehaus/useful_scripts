#!/bin/bash

TEST_ONLY=0
MAX_SUPPORTED_STATIONS=1000
MAX_SUPPORTED_CLIENTS=$MAX_SUPPORTED_STATIONS
INITIAL_SCAN_WAIT_PERIOD_SECONDS=2

function get_devices
{
	sudo airmon-ng &> airmon_dump.log
	cat ./airmon_dump.log \
		| grep -v Driver \
		| awk /./ \
		| sed 's/^[ \t]*[^ \t]\+[ \t]\+\([^ \t]\+\)[ \t]\+.\+$/\1/' \
		> ./airmon_devices.log
}

function set_permissions
{
	sudo chown -R ryan:ryan .
	sudo chmod -R a+r,a-w,u+s,g+s,o+s .
	sudo chmod ug+wx ./*.sh
	sudo chmod ug+w ./*.log
	sudo chmod ug+w .
}

function add_single_station_to_list
{
	tempStationBSSID="$1"
	found_global_list="$(cat GLOBAL_STATION_LIST.csv | grep "$tempStationBSSID")"
		tempStationFTS="$2"
		tempStationLTS="$3"
		tempStationChannel="$4"
		tempStationSpeed="$5"
		tempStationPrivacy="$6"
		tempStationCipher="$7"
		tempStationAuth="$8"
		tempStationPower="$9"
		tempStationBeacons="${10}"
		tempStationIVS="${11}"
		tempStationLANIP="${12}"
		tempStationIDLen="${13}"
		tempStationESSID="${14}"
		tempStationKey="${15}"
		tempStationCrackStatus="${16}"

		if [ "$found_global_list" == "" ]
		then
			echo $(echo "$tempLine" | tr -d '\n' | tr -d '\r')",""$tempStationCrackStatus" >> GLOBAL_STATION_LIST.csv
		else
			#echo "$tempStationBSSID already in STATION LIST"

			existingStationBSSID="$(echo $found_global_list | cut -d "," -f $STATION_BSSID_COL)"
			existingStationFTS="$(echo $found_global_list | cut -d "," -f $STATION_FTS_COL)"
			existingStationLTS="$(echo $found_global_list | cut -d "," -f $STATION_LTS_COL)"
			existingStationChannel="$(echo $found_global_list | cut -d "," -f $STATION_CHANNEL_COL)"
			existingStationSpeed="$(echo $found_global_list | cut -d "," -f $STATION_SPEED_COL)"
			existingStationPrivacy="$(echo $found_global_list | cut -d "," -f $STATION_PRIVACY_COL)"
			existingStationCipher="$(echo $found_global_list | cut -d "," -f $STATION_CIPHER_COL)"
			existingStationAuth="$(echo $found_global_list | cut -d "," -f $STATION_AUTH_COL)"
			existingStationPower="$(echo $found_global_list | cut -d "," -f $STATION_POWER_COL)"
			existingStationBeacons="$(echo $found_global_list | cut -d "," -f $STATION_BEACONS_COL)"
			existingStationIVS="$(echo $found_global_list | cut -d "," -f $STATION_IVS_COL)"
			existingStationLANIP="$(echo $found_global_list | cut -d "," -f $STATION_LANIP_COL)"
			existingStationIDLen="$(echo $found_global_list | cut -d "," -f $STATION_IDLEN_COL)"
			existingStationESSID="$(echo $found_global_list | cut -d "," -f $STATION_ESSID_COL)"
			existingStationKey="$(echo $found_global_list | cut -d "," -f $STATION_KEY_COL)"
			existingStationCrackStatus="$(echo $found_global_list | cut -d "," -f $STATION_CRACKSTATUS_COL)"

			newStationBSSID="$existingStationBSSID"
			newStationFTS="$existingStationFTS"
			newStationLTS="$existingStationLTS"
			newStationChannel="$existingStationChannel"
			newStationSpeed="$existingStationSpeed"
			newStationPrivacy="$existingStationPrivacy"
			newStationCipher="$existingStationCipher"
			newStationAuth="$existingStationAuth"
			newStationPower="$existingStationPower"
			newStationBeacons="$existingStationBeacons"
			newStationIVS="$existingStationIVS"
			newStationLANIP="$existingStationLANIP"
			newStationIDLen="$existingStationIDLen"
			newStationESSID="$existingStationESSID"
			newStationKey="$existingStationKey"
			newStationCrackStatus="$existingStationCrackStatus"
			#echo $tempStationCrackStatus
			if [ ! "$tempStationCrackStatus" == "Not Started" ]
			then
				newStationCrackStatus="$tempStationCrackStatus"
			fi

			numStationFields=$(cat STATION_FIELD_LIST.csv | wc -l)
			tempnewline=""
			for fieldIter in $(seq 1 $numStationFields)
			do
				if [ "$fieldIter" == "$STATION_BSSID_COL" ]
				then
					tempnewline="$tempnewline""$newStationBSSID"
				elif [ "$fieldIter" == "$STATION_FTS_COL" ]
				then
					tempnewline="$tempnewline""$newStationFTS"
				elif [ "$fieldIter" == "$STATION_LTS_COL" ]
				then
					tempnewline="$tempnewline""$newStationLTS"
				elif [ "$fieldIter" == "$STATION_CHANNEL_COL" ]
				then
					tempnewline="$tempnewline""$newStationChannel"
				elif [ "$fieldIter" == "$STATION_SPEED_COL" ]
				then
					tempnewline="$tempnewline""$newStationSpeed"
				elif [ "$fieldIter" == "$STATION_PRIVACY_COL" ]
				then
					tempnewline="$tempnewline""$newStationPrivacy"
				elif [ "$fieldIter" == "$STATION_CIPHER_COL" ]
				then
					tempnewline="$tempnewline""$newStationCipher"
				elif [ "$fieldIter" == "$STATION_AUTH_COL" ]
				then
					tempnewline="$tempnewline""$newStationAuth"
				elif [ "$fieldIter" == "$STATION_POWER_COL" ]
				then
					tempnewline="$tempnewline""$newStationPower"
				elif [ "$fieldIter" == "$STATION_BEACONS_COL" ]
				then
					tempnewline="$tempnewline""$newStationBeacons"
				elif [ "$fieldIter" == "$STATION_IVS_COL" ]
				then
					tempnewline="$tempnewline""$newStationIVS"
				elif [ "$fieldIter" == "$STATION_LANIP_COL" ]
				then
					tempnewline="$tempnewline""$newStationLANIP"
				elif [ "$fieldIter" == "$STATION_IDLEN_COL" ]
				then
					tempnewline="$tempnewline""$newStationIDLen"
				elif [ "$fieldIter" == "$STATION_ESSID_COL" ]
				then
					tempnewline="$tempnewline""$newStationESSID"
				elif [ "$fieldIter" == "$STATION_KEY_COL" ]
				then
					tempnewline="$tempnewline""$newStationKey"
				fi

				if [ $fieldIter -lt $numStationFields ]
				then
					tempnewline="$tempnewline"","
				fi
			done

			tempnewline="$tempnewline"",""$newStationCrackStatus"

			cat GLOBAL_STATION_LIST.csv | grep -v "Authentication" | grep -v "$tempStationBSSID" > tempstationlistfile1.csv
			echo "$tempnewline" >> tempstationlistfile1.csv
			head -n 1 GLOBAL_STATION_LIST.csv > tempstationlistfile2.csv
			chmod ug+rw GLOBAL_STATION_LIST.csv
			cat tempstationlistfile2.csv > GLOBAL_STATION_LIST.csv
			cat tempstationlistfile1.csv | sort -t "," -k $STATION_POWER_COL,$(($STATION_POWER_COL + 1)) | awk /./ >> GLOBAL_STATION_LIST.csv
			chmod ug-w GLOBAL_STATION_LIST.csv
			rm tempstationlistfile*.csv
		fi
}

function add_stations_to_list
{
	stations_file_to_add="$1"
	use_status="$2"

	temp_file_length=$(cat "$stations_file_to_add" | wc -l)
	file_length=$(( $temp_file_length - 1))

	for i in $(seq 1 $file_length)
	do
		tempLine="$(tail -n+$i "$stations_file_to_add" | head -n1)"
		tempStationBSSID="$(echo $tempLine | cut -d "," -f $STATION_BSSID_COL)"
		tempStationFTS="$(echo $tempLine | cut -d "," -f $STATION_FTS_COL)"
		tempStationLTS="$(echo $tempLine | cut -d "," -f $STATION_LTS_COL)"
		tempStationChannel="$(echo $tempLine | cut -d "," -f $STATION_CHANNEL_COL)"
		tempStationSpeed="$(echo $tempLine | cut -d "," -f $STATION_SPEED_COL)"
		tempStationPrivacy="$(echo $tempLine | cut -d "," -f $STATION_PRIVACY_COL)"
		tempStationCipher="$(echo $tempLine | cut -d "," -f $STATION_CIPHER_COL)"
		tempStationAuth="$(echo $tempLine | cut -d "," -f $STATION_AUTH_COL)"
		tempStationPower="$(echo $tempLine | cut -d "," -f $STATION_POWER_COL)"
		tempStationBeacons="$(echo $tempLine | cut -d "," -f $STATION_BEACONS_COL)"
		tempStationIVS="$(echo $tempLine | cut -d "," -f $STATION_IVS_COL)"
		tempStationLANIP="$(echo $tempLine | cut -d "," -f $STATION_LANIP_COL)"
		tempStationIDLen="$(echo $tempLine | cut -d "," -f $STATION_IDLEN_COL)"
		tempStationESSID="$(echo $tempLine | cut -d "," -f $STATION_ESSID_COL)"
		tempStationKey="$(echo $tempLine | cut -d "," -f $STATION_KEY_COL)"
		
		add_single_station_to_list "$tempStationBSSID" "$tempStationFTS" "$tempStationLTS" "$tempStationChannel" "$tempStationSpeed" "$tempStationPrivacy" "$tempStationCipher" "$tempStationAuth" "$tempStationPower" "$tempStationBeacons" "$tempStationIVS" "$tempStationLANIP" "$tempStationIDLen" "$tempStationESSID" "$tempStationKey" "$use_status"
	done

	cat GLOBAL_STATION_LIST.csv | grep -v "Authentication" > tempstationlistfile1.csv
	head -n 1 GLOBAL_STATION_LIST.csv > tempstationlistfile2.csv
	cat tempstationlistfile2.csv > GLOBAL_STATION_LIST.csv
	cat tempstationlistfile1.csv | sort -t "," -k $STATION_POWER_COL,$(($STATION_POWER_COL + 1)) | awk /./ >> GLOBAL_STATION_LIST.csv
	rm tempstationlistfile*.csv
}

function add_clients_to_list
{
	clients_file_to_add="$1"

	temp_file_length=$(cat "$clients_file_to_add" | wc -l)
	file_length=$(( $temp_file_length - 1))

	for i in $(seq 1 $file_length)
	do
		tempLine="$(tail -n+$i "$clients_file_to_add" | head -n1)"
		tempClientMAC="$(echo $tempLine | cut -d "," -f $CLIENT_STATIONMAC_COL)"
		found_global_list="$(cat GLOBAL_CLIENT_LIST.csv | grep "$tempClientMAC")"

		if [ "$found_global_list" == "" ]
		then
			echo "$tempLine" >> GLOBAL_CLIENT_LIST.csv
		else
			#echo "$tempClientMAC already in CLIENT LIST"
			tempClientFTS="$(echo $tempLine | cut -d "," -f $CLIENT_FTS_COL)"
			tempClientLTS="$(echo $tempLine | cut -d "," -f $CLIENT_LTS_COL)"
			tempClientPower="$(echo $tempLine | cut -d "," -f $CLIENT_POWER_COL)"
			tempClientPackets="$(echo $tempLine | cut -d "," -f $CLIENT_PACKETS_COL)"
			tempClientBSSID="$(echo $tempLine | cut -d "," -f $CLIENT_BSSID_COL)"
			tempClientESSIDS="$(echo $tempLine | cut -d "," -f $CLIENT_ESSIDS_COL)"

			existingClientMAC="$(echo $found_global_list | cut -d "," -f $CLIENT_STATIONMAC_COL)"
			existingClientFTS="$(echo $found_global_list | cut -d "," -f $CLIENT_FTS_COL)"
			existingClientLTS="$(echo $found_global_list | cut -d "," -f $CLIENT_LTS_COL)"
			existingClientPower="$(echo $found_global_list | cut -d "," -f $CLIENT_POWER_COL)"
			existingClientPackets="$(echo $found_global_list | cut -d "," -f $CLIENT_PACKETS_COL)"
			existingClientBSSID="$(echo $found_global_list | cut -d "," -f $CLIENT_BSSID_COL)"
			existingClientESSIDS="$(echo $found_global_list | cut -d "," -f $CLIENT_ESSIDS_COL)"

			newClientMAC="$existingClientMAC"
			newClientFTS="$existingClientFTS"
			newClientLTS="$existingClientLTS"
			newClientPower="$existingClientPower"
			newClientPackets="$existingClientPackets"
			newClientBSSID="$existingClientBSSID"
			newClientESSIDS="$existingClientESSIDS"

			numClientFields=$(cat CLIENT_FIELD_LIST.csv | wc -l)
			tempnewline=""
			for fieldIter in $(seq 1 $numClientFields)
			do
				if [ "$fieldIter" == "$CLIENT_STATIONMAC_COL" ]
				then
					tempnewline="$tempnewline""$newClientMAC"
				elif [ "$fieldIter" == "$CLIENT_FTS_COL" ]
				then
					tempnewline="$tempnewline""$newClientFTS"
				elif [ "$fieldIter" == "$CLIENT_LTS_COL" ]
				then
					tempnewline="$tempnewline""$newClientLTS"
				elif [ "$fieldIter" == "$CLIENT_POWER_COL" ]
				then
					tempnewline="$tempnewline""$newClientPower"
				elif [ "$fieldIter" == "$CLIENT_PACKETS_COL" ]
				then
					tempnewline="$tempnewline""$newClientPackets"
				elif [ "$fieldIter" == "$CLIENT_BSSID_COL" ]
				then
					tempnewline="$tempnewline""$newClientBSSID"
				elif [ "$fieldIter" == "$CLIENT_ESSIDS_COL" ]
				then
					tempnewline="$tempnewline""$newClientESSIDS"
				fi

				if [ $fieldIter -lt $numClientFields ]
				then
					tempnewline="$tempnewline"","
				fi
			done

			cat GLOBAL_CLIENT_LIST.csv | grep -v "Station MAC" | grep -v "$tempClientMAC" > tempclientlistfile1.csv
			echo "$tempnewline" >> tempclientlistfile1.csv
			head -n 1 GLOBAL_CLIENT_LIST.csv > tempclientlistfile2.csv
			cat tempclientlistfile2.csv > GLOBAL_CLIENT_LIST.csv
			cat tempclientlistfile1.csv | sort -t "," -k $CLIENT_POWER_COL,$(($CLIENT_POWER_COL + 1)) | awk /./ >> GLOBAL_CLIENT_LIST.csv
			rm tempclientlistfile*.csv
		fi
	done

	cat GLOBAL_CLIENT_LIST.csv | grep -v "Station MAC" > tempclientlistfile1.csv
	head -n 1 GLOBAL_CLIENT_LIST.csv > tempclientlistfile2.csv
	cat tempclientlistfile2.csv > GLOBAL_CLIENT_LIST.csv
	cat tempclientlistfile1.csv | sort -t "," -k $CLIENT_POWER_COL,$(($CLIENT_POWER_COL + 1)) | awk /./ >> GLOBAL_CLIENT_LIST.csv
	rm tempclientlistfile*.csv
}

sudo stop network-manager
TEMP_WPA_SUPPLICANT_COMMAND=$(ps -C wpa_supplicant --format args=)
echo killing wpa_supplicant $(ps -C wpa_supplicant --format pid=)
sudo kill $(ps -C wpa_supplicant --format pid=)
sleep 2
get_devices
wlaninterfaces=$(cat ./airmon_devices.log)
airodump_interfaces=""
airodump_interfaces_count=0
for each in $wlaninterfaces
do
	if [ ! "$TEST_ONLY" == "1" ]
	then
		sudo airmon-ng start $each &> ./airmon-ng_start_$each.log
	fi
	if [ ! "$airodump_interfaces" == "" ]
	then
		airodump_interfaces="$airodump_interfaces",
	fi
	airodump_interfaces="$airodump_interfaces"$each"mon"
	airodump_interfaces_count=$(( $airodump_interfaces_count + 1))
done

sleep 2

sudo airodump-ng \
	-w INIT_LIST_DUMP_ \
	--manufacture \
	--uptime \
	--wps \
	--write-interval 1 \
	"$airodump_interfaces" \
	--output-format csv,pcap &
set_permissions

sleep $INITIAL_SCAN_WAIT_PERIOD_SECONDS
clear
echo killing airodump-ng $(ps -C airodump-ng --format pid=)
sudo kill $(ps -C airodump-ng --format pid=)

list_dump_count=0
for csvFile in $(echo INIT_LIST_DUMP_*.csv | grep -v "kismet")
do
	chmod ug+rw .

	if [ "$list_dump_count" == "0" ]
	then
		chmod ug+rw GLOBAL_*_LIST.csv *_FIELD_LIST.csv
		cat "$csvFile" | sed 's/,[ \t]\+/,/g' | grep "Authentication" > GLOBAL_STATION_LIST.csv
		tempHeaders=$(echo $(cat GLOBAL_STATION_LIST.csv | tr -d '\n' | tr -d '\r')",CRACK_STATUS")
		cat "$csvFile" | sed 's/,[ \t]\+/,/g' | grep "Station MAC" > GLOBAL_CLIENT_LIST.csv
		cat GLOBAL_STATION_LIST.csv | sed 's/,/\n/g' | awk "/./" > STATION_FIELD_LIST.csv
		cat GLOBAL_CLIENT_LIST.csv | sed 's/,/\n/g' | awk "/./" > CLIENT_FIELD_LIST.csv
		echo "$tempHeaders" > GLOBAL_STATION_LIST.csv
		STATION_BSSID_COL=$(grep -n "BSSID" STATION_FIELD_LIST.csv | sed 's/:.\+$//')
		STATION_FTS_COL=$(grep -n "First time seen" STATION_FIELD_LIST.csv | sed 's/:.\+$//')
		STATION_LTS_COL=$(grep -n "Last time seen" STATION_FIELD_LIST.csv | sed 's/:.\+$//')
		STATION_CHANNEL_COL=$(grep -n "channel" STATION_FIELD_LIST.csv | sed 's/:.\+$//')
		STATION_SPEED_COL=$(grep -n "Speed" STATION_FIELD_LIST.csv | sed 's/:.\+$//')
		STATION_PRIVACY_COL=$(grep -n "Privacy" STATION_FIELD_LIST.csv | sed 's/:.\+$//')
		STATION_CIPHER_COL=$(grep -n "Cipher" STATION_FIELD_LIST.csv | sed 's/:.\+$//')
		STATION_AUTH_COL=$(grep -n "Authentication" STATION_FIELD_LIST.csv | sed 's/:.\+$//')
		STATION_POWER_COL=$(grep -n "Power" STATION_FIELD_LIST.csv | sed 's/:.\+$//')
		STATION_BEACONS_COL=$(grep -n "# beacons" STATION_FIELD_LIST.csv | sed 's/:.\+$//')
		STATION_IVS_COL=$(grep -n "# IV" STATION_FIELD_LIST.csv | sed 's/:.\+$//')
		STATION_LANIP_COL=$(grep -n "LAN IP" STATION_FIELD_LIST.csv | sed 's/:.\+$//')
		STATION_IDLEN_COL=$(grep -n "ID-length" STATION_FIELD_LIST.csv | sed 's/:.\+$//')
		STATION_ESSID_COL=$(grep -n "ESSID" STATION_FIELD_LIST.csv | sed 's/:.\+$//')
		STATION_KEY_COL=$(grep -n "Key" STATION_FIELD_LIST.csv | sed 's/:.\+$//')
		STATION_COL_COUNT=$(cat STATION_FIELD_LIST.csv | wc -l)
		STATION_CRACKSTATUS_COL=$(($STATION_COL_COUNT + 1))

		CLIENT_STATIONMAC_COL=$(grep -n "Station MAC" CLIENT_FIELD_LIST.csv | sed 's/:.\+$//')
		CLIENT_FTS_COL=$(grep -n "First time seen" CLIENT_FIELD_LIST.csv | sed 's/:.\+$//')
		CLIENT_LTS_COL=$(grep -n "Last time seen" CLIENT_FIELD_LIST.csv | sed 's/:.\+$//')
		CLIENT_POWER_COL=$(grep -n "Power" CLIENT_FIELD_LIST.csv | sed 's/:.\+$//')
		CLIENT_PACKETS_COL=$(grep -n "# packets" CLIENT_FIELD_LIST.csv | sed 's/:.\+$//')
		CLIENT_BSSID_COL=$(grep -n "BSSID" CLIENT_FIELD_LIST.csv | sed 's/:.\+$//')
		CLIENT_ESSIDS_COL=$(grep -n "Probed ESSIDs" CLIENT_FIELD_LIST.csv | sed 's/:.\+$//')
		CLIENT_COL_COUNT=$(cat CLIENT_FIELD_LIST.csv | wc -l)
	fi

	chmod ug+rw *_LIST_"$csvFile"
	cat "$csvFile" \
		| grep -A $MAX_SUPPORTED_STATIONS "Authentication" \
		| grep -B $MAX_SUPPORTED_STATIONS "Station MAC" \
		| grep -v "Authentication" \
		| grep -v "Station MAC" \
		| sed 's/,[ \t]\+/,/g' \
		| sed 's/\.[ \t]\+/\./g' \
		| sed 's/[ \t]\+\./\./g' \
		| awk "/./" > STATION_LIST_"$csvFile"

	cat "$csvFile" \
		| grep -A $MAX_SUPPORTED_CLIENTS "Station MAC" \
		| grep -v "Station MAC" \
		| sed 's/,[ \t]\+/,/g' \
		| sed 's/\.[ \t]\+/\./g' \
		| sed 's/[ \t]\+\./\./g' \
		| awk "/./" > CLIENT_LIST_"$csvFile"

	add_stations_to_list STATION_LIST_"$csvFile" "Not Started"
	add_clients_to_list CLIENT_LIST_"$csvFile"

	rm STATION_LIST_"$csvFile" CLIENT_LIST_"$csvFile"

	list_dump_count=$(($list_dump_count + 1))
done


temp_file_length=$(cat GLOBAL_STATION_LIST.csv | wc -l)
file_length=$(( $temp_file_length - 1))

active_interfaces=0

numPasses=0
MAXPASSES=10
while [ $numPasses -lt $MAXPASSES ]
do

for tempLineNumber in $(seq 2 $file_length)
do
	tempLine="$(tail -n+$tempLineNumber GLOBAL_STATION_LIST.csv | head -n1)"
	tempStationBSSID="$(echo $tempLine | cut -d "," -f $STATION_BSSID_COL)"
	tempStationFTS="$(echo $tempLine | cut -d "," -f $STATION_FTS_COL)"
	tempStationLTS="$(echo $tempLine | cut -d "," -f $STATION_LTS_COL)"
	tempStationChannel="$(echo $tempLine | cut -d "," -f $STATION_CHANNEL_COL)"
	tempStationSpeed="$(echo $tempLine | cut -d "," -f $STATION_SPEED_COL)"
	tempStationPrivacy="$(echo $tempLine | cut -d "," -f $STATION_PRIVACY_COL)"
	tempStationCipher="$(echo $tempLine | cut -d "," -f $STATION_CIPHER_COL)"
	tempStationAuth="$(echo $tempLine | cut -d "," -f $STATION_AUTH_COL)"
	tempStationPower="$(echo $tempLine | cut -d "," -f $STATION_POWER_COL)"
	tempStationBeacons="$(echo $tempLine | cut -d "," -f $STATION_BEACONS_COL)"
	tempStationIVS="$(echo $tempLine | cut -d "," -f $STATION_IVS_COL)"
	tempStationLANIP="$(echo $tempLine | cut -d "," -f $STATION_LANIP_COL)"
	tempStationIDLen="$(echo $tempLine | cut -d "," -f $STATION_IDLEN_COL)"
	tempStationESSID="$(echo $tempLine | cut -d "," -f $STATION_ESSID_COL)"
	tempStationKey="$(echo $tempLine | cut -d "," -f $STATION_KEY_COL)"
	tempStationCrackStatus="$(echo $tempLine | cut -d "," -f $STATION_CRACKSTATUS_COL)"

	if [ ! "$tempStationCrackStatus" == "DONE" ] && [ ! "$tempStationESSID" == "Niehaus315" ]
	then
		if [ "$tempStationPrivacy" == "WEP" ]
		then
			#echo $tempStationESSID is WEP
			if [ "$tempStationCrackStatus" == "Not Started" ] && [ $active_interfaces -lt $airodump_interfaces_count ]
			then
				echo $tempStationESSID starting scan
				sudo airodump-ng \
					-w INIT_LIST_DUMP_ \
					--manufacture \
					--uptime \
					--wps \
					--write-interval 1 \
					"$airodump_interfaces" \
					--output-format csv,pcap &> /dev/null &
				active_interfaces=$(($active_interfaces + 1))
				set_permissions
				tempStationCrackStatus="Scanning"
			elif [ "$tempStationCrackStatus" == "Scanning" ]
			then
				echo $tempStationESSID being scanned
				tempStationCrackStatus="Scanning With Attacks"
			elif [ "$tempStationCrackStatus" == "Scanning With Attacks" ]
			then
				echo $tempStationESSID being scanned with attacks
				tempStationCrackStatus="Cracking"
			elif [ "$tempStationCrackStatus" == "Cracking" ]
			then
				echo $tempStationESSID cracking
				tempStationCrackStatus="DONE"
				active_interfaces=$(($active_interfaces - 1))
			fi
		elif [ "$tempStationPrivacy" == "WPA" -o "$tempStationPrivacy" == "WPA2" -o "$tempStationPrivacy" == "WPA2 WPA" ]
		then
			#echo $tempStationESSID is WPA or WPA2
			if [ "$tempStationAuth" == "PSK" -o "$tempStationAuth" == "" ]
			then
				if [ "$tempStationCrackStatus" == "Not Started" ] && [ $active_interfaces -lt $airodump_interfaces_count ]
				then
					sudo airodump-ng \
						-w INIT_LIST_DUMP_ \
						--manufacture \
						--uptime \
						--wps \
						--write-interval 1 \
						"$airodump_interfaces" \
						--output-format csv,pcap &> /dev/null &
					active_interfaces=$(($active_interfaces + 1))
					set_permissions
					tempStationCrackStatus="Scanning"
				elif [ "$tempStationCrackStatus" == "Scanning" ]
				then
					echo $tempStationESSID being scanned
					tempStationCrackStatus="Scanning With Attacks"
				elif [ "$tempStationCrackStatus" == "Scanning With Attacks" ]
				then
					echo $tempStationESSID being scanned with attacks
					tempStationCrackStatus="Cracking"
				elif [ "$tempStationCrackStatus" == "Cracking" ]
				then
					echo $tempStationESSID cracking
					tempStationCrackStatus="DONE"
					active_interfaces=$(($active_interfaces - 1))
				fi
			fi
		elif [ "$tempStationPrivacy" == "OPN" ]
		then
			echo $tempStationESSID is OPEN > /dev/null
		else
			echo $tempStationESSID is UNKNOWN type of $tempStationPrivacy
		fi
		
		add_single_station_to_list "$tempStationBSSID" "$tempStationFTS" "$tempStationLTS" "$tempStationChannel" "$tempStationSpeed" "$tempStationPrivacy" "$tempStationCipher" "$tempStationAuth" "$tempStationPower" "$tempStationBeacons" "$tempStationIVS" "$tempStationLANIP" "$tempStationIDLen" "$tempStationESSID" "$tempStationKey" "$tempStationCrackStatus"
	fi
	sleep 0.1
done

  numPasses=$(($numPasses +1))
done

get_devices
wlaninterfaces=$(cat ./airmon_devices.log)
for each in $wlaninterfaces
do
        sudo airmon-ng stop "$each" &> ./airmon_stop_$each.log
done
sleep 2
set_permissions

sudo echo HAVE SUDO ACCESS
driver_depends=$(sudo modinfo -F depends iwlwifi)
sudo modprobe -r $driver_depends
sudo modprobe -r iwlwifi
sudo modprobe iwlwifi
sudo modprobe $driver_depends

echo running "sudo $TEMP_WPA_SUPPLICANT_COMMAND"
sudo $TEMP_WPA_SUPPLICANT_COMMAND
sudo start network-manager

