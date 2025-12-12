class Booking {
  // Display name of the member (maps from "memberName" in the API)
  final String name;

  // Full start DateTime (combines API's "date" + "startTime")
  final DateTime start;

  // List of amenity ids like ["sauna", "cold_plunge"]
  final List<String> amenities;

  Booking({
    required this.name,
    required this.start,
    required this.amenities,
  });

  // ----------------------------------------------------------
  // Create a Booking from JSON coming from your Express API.
  //
  // Expected JSON shape (from backend):
  // {
  //   "memberName": "Jonathan",
  //   "date": "2025-12-03",
  //   "startTime": "09:30",
  //   "amenities": ["sauna", "cold_plunge"],
  //   ... other fields we don't care about here ...
  // }
  // ----------------------------------------------------------
  factory Booking.fromJson(Map<String, dynamic> json) {
    // Parse the "date" string into a DateTime (yyyy-MM-dd)
    final date = DateTime.parse(json['date']);

    // Parse the "startTime" like "09:30" into hour & minute
    final timeString = json['startTime'] as String;
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    // Combine date + time into a single DateTime
    final startDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );

    return Booking(
      name: json['memberName'] as String, // API field → model field
      start: startDateTime,
      amenities: List<String>.from(json['amenities'] ?? []),
    );
  }

  // Optional helper if you ever want to send this back as JSON
  Map<String, dynamic> toJson() {
    // Format date as YYYY-MM-DD
    final dateStr =
        '${start.year.toString().padLeft(4, '0')}-'
        '${start.month.toString().padLeft(2, '0')}-'
        '${start.day.toString().padLeft(2, '0')}';

    // Format time as HH:mm
    final timeStr =
        '${start.hour.toString().padLeft(2, '0')}:'
        '${start.minute.toString().padLeft(2, '0')}';

    return {
      'memberName': name,
      'date': dateStr,
      'startTime': timeStr,
      'amenities': amenities,
    };
  }

  // ------------------------------------------------------------------

  String get timeRange {
    final hour = start.hour;
    final minute = start.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    final endTime = start.add(const Duration(hours: 1));
    final endHour = endTime.hour;
    final endMinute = endTime.minute.toString().padLeft(2, '0');
    final endPeriod = endHour >= 12 ? 'PM' : 'AM';
    final displayEndHour =
        endHour > 12 ? endHour - 12 : (endHour == 0 ? 12 : endHour);
    
    return '$displayHour:$minute$period - $displayEndHour:$endMinute$endPeriod';
  }

  bool isToday() {
    final now = DateTime.now();
    return start.year == now.year && 
           start.month == now.month && 
           start.day == now.day;
  }

  bool isFuture() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final bookingDate = DateTime(start.year, start.month, start.day);
    return bookingDate.isAfter(today);
  }

  String get dateKey {
    return '${start.year}-'
           '${start.month.toString().padLeft(2, '0')}-'
           '${start.day.toString().padLeft(2, '0')}';
  }

  String get displayDate {
    final now = DateTime.now();
    final tomorrow =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final bookingDate = DateTime(start.year, start.month, start.day);
    
    if (bookingDate == tomorrow) {
      return 'Tomorrow - ${_monthName(start.month)} ${start.day}';
    }
    
    final weekday = _weekdayName(start.weekday);
    return '$weekday - ${_monthName(start.month)} ${start.day}';
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _weekdayName(int weekday) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday',
      'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return days[weekday - 1];
  }
}
