/// Event definition

import '../tools/utils.dart';
import 'abstract.dart';

/// Event data
class Event extends AData {
  final String uid;
  final String title;
  DateTime start;
  DateTime end;
  final String? location;
	List<double>? coords;
  final String type;
  final String? description;
  final String? summary;
  final DateTime modification_date;

  Event({
    required this.uid,
    required this.title,
    required this.start,
    required this.end,
    required this.location,
    required this.type,
    required this.description,
    required this.summary,
    required this.modification_date
  }) : super(db_id_field:'uid');

  Event.from(Event e)
      : uid = e.uid,
      title = e.title,
      start = e.start,
      end = e.end,
      location = e.location,
      type = e.type,
      description = e.description,
      summary = e.summary,
      modification_date = e.modification_date,
      super(db_id_field: 'uid');

  Event.fromICalJson(Map<String, dynamic> json, String calendar, DateTime sync_date)
      : uid = json['UID'].toString(),
      title = clean_ics_text_fields(json['SUMMARY']) ?? '<< missing event title >>',
      start = DateTime.parse(json['DTSTART'] ?? get_ics_tz_key(json, 'DTSTART')).toLocal(),
      end = DateTime.parse(json['DTEND'] ?? get_ics_tz_key(json, 'DTEND')).toLocal(),
      location = clean_ics_text_fields(json['LOCATION'])?.trim(),
      type = calendar,
      description = clean_ics_text_fields(json['DESCRIPTION']),
      summary = clean_ics_text_fields(json['SUMMARY']),
      // modification_date = json.containsKey('LAST-MODIFIED') ? DateTime.parse(clean_ics_text_fields(json['LAST-MODIFIED'])!) : DateTime.now(),
			modification_date = sync_date,
      super(db_id_field: 'uid');

  @override
  get id { return uid; }

  @override
  Map<String, dynamic> toSqlMap() {
    return {
      'uid': uid,
      'title': title,
      'start': start.millisecondsSinceEpoch,
      'end': end.millisecondsSinceEpoch,
      'location': location ?? '',
      'type': type,
      'description': description ?? '',
      'summary': summary ?? '',
      'modification_date': modification_date.millisecondsSinceEpoch
    };
  }

  @override
  String toString() {
    return "$title $start $end (start is utc: ${start.isUtc})";
  }
}
