#!/bin/bash
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

#make the current's script's directory our working directory
pushd "$THIS_SCRIPTS_DIR" > /dev/null

#loop through all vpn urls containing download links to cert zips
#TODO: look into adding https://www.vpnme.me/freevpn.html
for freevpn_url in http://www.vpnbook.com/freevpn http://www.freevpn.me/accounts https://www.vpnkeys.com/get-free-vpn-instantly
do
	echo Processing "$freevpn_url"
	
	# grab the domain name from the url
	url_domain=$(echo "$freevpn_url" | sed 's/^[^:]\+:\/\/\([^\/]\+\).\+$/\1/')
	
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
	cat index.html | iconv -csf $(file -b --mime-encoding index.html) -t ascii | dos2unix | grep -EA 10 "OpenVPN[^,]" | grep -E "Username[ \t]*:" | sed 's/[ \t]\+//g' | sed 's/<[^>]\+>//g' | sed 's/^Username://' | unix2dos > username_password.txt
	cat index.html | iconv -csf $(file -b --mime-encoding index.html) -t ascii | dos2unix | grep -EA 10 "OpenVPN[^,]" | grep -E "Password[ \t]*:" | sed 's/[ \t]\+//g' | sed 's/<[^>]\+>//g' | sed 's/^Password://' | unix2dos >> username_password.txt
	
	# grab all zip file hrefs from the url and download them, only if the timestamp is newer than the file we may currently have
	for suffix in $(cat index.html | grep ".zip" | sed 's/[ \t]\+//g' | sed 's/.\+href="\([^"]\+\)".\+/\1/' | grep ".zip")
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
		username_password_contents=$(cat username_password.txt)
		if [ ! "$username_password_contents" == "" ]
		then
			echo auth-user-pass username_password.txt >> "$basename".NEW.ovpn
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
	popd > /dev/null
done
popd > /dev/null
