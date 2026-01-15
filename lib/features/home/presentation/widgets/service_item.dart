import 'package:flutter/material.dart';
import 'package:smart_service_wallet/features/services/data/models/service_model.dart';

class ServiceItem extends StatelessWidget {
  final ServiceModel service;
  final Color color;
  final VoidCallback onTap;

  const ServiceItem({
    super.key,
    required this.service,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(service.icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          service.name.split(' ').first,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        Text(
          'RM ${service.price}',
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (service.availabilityInfo != null)
          Text(
            service.availabilityInfo!,
            style: const TextStyle(fontSize: 8, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}
