#!/usr/bin/env bash

rm ./*.csv

count=0
> wellmark_output.csv
for each in $(echo part*.html)
do
	extraCommand="cat"
	if [ ! "$count" == "0" ]
	then
		extraCommand="tail -n+2"
	fi
	
	sed -z 's/\n/ /g' "$each" \
		| sed 's/[ \t]\+/ /g' \
		| sed 's|</tr>[ \t]*|</tr>\n|g' \
		| sed 's|<img [^>]\+>||g' \
		| sed 's|</a>||g' \
		| sed 's|<a [^>]\+>||g' \
		| sed 's|<input [^>]\+>||g' \
		| sed 's|<ul[^>]*>||g' \
		| sed 's|</ul>||g' \
		| sed 's|<li[^>]*>||g' \
		| sed 's|</li>||g' \
		| sed 's|<div[^>]*>||g' \
		| sed 's|</div>||g' \
		| sed 's|<span[^>]*>||g' \
		| sed 's|</span>||g' \
		| sed 's|<br>||g' \
		| sed 's|<[/]*tbody>||g' \
		| sed 's|&nbsp;| |g' \
		| sed 's|[ \t]*<tr>[ \t]*||g' \
		| sed 's|[ \t]*</tr>[ \t]*||g' \
		| sed 's|,||g' \
		| sed 's|</t[hd]>[ \t]*<t[hd][^>]*>|,|g' \
		| sed 's|<[/]*t[hd][^>]*>||g' \
		| sed 's|EOBView Download||g' \
		| sed 's|[ \t]*,[ \t]*|,|g' \
		| $extraCommand >> wellmark_output.csv
	count=$(($count +1))
done
cat wellmark_output.csv
