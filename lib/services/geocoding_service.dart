import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeocodingService {
  static Future<String> getAddress({
    required double latitude,
    required double longitude,
  }) async {
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Google Maps API key is missing.');
    }

    final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'latlng': '$latitude,$longitude',
      'key': apiKey,
    });

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Geocoding request failed.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final status = data['status'] as String?;

    if (status != 'OK') {
      throw Exception('Geocoding failed: $status');
    }

    final results = data['results'] as List<dynamic>;

    if (results.isEmpty) {
      throw Exception('No address found.');
    }

    return (results.first as Map<String, dynamic>)['formatted_address']
        as String;
  }
}
