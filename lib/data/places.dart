/// Places (events location) definition

import 'abstract.dart';

class Places extends AData {
	@override
	final int id;
	final String address;
	final int lat;
	final int lon;

	Places({required this.id,
			required this.address,
			required this.lat,
			required this.lon})
	: super(db_id_field:'id');

	@override
	Map<String, dynamic> toSqlMap() {
		return {
			'id': id,
			'address': address,
			'lat': lat,
			'lon': lon
			};
	}
}
