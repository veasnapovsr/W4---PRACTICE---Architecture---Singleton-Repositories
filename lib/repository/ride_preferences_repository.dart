import '../model/ride/locations.dart';
import '../model/ride_pref/ride_pref.dart';

abstract class RidePreferencesRepository {

  List<RidePreference> getPastPreferences();

  void addPreference(RidePreference preference);
}


class RidePreference {
  final Location departure;
  final DateTime departureDate;
  final Location arrival;
  final int requestedSeats;

  const RidePreference(
      {required this.departure,
        required this.departureDate,
        required this.arrival,
        required this.requestedSeats});

  @override
  String toString() {
    return 'RidePref(departure: ${departure.name}, '
        'departureDate: ${departureDate.toIso8601String()}, '
        'arrival: ${arrival.name}, '
        'requestedSeats: $requestedSeats)';
  }
}
