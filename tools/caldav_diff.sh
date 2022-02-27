#!/bin/sh

# generate files with last modification date from ICS calendars URL
# usage: ./caldav_diff.sh target_dir/ calendar_urls
# with calendar_urls a path to a file with a calendar name and an url on each line like:
# unicon_admin https://calendar.google.com/calendar/ical/j39mlonvmepkdc4797nk88f7ok%40group.calendar.google.com/public/basic.ics

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

while read calendar_name; do
  test "$calendar_name" || continue
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
