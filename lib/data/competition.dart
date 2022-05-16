import 'abstract.dart';
import '../services/results_list.dart';

class Competition extends AData {
  @override
  final int id;
  final String name;
  final String? competitor_list_pdf;
	final String? start_list_pdf;
	final DateTime updated_at;
	final ResultsList results;

	Competition({required this.id,
			required this.name,
			required this.competitor_list_pdf,
			required this.start_list_pdf,
			required this.updated_at,
			required this.results}
	) : super(db_id_field: 'id');

  @override
  Map<String, dynamic> toSqlMap() {
    return {
      'id': id,
      'name': name,
			'updated_at': updated_at,
			'start_list': start_list_pdf,
			'competitor_list': competitor_list_pdf
    };
  }

  @override
  String toString() {
    return "Competition('$id', '$name', '$updated_at')";
  }
}

