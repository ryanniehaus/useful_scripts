#!/usr/bin/env bash
#License info at https://github.com/ryanniehaus/useful_scripts/blob/master/LICENSE
# You must have the following utilities install for this to work:
#    - sed
#    - cat
#    - grep
#    - unix2dos
#    - dos2unix
#    - sort
#    - unzip
#    - wget
#    - iconv
#    - file
#    - touch
#    - stat
# The script runs on a bash shell

#get the current script's directory
THIS_SCRIPTS_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

temp_num_args="$#"
OUTPUT_DIR="$THIS_SCRIPTS_DIR"
TEMPORARY_DIR="$THIS_SCRIPTS_DIR"
if [ "$temp_num_args" == "2" ] 
then
	OUTPUT_DIR="$1"
	TEMPORARY_DIR="$2"
elif [ "$temp_num_args" == "1" ]
then
	OUTPUT_DIR="$1"
elif [ ! "$temp_num_args" == "0" ]
then
	echo USAGE:
	echo update_vpnprovidersinfo_and_extract_certs.sh [output_dir [temp_dir]]
	echo output_dir is a path that is writeable by the executor of the process & stores only the files necessary for OpenVPN to work
	echo temp_dir is a path that is writeable by the executor of the process & stores temporary files
	echo if temp_dir is not provided, the script path is used
	echo if output_dir is not provided, the script path is used
	exit 1
fi

echo Using OUTPUT_DIR="$OUTPUT_DIR"
echo Using TEMPORARY_DIR="$TEMPORARY_DIR"

