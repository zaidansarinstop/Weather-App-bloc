part of 'weather_cubit.dart';

enum WeatherStatus { initial, loading, success, failure }

extension WeatherStatusX on WeatherStatus {
  get isInitial => this == WeatherStatus.initial;
  get isLoading => this == WeatherStatus.initial;
  get isSuccess => this == WeatherStatus.initial;
  get isFailure => this == WeatherStatus.initial;
}

@JsonSerializable()
final class WeatherState extends Equatable {
  final WeatherStatus status;
  final Weather weather;
  final TempertaureUnits temperatureUnits;

  WeatherState({
    this.status = WeatherStatus.initial,
    this.temperatureUnits = TempertaureUnits.celcius,
    Weather? weather,
  }) : weather = weather ?? Weather.empty;

  factory WeatherState.fromJson(Map<String, dynamic> json) =>
      _$WeatherStateFromJson(json);

  WeatherState copyWith({
    WeatherStatus? status,
    TempertaureUnits? tempertaureUnits,
    Weather? weather,
  }) {
    return WeatherState(
        status: status ?? this.status,
        temperatureUnits: temperatureUnits,
        weather: weather ?? this.weather);
  }

  Map<String, dynamic> toJson() => _$WeatherStateToJson(this);

  @override
  List<Object> get props => [status, temperatureUnits, weather];
}
