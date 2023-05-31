import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_app_bloc/weather/models/weather.dart';
import 'package:weather_repository/weather_repository.dart'
    show WeatherRepository;

part 'weather_state.dart';
part 'weather_cubit.g.dart';

class WeatherCubit extends HydratedCubit<WeatherState> {
  final WeatherRepository _weatherRepository;

  WeatherCubit(this._weatherRepository) : super(WeatherState());

  Future<void> fetchWeather(String? city) async {
    if (city == null || city.isEmpty) return;

    emit(state.copyWith(status: WeatherStatus.loading));

    try {
      final weather = Weather.fromRepository(
        await _weatherRepository.getWeather(city),
      );

      final units = state.temperatureUnits;
      final value = units.isFarenheit
          ? weather.temperature.value.toFarenheit()
          : weather.temperature.value;

      emit(state.copyWith(
          status: WeatherStatus.success,
          tempertaureUnits: units,
          weather: weather.copyWith(temperature: Temperature(value: value))));
    } on Exception {
      emit(state.copyWith(status: WeatherStatus.failure));
    }
  }

  Future<void> refreshWeather() async {
    if (!state.status.isSuccess) return;
    if (state.weather == Weather.empty) return;

    try {
      final weather = Weather.fromRepository(
          await _weatherRepository.getWeather(state.weather.location));

      final units = state.temperatureUnits;
      final value = units.isFarenheit
          ? weather.temperature.value.toFarenheit()
          : weather.temperature.value;

      emit(state.copyWith(
          status: WeatherStatus.success,
          tempertaureUnits: units,
          weather: weather.copyWith(temperature: Temperature(value: value))));

      void toggleUnits() {
        final units = state.temperatureUnits.isFarenheit
            ? TempertaureUnits.celcius
            : TempertaureUnits.farenheit;

        if (!state.status.isSuccess) {
          emit(state.copyWith(tempertaureUnits: units));
          return;
        }

        final weather = state.weather;
        if (weather != Weather.empty) {
          final temperature = weather.temperature;
          final value = units.isCelcius
              ? temperature.value.toCelsius()
              : temperature.value.toFarenheit();

          emit(state.copyWith(
              tempertaureUnits: units,
              weather:
                  weather.copyWith(temperature: Temperature(value: value))));
        }
      }
    } on Exception {
      emit(state);
    }
  }

  @override
  WeatherState? fromJson(Map<String, dynamic> json) =>
      WeatherState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(WeatherState state) => state.toJson();
}

extension on double {
  double toFarenheit() => (this * 9 / 5) + 32;
  double toCelsius() => (this - 32) * 5 / 9;
}