#remove any remnants in the output directory
preexisting_output_files=$(echo "$OUTPUT_DIR"/*.ovpn "$OUTPUT_DIR"/*.pem "$OUTPUT_DIR"/*_username_password.txt)
if [ ! -d "$OUTPUT_DIR" ]
then
	mkdir -v "$OUTPUT_DIR"
elif [ ! "$preexisting_output_files" == "" ]
then
	rm -vrf "$OUTPUT_DIR"/*.ovpn "$OUTPUT_DIR"/*.pem "$OUTPUT_DIR"/*_username_password.txt
fi

#make the current's script's directory our working directory
pushd "$TEMPORARY_DIR" > /dev/null

#loop through all vpn urls containing download links to cert zips
for freevpn_url in http://www.vpnbook.com/freevpn http://www.freevpn.me/accounts https://www.vpnkeys.com/get-free-vpn-instantly https://www.vpnme.me/freevpn.html
do
	echo Processing "$freevpn_url"
	
	# grab the domain name from the url
# not sure why this line doesn't work on FreeBSD
#	url_domain=$(echo "$freevpn_url" | sed 's/^[^:]\+:\/\/\([^\/]\+\).\+$/\1/')
	url_domain=$(echo "$freevpn_url" | sed 's/^https*:\/\///' | sed 's/^s*ftp:\/\///' | sed 's/\/.*$//g')
	
	echo Domain "$url_domain"
	
	# create a subfolder for the domain and enter it
	if [ ! -d "$url_domain" ]
	then
		mkdir "$url_domain"
	fi
	pushd "$url_domain" > /dev/null
	
	# grab the url and rename it to index.html
	wget -O index.html "$freevpn_url"
	
	# grab and store current username and password
	index_mime_encoding=$(file -b --mime-encoding index.html)
	desired_encoding="ascii"
	encoding_conversion_command="iconv -c -s -f $index_mime_encoding -t $desired_encoding"
	
	base_username_password_filename="$url_domain"_username_password.txt
	
	cat index.html | $encoding_conversion_command | dos2unix | grep -EA 10 "OpenVPN[^,]" | grep -E "Username[ \t]*:" | sed 's/[ \t]\+//g' | sed 's/<[^>]\+>//g' | sed 's/^Username://' | unix2dos > "$base_username_password_filename"
	cat index.html | $encoding_conversion_command | dos2unix | grep -EA 10 "OpenVPN[^,]" | grep -E "Password[ \t]*:" | sed 's/[ \t]\+//g' | sed 's/<[^>]\+>//g' | sed 's/^Password://' | unix2dos >> "$base_username_password_filename"
	username_password_contents=$(cat "$base_username_password_filename")
	
	# Parse user/pass from vpnme.me index file
	if [ "$username_password_contents" == "" ]
	then
		rm "$base_username_password_filename"
		cat index.html | $encoding_conversion_command | dos2unix | grep -A 33 "[^a-z] OpenVPN List" | sed 's/[ \t]\+//g' | sed 's/<[^>]\+>//g' | grep -A 100 "Username" | grep -vE "^$" > server_user_pass_dump.txt
		cat server_user_pass_dump.txt | grep -A 100 Username | grep -B 100 -m 2 ":" | head -n-1 | tail -n+2 > user_list.txt
		cat server_user_pass_dump.txt | grep -A 100 Password | tail -n+2 > pass_list.txt
		rm server_user_pass_dump.txt
		number_of_servers=$(cat user_list.txt | wc -l)
		
		for server_index in `seq 1 $number_of_servers`;
		do
			temp_user=$(tail -n+$server_index user_list.txt | head -n 1)
			temp_pass=$(tail -n+$server_index pass_list.txt | head -n 1)
			temp_server=${temp_user:0:2}
			echo "$temp_user" > "$temp_server"_"$base_username_password_filename"
			echo "$temp_pass" >> "$temp_server"_"$base_username_password_filename"
			unix2dos "$temp_server"_"$base_username_password_filename"
		done
		rm user_list.txt
		rm pass_list.txt
	fi
	
	# grab all download*.html file hrefs from the url and download them, only if the timestamp is newer than the file we may currently have
	for suffix in $(cat index.html | grep -E "download[a-zA-Z0-9_]+\.html{0,1}" | sed 's/[ \t]\+//g' | sed 's/.\+href="\([^"]\+\)".\+/\1/' | grep -E "download[a-zA-Z0-9_]+\.html{0,1}")
	do
		# Make sure we aren't just assuming the paths are relative
	  suffix_is_relative=$(echo "$suffix" | sed 's/^\(.\).\+$/\1/')
	  if [ "$suffix_is_relative" == "/" ]
	  then
			wget -N "$url_domain""$suffix"
		else
			wget -N "$suffix"
		fi
	done
	
	# grab all zip file hrefs from the html files and download them, only if the timestamp is newer than the file we may currently have
	for suffix in $(cat *.htm* | grep ".zip" | sed 's/[ \t]\+//g' | sed 's/.\+href="\([^"]\+\)".\+/\1/' | grep ".zip")
	do
		# Make sure we aren't just assuming the paths are relative
	  suffix_is_relative=$(echo "$suffix" | sed 's/^\(.\).\+$/\1/')
	  if [ "$suffix_is_relative" == "/" ]
	  then
			wget -N "$url_domain""$suffix"
		else
			wget -N "$suffix"
		fi
	done

	# unzip all downloaded archives
	for zipfile in $(echo *.zip)
	do
		unzip -ouj "$zipfile" -d .
	done

	# for each openvpn file
	for ovpn_file in $(find . -type f -name "*.ovpn" | grep -vE "\.NEW\.ovpn" | sed 's/^\.\///')
	do
		basename=$(echo "$ovpn_file" | sed 's/^\(.\+\)\.ovpn$/\1/')
		> "$basename".NEW.ovpn
		
		# extract all inline certs to the .pem format
		for tagname in ca cert key dh extra-certs pkcs12 secret tls-auth
		do
			check_inline_tag_exists=$(cat "$ovpn_file" | grep -A 100 "<""$tagname"">" | grep -B 100 "</""$tagname"">" | grep -vE "</*""$tagname"">")
			# add the new cert file references to the start of the new ovpn copy
			if [ ! "$check_inline_tag_exists" == "" ]
			then
				cat "$ovpn_file" | grep -A 100 "<""$tagname"">" | grep -B 100 "</""$tagname"">" | grep -vE "</*""$tagname"">" > "$ovpn_file"."$tagname".pem
				echo "$tagname" "$ovpn_file"."$tagname".pem >> "$basename".NEW.ovpn
			fi
		done
		
		# if the username and password were found, add a reference to that file near the start of the new ovpn copy (not currently supported by network-manager, but it would be nice if it was)
		if [ "$username_password_contents" == "" ]
		then
			temp_server=$(echo "$ovpn_file" | sed 's/^.\+_\([^_]\{2\}\)_.\+\.ovpn$/\1/')
			echo auth-user-pass "$temp_server"_"$base_username_password_filename" >> "$basename".NEW.ovpn
		else
			echo auth-user-pass "$base_username_password_filename" >> "$basename".NEW.ovpn
		fi
		
		# copy all the other contents of the file, excluding any cert and auth lines that should already be in the new copy
		cat "$ovpn_file" \
			| dos2unix \
			| grep -vE "^auth-user-pass[ \t]*.*$" \
			| grep -vE "^ca[ \t]*.*$" \
			| grep -vE "^cert[ \t]*.*$" \
			| grep -vE "^key[ \t]*.*$" \
			| grep -vE "^dh[ \t]*.*$" \
			| grep -vE "^extra-certs[ \t]*.*$" \
			| grep -vE "^pkcs12[ \t]*.*$" \
			| grep -vE "^secret[ \t]*.*$" \
			| grep -vE "^tls-auth[ \t]*.*$" \
			| unix2dos >> "$basename".NEW.ovpn

		#grab original timestamp
		filemodtime=$(stat -c%y "$ovpn_file" | sed 's/[ ]\+/ /g')
		# replace the old copy with the new one
		mv -f "$basename".NEW.ovpn "$ovpn_file"
		#preserve original timestamp
		touch -m -d "$filemodtime" "$ovpn_file"
	done
	
	cp -vrf ./*.ovpn ./*.pem ./*"$base_username_password_filename" "$OUTPUT_DIR"/
	popd > /dev/null
done
popd > /dev/null
