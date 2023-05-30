import 'dart:convert';

import 'package:http/http.dart' as http;

import '../open_meteo_api.dart';

class LocationRequestFailure implements Exception {}

class LocationNotFoundFailure implements Exception {}

class WeatherRequestFailure implements Exception {}

class WeatherNotFoundFailure implements Exception {}

class OpenMeteoApiClient {
  final http.Client _httpClient;

  OpenMeteoApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  // Base URL
  static const _baseUrlWeather = 'api.open-meteo.com';

  // Base URL
  static const _baseUrlGeocoding = 'geocoding-api.open-meteo.com';

  // Location Search async Func
  Future<Location> locationSearch(String query) async {
    // Fetching with URL and query
    final locationRequest =
        Uri.https(_baseUrlGeocoding, '/v1/search', {'name': query, 'count': 1});

    // http get method
    final locationReponse = await _httpClient.get(locationRequest);

    // Exception for failed req
    if (locationReponse.statusCode != 200) {
      throw LocationRequestFailure();
    }

    // Decoding Json
    final locationJson = jsonDecode(locationReponse.body) as Map;

    // Exception for failed req
    if (!locationJson.containsKey('results')) throw LocationNotFoundFailure();

    // Grabbing the results as list
    final results = locationJson['results'] as List;

    // Exception if the list is empty
    if (results.isEmpty) throw LocationNotFoundFailure();

    // Returing the Map of Location
    return Location.fromJson(results.first as Map<String, dynamic>);
  }

  // Searches weather for the given lattitude and logitude
  Future<Weather> getWeather(
      {required double latitude, required double longitude}) async {
    final weatherRequest = Uri.https(_baseUrlWeather, '/v1/forecast',
        {'latitude': latitude, 'longitude': longitude});

    final weatherResponse = await _httpClient.get(weatherRequest);

    if (weatherResponse.statusCode != 200) {
      throw WeatherRequestFailure();
    }

    final weatherDetails = jsonDecode(weatherResponse.body) as Map;

    if (!weatherDetails.containsKey('current_weather')) {
      throw WeatherNotFoundFailure();
    }

    final weatherJson =
        weatherDetails['curren_weather'] as Map<String, dynamic>;

    return Weather.fromJson(weatherJson);
  }
}
