import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'config.dart' as config;

/// Open an URL in an external app if possible,
/// else show a toast to notify user about error
launch_url(String url) async {
  if (canLaunch(url) != false) {
    await launch(url);
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
String clean_ics_text_fields(String text) {
  String result = text
      .replaceAll('\\,', ',')
      .replaceAll('\\;', ';')
      .replaceAll('\\\\', '\\')
      .replaceAll('\\N', '\\n');
  return result;
}

class ResultWrapper<T> {
  ResultWrapper.success(this.data) : failure = null;
  ResultWrapper.failure(this.failure) : data = null;

  T? data;
  Failure? failure;

  ResultWrapper()
      :data = null, failure = null;

  bool get dataExists  => data != null;
  bool get failed => failure == null;
}

class Failure {
  final String message;
  Failure({required this.message});
}
