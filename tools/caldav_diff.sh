#!/bin/sh

set -e

dir="$1"
calendars="$2"

test -d "$dir" || {
  echo "missing dir '$dir'";
  exit 2;
}

test -f "$calendars" || {
  echo "bad file/parameter: '$calendars'";
  exit 3;
}

while read line; do
  test "$line" || continue
  calendar_name="$line"
  read url
  test "$url" || {
    echo "missing url for calendar '$calendar_name'";
    exit 1;
  }
  { curl --no-progress-meter "$url" || {
      echo "failed to download calendar '$calendar_name' from '$url'" >&2 ;
      continue;
   }; }  | grep '^LAST-MODIFIED:' | cut -d':' -f2 | sort -nr | head -1 > "$dir/$calendar_name"
done < "$calendars"
