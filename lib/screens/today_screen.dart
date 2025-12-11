import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../widgets/booking_card.dart';

class TodayScreen extends StatefulWidget {
  final List<Booking> bookings;

  const TodayScreen({super.key, required this.bookings});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  @override
  Widget build(BuildContext context) {
    final todayBookings = widget.bookings.where((b) => b.isToday()).toList();

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
                'Todays Appointments',
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
            child: todayBookings.isEmpty
                ? Center(
                    child: Text(
                      'No appointments today',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    itemCount: todayBookings.length,
                    itemBuilder: (context, index) {
                      return BookingCard(booking: todayBookings[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
