/// Abstract data
abstract class AData {
  AData({required this.db_id_field});
  Map<String, dynamic> toSqlMap();
  final String db_id_field;

  get id;
}
