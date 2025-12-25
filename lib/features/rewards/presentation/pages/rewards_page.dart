import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_service_wallet/features/rewards/data/models/offer_model.dart';
import 'package:smart_service_wallet/features/rewards/presentation/bloc/rewards_bloc.dart';
import 'package:smart_service_wallet/features/rewards/presentation/pages/claimed_reward_detail_page.dart';

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
                    _EmptyVoucherList()
                  else
                    ...state.claimedOffers.map(
                      (offer) => _ClaimedOfferCard(offer: offer),
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

class _OfferCard extends StatelessWidget {
  final OfferModel offer;
  const _OfferCard({required this.offer});

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

class _ClaimedOfferCard extends StatefulWidget {
  final OfferModel offer;
  const _ClaimedOfferCard({required this.offer});

  @override
  State<_ClaimedOfferCard> createState() => _ClaimedOfferCardState();
}

class _ClaimedOfferCardState extends State<_ClaimedOfferCard> {
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
        ...offers.map((offer) => _OfferCard(offer: offer)),
      ],
    );
  }
}

class _EmptyVoucherList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.confirmation_num_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Vouchers Yet',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Claim rewards above to see them here',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
