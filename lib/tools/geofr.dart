import 'dart:convert';

import '../config.dart' as config;
import 'package:http/http.dart' as http;

class GeoFR {
  GeoFR();
  geocode(String address) async {
    var uri = Uri.parse(config.geoservice.replaceFirst('QUERY', address));
    var client = http.Client();
    var response = await client.read(uri, headers: {
      'User-Agent': 'unicon mobile app'
    }).timeout(const Duration(seconds: 60));
    var result = json.decode(response);
    if (result.isEmpty) throw ("didn't found '$address'");
    var res = result.first;
    return [double.parse(res['lat']), double.parse(res['lon'])];
  }
}
