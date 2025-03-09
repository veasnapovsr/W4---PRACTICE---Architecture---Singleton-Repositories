import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/ride_pref/ride_pref.dart';
import '../../model/ride/locations.dart';
import '../../utils/animations_util.dart';
import '../../widgets/inputs/bla_location_picker.dart';
import '../../theme/theme.dart';
import '../../widgets/actions/bla_button.dart';
import '../../widgets/display/bla_divider.dart';
import 'dart:math';

class AvailableDriversScreen extends StatefulWidget {
  final RidePref ridePref;

  const AvailableDriversScreen({super.key, required this.ridePref});

  @override
  State<AvailableDriversScreen> createState() => _AvailableDriversScreenState();
}

class _AvailableDriversScreenState extends State<AvailableDriversScreen> {
  List<Map<String, dynamic>> _filteredRides = [];
  String _currentSort = "earliest";
  bool _isPerAccepted = false;
  RangeValues _priceRange = const RangeValues(0, 100);
  RangeValues _timeRange = const RangeValues(0, 24);
  bool _showDirectOnly = false;
  bool _showVerifiedOnly = false;
  bool _isEditingSearch = false;
  late RidePref _ridePref;
  final ValueNotifier<Location?> _departureNotifier =
      ValueNotifier<Location?>(null);
  final ValueNotifier<Location?> _arrivalNotifier =
      ValueNotifier<Location?>(null);
  final ValueNotifier<DateTime> _dateNotifier =
      ValueNotifier<DateTime>(DateTime.now());
  final ValueNotifier<int?> _seatsNotifier = ValueNotifier<int?>(null);
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _arrivalController = TextEditingController();
  List<String> _suggestions = [];
  bool _showDepartureSuggestions = false;
  bool _showArrivalSuggestions = false;
  List<String> items = ['1', '2', '3', '4', '5'];

  @override
  void initState() {
    super.initState();
    _ridePref = widget.ridePref;
    _departureNotifier.value = _ridePref.departure;
    _arrivalNotifier.value = _ridePref.arrival;
    _dateNotifier.value = _ridePref.departureDate;
    _seatsNotifier.value = _ridePref.requestedSeats;
    _departureController.text = _ridePref.departure.name;
    _arrivalController.text = _ridePref.arrival.name;
    _generateMockRides();
  }

  void _generateMockRides() {
    // Mocked fare calculation
    double baseFare = 50.0; // Example base fare

    // Generate more rides for better randomization
    _filteredRides = List.generate(15, (index) {
      // Randomize departure time between 5:00 and 22:00
      int randomHour = 5 + (index % 17); // Spread between 5 and 22
      int randomMinute = (index * 7) % 60; // Random minutes
      String departureTime =
          "${randomHour.toString().padLeft(2, '0')}:${randomMinute.toString().padLeft(2, '0')}";

      // Arrival time 2-4 hours after departure
      int arrivalHour = (randomHour + 2 + (index % 3)) % 24;
      String arrivalTime =
          "${arrivalHour.toString().padLeft(2, '0')}:${(randomMinute + 15) % 60}";

      // Random duration between 2-4 hours
      String duration = "${2 + (index % 3)}h${(index * 20) % 60}";

      // Randomize other properties
      bool isCarpool = index % 2 == 0; // 50% chance of carpool
      String driverName = "Driver ${index + 1}";
      double rating = 3.5 +
          (Random().nextDouble() * 1.5); // Random rating between 3.5 and 5.0
      double driverFare = baseFare *
          (0.8 +
              (Random().nextDouble() * 0.4)); // Random fare ±20% of base fare
      bool isVerified = Random().nextBool(); // 50% chance of verified
      bool isDirect = Random().nextBool(); // 50% chance of direct

      return {
        'departureTime': departureTime,
        'arrivalTime': arrivalTime,
        'duration': duration,
        'departureLocation': _ridePref.departure.name,
        'departureStation': isCarpool ? "" : "Main Station",
        'arrivalLocation': _ridePref.arrival.name,
        'arrivalStation': isCarpool ? "" : "Bus Stop",
        'price': driverFare,
        'isCarpool': isCarpool,
        'driverName': isCarpool ? driverName : null,
        'driverRating': isCarpool ? rating : null,
        'hasLimitedSeats':
            Random().nextInt(5) == 0, // 20% chance of limited seats
        'seatsAvailable':
            Random().nextInt(5) == 0 ? _ridePref.requestedSeats : null,
        'isVerified': isVerified,
        'isDirect': isDirect,
      };
    });

    // Shuffle the rides for random initial order
    _filteredRides.shuffle();

    // If any filters are active, apply them
    if (_showDirectOnly ||
        _showVerifiedOnly ||
        _priceRange != const RangeValues(0, 100) ||
        _timeRange != const RangeValues(0, 24)) {
      _applyFilters();
    }
  }

