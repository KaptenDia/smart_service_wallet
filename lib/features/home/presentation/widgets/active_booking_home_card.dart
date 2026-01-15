import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smart_service_wallet/features/services/data/models/booking_model.dart';
import 'package:smart_service_wallet/features/services/presentation/bloc/services_bloc.dart';

class ActiveBookingHomeCard extends StatelessWidget {
  final BookingModel booking;
  const ActiveBookingHomeCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    switch (booking.status) {
      case BookingStatus.inProgress:
        statusColor = const Color(0xFFF59E0B);
        statusText = 'In Progress';
        break;
      case BookingStatus.completed:
        statusColor = const Color(0xFF10B981);
        statusText = 'Completed';
        break;
      default:
        statusColor = const Color(0xFF6366F1);
        statusText = 'Confirmed';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(18),
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
                        fontSize: 16,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${DateFormat('jm').format(booking.dateTime)} • ${booking.location}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _showTracking(context, booking),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  backgroundColor: const Color(0xFF6366F1).withAlpha(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Track Service',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              if (booking.status == BookingStatus.completed) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => context.read<ServicesBloc>().add(
                    DismissBooking(booking.id),
                  ),
                  icon: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF10B981),
                  ),
                  tooltip: 'Finish',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showTracking(BuildContext context, BookingModel booking) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Service Status',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildStep(
              'Booking Confirmed',
              'Provider has accepted your request',
              true,
            ),
            _buildStep(
              'Provider on the Way',
              'Arriving in approximately 5 mins',
              booking.status != BookingStatus.confirmed,
            ),
            _buildStep(
              'Service Started',
              'Working on your ${booking.service.name}',
              booking.status == BookingStatus.inProgress ||
                  booking.status == BookingStatus.completed,
            ),
            _buildStep(
              'Service Completed',
              'We hope you enjoyed our service!',
              booking.status == BookingStatus.completed,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String title, String subtitle, bool isDone) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Icon(
            isDone
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: isDone ? Colors.green : Colors.grey.shade300,
            size: 24,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDone ? Colors.black87 : Colors.grey,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
