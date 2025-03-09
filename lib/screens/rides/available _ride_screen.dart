import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math'; // Add this import for Random
import '../../model/ride_pref/ride_pref.dart';
import '../../model/ride/locations.dart';
import '../../utils/animations_util.dart';
import '../../widgets/inputs/bla_location_picker.dart';
import '../../theme/theme.dart';
import '../../widgets/actions/bla_button.dart';
import '../../widgets/display/bla_divider.dart';

class AvailableDriversScreen extends StatefulWidget {
  final RidePref ridePref;

  const AvailableDriversScreen({super.key, required this.ridePref});

  @override
  State<AvailableDriversScreen> createState() => _AvailableDriversScreenState();
}

class _AvailableDriversScreenState extends State<AvailableDriversScreen> {
  List<Map<String, dynamic>> _filteredRides = [];
  List<Map<String, dynamic>> _originalRides = []; // Store original rides
  String _currentSort = "random"; // Change default sort to "random"
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
  final Random _random = Random(); // Add Random instance

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

  @override
  void dispose() {
    _departureNotifier.dispose();
    _arrivalNotifier.dispose();
    _dateNotifier.dispose();
    _seatsNotifier.dispose();
    _departureController.dispose();
    _arrivalController.dispose();
    super.dispose();
  }

  void _generateSuggestions(String query) {
    // Mock locations - replace with your actual location data
    final allLocations = [
      "London",
      "Manchester",
      "Birmingham",
      "Liverpool",
      "Leeds",
      "Glasgow",
      "Edinburgh",
      "Cardiff",
      "Belfast",
      "Bristol"
    ];

    setState(() {
      _suggestions = allLocations
          .where((location) =>
          location.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _updateSearch() {
    setState(() {
      _ridePref = RidePref(
        departure: Location(
            name: _departureController.text,
            country: _ridePref.departure.country),
        arrival: Location(
            name: _arrivalController.text, country: _ridePref.arrival.country),
        requestedSeats: _ridePref.requestedSeats,
        departureDate: _ridePref.departureDate,
      );
    });
    _generateMockRides();
  }

  void _generateMockRides() {
    // Mocked fare calculation
    double baseFare = calculateFare(
      _ridePref.departure.name,
      _ridePref.arrival.name,
      _ridePref.requestedSeats,
    );

    // Generate rides first
    _originalRides = List.generate(5, (index) {
      String departureTime =
          "${(index + 5).toString().padLeft(2, '0')}:${(index * 10).toString().padLeft(2, '0')}";
      String arrivalTime =
          "${(index + 8).toString().padLeft(2, '0')}:${(index * 10).toString().padLeft(2, '0')}";
      String duration = "${2 + (index % 3)}h${(index * 20) % 60}";
      bool isCarpool = index % 3 != 0;
      String driverName = "Driver ${index + 1}";
      double rating = 4.0 + (index * 0.2);
      double driverFare = baseFare * (1 + (index * 0.05));
      bool isVerified = index % 2 == 0;
      bool isDirect = index % 2 == 1;

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
        'hasLimitedSeats': index == 2,
        'seatsAvailable': index == 2 ? _ridePref.requestedSeats : null,
        'isVerified': isVerified,
        'isDirect': isDirect,
      };
    });

    // Randomize the rides initially
    _filteredRides = List.from(_originalRides);
    _shuffleRides();

    // Then apply any other filters if needed
    _applyFilters();
  }

  // Add this method to shuffle the rides
  void _shuffleRides() {
    // Create a copy to avoid modifying the original list directly
    List<Map<String, dynamic>> shuffled = List.from(_filteredRides);

    // Fisher-Yates shuffle algorithm
    for (int i = shuffled.length - 1; i > 0; i--) {
      int j = _random.nextInt(i + 1);
      var temp = shuffled[i];
      shuffled[i] = shuffled[j];
      shuffled[j] = temp;
    }

    setState(() {
      _filteredRides = shuffled;
    });
  }

  void _applyFilters() {
    // Start with all original rides
    List<Map<String, dynamic>> filtered = List.from(_originalRides);

    // Apply price range filter
    filtered = filtered.where((ride) {
      return ride['price'] >= _priceRange.start &&
          ride['price'] <= _priceRange.end;
    }).toList();

    // Apply time range filter
    filtered = filtered.where((ride) {
      int departureHour = int.parse(ride['departureTime'].split(':')[0]);
      return departureHour >= _timeRange.start &&
          departureHour <= _timeRange.end;
    }).toList();

    // Apply direct rides filter
    if (_showDirectOnly) {
      filtered = filtered.where((ride) => ride['isDirect']).toList();
    }

    // Apply verified drivers filter
    if (_showVerifiedOnly) {
      filtered = filtered.where((ride) => ride['isVerified']).toList();
    }

    // Apply sorting only if a specific sort is selected (not random)
    if (_currentSort != "random") {
      filtered.sort((a, b) {
        switch (_currentSort) {
          case "earliest":
            return a['departureTime'].compareTo(b['departureTime']);
          case "lowest":
            return a['price'].compareTo(b['price']);
          case "rating":
            return (b['driverRating'] ?? 0).compareTo(a['driverRating'] ?? 0);
          default:
            return 0;
        }
      });
    } else {
      // If sort is random, shuffle the filtered rides
      for (int i = filtered.length - 1; i > 0; i--) {
        int j = _random.nextInt(i + 1);
        var temp = filtered[i];
        filtered[i] = filtered[j];
        filtered[j] = temp;
      }
    }

    setState(() {
      _filteredRides = filtered;
    });
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FilterBottomSheet(
          initialSort: _currentSort, // Pass current sort to the sheet
          initialPerAccepted: _isPerAccepted,
          onFilterApplied: (String selectedFilter, bool isPerAccepted) {
            setState(() {
              _currentSort = selectedFilter;
              _isPerAccepted = isPerAccepted;
            });
            _applyFilters();
          },
        );
      },
    );
  }

  void _showSearchDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      transitionDuration: Duration(microseconds: 500),
      barrierLabel: MaterialLocalizations.of(context).dialogLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Material(
          color: Colors.transparent,
          child: Container(
            width: double.maxFinite,
            color: Colors.white,
            height: 300,
            padding: const EdgeInsets.all(16),
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              children: [
                // Departure Location
                SizedBox(height: 20),
                Row(children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close),
                    color: Colors.blue,
                  ),
                  Spacer(),
                  TextButton(onPressed: () {}, child: Text('clear',style: TextStyle(color: Colors.blue)))
                ]),
                SizedBox(height: 10),
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
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              departure?.name ?? 'Select departure',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          Spacer(),
                          GestureDetector(
                            child: const Icon(Icons.swap_vert,color: Colors.blue),
                            onTap: () {
                              final temp = _departureNotifier.value;
                              _departureNotifier.value =
                                  _arrivalNotifier.value;
                              _arrivalNotifier.value = temp;
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 10),
                BlaDivider(),
                const SizedBox(height: 10),
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
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              arrival?.name ?? 'Select arrival',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 10),
                const BlaDivider(),
                // Date Picker
                SizedBox(height: 10),
                ValueListenableBuilder<DateTime>(
                  valueListenable: _dateNotifier,
                  builder: (context, date, _) {
                    return InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: date,
                          firstDate: DateTime.now(),
                          lastDate:
                          DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          _dateNotifier.value = picked;
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('EEE, MMM d').format(date),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 10),
                const BlaDivider(),
                SizedBox(height: 10),
                // Seats Selector
                ValueListenableBuilder<int?>(
                  valueListenable: _seatsNotifier,
                  builder: (context, seats, _) {
                    return DropdownButton<String>(
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
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Apply Button
                BlaButton(
                  text: 'Search',
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
                        // Reset sort to random when searching
                        _currentSort = "random";
                      });
                      _generateMockRides();
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = "Sat 22 Feb";

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 25),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black54),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _showSearchDialog();
                      },
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
                  TextButton(
                    onPressed: () => _showFilterBottomSheet(context),
                    child: const Text(
                      "Filter",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 48), // Align under the search text
                child: Text(
                  '$formattedDate, ${_ridePref.requestedSeats} passenger${_ridePref.requestedSeats > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _filteredRides.length,
              itemBuilder: (context, index) {
                final ride = _filteredRides[index];
                return _buildRideCard(
                  departureTime: ride['departureTime'],
                  arrivalTime: ride['arrivalTime'],
                  duration: ride['duration'],
                  departureLocation: ride['departureLocation'],
                  departureStation: ride['departureStation'],
                  arrivalLocation: ride['arrivalLocation'],
                  arrivalStation: ride['arrivalStation'],
                  price: "£${ride['price'].toStringAsFixed(2)}",
                  isCarpool: ride['isCarpool'],
                  driverName: ride['driverName'],
                  driverRating: ride['driverRating'],
                  hasLimitedSeats: ride['hasLimitedSeats'],
                  seatsAvailable: ride['seatsAvailable'],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  final Function(String selectedFilter, bool isPerAccepted) onFilterApplied;
  final String initialSort;
  final bool initialPerAccepted;

  const FilterBottomSheet({
    super.key,
    required this.onFilterApplied,
    this.initialSort = "random",
    this.initialPerAccepted = false,
  });

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _selectedFilter;
  late bool _isPerAccepted;
  RangeValues _priceRange = const RangeValues(0, 100);
  RangeValues _timeRange = const RangeValues(0, 24);
  bool _showDirectOnly = false;
  bool _showVerifiedOnly = false;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialSort;
    _isPerAccepted = widget.initialPerAccepted;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Filters",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedFilter = "random"; // Set to random when clearing
                    _isPerAccepted = false;
                    _priceRange = const RangeValues(0, 100);
                    _timeRange = const RangeValues(0, 24);
                    _showDirectOnly = false;
                    _showVerifiedOnly = false;
                  });
                  widget.onFilterApplied(_selectedFilter, _isPerAccepted);

                },
                child: const Text("Clear all"),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Sort By Section
          const Text(
            "Sort By",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          RadioListTile(
            title: const Text("Earliest Departure"),
            value: "earliest",
            groupValue: _selectedFilter,
            onChanged: (value) {
              setState(() {
                _selectedFilter = value.toString();
              });
            },
          ),
          RadioListTile(
            title: const Text("Lowest Price"),
            value: "lowest",
            groupValue: _selectedFilter,
            onChanged: (value) {
              setState(() {
                _selectedFilter = value.toString();
              });
            },
          ),
          BlaDivider(),
          const SizedBox(height: 10),
          const Text(
            "Details",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),

          CheckboxListTile(
            title: const Text("Pets accepted"),
            value: _isPerAccepted, // Use _isPerAccepted for the "Pets accepted" checkbox
            onChanged: (value) {
              setState(() {
                _isPerAccepted = value!;
              });
            },
          ),

          const SizedBox(height: 20),

          // Apply Button
          Align(
            alignment: Alignment.topRight,
            child: SizedBox(
              width: 120,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                ),
                onPressed: () {
                  widget.onFilterApplied(_selectedFilter, _isPerAccepted);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(fontSize: 18,color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildRideCard({
  required String departureTime,
  required String arrivalTime,
  required String duration,
  required String departureLocation,
  String? departureStation,
  required String arrivalLocation,
  String? arrivalStation,
  required String price,
  required bool isCarpool,
  String? driverName,
  double? driverRating,
  bool hasLimitedSeats = false,
  int? seatsAvailable,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side - times and route
              Expanded(
                flex: 7,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          departureTime,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          duration,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          arrivalTime,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.teal,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  departureLocation,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (departureStation != null &&
                                    departureStation.isNotEmpty)
                                  Text(
                                    departureStation,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.teal[700],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          height: 30,
                          width: 2,
                          color: Colors.teal,
                        ),
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.teal,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  arrivalLocation,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (arrivalStation != null &&
                                    arrivalStation.isNotEmpty)
                                  Text(
                                    arrivalStation,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.teal[700],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Right side - price
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (hasLimitedSeats && seatsAvailable != null)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "$seatsAvailable seats at this price",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[400],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              if (isCarpool)
                _buildDriverInfo(driverName ?? "Driver", driverRating ?? 0.0)
              else
                _buildBusInfo(),
              const Spacer(),
              if (!isCarpool)
                Row(
                  children: [
                    Icon(Icons.power, color: Colors.grey[400]),
                    const SizedBox(width: 12),
                    Icon(Icons.wc, color: Colors.grey[400]),
                  ],
                )
              else
                Icon(Icons.group, color: Colors.grey[400]),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildBusInfo() {
  return Row(
    children: [
      Icon(Icons.directions_bus, color: Colors.grey[600], size: 20),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          "BusService",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    ],
  );
}

Widget _buildDriverInfo(String name, double rating) {
  return Row(
    children: [
      Icon(Icons.directions_car, color: Colors.grey[600], size: 20),
      const SizedBox(width: 8),
      CircleAvatar(
        radius: 12,
        backgroundColor: Colors.blue,
        child: Text(
          name[0],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
      const SizedBox(width: 8),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 14),
              const SizedBox(width: 2),
              Text(
                rating.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

double calculateFare(String departure, String arrival, int seats) {
  return (departure.length + arrival.length) * seats * 2.5;
}
