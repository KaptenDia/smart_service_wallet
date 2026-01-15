import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_service_wallet/features/rewards/data/models/offer_model.dart';
import 'package:smart_service_wallet/features/rewards/presentation/bloc/rewards_bloc.dart';
import 'package:smart_service_wallet/features/rewards/presentation/widgets/claim_offer_card.dart';
import 'package:smart_service_wallet/features/rewards/presentation/widgets/empty_voucher_list.dart';
import 'package:smart_service_wallet/features/rewards/presentation/widgets/offer_card.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rewards')),
      body: BlocBuilder<RewardsBloc, RewardsState>(
        builder: (context, state) {
          if (state is RewardsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RewardsLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Section(
                    title: 'Featured Campaigns',
                    offers: state.offers
                        .where((o) => o.id.startsWith('c'))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  _Section(
                    title: 'Exclusive Events',
                    offers: state.offers
                        .where((o) => o.id.startsWith('e'))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  _Section(
                    title: 'Special Promotions',
                    offers: state.offers
                        .where((o) => o.id.startsWith('r'))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  _Section(
                    title: 'Loyalty Rewards',
                    offers: state.offers
                        .where((o) => o.id.startsWith('l'))
                        .toList(),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'My Vouchers',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (state.claimedOffers.isEmpty)
                    const EmptyVoucherList()
                  else
                    ...state.claimedOffers.map(
                      (offer) => ClaimedOfferCard(offer: offer),
                    ),
                ],
              ),
            );
          }
          return const Center(child: Text('Initialize rewards...'));
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<OfferModel> offers;

  const _Section({required this.title, required this.offers});

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...offers.map((offer) => OfferCard(offer: offer)),
      ],
    );
  }
}
