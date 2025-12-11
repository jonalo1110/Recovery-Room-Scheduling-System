import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


import '../config/api_config.dart';
import '../models/booking.dart';
import 'today_screen.dart';
import 'upcoming_screen.dart';
import 'create_booking_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Tracks which tab the user is viewing (Home or Upcoming)
  int _selectedIndex = 0;

  // Holds all bookings shown in Today + Upcoming screens
  List<Booking> _allBookings = [];
  // Simple loading flag (could be used to show a spinner later)
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // When the app opens, load bookings from the backend
    _fetchBookings();
  }

  // Fetch bookings from your Express API: GET /api/bookings
  // Parses JSON, Booking objects using Booking.fromJson
  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/bookings');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        final bookings = data
            .map((json) => Booking.fromJson(json as Map<String, dynamic>))
            .toList();

        setState(() {
          _allBookings = bookings;
          _isLoading = false;
        });
      } else {
        // Non-200 response from server
        setState(() {
          _isLoading = false;
        });
        //show an error SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load bookings: ${response.statusCode}'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } catch (e) {
      // Network or parsing error
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading bookings: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  // Opens the CreateBookingScreen and waits for a result.
  // This is the ONLY place the create screen is opened.
  Future<void> _navigateToCreateBooking() async {
    // Push the CreateBookingScreen and wait for a boolean result.
    // true, booking created successfully
    // false / null, user backed out or failed
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const CreateBookingScreen()),
    );

    if (!mounted) return;

    // If the booking was created, show a confirmation.
    if (created == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking created successfully!')),
      );
    // reload fresh data from the API
      await _fetchBookings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps both screens alive (so switching tabs is instant)
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          TodayScreen(bookings: _allBookings), // Shows today's bookings
          UpcomingScreen(bookings: _allBookings), // Shows future bookings
        ],
      ),

      // Floating "+" button that opens the create booking screen
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateBooking, // Navigation triggered here
        backgroundColor: const Color(0xFFBBBBBB),
        child: const Icon(Icons.add, color: Colors.black, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // Bottom navigation bar for switching between Today & Upcoming screens
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          // Updates which tab is shown
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 28),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time, size: 28),
            label: 'Upcoming',
          ),
        ],
      ),
    );
  }
}