  void _showSearchDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) => Container(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          )),
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Handle bar
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        // Departure Location
                        ValueListenableBuilder<Location?>(
                          valueListenable: _departureNotifier,
                          builder: (context, departure, _) {
                            return InkWell(
                              onTap: () async {
                                Location? selectedLocation =
                                    await Navigator.of(context).push<Location>(
                                  AnimationUtils.createBottomToTopRoute(
                                    BlaLocationPicker(initLocation: departure),
                                  ),
                                );
                                if (selectedLocation != null) {
                                  _departureNotifier.value = selectedLocation;
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.location_on,
                                        color: Colors.grey[600]),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        departure?.name ?? 'Select departure',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.swap_vert),
                                      onPressed: () {
                                        final temp = _departureNotifier.value;
                                        _departureNotifier.value =
                                            _arrivalNotifier.value;
                                        _arrivalNotifier.value = temp;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        // Arrival Location
                        ValueListenableBuilder<Location?>(
                          valueListenable: _arrivalNotifier,
                          builder: (context, arrival, _) {
                            return InkWell(
                              onTap: () async {
                                Location? selectedLocation =
                                    await Navigator.of(context).push<Location>(
                                  AnimationUtils.createBottomToTopRoute(
                                    BlaLocationPicker(initLocation: arrival),
                                  ),
                                );
                                if (selectedLocation != null) {
                                  _arrivalNotifier.value = selectedLocation;
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.location_on,
                                        color: Colors.grey[600]),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        arrival?.name ?? 'Select arrival',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const BlaDivider(),

                        // Date Picker
                        ValueListenableBuilder<DateTime>(
                          valueListenable: _dateNotifier,
                          builder: (context, date, _) {
                            return InkWell(
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: date,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 365)),
                                );
                                if (picked != null) {
                                  _dateNotifier.value = picked;
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        color: Colors.grey[600]),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat('EEE, MMM d').format(date),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        const BlaDivider(),

                        // Seats Selector
                        ValueListenableBuilder<int?>(
                          valueListenable: _seatsNotifier,
                          builder: (context, seats, _) {
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: seats?.toString(),
                                hint: const Text('Select seats'),
                                items: items.map((String item) {
                                  return DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(item),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    _seatsNotifier.value = int.parse(value);
                                  }
                                },
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        // Apply Button
                        BlaButton(
                          text: 'Apply',
                          onPressed: () {
                            if (_departureNotifier.value != null &&
                                _arrivalNotifier.value != null &&
                                _seatsNotifier.value != null) {
                              setState(() {
                                _ridePref = RidePref(
                                  departure: _departureNotifier.value!,
                                  arrival: _arrivalNotifier.value!,
                                  departureDate: _dateNotifier.value,
                                  requestedSeats: _seatsNotifier.value!,
                                );
                              });
                              _generateMockRides();
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        DateFormat('EEE d MMM').format(_ridePref.departureDate);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black54),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _showSearchDialog,
                      child: Text(
                        '${_ridePref.departure.name} → ${_ridePref.arrival.name}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                '$formattedDate, ${_ridePref.requestedSeats} passenger${_ridePref.requestedSeats > 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _filteredRides.length,
        itemBuilder: (context, index) {
          final ride = _filteredRides[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text('${ride['departureTime']} - ${ride['arrivalTime']}'),
              subtitle: Text(
                  '${ride['departureLocation']} to ${ride['arrivalLocation']}'),
              trailing: Text('£${ride['price'].toStringAsFixed(2)}'),
            ),
          );
        },
      ),
    );
  }

  void _applyFilters() {
    setState(() {
      List<Map<String, dynamic>> filteredList = List.from(_filteredRides);

      // Apply price range filter
      filteredList = filteredList.where((ride) {
        return ride['price'] >= _priceRange.start &&
            ride['price'] <= _priceRange.end;
      }).toList();

      // Apply time range filter
      filteredList = filteredList.where((ride) {
        int departureHour = int.parse(ride['departureTime'].split(':')[0]);
        return departureHour >= _timeRange.start &&
            departureHour <= _timeRange.end;
      }).toList();

      // Apply direct rides filter
      if (_showDirectOnly) {
        filteredList = filteredList.where((ride) => ride['isDirect']).toList();
      }

      // Apply verified drivers filter
      if (_showVerifiedOnly) {
        filteredList =
            filteredList.where((ride) => ride['isVerified']).toList();
      }

      // Only apply sorting if a specific sort is selected
      if (_currentSort != "earliest") {
        filteredList.sort((a, b) {
          switch (_currentSort) {
            case "lowest":
              return a['price'].compareTo(b['price']);
            case "rating":
              double aRating = a['driverRating'] ?? 0;
              double bRating = b['driverRating'] ?? 0;
              return bRating.compareTo(aRating);
            default:
              return 0;
          }
        });
      }

      _filteredRides = filteredList;
    });
  }
}
