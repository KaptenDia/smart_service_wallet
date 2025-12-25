import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smart_service_wallet/features/services/data/models/service_model.dart';
import 'package:smart_service_wallet/features/services/data/models/booking_model.dart';
import 'package:smart_service_wallet/features/services/presentation/bloc/services_bloc.dart';
import 'booking_selection_page.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Services'), centerTitle: true),
      body: BlocConsumer<ServicesBloc, ServicesState>(
        listener: (context, state) {
          if (state is ServiceBookingSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ServicesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ServicesLoaded) {
            final activeOnes = state.activeBookings
                .where(
                  (b) =>
                      b.status == BookingStatus.confirmed ||
                      b.status == BookingStatus.inProgress,
                )
                .toList();

            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<ServicesBloc>().add(LoadServices()),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (activeOnes.isNotEmpty) ...[
                    const Text(
                      'Active Bookings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...activeOnes.map((b) => _ActiveBookingCard(booking: b)),
                    const SizedBox(height: 32),
                  ],
                  const _SectionHeader(title: 'Available Services'),
                  const SizedBox(height: 16),
                  ...state.services.map(
                    (service) => _ServiceCard(service: service),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Initialize services...'));
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

class _ActiveBookingCard extends StatelessWidget {
  final BookingModel booking;
  const _ActiveBookingCard({required this.booking});

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

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = service.status == ServiceStatus.available;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: isAvailable ? () => _navigateToBooking(context) : null,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        service.icon,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          Text(
                            service.availabilityInfo ?? 'Check availability',
                            style: TextStyle(
                              fontSize: 12,
                              color: isAvailable ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RM ${service.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'or ${service.tokenPrice} GP',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: isAvailable
                          ? () => _navigateToBooking(context)
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        backgroundColor: isAvailable
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade200,
                        foregroundColor: isAvailable
                            ? Colors.white
                            : Colors.grey.shade500,
                      ),
                      child: Text(isAvailable ? 'Book' : 'Busy'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToBooking(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BookingSelectionPage(service: service)),
    );
  }
}
