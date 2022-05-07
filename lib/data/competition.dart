import 'abstract.dart';

class Competition extends AData {
  @override
  final int id;
  final String name;
  final String slug;

  Competition({required this.id, required this.name, required this.slug}) : super(db_id_field: 'id');

  @override
  Map<String, dynamic> toSqlMap() {
    return {
      'id': id,
      'slug': slug,
      'name': name
    };
  }

  @override
  String toString() {
    return "Competition('$id', '$slug', '$name')";
  }
}
