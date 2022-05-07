/// Utility functions/wrappers

import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config.dart' as config;

/// Open an URL in an external app if possible,
/// else show a toast to notify user about error
launch_url(String url) async {
	var _url = Uri.parse(url);
  if ((await canLaunchUrl(_url)) != false) {
    await launchUrl(_url);
    return;
  }
  Fluttertoast.showToast(
      msg: "Failed to open '$url'",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 2,
      fontSize: 16.0
  );
}

/// Change event date/hour according to configured
/// calendar offset, to show calendar as if user was
/// already in the correct timezone
DateTime fit_date_to_cal(DateTime date) {
  var current_offset = DateTime.now().timeZoneOffset;
  var app_calendar_offset = Duration(
      hours: config.calendar_utc_offset['hour']!,
      minutes: config.calendar_utc_offset['minute']!
  );
  if (app_calendar_offset == current_offset)
    return date;

  var offset = (current_offset - app_calendar_offset).abs();

  return (current_offset > app_calendar_offset) ?
      date.subtract(offset)
      : date.add(offset);
}

/// Unescape ICS fields
String? clean_ics_text_fields(String? text) {
  return text
      ?.replaceAll('\\,', ',')
      .replaceAll('\\;', ';')
      .replaceAll('\\\\', '\\')
      .replaceAll('\\N', '\\n');
}

String get_ics_tz_key(Map<String, dynamic> ics, String clean_key) {
  String value = '';
  ics.forEach((k, v) {
    if (k.startsWith(clean_key)) {
      value = v;
      return;
    }
  });
  return value.trim();
}


