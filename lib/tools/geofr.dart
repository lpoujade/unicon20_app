import 'dart:convert';

import '../config.dart' as config;
import 'package:http/http.dart' as http;

class GeoFR {
	GeoFR();
	geocode(String address) async {
		var uri = Uri.parse(config.geoservice.replaceFirst('QUERY', address));
		var client = http.Client();
    var response = await client.read(uri).timeout(const Duration(seconds: 60));
		var result = json.decode(response);
		var coords = result['features'][0]['geometry']['coordinates'];
		List<double> latlng = [coords[1], coords[0]];
		return latlng;
	}
}
