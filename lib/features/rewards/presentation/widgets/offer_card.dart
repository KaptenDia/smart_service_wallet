import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_service_wallet/features/rewards/data/models/offer_model.dart';
import 'package:smart_service_wallet/features/rewards/presentation/bloc/rewards_bloc.dart';

class OfferCard extends StatelessWidget {
  final OfferModel offer;
  const OfferCard({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            offer.imageUrl,
            height: 140,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  offer.description,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${offer.pointsRequired} GP Coins',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: offer.isClaimed
                          ? null
                          : () => context.read<RewardsBloc>().add(
                              ClaimOffer(offer.id),
                            ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(80, 36),
                      ),
                      child: Text(offer.isClaimed ? 'Claimed' : 'Claim'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
