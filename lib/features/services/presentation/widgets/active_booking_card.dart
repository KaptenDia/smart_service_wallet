import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_service_wallet/features/services/data/models/booking_model.dart';

class ActiveBookingCard extends StatelessWidget {
  final BookingModel booking;
  const ActiveBookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    switch (booking.status) {
      case BookingStatus.confirmed:
        statusColor = Colors.blue;
        statusText = 'Confirmed';
        break;
      case BookingStatus.inProgress:
        statusColor = Colors.orange;
        statusText = 'In Progress';
        break;
      case BookingStatus.completed:
        statusColor = Colors.green;
        statusText = 'Completed';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Pending';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withAlpha(50)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(booking.service.icon, color: statusColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.service.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${DateFormat('MMM dd').format(booking.dateTime)} at ${DateFormat('jm').format(booking.dateTime)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                booking.location,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Spacer(),
              if (booking.status == BookingStatus.inProgress)
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.orange,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
