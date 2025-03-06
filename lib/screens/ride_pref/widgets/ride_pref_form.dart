// import 'package:flutter/material.dart';
//
// import '../../../model/ride/locations.dart';
// import '../../../model/ride_pref/ride_pref.dart';
// import '../../../theme/theme.dart';
// import '../../../utils/animations_util.dart';
// import '../../../utils/date_time_util.dart';
// import '../../../widgets/actions/bla_button.dart';
// import '../../../widgets/display/bla_divider.dart';
// import '../../../widgets/inputs/bla_location_picker.dart';
// import '../../rides/rides_screen.dart';
// import 'ride_pref_input_tile.dart';
//
// ///
// /// A Ride Preference From is a view to select:
// ///   - A depcarture location
// ///   - An arrival location
// ///   - A date
// ///   - A number of seats
// ///
// /// The form can be created with an existing RidePref (optional).
// ///
// class RidePrefForm extends StatefulWidget {
//   // The form can be created with an optional initial RidePref.
//   final RidePref? initRidePref;
//
//   const RidePrefForm({super.key, this.initRidePref});
//
//   @override
//   State<RidePrefForm> createState() => _RidePrefFormState();
// }
//
// class _RidePrefFormState extends State<RidePrefForm> {
//   Location? departure;
//   late DateTime departureDate;
//   Location? arrival;
//   late int requestedSeats;
//
//
//
//   // ----------------------------------
//   // Initialize the Form attributes
//   // ----------------------------------
//
//   @override
//   void initState() {
//     super.initState();
//
//     if (widget.initRidePref != null) {
//       departure = widget.initRidePref!.departure;
//       arrival = widget.initRidePref!.arrival;
//       departureDate = widget.initRidePref!.departureDate;
//       requestedSeats = widget.initRidePref!.requestedSeats;
//     } else {
//       // If no given preferences, we select default ones :
//       departure = null; // User shall select the departure
//       departureDate = DateTime.now(); // Now  by default
//       arrival = null; // User shall select the arrival
//       requestedSeats = 1; // 1 seat book by default
//     }
//   }
//
//   // ----------------------------------
//   // Handle events
//   // ----------------------------------
//
//
//   void onDeparturePressed() async {
//     // 1- Select a location
//     Location? selectedLocation = await Navigator.of(context).push<Location>(
//         AnimationUtils.createBottomToTopRoute(BlaLocationPicker(initLocation: departure,))
//         );
//
//     // 2- Update the from if needed
//     if (selectedLocation != null) {
//       setState(() {
//         departure = selectedLocation;
//       });
//     }
//   }
//
//   void onArrivalPressed() async {
//     // 1- Select a location
//     Location? selectedLocation = await Navigator.of(context).push<Location>(
//         AnimationUtils.createBottomToTopRoute(BlaLocationPicker(initLocation: arrival,)));
//
//     // 2- Update the from if needed
//     if (selectedLocation != null) {
//       setState(() {
//         arrival = selectedLocation;
//       });
//     }
//   }
//
//   void onSubmit() {
//         bool hasDeparture = departure != null;
//     bool hasArrival = arrival != null;
//
//     if (hasDeparture && hasArrival) {
//       // 1- Crea a Ride Pref from user inputs
//       RidePref newRideRef = RidePref(
//           departure: departure!,
//           departureDate: departureDate,
//           arrival: arrival!,
//           requestedSeats: requestedSeats);
//
//       // 2 - Navigate to the rides screen (with a buttom to top animation)
//       Navigator.of(context)
//           .push(AnimationUtils.createBottomToTopRoute(RidesScreen(
//         initialRidePref: newRideRef,
//       )));
//     }
//   }
//
//
//   void onSwappingLocationPressed() {
//     setState(() {
//       // We switch only if both departure and arrivate are defined
//         if (departure != null && arrival != null) {
//           Location temp = departure!;
//           departure = Location.copy(arrival!);
//           arrival = Location.copy(temp);
//         }
//       });
//   }
//
//
//   // ----------------------------------
//   // Compute the widgets rendering
//   // ----------------------------------
//     String get departureLabel =>
//       departure != null ? departure!.name : "Leaving from";
//   String get arrivalLabel => arrival != null ? arrival!.name : "Going to";
//
//   bool get showDeparturePLaceHolder => departure == null;
//   bool get showArrivalPLaceHolder => arrival == null;
//
//   String get dateLabel => DateTimeUtils.formatDateTime(departureDate);
//   String get numberLabel => requestedSeats.toString();
//
//   bool get switchVisible => arrival!=null && departure != null;
//
//
//   // ----------------------------------
//   // Build the widgets
//   // ----------------------------------
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: BlaSpacings.m),
//             child: Column(
//               children: [
//                 // 1 - Input the ride departure
//                 RidePrefInputTile(
//                     isPlaceHolder: showDeparturePLaceHolder,
//                     title: departureLabel,
//                     leftIcon: Icons.location_on,
//                     onPressed: onDeparturePressed,
//                     rightIcon: switchVisible? Icons.swap_vert:null,
//                     onRightIconPressed: switchVisible? onSwappingLocationPressed: null,
//                     ),
//                 const BlaDivider(),
//
//                 // 2 - Input the ride arrival
//                 RidePrefInputTile(
//                     isPlaceHolder: showArrivalPLaceHolder,
//                     title: arrivalLabel,
//                     leftIcon: Icons.location_on,
//                     onPressed: onArrivalPressed),
//                 const BlaDivider(),
//
//                 // 3 - Input the ride date
//                 RidePrefInputTile(
//                     title: dateLabel,
//                     leftIcon: Icons.calendar_month,
//                     onPressed: () => {}),
//                 const BlaDivider(),
//
//                 // 4 - Input the requested number of seats
//                 RidePrefInputTile(
//                     title: numberLabel,
//                     leftIcon: Icons.person_2_outlined,
//                     onPressed: () => {})
//               ],
//             ),
//           ),
//
//           // 5 - Launch a search
//           BlaButton(text: 'Search', onPressed: onSubmit),
//
//
//         ]);
//   }
// }
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../model/ride/locations.dart';
import '../../../model/ride_pref/ride_pref.dart';
import '../../../service/ride_prefs_service.dart';
import '../../../theme/theme.dart';
import '../../../utils/animations_util.dart';
import '../../../widgets/actions/bla_button.dart';
import '../../../widgets/display/bla_divider.dart';
import '../../../widgets/inputs/bla_location_picker.dart';
import '../../rides/available _ride_screen.dart';
import '../../rides/rides_screen.dart';
import 'ride_pref_input_tile.dart';
import 'ride_pref_history_tile.dart';

