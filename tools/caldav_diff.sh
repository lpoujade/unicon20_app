#!/bin/sh

# periodically download calendar ICS files, compare its hash with
# previous version and generate a file with last modification date

# caldav_diff.sh
# calendars.md5sum
# calendars/ [calendars list with last modification date]

dir="$1"
calendars="$2"
gen_md5="$3"

test -d "$dir" || {
  echo "missing dir '$dir'";
  exit 2;
}

test -f "$calendars" || {
  echo "bad file/parameter: '$calendars'";
  exit 3;
}

mkdir -p $dir/ics
mkdir -p $dir/md5sums

while read calendar_name; do
  test "$calendar_name" || continue
  read url
  test "$url" || {
    echo "missing url for calendar '$calendar_name'" >&2;
    continue;
  }
	curl --no-progress-meter  "$url" | grep -v DTSTAMP > $dir/ics/$calendar_name.ics || {
		echo "failed to download calendar '$calendar_name' from '$url'" >&2;
		continue;
	}
	md5sum --status -c $dir/md5sums/$calendar_name || {
		date +%s > $dir/$calendar_name
		md5sum $dir/ics/$calendar_name.ics > $dir/md5sums/$calendar_name;
	}
done < "$calendars"
