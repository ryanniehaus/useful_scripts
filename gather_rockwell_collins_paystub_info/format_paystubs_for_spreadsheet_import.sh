#!/usr/bin/env bash

rm ./*.csv
OUTPUT_BASENAME=rockwell_collins_paystub_output

function getFieldNoInTableHeader()
{
  tableFile="$1"
  fieldToFind="$2"
  
  fieldInHeader=$(head -n 1 "$tableFile" | grep "$fieldToFind")
  if [ "$fieldInHeader" == "" ]
  then
    echo "-1"
  else
    head -n 1 "$tableFile" | sed 's|^\(.*;*\)'"$fieldToFind"';*.*$|\1|;s|[^;]\+||g' | wc -c
  fi
}

> pretax_names_unsorted.txt
> posttax_names_unsorted.txt
> taxes_names_unsorted.txt
> company_contributions_names_unsorted.txt
> earnings_names_unsorted.txt
for each in $(echo stub*.html)
#for each in $(echo stub0.html)
do
	stubCSVFile=$(basename "$each" | sed 's|\..\+$||').csv
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
		| sed -z 's|[\n][\n]\+|\n|g' \
		| sed -z 's|[ \t]\+[$]|$|g' \
		| sed -z 's|[$][ \t]\+|$|g' \
		| sed -z 's|(\([$][^)]\+\))|-\1|g' > "$stubCSVFile"
		
	cat "$stubCSVFile" | grep -EA 100 "^Pretax Deferrals" | grep -m 1 -B 100 "TABLE_END" | head -n-1 > temp_pretax_table.csv
	cat "$stubCSVFile" | grep -EA 100 "^Post Tax Deductions" | grep -m 1 -B 100 "TABLE_END" | head -n-1 > temp_posttax_table.csv
	cat "$stubCSVFile" | grep -EA 100 "^Taxes" | grep -m 1 -B 100 "TABLE_END" | head -n-1 > temp_taxes_table.csv
	cat "$stubCSVFile" | grep -EA 100 "^Company Contributions" | grep -m 1 -B 100 "TABLE_END" | head -n-1 > temp_company_contributions_table.csv
	cat "$stubCSVFile" | grep -EA 100 "^Earnings" | grep -m 1 -B 100 "TABLE_END" | head -n-1 > temp_earnings_table.csv
	cat "$stubCSVFile" | grep -EA 100 "^Company Code" | grep -m 1 -B 100 "TABLE_END" | head -n-1 > temp_paystub_header_table.csv
	
	cat temp_pretax_table.csv | tail -n+2 | cut -f 1 -d ";" >> pretax_names_unsorted.txt
	cat temp_posttax_table.csv | tail -n+2 | cut -f 1 -d ";" >> posttax_names_unsorted.txt
	cat temp_taxes_table.csv | tail -n+2 | cut -f 1 -d ";" >> taxes_names_unsorted.txt
	cat temp_company_contributions_table.csv | tail -n+2 | cut -f 1 -d ";" >> company_contributions_names_unsorted.txt
	cat temp_earnings_table.csv | tail -n+2 | cut -f 1 -d ";" >> earnings_names_unsorted.txt
done

sort -du earnings_names_unsorted.txt -o earnings_names_sorted.txt; rm earnings_names_unsorted.txt
sort -du company_contributions_names_unsorted.txt -o company_contributions_names_sorted.txt; rm company_contributions_names_unsorted.txt
sort -du pretax_names_unsorted.txt -o pretax_names_sorted.txt; rm pretax_names_unsorted.txt
sort -du taxes_names_unsorted.txt -o taxes_names_sorted.txt; rm taxes_names_unsorted.txt
sort -du posttax_names_unsorted.txt -o posttax_names_sorted.txt; rm posttax_names_unsorted.txt

> "$OUTPUT_BASENAME".csv
echo -n "Pay Date;" >> "$OUTPUT_BASENAME".csv
for listPrefix in earnings company_contributions pretax taxes posttax
do
	while IFS= read -r tempLine
	do
	  echo -n "$listPrefix""_""$tempLine"";" >> "$OUTPUT_BASENAME".csv
	done < "$listPrefix"_names_sorted.txt
done
echo "" >> "$OUTPUT_BASENAME".csv
for stubCSVFile in $(echo stub*.csv)
#for stubCSVFile in $(echo stub0.csv)
do
	cat "$stubCSVFile" | grep -EA 100 "^Pretax Deferrals" | grep -m 1 -B 100 "TABLE_END" | head -n-1 > temp_pretax_table.csv
	cat "$stubCSVFile" | grep -EA 100 "^Post Tax Deductions" | grep -m 1 -B 100 "TABLE_END" | head -n-1 > temp_posttax_table.csv
	cat "$stubCSVFile" | grep -EA 100 "^Taxes" | grep -m 1 -B 100 "TABLE_END" | head -n-1 > temp_taxes_table.csv
	cat "$stubCSVFile" | grep -EA 100 "^Company Contributions" | grep -m 1 -B 100 "TABLE_END" | head -n-1 > temp_company_contributions_table.csv
	cat "$stubCSVFile" | grep -EA 100 "^Earnings" | grep -m 1 -B 100 "TABLE_END" | head -n-1 > temp_earnings_table.csv
	cat "$stubCSVFile" | grep -EA 100 "^Company Code" | grep -m 1 -B 100 "TABLE_END" | head -n-1 > temp_paystub_header_table.csv
	
	PayDateFieldNo=$(getFieldNoInTableHeader temp_paystub_header_table.csv "Pay Date")
	PayDate=$(cat temp_paystub_header_table.csv | tail -n+2 | cut -f $PayDateFieldNo -d ";")
	
	listPrefix=earnings
	fieldToReturn=Gross
	while IFS= read -r tempLine
	do
	  tempFieldNo=$(getFieldNoInTableHeader temp_"$listPrefix"_table.csv "$fieldToReturn")
	  declare "$listPrefix"_$(echo "$tempLine" | sed 's|[ \t%$./\-]|_|g')=$(cat temp_"$listPrefix"_table.csv | tail -n+2 | grep -E "^""$tempLine"";" | cut -f $tempFieldNo -d ";")
	done < "$listPrefix"_names_sorted.txt
	
	listPrefix=company_contributions
	fieldToReturn=Current
	while IFS= read -r tempLine
	do
	  tempFieldNo=$(getFieldNoInTableHeader temp_"$listPrefix"_table.csv "$fieldToReturn")
	  declare "$listPrefix"_$(echo "$tempLine" | sed 's|[ \t%$./\-]|_|g')=$(cat temp_"$listPrefix"_table.csv | tail -n+2 | grep -E "^""$tempLine"";" | cut -f $tempFieldNo -d ";")
	done < "$listPrefix"_names_sorted.txt
	
	listPrefix=pretax
	fieldToReturn=Gross
	while IFS= read -r tempLine
	do
	  tempFieldNo=$(getFieldNoInTableHeader temp_"$listPrefix"_table.csv "$fieldToReturn")
	  declare "$listPrefix"_$(echo "$tempLine" | sed 's|[ \t%$./\-]|_|g')=$(cat temp_"$listPrefix"_table.csv | tail -n+2 | grep -E "^""$tempLine"";" | cut -f $tempFieldNo -d ";")
	done < "$listPrefix"_names_sorted.txt
	
	listPrefix=taxes
	fieldToReturn=Current
	while IFS= read -r tempLine
	do
	  tempFieldNo=$(getFieldNoInTableHeader temp_"$listPrefix"_table.csv "$fieldToReturn")
	  declare "$listPrefix"_$(echo "$tempLine" | sed 's|[ \t%$./\-]|_|g')=$(cat temp_"$listPrefix"_table.csv | tail -n+2 | grep -E "^""$tempLine"";" | cut -f $tempFieldNo -d ";")
	done < "$listPrefix"_names_sorted.txt
	
	listPrefix=posttax
	fieldToReturn=Current
	while IFS= read -r tempLine
	do
	  tempFieldNo=$(getFieldNoInTableHeader temp_"$listPrefix"_table.csv "$fieldToReturn")
	  declare "$listPrefix"_$(echo "$tempLine" | sed 's|[ \t%$./\-]|_|g')=$(cat temp_"$listPrefix"_table.csv | tail -n+2 | grep -E "^""$tempLine"";" | cut -f $tempFieldNo -d ";")
	done < "$listPrefix"_names_sorted.txt
	
	echo -n "$PayDate;" >> "$OUTPUT_BASENAME".csv
	numProcessed=0
	numEmpty=0
	for listPrefix in earnings company_contributions pretax taxes posttax
	do
		while IFS= read -r tempLine
		do
		  tempVarName="$listPrefix""_"$(echo "$tempLine" | sed 's|[ \t%$./\-]|_|g')
		  tempValue="${!tempVarName}"
			echo -n "$tempValue;" >> "$OUTPUT_BASENAME".csv
			numProcessed=$(($numProcessed + 1))
			
			if [ "$tempValue" == "" ]
			then
				numEmpty=$(($numEmpty + 1))
			fi
		done < "$listPrefix"_names_sorted.txt
	done
	echo "" >> "$OUTPUT_BASENAME".csv
	
	#test for empty line
	if [ "$numProcessed" == "$numEmpty" ]
	then
	  echo ERROR DETECTED WITH "$stubCSVFile" numProcessed=$numProcessed numEmpty=$numEmpty
	fi
done
cat "$OUTPUT_BASENAME".csv