class RidePrefForm extends StatefulWidget {
  final RidePref? initRidePref;

  const RidePrefForm({super.key, this.initRidePref});

  @override
  State<RidePrefForm> createState() => _RidePrefFormState();
}

class _RidePrefFormState extends State<RidePrefForm> {
  Location? departure;
  late DateTime departureDate;
  Location? arrival;
  String? selectedValue;
  List<String> items = ['1', '2', '3', '4', '5'];
  List<RidePref> rideHistory = [];

  @override
  void initState() {
    super.initState();
    if (widget.initRidePref != null) {
      departure = widget.initRidePref!.departure;
      arrival = widget.initRidePref!.arrival;
      departureDate = widget.initRidePref!.departureDate;
    } else {
      departure = null;
      departureDate = DateTime.now();
      arrival = null;
    }

    // Load ride history from SharedPreferences
    _loadRideHistory();
  }

  // Convert Country enum to String for storage
  String _countryToString(Country country) {
    return country.name;
  }

  // Convert String back to Country enum
  Country _stringToCountry(String countryName) {
    return Country.values.firstWhere(
          (c) => c.name == countryName,
      orElse: () => Country.france, // Default value if not found
    );
  }

  // Load ride history from SharedPreferences
  Future<void> _loadRideHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('ride_history') ?? [];

    if (historyJson.isEmpty) return;

