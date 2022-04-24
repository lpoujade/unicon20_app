#!/bin/sh

_encode() {
	node -e "console.log(encodeURI(\"$1\".trim()))" || echo "failed to encode '$1'"
}

_search() {
	addr=$(_encode "$1")
	url="https://nominatim.lpo.host/search?q=$addr&limit=1"
	#url="https://api-adresse.data.gouv.fr/search?q=$addr&limit=1&autocomplete=0"
	echo "$1 :"
	echo "$url"
	curl -s "$url" | json_pp
}

_search "$(echo "$1" | tr -d '\r')"
