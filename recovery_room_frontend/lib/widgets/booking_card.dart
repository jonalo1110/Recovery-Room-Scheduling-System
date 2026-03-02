import 'package:flutter/material.dart';
import '../models/booking.dart';
import 'amenity_icon.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;

  const BookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF4A6741),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            booking.timeRange,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  booking.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (booking.amenities.contains('sauna'))
                    AmenityIcon(icon: Icons.hot_tub, size: 24),
                  if (booking.amenities.contains('cold_plunge'))
                    AmenityIcon(icon: Icons.ac_unit, size: 24),
                  if (booking.amenities.contains('normatech'))
                    AmenityIcon(icon: Icons.accessibility_new, size: 24),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}