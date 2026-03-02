import 'package:flutter/material.dart';
import '../config/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateBookingScreen extends StatefulWidget {
  const CreateBookingScreen({super.key});

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  // Text input controller for member name
  final _nameController = TextEditingController();

  // Local state for selected date & time
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  // Which amenities are currently selected (stores their ids)
  Set<String> _selectedAmenities = {};

  // Prevents double-tapping the "Create Booking" button
  bool _isSubmitting = false;

  // Static list of all amenities you offer.
  // id, value sent to API
  // name & icon, used for display in the UI
  final List<Map<String, dynamic>> amenities = [
    {'id': 'sauna', 'name': 'Sauna', 'icon': Icons.hot_tub},
    {'id': 'cold_plunge', 'name': 'Cold Plunge', 'icon': Icons.ac_unit},
    {'id': 'normatech', 'name': 'Normatech', 'icon': Icons.accessibility_new},
  ];

  // Main action: validate form, call API, and pop with a bool.
  // true,  booking created successfully
  // null, user backed out or an error occurred
  void _createBooking() async {
    // Ignore taps while a request is already in flight
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
    });

    // 1) Basic validation: name required
    if (_nameController.text.trim().isEmpty) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a member name'),
          backgroundColor: Colors.red[700],
        ),
      );
      return;
    }

    // 2) Basic validation: at least one amenity required
    if (_selectedAmenities.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one amenity'),
          backgroundColor: Colors.red[700],
        ),
      );
      return;
    }

    // 3) Format date as YYYY-MM-DD (what your backend expects)
    final dateStr =
        '${_selectedDate.year.toString().padLeft(4, '0')}-'
        '${_selectedDate.month.toString().padLeft(2, '0')}-'
        '${_selectedDate.day.toString().padLeft(2, '0')}';

    // 4) Format time as HH:mm (24-hour)
    final timeStr =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:'
        '${_selectedTime.minute.toString().padLeft(2, '0')}';

    // 5) JSON body that matches POST /api/bookings on your Express server
    final bookingData = {
      'memberName': _nameController.text.trim(),
      'date': dateStr,
      'startTime': timeStr,
      'partySize': 1,                         // fixed to 1 for now
      'amenities': _selectedAmenities.toList(), // ["sauna", "cold_plunge", ...]
    };

    try {
      // Build URL like http://localhost:3000/api/bookings (or Render URL)
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/bookings');

      // 6) Send POST request to your backend
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bookingData),
      );

      if (!mounted) return;

      // 7) Success (201/200) → tell parent screen "it worked" and close
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _isSubmitting = false;
        });

        // Use next frame to avoid Navigator "locked" assertion
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (Navigator.of(context).canPop()) {
            // Parent (`MainScreen`) receives `true` and can refresh / show SnackBar
            Navigator.of(context).pop(true);
          }
        });
      } else {
        // 8) Server responded but with an error status code
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to create booking: ${response.statusCode}',
            ),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } catch (e) {
      // 9) Network or unexpected error (no response from server)
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Full-screen form UI to capture booking details
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          // Simple back arrow: just closes the screen with no result
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('New Booking', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MEMBER NAME INPUT
            Text(
              'Member Name',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField
              (
              controller: _nameController,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Enter name',
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // DATE PICKER
            Text(
              'Date',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                // Shows native date picker and updates local state
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Icon(Icons.calendar_today, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // TIME PICKER
            Text(
              'Start Time',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                // Shows time picker and updates local state
                final time = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                  initialEntryMode: TimePickerEntryMode.input,
                );
                if (time != null) {
                  setState(() {
                    _selectedTime = time;
                  });
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedTime.format(context),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Icon(Icons.access_time, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // AMENITIES SELECTION
            Text(
              'Amenities',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: amenities.map((amenity) {
                // Check whether this amenity is currently selected
                final isSelected = _selectedAmenities.contains(amenity['id']);
                return GestureDetector(
                  onTap: () {
                    // Toggle amenity in the selected set
                    setState(() {
                      if (isSelected) {
                        _selectedAmenities.remove(amenity['id']);
                      } else {
                        _selectedAmenities.add(amenity['id']);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF4A6741)
                          : const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF4A6741)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(amenity['icon'], color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          amenity['name'],
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),

            // SUBMIT BUTTON 
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // Disabled while submitting to prevent multiple API calls
                onPressed: _isSubmitting ? null : _createBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A6741),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isSubmitting ? 'Creating...' : 'Create Booking',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up controller when screen is destroyed
    _nameController.dispose();
    super.dispose();
  }
}
