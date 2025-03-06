import 'package:flutter/material.dart';
import '../../model/ride_pref/ride_pref.dart';

class AvailableDriversScreen extends StatelessWidget {
  final RidePref ridePref;

  const AvailableDriversScreen({super.key, required this.ridePref});

  @override
  Widget build(BuildContext context) {
    // Mocked fare calculation
    double fare = calculateFare(ridePref.departure.name, ridePref.arrival.name, ridePref.requestedSeats);

    // Format date for display (Saturday, February 22)
    String formattedDate = "Sat 22 Feb";

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
                  Text(
                    '${ridePref.departure.name} → ${ridePref.arrival.name}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
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
              Text(
                '$formattedDate, ${ridePref.requestedSeats} passenger${ridePref.requestedSeats > 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          // bottom: PreferredSize(
          //   preferredSize: const Size.fromHeight(50),
          //   child: Container(
          //     width: double.infinity,
          //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         _buildTabOption("All", "5", true),
          //         _buildTabOption("Carpool", "5", false),
          //         _buildTabOption("Bus", "0", false),
          //       ],
          //     ),
          //   ),
          // ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Expanded(
            child: ListView.builder(
              itemCount: 5, // Mocked 5 drivers
              itemBuilder: (context, index) {
                // Generate different departure and arrival times for each driver
                String departureTime = "${(index + 5).toString().padLeft(2, '0')}:${(index * 10).toString().padLeft(2, '0')}";
                String arrivalTime = "${(index + 8).toString().padLeft(2, '0')}:${(index * 10).toString().padLeft(2, '0')}";
                // Fixed duration formatting
                String duration = "${2 + (index % 3)}h${(index * 20) % 60}";

                bool isCarpool = index % 3 != 0;
                String driverName = "Driver ${index + 1}";
                double rating = 4.0 + (index * 0.2);
                double driverFare = fare * (1 + (index * 0.05));

                return _buildRideCard(
                  departureTime: departureTime,
                  arrivalTime: arrivalTime,
                  duration: duration,
                  departureLocation: ridePref.departure.name,
                  departureStation: isCarpool ? "" : "Main Station",
                  arrivalLocation: ridePref.arrival.name,
                  arrivalStation: isCarpool ? "" : "Bus Stop",
                  price: "£${driverFare.toStringAsFixed(2)}",
                  isCarpool: isCarpool,
                  driverName: isCarpool ? driverName : null,
                  driverRating: isCarpool ? rating : null,
                  hasLimitedSeats: index == 2,
                  seatsAvailable: index == 2 ? ridePref.requestedSeats : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabOption(String title, String count, bool isSelected) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.teal[800] : Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.teal : Colors.transparent,
                width: 3.0,
              ),
            ),
          ),
          child: Text(
            count,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.teal[800] : Colors.black54,
            ),
          ),
        ),
      ],
    );
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
                                  if (departureStation != null && departureStation.isNotEmpty)
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
                                  if (arrivalStation != null && arrivalStation.isNotEmpty)
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
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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

          // Bottom section with transport type or driver info
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
}