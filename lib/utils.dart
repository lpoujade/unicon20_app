
String clean_ics_text_fields(String text) {
  String result = text
      .replaceAll('\\,', ',')
      .replaceAll('\\;', ';')
      .replaceAll('\\\\', '\\')
      .replaceAll('\\N', '\\n');
  return result;
}
