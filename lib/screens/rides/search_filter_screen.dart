import 'package:flutter/material.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  _SearchFilterScreenState createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  String _selectedFilter = "earliest"; // Default filter
  bool _isPerAccepted = false;

  final List<Map<String, dynamic>> rideData = [
    {"departure": "08:00 AM", "price": 50, "perAccepted": true},
    {"departure": "09:30 AM", "price": 40, "perAccepted": false},
    {"departure": "07:15 AM", "price": 60, "perAccepted": true},
    {"departure": "10:00 AM", "price": 35, "perAccepted": true},
  ];

  List<Map<String, dynamic>> filteredRides = [];

  void _applyFilter() {
    setState(() {
      filteredRides = List.from(rideData);

      // Sorting based on selected radio button
      if (_selectedFilter == "earliest") {
        filteredRides.sort((a, b) => a["departure"].compareTo(b["departure"]));
      } else if (_selectedFilter == "lowest") {
        filteredRides.sort((a, b) => a["price"].compareTo(b["price"]));
      }

      // Applying checkbox filter
      if (_isPerAccepted) {
        filteredRides = filteredRides.where((ride) => ride["perAccepted"]).toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    filteredRides = List.from(rideData); // Initialize with all rides
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Filter Rides',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Radio buttons for filtering
            const Text("Sort By:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

            // Checkbox for per accepted filter
            CheckboxListTile(
              title: const Text("pat Accepted"),
              value: _isPerAccepted,
              onChanged: (value) {
                setState(() {
                  _isPerAccepted = value!;
                });
              },
            ),

            // Apply filter button
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _applyFilter,
                child: const Text(
                  'See Details',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Displaying filtered ride data
            const Text("Filtered Rides:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: filteredRides.length,
                itemBuilder: (context, index) {
                  final ride = filteredRides[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text("Departure: ${ride['departure']}"),
                      subtitle: Text("Price: \$${ride['price']}"),
                      trailing: ride["perAccepted"]
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.cancel, color: Colors.red),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
