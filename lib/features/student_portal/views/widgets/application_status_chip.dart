/**
 * Student Numbers: [Student Number 1], [Student Number 2], [Student Number 3], [Student Number 4], [Student Number 5]
 * Student Names  : [Full Name 1], [Full Name 2], [Full Name 3], [Full Name 4], [Full Name 5]
 * Question: Application Status Chip Widget
 */
import 'package:flutter/material.dart';

class ApplicationStatusChip extends StatelessWidget {
  final String status;

  const ApplicationStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case 'approved':
        bgColor   = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        icon      = Icons.check_circle_outline;
        break;
      case 'rejected':
        bgColor   = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        icon      = Icons.cancel_outlined;
        break;
      default: // pending
        bgColor   = const Color(0xFFFFF8E1);
        textColor = const Color(0xFFE65100);
        icon      = Icons.hourglass_empty;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 4),
          Text(
            status[0].toUpperCase() + status.substring(1),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
