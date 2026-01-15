import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_service_wallet/features/services/data/models/booking_model.dart';
import 'package:smart_service_wallet/features/services/presentation/bloc/services_bloc.dart';
import 'package:smart_service_wallet/features/services/presentation/widgets/active_booking_card.dart';
import 'package:smart_service_wallet/features/services/presentation/widgets/service_card.dart';

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
                    ...activeOnes.map((b) => ActiveBookingCard(booking: b)),
                    const SizedBox(height: 32),
                  ],
                  const _SectionHeader(title: 'Available Services'),
                  const SizedBox(height: 16),
                  ...state.services.map(
                    (service) => ServiceCard(service: service),
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
