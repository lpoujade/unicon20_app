#!/bin/sh

_encode() {
	node -e "console.log(encodeURI(\"$1\".trim()))" || echo "failed to encode '$1'"
}

_search() {
	addr=$(_encode "$1")
	url="https://nominatim.lpo.host/search?q=$addr&limit=1"
	echo "$1 :"
	curl -s "$url" | json_pp | grep -E '"(lat|lon)"'

	echo "---------------"
}

#_encode "$1"
_search "$1"
