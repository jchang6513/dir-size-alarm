#!/bin/bash
source .dsa.conf
# df $1 | awk '{ print $4 }' | tail -n 1 | numfmt --from=iec-i

lineNoty() {
	curl --location --request POST 'https://notify-api.line.me/api/notify' \
		--header "Authorization: Bearer $LINE_TOKEN" \
		--form "message=\"Warning!!! The available size of $1 is under ${2}\""

	curl --location --request POST 'https://notify-api.line.me/api/notify' \
		--header "Authorization: Bearer $LINE_TOKEN" \
		--form "message=\"$(df -h $1)\""

	}

while read line; do
	dirPath=$(echo $line| awk -F ' ' '{print $1}')
	threshold=$(echo $line | awk -F ' ' '{print $2}')

	avail=$(df -h $dirPath | awk '{ print $4 }' | tail -n 1)

	echo $dirPath, $avail, $threshold, $(numfmt --from=$NUMFMT_FROM $threshold)

	if (( $(numfmt --from=$NUMFMT_FROM $avail)  > $(numfmt --from=$NUMFMT_FROM $threshold) )); then
		echo OK; 
	else 
		lineNoty $dirPath $threshold
		echo NOT OK !!!; 
	fi
done < dirs.txt

