// import 'package:flutter/material.dart';
// import 'package:week_3_blabla_project/model/ride/locations.dart';
//
// import '../../service/locations_service.dart';
// import '../../theme/theme.dart';
// import '../custom_text_field_widget/custom_text_field.dart';
//
// ///
// /// This full-screen modal is in charge of providing (if confirmed) a selected location.
// ///
// class BlaLocationPicker extends StatefulWidget {
//   final Location?
//       initLocation; // The picker can be triguer with an existing location name
//
//   const BlaLocationPicker({super.key, this.initLocation});
//
//   @override
//   State<BlaLocationPicker> createState() => _BlaLocationPickerState();
// }
//
// class _BlaLocationPickerState extends State<BlaLocationPicker> {
//   List<Location> filteredLocations = [];
//
//   // ----------------------------------
//   // Initialize the Form attributes
//   // ----------------------------------
//
//   @override
//   void initState() {
//     super.initState();
//
//     if (widget.initLocation != null) {
//       filteredLocations = getLocationsFor(widget.initLocation!.name);
//     }
//   }
//
//   void onBackSelected() {
//     Navigator.of(context).pop();
//   }
//
//   void onLocationSelected(Location location) {
//     Navigator.of(context).pop(location);
//   }
//
//   void onSearchChanged(String searchText) {
//     List<Location> newSelection = [];
//
//     if (searchText.length > 1) {
//       // We start to search from 2 characters only.
//       newSelection = getLocationsFor(searchText);
//     }
//
//     setState(() {
//       filteredLocations = newSelection;
//     });
//   }
//
//   List<Location> getLocationsFor(String text) {
//     return LocationsService.availableLocations
//         .where((location) =>
//             location.name.toUpperCase().contains(text.toUpperCase()))
//         .toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: Padding(
//       padding: const EdgeInsets.only(
//           left: BlaSpacings.m, right: BlaSpacings.m, top: BlaSpacings.s),
//       child: Column(
//         children: [
//           // Top search Search bar
//           BlaSearchBar(
//             onBackPressed: onBackSelected,
//             onSearchChanged: onSearchChanged,
//           ),
//
//           Expanded(
//             child: ListView.builder(
//               itemCount: filteredLocations.length,
//               itemBuilder: (ctx, index) => LocationTile(
//                 location: filteredLocations[index],
//                 onSelected: onLocationSelected,
//               ),
//             ),
//           ),
//         ],
//       ),
//     ));
//   }
// }
//
// ///
// /// This tile represents an item in the list of past entered ride inputs
// ///s
// class LocationTile extends StatelessWidget {
//   final Location location;
//   final Function(Location location) onSelected;
//
//   const LocationTile(
//       {super.key, required this.location, required this.onSelected});
//
//   String get title => location.name;
//
//   String get subTitle => location.country.name;
//
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       onTap: () => onSelected(location),
//       title: Text(title,
//           style: BlaTextStyles.body.copyWith(color: BlaColors.textNormal)),
//       subtitle: Text(subTitle,
//           style: BlaTextStyles.label.copyWith(color: BlaColors.textLight)),
//       trailing: Icon(
//         Icons.arrow_forward_ios,
//         color: BlaColors.iconLight,
//         size: 16,
//       ),
//     );
//   }
// }
//
//
import 'package:flutter/material.dart';
import 'package:week_3_blabla_project/model/ride/locations.dart';

import '../../service/locations_service.dart';
import '../../theme/theme.dart';
import '../custom_text_field_widget/custom_text_field.dart';

/// Full-screen modal for selecting a location.
class BlaLocationPicker extends StatefulWidget {
  final Location? initLocation; // Picker can be triggered with an existing location

  const BlaLocationPicker({super.key, this.initLocation});

  @override
  State<BlaLocationPicker> createState() => _BlaLocationPickerState();
}

class _BlaLocationPickerState extends State<BlaLocationPicker> {
  List<Location> filteredLocations = [];

  @override
  void initState() {
    super.initState();
    filteredLocations = LocationsService.availableLocations;
  }

  void onBackSelected() {
    Navigator.of(context).pop();
  }

  void onLocationSelected(Location location) {
    Navigator.of(context).pop(location);
  }

  void onSearchChanged(String searchText) {
    setState(() {
      if (searchText.length > 1) {
        filteredLocations = LocationsService.availableLocations
            .where((location) =>
            location.name.toLowerCase().contains(searchText.toLowerCase()))
            .toList();
      } else {
        filteredLocations = LocationsService.availableLocations;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
            left: BlaSpacings.m, right: BlaSpacings.m, top: BlaSpacings.s),
        child: Column(
          children: [
            BlaSearchBar(
              onBackPressed: onBackSelected,
              onSearchChanged: onSearchChanged,
            ),
            Expanded(
              child: filteredLocations.isEmpty
                  ? Center(
                child: Text(
                  "No Data Found",
                  style: BlaTextStyles.body.copyWith(
                    color: BlaColors.textLight,
                    fontSize: 16,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: filteredLocations.length,
                itemBuilder: (ctx, index) => LocationTile(
                  location: filteredLocations[index],
                  onSelected: onLocationSelected,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LocationTile extends StatelessWidget {
  final Location location;
  final Function(Location location) onSelected;

  const LocationTile(
      {super.key, required this.location, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => onSelected(location),
      title: Text(location.name,
          style: BlaTextStyles.body.copyWith(color: BlaColors.textNormal)),
      subtitle: Text(location.country.name,
          style: BlaTextStyles.label.copyWith(color: BlaColors.textLight)),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: BlaColors.iconLight,
        size: 16,
      ),
    );
  }
}

