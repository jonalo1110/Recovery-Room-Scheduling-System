import 'package:flutter/material.dart';

class AmenityIcon extends StatelessWidget {
  final IconData icon;
  final double size;

  const AmenityIcon({super.key, required this.icon, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.white, size: size),
    );
  }
}