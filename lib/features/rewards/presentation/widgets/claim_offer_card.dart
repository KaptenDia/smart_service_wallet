import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smart_service_wallet/features/rewards/data/models/offer_model.dart';
import 'package:smart_service_wallet/features/rewards/presentation/pages/claimed_reward_detail_page.dart';

class ClaimedOfferCard extends StatefulWidget {
  final OfferModel offer;
  const ClaimedOfferCard({super.key, required this.offer});

  @override
  State<ClaimedOfferCard> createState() => ClaimedOfferCardState();
}

class ClaimedOfferCardState extends State<ClaimedOfferCard> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _calculateRemaining());
    });
  }

  void _calculateRemaining() {
    if (widget.offer.expiry != null) {
      _remaining = widget.offer.expiry!.difference(DateTime.now());
      if (_remaining.isNegative) _remaining = Duration.zero;
    } else {
      _remaining = Duration.zero;
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remaining.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = _remaining.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withAlpha(128),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.qr_code_2,
            size: 40,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.offer.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Expires in ${minutes}m ${seconds}s',
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ClaimedRewardDetailPage(offer: widget.offer),
              ),
            ),
            child: const Text('Use'),
          ),
        ],
      ),
    );
  }
}
