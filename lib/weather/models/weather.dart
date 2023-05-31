import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_repository/weather_repository.dart' hide Weather;

import 'package:weather_repository/weather_repository.dart'
    as weather_repository;

part 'weather.g.dart';

enum TempertaureUnits { farenheit, celcius }

extension TemperatureUnitsX on TempertaureUnits {
  bool get isFarenheit => this == TempertaureUnits.farenheit;

  bool get isCelcius => this == TempertaureUnits.celcius;
}

@JsonSerializable()
class Temperature extends Equatable {
  final double value;

  Temperature({required this.value});

  factory Temperature.fromJson(Map<String, dynamic> json) =>
      _$TemperatureFromJson(json);

  Map<String, dynamic> toJson() => _$TemperatureToJson(this);

  @override
  List<Object?> get props => [value];
}

@JsonSerializable()
class Weather extends Equatable {
  final WeatherCondition condition;
  final DateTime lastUpdated;
  final String location;
  final Temperature temperature;

  Weather(
      {required this.condition,
      required this.lastUpdated,
      required this.location,
      required this.temperature});

  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);

  factory Weather.fromRepository(weather_repository.Weather weather) {
    return Weather(
        condition: weather.condition,
        lastUpdated: DateTime.now(),
        location: weather.location,
        temperature: Temperature(value: weather.temperature));
  }

  // For an empty Weather
  static final empty = Weather(
      condition: WeatherCondition.unknown,
      lastUpdated: DateTime(0),
      location: '--',
      temperature: Temperature(value: 0));

  @override
  List<Object?> get props => [condition, lastUpdated, location, temperature];

  Map<String, dynamic> toJson() => _$WeatherToJson(this);

  Weather copyWith({
    WeatherCondition? condition,
    DateTime? lastUpdated,
    String? location,
    Temperature? temperature,
  }) {
    return Weather(
        condition: condition ?? this.condition,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        location: location ?? this.location,
        temperature: temperature ?? this.temperature);
  }
}
