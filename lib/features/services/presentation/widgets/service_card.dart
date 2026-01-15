import 'package:flutter/material.dart';
import 'package:smart_service_wallet/features/services/data/models/service_model.dart';
import 'package:smart_service_wallet/features/services/presentation/pages/booking_selection_page.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;

  const ServiceCard({super.key, required this.service});

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
