import 'abstract.dart';

class Result extends AData {
	@override
	final int id;
	final String name;
	final String pdf;
	final DateTime published_at;

	Result({required this.id,
			required this.name,
			required this.pdf,
			required this.published_at}
	): super(db_id_field: 'id');

  @override
  Map<String, dynamic> toSqlMap() {
    return {
      'id': id,
      'name': name,
      'pdf': pdf,
			'published_at': published_at.millisecondsSinceEpoch
    };
  }
}
