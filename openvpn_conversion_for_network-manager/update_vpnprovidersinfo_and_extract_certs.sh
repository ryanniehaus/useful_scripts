#!/bin/bash

for freevpn_url in http://www.vpnbook.com/freevpn
do
	echo Processing "$freevpn_url"
	
	url_domain=$(echo "$freevpn_url" | sed 's/^[^:]\+:\/\/\([^\/]\+\).\+$/\1/')
	
	echo Domain "$url_domain"
	
	mkdir "$url_domain"
	pushd "$url_domain"
	
	wget -O index.html "$freevpn_url"
	cat index.html | grep "Username:" | sed 's/[ \t]\+//g' | sed 's/<[^>]\+>//g' | sort -du | dos2unix | sed 's/^Username://' | unix2dos > username_password.txt
	cat index.html | grep "Password:" | sed 's/[ \t]\+//g' | sed 's/<[^>]\+>//g' | sort -du | dos2unix | sed 's/^Password://' | unix2dos >> username_password.txt
	for suffix in $(cat index.html | grep ".zip" | sed 's/[ \t]\+//g' | sed 's/.\+href="\([^"]\+\)".\+/\1/' | grep ".zip")
	do
	  suffix_is_relative=$(echo "$suffix" | sed 's/^\(.\).\+$/\1/')
	  if [ "$suffix_is_relative" == "/" ]
	  then
			wget -N "$url_domain""$suffix"
		else
			wget -N "$suffix"
		fi
	done

	for zipfile in $(echo *.zip)
	do
		unzip -ou "$zipfile" -d .
	done

	for ovpn_file in $(find . -type f -name "*.ovpn" | grep -vE "\.NEW\.ovpn" | sed 's/^\.\///')
	do
		basename=$(echo "$ovpn_file" | sed 's/^\(.\+\)\.ovpn$/\1/')
		> "$basename".NEW.ovpn
		for tagname in ca cert key dh extra-certs pkcs12 secret tls-auth
		do
			check_inline_tag_exists=$(cat "$ovpn_file" | grep -A 100 "<""$tagname"">" | grep -B 100 "</""$tagname"">" | grep -vE "</*""$tagname"">")
			if [ ! "$check_inline_tag_exists" == "" ]
			then
				cat "$ovpn_file" | grep -A 100 "<""$tagname"">" | grep -B 100 "</""$tagname"">" | grep -vE "</*""$tagname"">" > "$ovpn_file"."$tagname".pem
				echo "$tagname" "$ovpn_file"."$tagname".pem >> "$basename".NEW.ovpn
			fi
		done
		username_password_contents=$(cat username_password.txt)
		if [ ! "$username_password_contents" == "" ]
		then
			echo auth-user-pass username_password.txt >> "$basename".NEW.ovpn
		fi
		cat "$ovpn_file" \
			| dos2unix \
			| grep -vE "^auth-user-pass[ \t]*$" \
			| grep -vE "^ca[ \t]*.*$" \
			| grep -vE "^cert[ \t]*.*$" \
			| grep -vE "^key[ \t]*.*$" \
			| grep -vE "^dh[ \t]*.*$" \
			| grep -vE "^extra-certs[ \t]*.*$" \
			| grep -vE "^pkcs12[ \t]*.*$" \
			| grep -vE "^secret[ \t]*.*$" \
			| grep -vE "^tls-auth[ \t]*.*$" \
			| unix2dos >> "$basename".NEW.ovpn
		mv "$basename".NEW.ovpn "$ovpn_file"
	done
	popd
done
