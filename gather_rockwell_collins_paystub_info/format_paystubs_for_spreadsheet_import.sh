#!/usr/bin/env bash

rm ./*.csv
OUTPUT_BASENAME=rockwell_collins_paystub_output

count=0
> "$OUTPUT_BASENAME".csv
for each in $(echo stub*.html)
do
	extraCommand="cat"
	if [ ! "$count" == "0" ]
	then
		extraCommand="tail -n+2"
	fi
	
	sed -z 's/[\n\r]\+/ /g' "$each" \
		| sed 's/[ \t]\+/ /g' \
		| sed 's|</tr>[ \t]*|</tr>\n|g' \
		| sed 's|<script[^>]*>.\+</script>||g' \
		| sed 's|<!--.\+-->||g' \
		| sed 's|<div[^>]*>||g' \
		| sed 's|</div>||g' \
		| sed 's|<span[^>]*>||g' \
		| sed 's|</span>||g' \
		| sed 's|<font[^>]*>||g' \
		| sed 's|</font>||g' \
		| sed 's|<tbody[^>]*>||g' \
		| sed 's|</tbody>||g' \
		| sed 's|<h[0-9]*[^>]*>||g' \
		| sed 's|</h[0-9]*>||g' \
		| sed 's|<tr[^>]*>|<tr>|g' \
		| sed 's|<td[^>]*>|<td>|g' \
		| sed 's|<table[^>]*>|<table>|g' \
		| sed 's|&nbsp;| |g' \
		| sed 's|<img [^>]\+>||g' \
		| sed 's|</*b>||g' \
		| sed 's|</a>||g' \
		| sed 's|<a [^>]\+>||g' \
		| sed 's|^[^<>]*<table>|<table>|g' \
		| sed 's|<table>|\nTABLE_START\n|g' \
		| sed 's|</table>|\nTABLE_END\n|g' \
		| sed 's|<br>| |g' \
		| sed 's|</td>[ \t]*<td>|;|g' \
		| sed 's|<tr>[ \t]*</tr>||g' \
		| sed 's|</td>[ \t]*</tr>||g' \
		| sed 's|<tr>[ \t]*<td>||g' \
		| sed 's|;[ \t]\+|;|g' \
		| sed 's|[ \t]\+;|;|g' \
		| sed 's|^[ \t]\+||g' \
		| sed 's|^;\+$||' \
		| sed 's|,||g' \
		| sed -z 's|[\n][\n]\+|\n|g' \
		| sed -z 's|TABLE_START\nTABLE_END||g' \
		| sed -z 's|[\n][\n]\+|\n|g' \
		| sed -z 's|TABLE_START\nTABLE_START|TABLE_START|g' \
		| sed -z 's|[\n][\n]\+|\n|g' \
		| sed -z 's|TABLE_END\nTABLE_END|TABLE_END|g' \
		| sed -z 's|[\n][\n]\+|\n|g' > $(basename "$each" | sed 's|\..\+$||').csv
	
	if [ 0 == 1 ]
	then
	sed -z 's/[\n\r]\+/ /g' "$each" \
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
		| $extraCommand >> "$OUTPUT_BASENAME".csv
	fi
	count=$(($count +1))
done
cat "$OUTPUT_BASENAME".csv