    setState(() {
      rideHistory = historyJson.map((item) {
        Map<String, dynamic> rideMap = json.decode(item);

        // Convert the departure location
        Map<String, dynamic> departureMap = rideMap['departure'];
        Location departureLocation = Location(
          name: departureMap['name'],
          country: _stringToCountry(departureMap['country']),
        );

        // Convert the arrival location
        Map<String, dynamic> arrivalMap = rideMap['arrival'];
        Location arrivalLocation = Location(
          name: arrivalMap['name'],
          country: _stringToCountry(arrivalMap['country']),
        );

        return RidePref(
          departure: departureLocation,
          arrival: arrivalLocation,
          departureDate: DateTime.parse(rideMap['departureDate']),
          requestedSeats: rideMap['requestedSeats'],
        );
      }).toList();
    });
  }

  // Save ride preference to SharedPreferences
  Future<void> _saveRidePref(RidePref ridePref) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> historyJson = prefs.getStringList('ride_history') ?? [];

    // Convert Location to Map manually
    Map<String, dynamic> departureMap = {
      'name': ridePref.departure.name,
      'country': _countryToString(ridePref.departure.country),
    };

    Map<String, dynamic> arrivalMap = {
      'name': ridePref.arrival.name,
      'country': _countryToString(ridePref.arrival.country),
    };

    // Create RidePref Map
    Map<String, dynamic> rideMap = {
      'departure': departureMap,
      'arrival': arrivalMap,
      'departureDate': ridePref.departureDate.toIso8601String(),
      'requestedSeats': ridePref.requestedSeats,
    };

    // Add to history list (limit to 10 most recent items)
    historyJson.insert(0, json.encode(rideMap));
    if (historyJson.length > 10) {
      historyJson = historyJson.sublist(0, 10);
    }

    // Save to SharedPreferences
    await prefs.setStringList('ride_history', historyJson);

    // Update state
    _loadRideHistory();
  }

  void onDatePressed() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: departureDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() {
        departureDate = pickedDate;
      });
    }
  }

  void onDeparturePressed() async {
    Location? selectedLocation = await Navigator.of(context).push<Location>(
      AnimationUtils.createBottomToTopRoute(
          BlaLocationPicker(initLocation: departure)),
    );
    if (selectedLocation != null) {
      setState(() {
        departure = selectedLocation;
      });
    }
  }

  void onArrivalPressed() async {
    Location? selectedLocation = await Navigator.of(context).push<Location>(
      AnimationUtils.createBottomToTopRoute(
          BlaLocationPicker(initLocation: arrival)),
    );
    if (selectedLocation != null) {
      setState(() {
        arrival = selectedLocation;
      });
    }
  }

  void onSubmit() {
    if (departure == null || arrival == null || selectedValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields before searching.")),
      );
      return;
    }

    RidePref newRidePref = RidePref(
      departure: departure!,
      departureDate: departureDate,
      arrival: arrival!,
      requestedSeats: int.parse(selectedValue!),
    );

    // Save the ride preference to SharedPreferences
    _saveRidePref(newRidePref);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AvailableDriversScreen(ridePref: newRidePref),
      ),
    );

    // Clear fields after navigation
    setState(() {
      departure = null;
      arrival = null;
      selectedValue = null;
      departureDate = DateTime.now();
    });
  }


  String get dateLabel => DateFormat('EEE d MMM').format(departureDate);
  String get departureLabel => departure != null ? departure!.name : "Leaving from";
  String get arrivalLabel => arrival != null ? arrival!.name : "Going to";

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              RidePrefInputTile(
                isPlaceHolder: departure == null,
                title: departureLabel,
                leftIcon: Icons.location_on,
                onPressed: onDeparturePressed,
              ),
              const BlaDivider(),
              RidePrefInputTile(
                isPlaceHolder: arrival == null,
                title: arrivalLabel,
                leftIcon: Icons.location_on,
                onPressed: onArrivalPressed,
              ),
              const BlaDivider(),
              RidePrefInputTile(
                title: dateLabel,
                leftIcon: Icons.calendar_month,
                onPressed: onDatePressed,
              ),
              const BlaDivider(),
              SizedBox(height: 10,),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      customButton: Row(
                        children: [
                          Icon(
                            Icons.event_seat,
                            size: 25,
                            color: BlaColors.textLight,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              selectedValue ?? 'Select Seats',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: BlaColors.textLight,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      items: items.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: BlaColors.textLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      value: selectedValue,
                      onChanged: (value) {
                        setState(() {
                          selectedValue = value;
                        });
                      },
                      buttonStyleData: ButtonStyleData(
                        height: 50,
                        width: double.infinity,
                        padding: const EdgeInsets.only(left: 14, right: 14),
                        elevation: 2,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10,),

              const BlaDivider(),
            ],
          ),
        ),
        BlaButton(text: 'Search', onPressed: onSubmit),
        const SizedBox(height: 20),
        if (rideHistory.isNotEmpty)
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ride History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  // shrinkWrap: true,
                  // physics: NeverScrollableScrollPhysics(),
                  itemCount: rideHistory.length,
                  itemBuilder: (context, index) {
                    final ride = rideHistory[index];
                    return RidePrefHistoryTile(ridePref: ride);
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }
}


