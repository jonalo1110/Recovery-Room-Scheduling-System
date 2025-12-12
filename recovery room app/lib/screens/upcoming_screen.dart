import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../widgets/booking_card.dart';

class UpcomingScreen extends StatefulWidget {
  final List<Booking> bookings;

  const UpcomingScreen({super.key, required this.bookings});

  @override
  State<UpcomingScreen> createState() => _UpcomingScreenState();
}

class _UpcomingScreenState extends State<UpcomingScreen> {
  @override
  Widget build(BuildContext context) {
    final futureBookings = widget.bookings.where((b) => b.isFuture()).toList();

    final Map<String, List<Booking>> groupedBookings = {};
    for (var booking in futureBookings) {
      final dateKey = booking.dateKey;
      if (!groupedBookings.containsKey(dateKey)) {
        groupedBookings[dateKey] = [];
      }
      groupedBookings[dateKey]!.add(booking);
    }

    final sortedDates = groupedBookings.keys.toList()..sort();

    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: Center(
              child: Image.asset(
                'assets/images/pitwhite.png',
                height: 150,
                width: 150,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Upcoming Appointments',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: sortedDates.isEmpty
                ? Center(
                    child: Text(
                      'No upcoming appointments',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    itemCount: sortedDates.length,
                    itemBuilder: (context, index) {
                      final dateKey = sortedDates[index];
                      final bookingsForDate = groupedBookings[dateKey]!;
                      final displayDate = bookingsForDate.first.displayDate;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              displayDate,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          ...bookingsForDate.map((booking) {
                            return BookingCard(booking: booking);
                          }).toList(),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}